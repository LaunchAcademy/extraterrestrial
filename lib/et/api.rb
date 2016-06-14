require "net/http/post/multipart"
require "securerandom"
require "base64"
require "json"
require "openssl"

module ET
  class API
    attr_reader :host, :username, :token

    def initialize(options)
      @host = options[:host]
      @username = options[:username]
      @token = options[:token]
    end

    def list_lessons
      request = Net::HTTP::Get.new(lessons_url)
      request["Authorization"] = auth_header

      response = issue_request(request)
      JSON.parse(response.body, symbolize_names: true)[:lessons]
    end

    def get_lesson(slug)
      request = Net::HTTP::Get.new(lesson_url(slug))
      request["Authorization"] = auth_header

      response = issue_request(request)

      body = JSON.parse(response.body, symbolize_names: true)
      body[:lesson]
    end

    def download_file(url)
      uri = URI(url)
      dest = random_filename

      request = Net::HTTP::Get.new(uri.path)
      response = issue_request(request, url)
      if response.code == "200"
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
      url = submission_url(lesson.slug)

      File.open(submission_file) do |f|
        request = Net::HTTP::Post::Multipart.new(url.path,
          "submission[archive]" => UploadIO.new(f, "application/x-tar", "archive.tar.gz"))
        request["Authorization"] = auth_header

        issue_request(request)
      end
    end

    private
    def issue_request(request, url = nil)
      uri = URI.parse(url || @host)
      begin
        Net::HTTP.start(uri.host, uri.port,
          use_ssl: uri.scheme == "https") do |http|

          http.request(request)
        end
      rescue OpenSSL::SSL::SSLError => e
        if operating_system.platform_family?(:windows)
          https = Net::HTTP.new(uri.host, uri.port)
          https.verify_mode = OpenSSL::SSL::VERIFY_NONE
          https.use_ssl = uri.scheme == 'https'
          https.start do |http|
            http.request(request)
          end
        else
          raise e
        end
      end
    end

    def lesson_url(slug)
      URI.join(host, "lessons/#{slug}.json?submittable=1")
    end

    def lessons_url
      URI.join(host, "lessons.json?submittable=1")
    end

    def submission_url(slug)
      URI.join(host, "lessons/#{slug}/submissions.json")
    end

    def random_filename
      File.join(Dir.mktmpdir, SecureRandom.hex)
    end

    def credentials
      Base64.strict_encode64("#{username}:#{token}")
    end

    def auth_header
      "Basic #{credentials}"
    end

    def operating_system
      @os ||= ET::OperatingSystem.new
    end
  end
end
