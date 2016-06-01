require "spec_helper"

describe ET::Lesson do
  context "archive! method" do
    it "creates a tar.gz file" do
      path = '/tmp/et'
      filename = 'fab'

      FileUtils.rm_rf(File.join(path, filename))
      FileUtils.mkdir_p(path)

      allow(Dir).to receive(:mktmpdir).and_return(path)
      allow(SecureRandom).to receive(:hex).and_return(filename)

      lesson = ET::Lesson.new(File.join(File.dirname(__FILE__), '../data/sample-challenge'))
      resulting_file = lesson.archive!

      expect(resulting_file).to_not be_nil
      expect(FileTest).to exist(resulting_file)
    end
  end
end
