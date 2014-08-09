require "yaml"

module SampleConfig
  def write_sample_config_to(dir)
    config = {
      "username" => "bob",
      "token" => "1234",
      "host" => "http://localhost:3000"
    }

    path = File.join(dir, ".et")
    File.write(path, config.to_yaml)
  end
end
