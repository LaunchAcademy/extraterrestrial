describe "submit challenge" do
  let(:runner) { ET::Runner.new }

  let(:sample_archive_path) do
    project_root.join("spec/data/archive.tar.gz")
  end

  context "when in a working area" do
    it "packages and uploads directory" do
      Dir.mktmpdir("test") do |tmpdir|
        write_sample_config_to(tmpdir)
        challenge_dir = write_sample_challenge_to(tmpdir, "some-challenge")

        expect_any_instance_of(ET::API).to receive(:submit_challenge).
          with(challenge_dir).
          and_return(true)

         _, _ = capture_output do
          expect(runner.go(["submit"], challenge_dir)).to eq(0)
        end
      end
    end
  end
end
