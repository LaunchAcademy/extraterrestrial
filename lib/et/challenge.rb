require "securerandom"

module ET
  class Challenge
    attr_reader :cwd

    def initialize(cwd)
      @cwd = cwd
    end

    def archive!
      if exists?
        filepath = random_archive_path

        cmd = "tar zcf #{filepath} -C #{dir} . --exclude='.challenge'"

        ignored_files.each do |file|
          cmd += " --exclude='#{file}'"
        end

        if system(cmd)
          filepath
        else
          nil
        end
      else
        nil
      end
    end

    def dir
      @dir ||= find_challenge_dir(cwd)
    end

    def slug
      File.basename(dir)
    end

    def exists?
      !dir.nil?
    end

    def ignored_files
      config["ignore"] || []
    end

    private

    def config
      @config ||= YAML.load(File.read(File.join(dir, ".challenge")))
    end

    def random_archive_path
      File.join(Dir.mktmpdir, "#{SecureRandom.hex}.tar.gz")
    end

    def find_challenge_dir(current_dir)
      path = File.join(current_dir, ".challenge")

      if File.exists?(path)
        current_dir
      elsif current_dir == "/" || current_dir == "."
        nil
      else
        find_challenge_dir(File.dirname(current_dir))
      end
    end
  end
end
