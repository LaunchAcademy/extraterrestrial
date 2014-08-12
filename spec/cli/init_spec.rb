require "json"

describe "init" do
  it "writes the user credentials to a config file" do
    Dir.mktmpdir("test") do |tmpdir|
      arguments = [
        "init",
        "-u", "barry",
        "-t", "foobar",
        "-h", "http://localhost:3000"
      ]

      runner = ET::Runner.new(tmpdir)
      _, _ = capture_output do
        expect(runner.go(arguments)).to eq(0)
      end

      filepath = File.join(tmpdir, ".et")
      expect(File.exist?(filepath)).to eq(true)

      config = YAML.load(File.read(filepath))
      expect(config["username"]).to eq("barry")
      expect(config["token"]).to eq("foobar")
      expect(config["host"]).to eq("http://localhost:3000")
    end
  end
end
