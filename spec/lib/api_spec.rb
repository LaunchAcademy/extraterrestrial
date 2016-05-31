describe ET::API do
  let(:api) { ET::API.new(host: "http://localhost:3000") }
  let(:lessons_uri) do
    URI("http://localhost:3000/lessons.json?submittable=1")
  end

  let(:lessons_response) do
    File.read("spec/data/lessons.json")
  end

  describe "lessons" do
    it "queries for a list of lessons" do
      request = {}
      response = double
      http = double
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
      request = {}
      response = double
      http = double

      lesson_uri = URI("http://localhost:3000/lessons/rock-paper-scissors.json?submittable=1")
      expect(Net::HTTP::Get).to receive(:new).
        with(lesson_uri).
        and_return(request)
      expect(Net::HTTP).to receive(:start).with(
        lesson_uri.host,
        lesson_uri.port,
        use_ssl: lesson_uri.scheme == "https").
        and_yield(http)
      expect(http).to receive(:request).and_return(response)
      expect(response).to receive(:body).and_return(lesson_response)

      result = api.get_lesson("rock-paper-scissors")

      expect(result[:title]).to eq("Rock, Paper, Scissors")
      expect(result[:archive_url]).to eq("http://example.com/rock-paper-scissors.tar.gz")
    end
  end

  context 'ssl verification' do
    it 're-raises an exception for non Windows machines' do
      dbl_os = double
      allow(dbl_os).to receive(:platform_family?).with(:windows).and_return(false)
      expect(ET::OperatingSystem).to receive(:new).and_return(dbl_os)

      expect(Net::HTTP).to receive(:start).and_raise(OpenSSL::SSL::SSLError)
      expect{ api.list_lessons }.to raise_error(OpenSSL::SSL::SSLError)
    end

    it 'swallows the exception for windows machines and reissues' do
      http = double
      allow(http).to receive(:start).and_yield(http)
      allow(http).to receive(:verify_mode=)
      allow(http).to receive(:use_ssl=)
      response = double

      allow(http).to receive(:request).and_return(response)
      allow(response).to receive(:body).and_return(lessons_response)

      allow(Net::HTTP).to receive(:start).
        with(
          lessons_uri.host,
          lessons_uri.port,
          use_ssl: lessons_uri.scheme == 'https').
            and_raise(OpenSSL::SSL::SSLError)

      expect(Net::HTTP).to receive(:new).with(
          lessons_uri.host,
          lessons_uri.port).
          and_return(http)

      dbl_os = double
      allow(dbl_os).to receive(:platform_family?).and_return(:windows)
      allow(ET::OperatingSystem).to receive(:new).and_return(dbl_os)

      api.list_lessons
    end
  end
end
