require "faraday"
require "faraday_middleware"

module ET
  class FallbackConnection
    def initialize(opts = {}, &block)
      @connection = Faraday.new(opts, &block)

      @fallback_connection = Faraday.new(opts.merge(:ssl => {:verify => false}))
    end

    def open(&block)
      begin
        block.call(@connection)
      rescue Faraday::SSLError => e
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
