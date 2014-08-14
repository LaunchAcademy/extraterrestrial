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
    options = { "title" => slug.capitalize, "slug" => slug }

    dir = File.join(working_dir, slug)
    system("mkdir #{dir}")

    File.write(File.join(dir, "README.md"), "# README")
    File.write(File.join(dir, ".challenge"), options.to_yaml)

    dir
  end
end
