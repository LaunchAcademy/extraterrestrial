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

      pre { |_, _, _, _| check_config! }

      desc "Initialize current directory as challenge work area."
      skips_pre
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
          save_config(settings)
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
          challenge = Challenge.new(cwd)
          api.submit_challenge(challenge)
        end
      end

      run(args)
    end

    def api
      @api ||= API.new(host: host, username: username, token: token)
    end

    def host
      config.host
    end

    def username
      config.username
    end

    def token
      config.token
    end

    def setting(key)
      config.exists? && config[key]
    end

    def config
      @config ||= Config.new(cwd)
    end

    private

    def prompt_for_missing(settings)
      settings.each do |key, value|
        if value.nil?
          existing_value = setting(key)

          if existing_value
            print "#{key.capitalize} (#{existing_value}): "
          else
            print "#{key.capitalize}: "
          end

          input = gets.chomp

          if input && !input.empty?
            settings[key] = input
          else
            settings[key] = existing_value
          end
        end
      end

      settings
    end

    def check_config!
      if config.exists?
        true
      else
        raise StandardError.new("Could not find configuration file. " +
          "Run `et init` to create one.")
      end
    end

    def save_config(settings)
      if config.exists?
        config.update(settings)
      else
        File.write(File.join(cwd, ".et"), settings.to_yaml)
      end
    end
  end
end
