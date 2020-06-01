require "pathname"
require "securerandom"
require "rubygems/package"

module ET
  class Lesson
    attr_reader :cwd

    def initialize(cwd)
      @cwd = cwd
    end

    def archive!
      if exists?
        filepath = random_archive_path

        File.open(filepath, "wb") do |file|
          Zlib::GzipWriter.wrap(file) do |gz|
            Gem::Package::TarWriter.new(gz) do |tar|
              ET::SubmissionFileList.new(dir).each do |file|
                relative_path = file
                absolute_path = File.join(dir, file)

                if FileTest.directory?(absolute_path)
                  tar.mkdir(relative_path, 0755)
                else
                  file_contents = File.read(absolute_path)
                  tar.add_file_simple("./" + relative_path, 0555, file_contents.bytesize) do |io|
                    io.write(file_contents)
                  end
                end
              end
            end
          end
        end
        filepath
      else
        nil
      end
    end

    def dir
      @dir ||= find_lesson_dir(cwd)
    end

    def slug
      File.basename(dir)
    end

    def exists?
      !dir.nil?
    end

    protected

    def config
      @config ||= YAML.load_file(File.join(dir, ".lesson.yml"))
    end

    def random_archive_path
      File.join(Dir.mktmpdir, "#{SecureRandom.hex}.tar.gz")
    end

    def find_lesson_dir(current_dir)
      path = File.join(current_dir, ".etignore")

      if File.exists?(path)
        current_dir
      elsif current_dir == "." || Pathname.new(current_dir).root?
        nil
      else
        find_lesson_dir(File.dirname(current_dir))
      end
    end
  end
end
