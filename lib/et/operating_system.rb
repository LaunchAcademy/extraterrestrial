require 'rbconfig'

module ET
  class OperatingSystem
    attr_reader :raw_name, :version

    def initialize(os = nil, version = nil)
      @raw_name, @version = os, version
      if @raw_name.nil?
        derive_raw_name
      end
    end

    #cribbed from Selenium
    def name
      case @raw_name
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        :windows
      when /darwin|mac os/
        :mac
      when /linux/
        :linux
      when /solaris|bsd/
        :unix
      end
    end

    def platform_family?(platform)
      name == platform.to_sym
    end

    protected
    def derive_raw_name
      @raw_name = RbConfig::CONFIG['host_os']
    end
  end
end
