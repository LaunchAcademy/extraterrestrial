describe "list challenges" do
  let(:sample_challenges) do
    JSON.parse(File.read("spec/data/challenges.json"), symbolize_names: true)[:lessons]
  end

  it "prints the titles and slug" do
    expect_any_instance_of(ET::API).to receive(:list_challenges).
      and_return(sample_challenges)

    Dir.mktmpdir("test") do |tmpdir|
      write_sample_config_to(tmpdir)

      runner = ET::Runner.new(tmpdir)
      stdout, _ = capture_output do
        expect(runner.go(["list"])).to eq(0)
      end

      expect(stdout).to include("Guess the Number")
      expect(stdout).to include("guess-the-number")

      expect(stdout).to include("Auto-Guesser")
      expect(stdout).to include("auto-guesser")
    end
  end
end
