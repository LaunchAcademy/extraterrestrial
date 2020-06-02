require "spec_helper"

describe ET::Lesson do
  context "archive! method" do
    it "creates a tar.gz file" do
      path = Dir.mktmpdir
      filename = 'fab'

      FileUtils.rm_rf(File.join(path, filename))
      FileUtils.mkdir_p(path)

      allow(Dir).to receive(:mktmpdir).and_return(path)
      allow(SecureRandom).to receive(:hex).and_return(filename)

      exercise_path = File.expand_path(
        File.join(File.dirname(__FILE__), '../data/sample-exercise'))
      lesson = ET::Lesson.new(exercise_path)
      resulting_file = lesson.archive!

      expect(resulting_file).to_not be_nil
      expect(FileTest).to exist(resulting_file)
    end
  end
end
