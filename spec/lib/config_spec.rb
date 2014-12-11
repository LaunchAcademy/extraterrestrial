require "yaml"

describe ET::Config do
  describe "#save" do
    let(:options) do
      {
        "username" => "foobar",
        "token" => "supersecret",
        "host" => "http://example.com"
      }
    end

    it "writes a new config file if doesn't exist" do
      Dir.mktmpdir("test") do |tmpdir|
        config = ET::Config.new(tmpdir)
        config.save!(options)

        config_file = File.join(tmpdir, ".et")
        expect(File.exists?(config_file)).to eq(true)

        saved_options = YAML.load_file(config_file)

        options.each do |key, value|
          expect(saved_options[key]).to eq(value)
        end
      end
    end

    it "updates an existing config file with new options" do
      Dir.mktmpdir("test") do |parent_dir|
        nested_dir = File.join(parent_dir, "nested")
        Dir.mkdir(nested_dir)

        write_sample_config_to(parent_dir)

        config = ET::Config.new(nested_dir)
        config.save!(options)

        expect(File.exists?(File.join(nested_dir, ".et"))).to eq(false)

        saved_options = YAML.load_file(File.join(parent_dir, ".et"))
        options.each do |key, value|
          expect(saved_options[key]).to eq(value)
        end
      end
    end
  end

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

    it "prepends http if scheme not provided" do
      Dir.mktmpdir("test") do |tmpdir|
        write_sample_config_to(tmpdir, "host" => "example.com")

        config = ET::Config.new(tmpdir)
        expect(config.host).to eq("http://example.com")
      end
    end
  end
end
