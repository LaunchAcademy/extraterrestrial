require "yaml"

describe ET::Challenge do
  describe "#dir" do
    it "selects the directory containing the challenge file" do
      Dir.mktmpdir do |tmpdir|
        challenge_dir = add_sample_challenge(tmpdir)

        challenge = ET::Challenge.new(challenge_dir)
        expect(challenge.dir).to eq(challenge_dir)
      end
    end

    it "checks parent directories for the challenge file", focus: true do
      Dir.mktmpdir do |tmpdir|
        challenge_dir = add_sample_challenge(tmpdir)

        child_dir = File.join(challenge_dir, "child")
        Dir.mkdir(child_dir)

        challenge = ET::Challenge.new(child_dir)
        expect(challenge.dir).to eq(challenge_dir)
      end
    end

    it "returns nil if no challenge file found" do
      Dir.mktmpdir do |tmpdir|
        challenge = ET::Challenge.new(tmpdir)
        expect(challenge.dir).to eq(nil)
      end
    end
  end

  describe "#archive" do
    it "packages up files in the given directory" do
      archive_path = nil

      begin
        Dir.mktmpdir do |tmpdir|
          challenge_dir = add_sample_challenge(tmpdir)

          challenge = ET::Challenge.new(challenge_dir)
          archive_path = challenge.archive!

          contents = read_file_from_gzipped_archive(archive_path, "./problem.rb")
          expect(contents).to eq("# YOUR CODE GOES HERE\n")
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
        Dir.mktmpdir do |tmpdir|
          challenge_dir = add_sample_challenge(tmpdir)

          challenge = ET::Challenge.new(challenge_dir)
          archive_path = challenge.archive!

          files = list_files_in_gzipped_archive(archive_path)

          expect(files).to include("./problem.rb")
          expect(files).to_not include("./sample-challenge.md")
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
