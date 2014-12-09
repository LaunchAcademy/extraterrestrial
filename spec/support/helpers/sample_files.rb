require "yaml"

module SampleFiles
  def write_sample_config_to(dir, additional_settings = nil)
    settings = {
      "username" => "bob",
      "token" => "1234",
      "host" => "http://localhost:3000"
    }

    if additional_settings
      settings = settings.merge(additional_settings)
    end

    config = ET::Config.new(dir)
    config.save!(settings)
  end

  def add_sample_exercise(dir)
    system("cp", "-r", project_root.join("spec/data/sample-exercise").to_s, dir)
    File.join(dir, "sample-exercise")
  end

  def add_sample_challenge(dir)
    system("cp", "-r", project_root.join("spec/data/sample-challenge").to_s, dir)
    File.join(dir, "sample-challenge")
  end
end
