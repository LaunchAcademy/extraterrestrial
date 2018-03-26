require "gli"
require "yaml"
require 'pry'

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

      desc "Initialize current directory as a work area."
      skips_pre
      command :init do |c|
        c.flag [:u, :user], desc: "Username"
        c.flag [:t, :token], desc: "Login token"
        c.flag [:h, :host], desc: "Server hosting the lessons"

        c.action do |_global_options, options, _cmdargs|
          settings = {
            "username" => options[:user],
            "token" => options[:token],
            "host" => options[:host]
          }

          settings = prompt_for_missing(settings)
          config.save!(settings)

          puts "Saved configuration to #{config.path}"
        end
      end

      desc "List available lessons."
      command :list do |c|
        c.action do |_global_options, _options, _cmdargs|
          Formatter.print_table(api.list_lessons, 'slug', 'title', 'type')
        end
      end

      desc "Download lesson to your working area."
      command :get do |c|
        c.action do |_global_options, _options, cmdargs|
          cmdargs.each do |slug|
            lesson = api.get_lesson(slug)
            archive = api.download_file(lesson['archive_url'])
            archive_manager = ET::ArchiveManager.new(archive, cwd)
            archive_manager.unpack

            if !archive_manager.unpacked_files.empty?
              archive_manager.delete_archive
              puts "'#{slug}' extracted to '#{archive_manager.destination}'"
            else
              raise StandardError.new("Failed to extract the archive.")
            end
          end
        end
      end

     desc "Download every available lesson to your working area."
     command :getall do |c|
       c.action do |_global_options, _options, _cmdargs|
       api.list_lessons.each do |slug|
           lesson = api.get_lesson(slug['slug'])
            archive = api.download_file(lesson['archive_url'])
            archive_manager = ET::ArchiveManager.new(archive, cwd)
            archive_manager.unpack

            if !archive_manager.unpacked_files.empty?
              archive_manager.delete_archive
              puts "'#{slug}' extracted to '#{archive_manager.destination}'"
            else
              raise StandardError.new("Failed to extract the archive.")
            end
          end
        end
      end

      desc "Submit the lesson in this directory."
      command :submit do |c|
        c.action do |_global_options, _options, _cmdargs|
          lesson = Lesson.new(cwd)

          if lesson.exists?
            api.submit_lesson(lesson)
            puts "Lesson submitted"
          else
            raise StandardError.new("Not in a lesson directory.")
          end
        end
      end

      desc "Run an exercise test suite."
      command :test do |c|
        c.action do |_global_options, _options, _cmdargs|
          exercise = Exercise.new(cwd)

          if exercise.exists?
            exercise.run_tests
          else
            raise StandardError.new("Not in an exercise directory.")
          end
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
  end
end
