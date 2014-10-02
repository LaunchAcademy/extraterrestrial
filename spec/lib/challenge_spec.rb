require "yaml"

describe ET::Challenge do
  let(:challenge_info) do
    {
      "title" => "Guess the Number",
      "ignore" => ["README.md"]
    }
  end

  describe "#dir" do
    it "selects the directory containing the challenge file" do
      Dir.mktmpdir do |challenge_dir|
        challenge_path = File.join(challenge_dir, ".lesson.yml")
        File.write(challenge_path, challenge_info.to_yaml)

        challenge = ET::Challenge.new(challenge_dir)
        expect(challenge.dir).to eq(challenge_dir)
      end
    end

    it "checks parent directories for the challenge file" do
      Dir.mktmpdir do |parent_dir|
        challenge_path = File.join(parent_dir, ".lesson.yml")
        File.write(challenge_path, challenge_info.to_yaml)

        child_dir = File.join(parent_dir, "foobar")

        challenge = ET::Challenge.new(child_dir)
        expect(challenge.dir).to eq(parent_dir)
      end
    end

    it "returns nil if no challenge file found" do
      challenge = ET::Challenge.new(Dir.tmpdir)
      expect(challenge.dir).to eq(nil)
    end
  end

  describe "#archive" do
    it "packages up files in the given directory" do
      archive_path = nil

      begin
        Dir.mktmpdir do |challenge_dir|
          challenge_path = File.join(challenge_dir, ".lesson.yml")
          File.write(challenge_path, challenge_info.to_yaml)

          file_path = File.join(challenge_dir, "file.rb")
          File.write(file_path, "2 + 2 == 5")

          challenge = ET::Challenge.new(challenge_dir)
          archive_path = challenge.archive!

          contents = read_file_from_gzipped_archive(archive_path, "./file.rb")
          expect(contents).to eq("2 + 2 == 5")
        end
      ensure
        if archive_path && File.exist?(archive_path)
          FileUtils.rm(archive_path)
        end
      end
    end

    it "excludes files in the ignore array" do
      archive_path = nil

      begin
        Dir.mktmpdir do |dir|
          File.write(File.join(dir, ".lesson.yml"), challenge_info.to_yaml)
          File.write(File.join(dir, "file.rb"), "2 + 2 == 5")
          File.write(File.join(dir, "README.md"), "Ignore me!")

          challenge = ET::Challenge.new(dir)
          archive_path = challenge.archive!

          files = list_files_in_gzipped_archive(archive_path)

          expect(files).to include("./file.rb")
          expect(files).to_not include("./README.md")
          expect(files).to_not include("./.lesson.yml")
        end
      ensure
        if archive_path && File.exist?(archive_path)
          FileUtils.rm(archive_path)
        end
      end
    end
  end
end
