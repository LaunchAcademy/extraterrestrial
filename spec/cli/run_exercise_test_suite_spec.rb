describe "run exercise test suite" do
  context "when in an exercise directory" do
    it "runs the test suite" do
      Dir.mktmpdir("test") do |tmpdir|
        write_sample_config_to(tmpdir)
        exercise_dir = add_sample_exercise(tmpdir)

        expect_any_instance_of(ET::Exercise).to receive(:run_tests).and_return(true)

        runner = ET::Runner.new(exercise_dir)
        _, _ = capture_output do
          expect(runner.go(["test"])).to eq(0)
        end
      end
    end
  end

  context "when not in an exercise directory" do
    it "fails to run the test suite" do
      Dir.mktmpdir("test") do |tmpdir|
        write_sample_config_to(tmpdir)
        expect_any_instance_of(ET::Exercise).to_not receive(:run_tests)

        runner = ET::Runner.new(tmpdir)
        _, _ = capture_output do
          expect(runner.go(["test"])).to eq(1)
        end
      end
    end
  end
end
