require "rest-client"
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
      response = RestClient.get(lessons_url)
      JSON.parse(response, symbolize_names: true)[:lessons]
    end

    def get_lesson(slug)
      response = RestClient.get(lesson_url(slug))
      body = JSON.parse(response, symbolize_names: true)
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
      RestClient.post(submission_url(lesson.slug),
        { submission: { archive: File.new(submission_file) }},
        { "Authorization" => auth_header })
    end

    private

    def lesson_url(slug)
      URI.join(host, "lessons/#{slug}.json").to_s
    end

    def lessons_url
      URI.join(host, "lessons.json?submittable=1").to_s
    end

    def submission_url(slug)
      URI.join(host, "lessons/#{slug}/submissions.json").to_s
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
