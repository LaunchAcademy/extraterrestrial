module ET
  class Exercise
    attr_reader :dir

    def initialize(dir)
      @dir = dir
    end

    def run_tests
    end

    def exists?
      !path.nil?
    end

    def path
      @path ||= find_exercise_dir(dir)
    end

    private

    def find_exercise_dir(current_dir)
      path = File.join(current_dir, ".lesson.yml")

      if File.exists?(path) && exercise_lesson?(path)
        current_dir
      elsif current_dir == "." || Pathname.new(current_dir).root?
        nil
      else
        find_exercise_dir(File.dirname(current_dir))
      end
    end

    def exercise_lesson?(config_path)
      YAML.load_file(config_path)["type"] == "exercise"
    end
  end
end
