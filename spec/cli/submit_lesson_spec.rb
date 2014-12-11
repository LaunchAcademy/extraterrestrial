describe "submit lesson" do
  let(:sample_archive_path) do
    project_root.join("spec/data/archive.tar.gz")
  end

  context "when in a working area" do
    it "packages and uploads a challenge directory" do
      Dir.mktmpdir("test") do |tmpdir|
        write_sample_config_to(tmpdir)
        challenge_dir = add_sample_challenge(tmpdir)

        expect_any_instance_of(ET::API).to receive(:submit_lesson).
          and_return(true)

        runner = ET::Runner.new(challenge_dir)
         _, _ = capture_output do
          expect(runner.go(["submit"])).to eq(0)
        end
      end
    end

    it "packages and uploads an exercise directory" do
      Dir.mktmpdir("test") do |tmpdir|
        write_sample_config_to(tmpdir)
        exercise_dir = add_sample_exercise(tmpdir)

        expect_any_instance_of(ET::API).to receive(:submit_lesson).
          and_return(true)

        runner = ET::Runner.new(exercise_dir)
         _, _ = capture_output do
          expect(runner.go(["submit"])).to eq(0)
        end
      end
    end
  end
end
