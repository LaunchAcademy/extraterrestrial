require "gli"
require "yaml"

module ET
  class Runner
    include GLI::App

    def go(args, cwd = Dir.pwd)
      version VERSION

      desc "Initialize current directory as challenge work area."
      command :init do |c|
        c.flag [:u, :user], desc: "Username"
        c.flag [:t, :token], desc: "Login token"
        c.flag [:h, :host], desc: "Server hosting the challenges"

        c.action do |_global_options, options, _cmdargs|
          config = {
            "username" => options[:user],
            "token" => options[:token],
            "host" => options[:host]
          }

          File.write(File.join(cwd, ".et"), config.to_yaml)
        end
      end

      desc "List available challenges."
      command :list do |c|
        c.action do |_global_options, _options, _cmdargs|
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
