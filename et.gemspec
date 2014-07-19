require File.join(
  [File.dirname(__FILE__), "lib", "et", "version.rb"])
Gem::Specification.new do |s|
  s.name = "et"
  s.version = ET::VERSION
  s.author = "Adam Sheehan"
  s.email = "adam.sheehan@launchacademy.com"
  s.homepage = "http://www.launchacademy.com"
  s.platform = Gem::Platform::RUBY
  s.summary = "Command-line interface for the event horizon."
  s.description = <<-DESC
Users can download challenges and submit their solutions via the command-line
interface.
DESC

  s.files = `git ls-files`.split("\n")
  s.require_paths << "lib"
  s.has_rdoc = false
  s.bindir = "bin"
  s.executables << "et"
  s.license = "MIT"
  s.add_development_dependency("rake", "~> 10.3")
  s.add_development_dependency("rspec", "~> 3.0.0")
  s.add_runtime_dependency("gli", "2.11.0")
end
