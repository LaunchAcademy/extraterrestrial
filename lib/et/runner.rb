module ET
  class Runner
    SUCCESS = 0

    def self.go(_args)
      api = API.new("http://localhost:3000")
      results = api.list_challenges

      results[:challenges].each do |challenge|
        puts challenge[:title]
        puts challenge[:slug]
      end

      SUCCESS
    end
  end
end
