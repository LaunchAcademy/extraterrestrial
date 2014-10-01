describe ET::API do
  let(:api) { ET::API.new(host: "http://localhost:3000") }

  describe "challenges" do
    let(:challenges_response) do
      File.read("spec/data/challenges.json")
    end

    it "queries for a list of challenges" do
      expect(RestClient).to receive(:get).
        with("http://localhost:3000/lessons.json?type=challenge").
        and_return(challenges_response)

      results = api.list_challenges

      expect(results.count).to eq(2)
      expect(results[0][:title]).to eq("Auto-Guesser")
      expect(results[0][:slug]).to eq("auto-guesser")
    end

    let(:challenge_response) do
      File.read("spec/data/challenge.json")
    end

    it "queries for a single challenge" do
      expect(RestClient).to receive(:get).
        with("http://localhost:3000/lessons/rock-paper-scissors.json").
        and_return(challenge_response)

      result = api.get_challenge("rock-paper-scissors")

      expect(result[:title]).to eq("Rock, Paper, Scissors")
      expect(result[:archive_url]).to eq("http://example.com/rock-paper-scissors.tar.gz")
    end
  end
end
