require "rake/file_list"

module ET
  class SubmissionFileList
    include Enumerable

    def initialize(path)
      @path = path
    end

    def files
      unless @files
        @files = Rake::FileList[File.join(@path, "**/*")].
          sub(File.join(@path, "/"), "").
          exclude(ignore_globs)
      end

      @files
    end

    def each(&block)
      files.each do |file|
        block.call(file)
      end
    end


    protected
    def ignore_globs
      lesson_ignore_globs + [".lesson.yml"]
    end

    def lesson_ignore_globs
      unless @lesson_ignore_globs
        lesson_yml = File.join(@path, ".lesson.yml")
        if FileTest.exists?(lesson_yml)
          @lesson_ignore_globs = YAML.load_file(lesson_yml)['ignore'] || []
        else
          @lesson_ignore_globs = []
        end
      end
      @lesson_ignore_globs
    end
  end
end
