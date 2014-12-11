describe ET::API do
  let(:api) { ET::API.new(host: "http://localhost:3000") }

  describe "lessons" do
    let(:lessons_response) do
      File.read("spec/data/lessons.json")
    end

    it "queries for a list of lessons" do
      expect(RestClient).to receive(:get).
        with("http://localhost:3000/lessons.json?submittable=1").
        and_return(lessons_response)

      results = api.list_lessons

      expect(results.count).to eq(3)
      expect(results[0][:title]).to eq("Max Number")
      expect(results[0][:slug]).to eq("max-number")
      expect(results[0][:type]).to eq("exercise")
    end

    let(:lesson_response) do
      File.read("spec/data/challenge.json")
    end

    it "queries for a single lesson" do
      expect(RestClient).to receive(:get).
        with("http://localhost:3000/lessons/rock-paper-scissors.json").
        and_return(lesson_response)

      result = api.get_lesson("rock-paper-scissors")

      expect(result[:title]).to eq("Rock, Paper, Scissors")
      expect(result[:archive_url]).to eq("http://example.com/rock-paper-scissors.tar.gz")
    end
  end
end
