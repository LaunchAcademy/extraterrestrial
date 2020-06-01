require "rake/file_list"

module ET
  class SubmissionFileList
    include Enumerable
    DEFAULT_IGNORE_GLOBS = [
      '.etignore',
      'node_modules/'
    ]

    def initialize(path)
      @path = path
    end

    def files
      unless @files
        @files = Rake::FileList[File.join(@path, "**/*"), File.join(@path, ".etignore")]
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
      etignore_globs + [] + DEFAULT_IGNORE_GLOBS
    end

    def etignore_globs
      unless @etignore_globs
        etignore = File.join(@path, '.etignore')
        if FileTest.exists?(etignore)
          @etignore_globs = File.read(etignore).split(/\n/)
          @etignore_globs.delete_if { | string | string.start_with?("#") || string.empty?}
        else
          @etignore_globs = []
        end
      end
      @etignore_globs
    end
  end
end
