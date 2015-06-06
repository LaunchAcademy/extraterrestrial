describe ET::API do
  let(:api) { ET::API.new(host: "http://localhost:3000") }

  describe "lessons" do
    let(:lessons_response) do
      File.read("spec/data/lessons.json")
    end

    it "queries for a list of lessons" do
      request = {}
      response = double
      http = double
      lessons_uri = URI("http://localhost:3000/lessons.json?submittable=1")
      expect(Net::HTTP::Get).to receive(:new).
        with(lessons_uri).
        and_return(request)
      expect(Net::HTTP).to receive(:start).with(
        lessons_uri.host,
        lessons_uri.port,
        use_ssl: lessons_uri.scheme == "https").
        and_yield(http)
      expect(http).to receive(:request).and_return(response)
      expect(response).to receive(:body).and_return(lessons_response)

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
      expect(Net::HTTP).to receive(:get).
        with(URI("http://localhost:3000/lessons/rock-paper-scissors.json")).
        and_return(lesson_response)

      result = api.get_lesson("rock-paper-scissors")

      expect(result[:title]).to eq("Rock, Paper, Scissors")
      expect(result[:archive_url]).to eq("http://example.com/rock-paper-scissors.tar.gz")
    end
  end
end
