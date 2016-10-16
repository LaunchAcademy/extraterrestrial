require "faraday"
require "faraday_middleware"

module ET
  class FallbackConnection
    def initialize(opts = {}, &block)
      @connection = Faraday.new(opts, &block)

      @fallback_connection = Faraday.new(opts.merge(:ssl => {:verify => false}))
    end

    def with_ssl_fallback(&block)
      begin
        block.call(@connection)
      rescue OpenSSL::SSL::SSLError => e
        if operating_system.platform_family?(:windows)
          block.call(@fallback_connection)
        else
          raise e
        end
      end
    end

    private
    def operating_system
      @os ||= ET::OperatingSystem.new
    end
  end
end
