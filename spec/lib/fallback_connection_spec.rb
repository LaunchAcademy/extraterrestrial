describe ET::FallbackConnection do
  let(:cnn) do
    ET::FallbackConnection.new(:url => 'http://localhost')
  end

  context 'ssl verification' do
    it 're-raises an exception for non Windows machines' do
      dbl_os = double
      allow(dbl_os).to receive(:platform_family?).with(:windows).and_return(false)
      expect(ET::OperatingSystem).to receive(:new).and_return(dbl_os)

      allow_any_instance_of(Faraday::Connection).
        to receive(:get).and_raise(Faraday::SSLError.new(OpenSSL::SSL::SSLError))

      expect{ cnn.with_ssl_fallback{|client| client.get('/') }}.
        to raise_error(Faraday::SSLError)
    end

    it 'swallows the exception for windows machines and reissues' do
      dbl_os = double
      allow(dbl_os).to receive(:platform_family?).and_return(:windows)
      allow(ET::OperatingSystem).to receive(:new).and_return(dbl_os)

      called_twice = false
      allow_any_instance_of(Faraday::Connection).to receive(:get) do |*args|
        if args[0].ssl.verify != false
          #simulate a windows SSL verification failed
          raise Faraday::SSLError.new(OpenSSL::SSL::SSLError.new)
        elsif args[0].ssl.verify == false
          #flip the switch that the request was reissued without SSL verification
          called_twice = true
          double(:body => '{}')
        end
      end

      cnn.with_ssl_fallback do |client|
        client.get('/')
      end
      expect(called_twice).to be(true)
    end
  end
end
