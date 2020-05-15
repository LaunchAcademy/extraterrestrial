require "rake/file_list"

module ET
  class SubmissionFileList
    include Enumerable
    DEFAULT_IGNORE_GLOBS = [
      '.lesson.yml',
      'node_modules/'
    ]

    def initialize(path)
      @path = path
    end

    def files
      unless @files
        @files = Rake::FileList[File.join(@path, "**/*"), File.join(@path, ".gitignore") ]
        ignore_globs.each do |glob|
          filename = File.join(@path, glob)

          if File.directory?(filename)
            filename += glob.end_with?("/") ? "**/*" : "/**/*"
          end

          @files = @files.exclude(filename)
        end
        @files = @files.sub(File.join(@path, "/"), "")
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
      gitignore_globs + [] + DEFAULT_IGNORE_GLOBS
    end

    def gitignore_globs
      unless @gitignore_globs
        gitignore = File.join(@path, '.gitignore')
        if FileTest.exists?(gitignore)
          @gitignore_globs = File.read(gitignore).split(/\n/)
          @gitignore_globs.delete_if { | string | string.start_with?("#") || string.empty?}
        else
          @gitignore_globs = []
        end
      end
      @gitignore_globs
    end
  end
end
