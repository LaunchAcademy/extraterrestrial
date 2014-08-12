require "yaml"

module SampleFiles
  def write_sample_config_to(dir, additional_settings = nil)
    config = {
      "username" => "bob",
      "token" => "1234",
      "host" => "http://localhost:3000"
    }

    if additional_settings
      config = config.merge(additional_settings)
    end

    path = File.join(dir, ".et")
    File.write(path, config.to_yaml)
  end

  def write_sample_challenge_to(working_dir, slug)
    challenge_dir = File.join(working_dir, slug)
    system("mkdir #{challenge_dir}")

    readme_path = File.join(challenge_dir, "README.md")
    File.write(readme_path, "# README")

    challenge_dir
  end
end
