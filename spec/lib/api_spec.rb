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
      client = Faraday.new do |builder|
        builder.response :json

        builder.adapter :test do |stubs|
          stubs.get("/lessons.json") do
            [200, {}, lessons_response]
          end
        end
      end

      allow_any_instance_of(ET::API).to receive(:client).and_return(client)

      results = api.list_lessons

      expect(results.count).to eq(3)
      expect(results[0]['title']).to eq("Max Number")
      expect(results[0]['slug']).to eq("max-number")
      expect(results[0]['type']).to eq("exercise")
    end

    let(:lesson_response) do
      File.read("spec/data/challenge.json")
    end

    it "queries for a single lesson" do
      client = Faraday.new do |builder|
        builder.response :json

        builder.adapter :test do |stubs|
          stubs.get("/lessons/rock-paper-scissors.json") do
            [200, {}, lesson_response]
          end
        end
      end

      allow_any_instance_of(ET::API).to receive(:client).and_return(client)

      result = api.get_lesson("rock-paper-scissors")

      expect(result['title']).to eq("Rock, Paper, Scissors")
      expect(result['archive_url']).to   eq('http://example.com/rock-paper-scissors.tar.gz')
    end
  end

  context 'ssl verification' do
    it 're-raises an exception for non Windows machines' do
      dbl_os = double
      allow(dbl_os).to receive(:platform_family?).with(:windows).and_return(false)
      expect(ET::OperatingSystem).to receive(:new).and_return(dbl_os)

      allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(OpenSSL::SSL::SSLError)
      expect{ api.list_lessons }.to raise_error(OpenSSL::SSL::SSLError)
    end

    it 'swallows the exception for windows machines and reissues' do
      dbl_os = double
      allow(dbl_os).to receive(:platform_family?).and_return(:windows)
      allow(ET::OperatingSystem).to receive(:new).and_return(dbl_os)

      called_twice = false
      allow_any_instance_of(Faraday::Connection).to receive(:get) do |*args|
        if args[0].ssl.verify != false
          #simulate a windows SSL verification failed
          raise OpenSSL::SSL::SSLError
        elsif args[0].ssl.verify == false
          #flip the switch that the request was reissued without SSL verification
          called_twice = true
          double(:body => '{}')
        end
      end

      api.list_lessons
      expect(called_twice).to be(true)
    end
  end

  context 'downloading files' do
    it 'returns nil when a 404 is encountered' do
      filename = 'somefile.tar.gz'
      client = Faraday.new do |builder|
        builder.response :json

        builder.adapter :test do |stubs|
          stubs.get("/#{filename}") do
            [404, {}, '']
          end
        end
      end

      allow_any_instance_of(ET::API).to receive(:client).and_return(client)
      expect(api.download_file("http://example.com/#{filename}")).to be_nil
    end

    it 'returns a local file when a challenge is successfully downloaded' do
      path = '/tmp/et'
      filename = 'some-challenge.tar.gz'

      FileUtils.rm_rf(File.join(path, filename))
      FileUtils.mkdir_p(path)

      filename = 'somefile.tar.gz'
      client = Faraday.new do |builder|
        builder.adapter :test do |stubs|
          stubs.get("/#{filename}") do
            [200, {}, '']
          end
        end
      end

      allow_any_instance_of(ET::API).to receive(:client).and_return(client)
      allow(Dir).to receive(:mktmpdir).and_return(path)
      allow(SecureRandom).to receive(:hex).and_return(filename)

      url = "http://example.com/#{filename}"

      expect(api.download_file(url)).to eql(File.join(path, filename))
    end
  end
end
