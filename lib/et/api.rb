require "securerandom"
require "base64"
require "json"
require "openssl"

require_relative "fallback_connection"
module ET
  class API
    attr_reader :host, :username, :token

    def initialize(options)
      @host = options[:host]
      @username = options[:username]
      @token = options[:token]
    end

    def list_lessons
      response = nil
      api_client.open do |client|
        response = client.get('/lessons.json', :submittable => 1)
      end
      response.body['lessons']
    end

    def get_lesson(slug)
      resp = nil
      api_client.open do |client|
        resp = client.get(lesson_url(slug), :submittable => 1)
      end
      resp.body['lesson']
    end

    def download_file(url)
      response = nil
      dest = random_filename

      download_client(url).open do |client|
        response = client.get(URI(url).path)
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
      resp = nil
      api_client.open do |client|
        resp = client.post(submission_url(lesson.slug),
          "submission" => { "archive" => io})
      end
      resp
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

    def api_client
      @api_client ||= ET::FallbackConnection.new(:url => @host) do |client|
        client.request :multipart

        client.request :url_encoded
        client.request :basic_auth, username, token

        client.response :json, :content_type => /\bjson$/

        client.adapter  Faraday.default_adapter
      end
    end

    def download_client(url)
      uri = URI(url)
      scheme_and_host = [uri.scheme, uri.host].join('://')
      ET::FallbackConnection.new(:url => scheme_and_host) do |client|
        client.adapter  Faraday.default_adapter
      end
    end
  end
end
