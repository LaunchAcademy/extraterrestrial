module ET
  class Exercise < Lesson
    def run_tests
      system("rspec", "--color", "--fail-fast", spec_file)
    end

    def exists?
      !dir.nil? && config["type"] == "exercise"
    end

    def spec_file
      File.join(dir, "test", "#{slug.gsub("-", "_")}_test.rb")
    end
  end
end
