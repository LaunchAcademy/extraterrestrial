describe "list lessons" do
  let(:sample_lessons_file) { project_root.join("spec/data/lessons.json") }

  let(:sample_lessons) do
    JSON.parse(File.read(sample_lessons_file), symbolize_names: true)[:lessons]
  end

  it "prints the titles and slug" do
    expect_any_instance_of(ET::API).to receive(:list_lessons).
      and_return(sample_lessons)

    Dir.mktmpdir("test") do |tmpdir|
      write_sample_config_to(tmpdir)

      runner = ET::Runner.new(tmpdir)
      stdout, _ = capture_output do
        expect(runner.go(["list"])).to eq(0)
      end

      expect(stdout).to include("Max Number")
      expect(stdout).to include("max-number")
      expect(stdout).to include("exercise")

      expect(stdout).to include("Optimal Guesser")
      expect(stdout).to include("optimal-guesser")
      expect(stdout).to include("challenge")
    end
  end
end
