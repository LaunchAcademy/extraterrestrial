module ET
  describe API do
    let(:api) { API.new("http://localhost:3000") }

    describe "challenges" do
      let(:challenges_response) do
        File.read("spec/data/challenges.json")
      end

      it "queries for a list of challenges" do
        expect(RestClient).to receive(:get).
          with("http://localhost:3000/challenges.json").
          and_return(challenges_response)

        results = api.list_challenges

        expect(results[:challenges].count).to eq(2)
        expect(results[:challenges][0][:title]).to eq("Auto-Guesser")
        expect(results[:challenges][0][:slug]).to eq("auto-guesser")
      end
    end
  end
end
