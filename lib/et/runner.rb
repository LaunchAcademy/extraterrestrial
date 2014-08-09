require "gli"
require "yaml"

module ET
  class Runner
    extend GLI::App
    version VERSION

    def self.go(args, cwd = Dir.pwd)
      desc "Initialize current directory as challenge work area."
      command :init do |c|
        c.action do |_global_options, _options, args|
          config = {
            "username" => args[0],
            "token" => args[1],
            "host" => args[2]
          }

          File.write(File.join(cwd, ".et"), config.to_yaml)
        end
      end

      desc "List available challenges."
      command :challenges do |c|
        c.action do |_global_options, _options, _args|
          api = API.new("http://localhost:3000")
          results = api.list_challenges

          results[:challenges].each do |challenge|
            puts challenge[:title]
            puts challenge[:slug]
          end
        end
      end

      run(args)
    end
  end
end
