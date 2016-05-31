describe ET::ArchiveManager do
  let!(:archive) { File.join(File.dirname(__FILE__), "..", "data", "some-challenge.tar.gz") }
  let!(:destination) { Dir.mktmpdir }
  let!(:lesson_extractor) { ET::ArchiveManager.new(archive, destination) }

  describe "#new" do
    it "takes an archive and destination" do
      expect(lesson_extractor).to be_a(ET::ArchiveManager)
    end
  end

  describe "#unpack" do
    it "extracts files from the archive" do
      lesson_extractor.unpack
      extracted_files =  Dir.entries(File.join(destination, "some-challenge"))
      expect(extracted_files).to include("README.md")
      expect(extracted_files).to include("sample.rb")
    end

    it "returns an array of extracted filenames" do
      result = lesson_extractor.unpack
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first).to match /sample.rb/
    end
  end
end
