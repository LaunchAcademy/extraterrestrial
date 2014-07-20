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
  end
end
