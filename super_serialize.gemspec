$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "super_serialize/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "super_serialize"
  s.version     = SuperSerialize::VERSION
  s.authors     = ["Ricardo Quiñones"]
  s.email       = ["r.a.quinones@gmail.com"]
  s.homepage    = ""
  s.summary     = "Allows for dynamically serializing fixnums, floats, arrays, hashes, and, of course, strings."
  s.description = "A super, simple way to serialize anything from fixnums and floats to arrays and hashes."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", ">= 3.2.18"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
