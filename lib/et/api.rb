require "net/http/post/multipart"
require "securerandom"
require "base64"
require "json"

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

      response = nil
      Net::HTTP.start(lessons_url.host, lessons_url.port,
        use_ssl: lessons_url.scheme == "https") do |http|

        response = http.request(request)
      end
      JSON.parse(response.body, symbolize_names: true)[:lessons]
    end

    def get_lesson(slug)
      request = Net::HTTP::Get.new(lesson_url(slug))
      request["Authorization"] = auth_header

      response = nil
      Net::HTTP.start(lessons_url.host, lessons_url.port,
        use_ssl: lessons_url.scheme == "https") do |http|

        response = http.request(request)
      end
      body = JSON.parse(response.body, symbolize_names: true)
      body[:lesson]
    end

    def download_file(url)
      uri = URI(url)
      dest = random_filename

      Net::HTTP.start(uri.host, uri.port,
        use_ssl: uri.scheme == "https") do |http|

        resp = http.get(uri.path)

        open(dest, 'wb') do |file|
          file.write(resp.body)
        end
      end

      dest
    end

    def submit_lesson(lesson)
      submission_file = lesson.archive!
      url = submission_url(lesson.slug)

      File.open(submission_file) do |f|
        request = Net::HTTP::Post::Multipart.new(url.path,
          "submission[archive]" => UploadIO.new(f, "application/x-tar", "archive.tar.gz"))
        request["Authorization"] = auth_header

        Net::HTTP.start(url.host, url.port,
          use_ssl: url.scheme == "https") do |http|

          http.request(request)
        end
      end
    end

    private

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
  end
end
