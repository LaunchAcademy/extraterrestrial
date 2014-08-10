require "rest-client"
require "json"

module ET
  class API
    attr_reader :host

    def initialize(host)
      @host = host
    end

    def list_challenges
      response = RestClient.get("http://localhost:3000/challenges.json")
      JSON.parse(response, symbolize_names: true)
    end

    def get_challenge(slug)
      {
        title: "Blackjack",
        slug: "blackjack",
        archive_url: "http://localhost:3000/some-archive.tar.gz"
      }
    end

    def download_file(url)
      File.join(File.dirname(__FILE__), "../../spec/data/archive.tar.gz")
    end

    def submit_challenge(dir)
    end
  end
end
