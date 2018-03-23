$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "kitting/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "kitting"
  s.version     = Kitting::VERSION
  s.authors     = ["ACCORDION TEAM"]
  s.email       = ["bewebportal.accordionsystems.com"]
  s.homepage    = "http://www.accordionsystems.com"
  s.summary     = "Web Portal Kitting Application"
  s.description = "Description  ....... "

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.12"
  #s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
