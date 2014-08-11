require "pathname"

module PathHelper
  def project_root
    Pathname.new(File.join(File.dirname(__FILE__), "../../.."))
  end
end
