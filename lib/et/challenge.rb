module ET
  class Challenge < Lesson
    def exists?
      !dir.nil? && config["type"] == "challenge"
    end
  end
end
