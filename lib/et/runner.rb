require "gli"
require "yaml"

module ET
  class Runner
    include GLI::App

    attr_reader :cwd

    def initialize(cwd = Dir.pwd)
      @cwd = cwd
    end

    def go(args)
      version VERSION

      desc "Initialize current directory as challenge work area."
      command :init do |c|
        c.flag [:u, :user], desc: "Username"
        c.flag [:t, :token], desc: "Login token"
        c.flag [:h, :host], desc: "Server hosting the challenges"

        c.action do |_global_options, options, _cmdargs|
          settings = {
            "username" => options[:user],
            "token" => options[:token],
            "host" => options[:host]
          }

          settings = prompt_for_missing(settings)
          File.write(File.join(cwd, ".et"), settings.to_yaml)
        end
      end

      desc "List available challenges."
      command :list do |c|
        c.action do |_global_options, _options, _cmdargs|
          Formatter.print_table(api.list_challenges[:challenges], :slug, :title)
        end
      end

      desc "Download challenge to your working area."
      command :get do |c|
        c.action do |_global_options, _options, cmdargs|
          cmdargs.each do |slug|
            challenge = api.get_challenge(slug)
            archive = api.download_file(challenge[:archive_url])

            system("tar zxf #{archive} -C #{cwd}")
            system("rm #{archive}")
          end
        end
      end

      desc "Submit the challenge in this directory."
      command :submit do |c|
        c.action do |_global_options, _options, _cmdargs|
          api.submit_challenge(cwd)
        end
      end

      run(args)
    end

    def api
      @api ||= API.new(host)
    end

    def host
      config.host
    end

    def config
      @config ||= load_config
    end

    private

    def prompt_for_missing(settings)
      settings.each do |key, value|
        if value.nil?
          print "#{key.capitalize}: "
          input = gets.chomp
          settings[key] = input
        end
      end

      settings
    end

    def load_config
      c = Config.new(cwd)
      if c.path.nil?
        raise StandardError.new("Could not find configuration file. " +
          "Run `et init` to create one.")
      end
      c
    end
  end
end
