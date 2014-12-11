describe ET::Exercise do
  describe "#exists?" do
    it "is true if within an exercise directory" do
      Dir.mktmpdir do |tmpdir|
        exercise_dir = add_sample_exercise(tmpdir)
        exercise = ET::Exercise.new(exercise_dir)

        expect(exercise.exists?).to eq(true)
      end
    end

    it "is false when in a challenge directory" do
      Dir.mktmpdir do |tmpdir|
        challenge_dir = add_sample_challenge(tmpdir)
        exercise = ET::Exercise.new(challenge_dir)

        expect(exercise.exists?).to eq(false)
      end
    end

    it "is false when not in a lesson dir" do
      Dir.mktmpdir do |tmpdir|
        exercise = ET::Exercise.new(tmpdir)
        expect(exercise.exists?).to eq(false)
      end
    end
  end
end
