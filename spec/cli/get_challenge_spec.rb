describe "get challenge" do
  let(:challenge_info) do
    {
      title: "Some Challenge",
      slug: "some-challenge",
      archive_url: "http://localhost:3000/some-challenge.tar.gz"
    }
  end

  let(:sample_archive_path) do
    project_root.join("spec/data/some-challenge.tar.gz")
  end

  context "when in a working area" do
    it "downloads and extracts the challenge" do
      tmp_archive_path = File.join(Dir.tmpdir, "some-challenge.tar.gz")
      system("cp #{sample_archive_path} #{tmp_archive_path}")

      expect_any_instance_of(ET::API).to receive(:get_challenge).
        with("some-challenge").
        and_return(challenge_info)

      expect_any_instance_of(ET::API).to receive(:download_file).
        with("http://localhost:3000/some-challenge.tar.gz").
        and_return(tmp_archive_path)

      Dir.mktmpdir("test") do |tmpdir|
        write_sample_config_to(tmpdir)

        runner = ET::Runner.new(tmpdir)
         _, _ = capture_output do
          expect(runner.go(["get", "some-challenge"])).to eq(0)
        end

        ["some-challenge/README.md", "some-challenge/sample.rb"].each do |filename|
          path = File.join(tmpdir, filename)
          expect(File.exist?(path)).to eq(true)
        end
      end
    end
  end
end
