module Extraterrestrial
  class Runner
    def self.go(args)
      data = API.list_challenges

      data[:challenges].each do |challenge|
        puts challenge[:title]
        puts challenge[:slug]
      end
    end
  end
end
