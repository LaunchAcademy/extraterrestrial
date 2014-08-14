describe ET::Config do
  describe "#path" do
    it "finds the config file in the given directory" do
      Dir.mktmpdir("test") do |tmpdir|
        write_sample_config_to(tmpdir)

        config = ET::Config.new(tmpdir)
        expect(config.path).to eq(File.join(tmpdir, ".et"))
      end
    end

    it "finds the config file in parent directories" do
      Dir.mktmpdir("test") do |parent_dir|
        nested_dir = File.join(parent_dir, "nested")
        Dir.mkdir(nested_dir)

        write_sample_config_to(parent_dir)

        config = ET::Config.new(nested_dir)
        expect(config.path).to eq(File.join(parent_dir, ".et"))
      end
    end

    it "returns nil if no config file present" do
      config = ET::Config.new(Dir.tmpdir)
      expect(config.path).to eq(nil)
    end
  end

  describe "#host" do
    it "reads the host from the config" do
      Dir.mktmpdir("test") do |tmpdir|
        write_sample_config_to(tmpdir, "host" => "http://example.com")

        config = ET::Config.new(tmpdir)
        expect(config.host).to eq("http://example.com")
      end
    end

    it "preprends http if scheme not provided" do
      Dir.mktmpdir("test") do |tmpdir|
        write_sample_config_to(tmpdir, "host" => "example.com")

        config = ET::Config.new(tmpdir)
        expect(config.host).to eq("http://example.com")
      end
    end
  end
end
