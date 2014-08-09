describe "get challenge" do
  let(:runner) { ET::Runner.new }

  let(:challenge_info) do
    {
      title: "Blackjack",
      slug: "blackjack",
      archive_url: "http://localhost:3000/some-archive.tar.gz"
    }
  end

  let(:sample_archive_path) do
    project_root.join("spec/data/archive.tar.gz")
  end

  context "when in a working area" do
    it "downloads and extracts the challenge" do
      tmp_archive_path = File.join(Dir.tmpdir, "archive.tar.gz")
      system("cp #{sample_archive_path} #{tmp_archive_path}")

      expect_any_instance_of(ET::API).to receive(:get_challenge).
        with("blackjack").
        and_return(challenge_info)

      expect_any_instance_of(ET::API).to receive(:download_file).
        with("http://localhost:3000/some-archive.tar.gz").
        and_return(tmp_archive_path)

      Dir.mktmpdir("test") do |tmpdir|
        write_sample_config_to(tmpdir)

         _, _ = capture_output do
          expect(runner.go(["get", "blackjack"], tmpdir)).to eq(0)
        end

        ["blackjack/README.md", "blackjack/sample.rb"].each do |filename|
          path = File.join(tmpdir, filename)
          expect(File.exist?(path)).to eq(true)
        end
      end
    end
  end
end
