require "yaml"
require "pathname"

module ET
  class Config
    attr_reader :current_dir

    def initialize(current_dir)
      @current_dir = current_dir
    end

    def path
      @path ||= find_config_file(current_dir)
    end

    def host
      if options["host"].start_with?("http")
        options["host"]
      else
        "http://" + options["host"]
      end
    end

    def username
      options["username"]
    end

    def token
      options["token"]
    end

    def exists?
      !path.nil?
    end

    def [](key)
      options[key]
    end

    def save!(options)
      if exists?
        File.write(path, options.to_yaml)
      else
        File.write(File.join(current_dir, ".et"), options.to_yaml)
      end
    end

    private

    def options
      @options ||= YAML.load(File.read(path))
    end

    def find_config_file(dir)
      config_path = File.join(dir, ".et")

      if File.exists?(config_path)
        config_path
      elsif dir == "." || Pathname.new(dir).root?
        nil
      else
        find_config_file(File.dirname(dir))
      end
    end
  end
end
