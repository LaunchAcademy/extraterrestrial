module ET
  class Exercise < Lesson
    def run_tests
    end

    def exists?
      !dir.nil? && config["type"] == "exercise"
    end
  end
end
