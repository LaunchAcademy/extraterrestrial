require "securerandom"
require "base64"
require "json"
require "openssl"
require "faraday"
require "faraday_middleware"

module ET
  class API
    attr_reader :host, :username, :token

    def initialize(options)
      @host = options[:host]
      @username = options[:username]
      @token = options[:token]
    end

    def list_lessons
      resp = nil
      with_ssl_fallback do |client|
        resp = client.get('/lessons.json', :submittable => 1)
      end
      resp.body['lessons']
    end

    def get_lesson(slug)
      resp = nil
      with_ssl_fallback do |client|
        resp = client.get(lesson_url(slug), :submittable => 1)
      end
      resp.body['lesson']
    end

    def download_file(url)
      response = nil
      uri = URI(url)
      dest = random_filename
      with_ssl_fallback(:url => uri.scheme + "://" + uri.host) do |client|
        response = client.get(uri.path)
      end
      if response.status == 200
        open(dest, 'wb') do |file|
          file.write(response.body)
        end
        dest
      else
        nil
      end
    end

    def submit_lesson(lesson)
      submission_file = lesson.archive!
      io = Faraday::UploadIO.new(submission_file, "application/x-tar")
      with_ssl_fallback do |client|
        resp = client.post(submission_url(lesson.slug),
          "submission" => { "archive" => io})
      end
    end

    private
    def lesson_url(slug)
      "/lessons/#{slug}.json"
    end

    def submission_url(slug)
      "/lessons/#{slug}/submissions.json"
    end

    def random_filename
      File.join(Dir.mktmpdir, SecureRandom.hex)
    end

    def operating_system
      @os ||= ET::OperatingSystem.new
    end

    def with_ssl_fallback(options = nil, &block)
      opts = options || default_faraday_options
      begin
        block.call(client(opts))
      rescue OpenSSL::SSL::SSLError => e
        if operating_system.platform_family?(:windows)
          block.call(win_client_fallback(opts))
        else
          raise e
        end
      end
    end

    def default_faraday_options
      {:url => @host}
    end

    def client(options)
      @client ||= configure_faraday(options)
    end

    def win_client_fallback(options)
      @win_client_fallback ||= configure_faraday(options.merge({
        :ssl => {:verify => false}
      }))
    end

    def configure_faraday(options)
      Faraday.new(options) do |client|
        client.request :multipart
        client.request :url_encoded
        client.request :basic_auth, username, token

        client.response :json, :content_type => /\bjson$/

        client.adapter  Faraday.default_adapter
      end
    end
  end
end
