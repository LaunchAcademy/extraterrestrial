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
      options["host"]
    end

    private

    def options
      @options ||= YAML.load(File.read(path))
    end

    def find_config_file(dir)
      config_path = File.join(dir, ".et")

      if File.exists?(config_path)
        config_path
      elsif dir == "/" || dir == "."
        nil
      else
        find_config_file(File.dirname(dir))
      end
    end
  end
end
