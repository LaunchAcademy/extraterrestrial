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
  s.bindir = "bin"
  s.executables << "et"
  s.license = "MIT"
  s.add_development_dependency("pry", '~> 0')
  s.add_runtime_dependency("rspec", "~> 3.0")
  s.add_runtime_dependency("rake", "~> 10")
  s.add_runtime_dependency("rspec-mocks", "~> 3.0")
  s.add_runtime_dependency("multipart-post", "~> 2.0")
  s.add_runtime_dependency("gli", "2.11.0")
  s.add_runtime_dependency("faraday", "~> 0.9")
  s.add_runtime_dependency("faraday_middleware", "~> 0.10")
end
