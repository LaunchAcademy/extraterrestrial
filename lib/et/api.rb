require "rest-client"
require "securerandom"
require "base64"
require "json"

module ET
  class API
    attr_reader :host, :username, :token

    def initialize(options)
      @host = options[:host]
      @username = options[:username]
      @token = options[:token]
    end

    def list_challenges
      response = RestClient.get("http://localhost:3000/challenges.json")
      JSON.parse(response, symbolize_names: true)
    end

    def get_challenge(slug)
      response = RestClient.get("http://localhost:3000/challenges/#{slug}.json")
      body = JSON.parse(response, symbolize_names: true)
      body[:challenge]
    end

    def download_file(url)
      uri = URI(url)
      dest = random_filename

      Net::HTTP.start(uri.host, uri.port,
        use_ssl: uri.scheme == "https") do |http|

        resp = http.get(uri.path)

        open(dest, 'wb') do |file|
          file.write(resp.body)
        end
      end

      dest
    end

    def submit_challenge(dir)
    end

    private

    def random_filename
      File.join(Dir.mktmpdir, SecureRandom.hex)
    end

    def credentials
      Base64.strict_encode64("#{username}:#{token}")
    end

    def auth_header
      "Basic #{credentials}"
    end
  end
end
