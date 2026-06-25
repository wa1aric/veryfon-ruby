require_relative "lib/veryfon/version"

Gem::Specification.new do |s|
  s.name        = "veryfon"
  s.version     = Veryfon::VERSION
  s.summary     = "Ruby client for Veryfon phone verification API"
  s.description = "Create and check phone verifications via missed call. Handles auth, phone normalization, polling, and webhook signature verification."
  s.authors     = ["Valerii"]
  s.license     = "MIT"

  s.required_ruby_version = ">= 3.0"

  s.files = Dir["lib/**/*.rb"] + ["README.md"]
  s.require_paths = ["lib"]

  s.metadata["source_code_uri"] = "https://github.com/wa1aric/veryfon-ruby"
end
