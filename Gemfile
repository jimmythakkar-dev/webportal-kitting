if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source 'https://rubygems.org'

gem 'rails', '3.2.12'
gem 'kitting',:path => 'lib/kitting'
gem 'rmagick' #interface between ruby and imagemagick
gem 'carrierwave' #Classier solution for file uploads for Rails, Sinatra and other Ruby web frameworks
gem 'paper_trail', "~> 2.7.2" #maintaining history
gem 'jquery-rails', "~> 3.0.4" #jquery + ujs support
gem 'jquery-ui-rails', "~> 4.1.1" #jQuery UI for the Rails asset pipeline
gem "will_paginate", "~> 3.0.4" #pagiination in rails
gem 'writeexcel' #Write to a cross-platform Excel binary file.
gem "amoeba", "~> 2.0.0" #A ruby gem to allow the copying of ActiveRecord objects and their associated children, configurable with a DSL on the model
gem 'wkhtmltopdf-binary' #Provides binaries for WKHTMLTOPDF project in an easily accessible package.
gem "wicked_pdf" #Wicked PDF uses the shell utility wkhtmltopdf to serve a PDF file to a user from HTML
gem 'chunky_png' #ChunkyPNG is a pure Ruby library to read and write PNG images and access textual metadata. It has no dependency on RMagick, or any other library for that matter.
gem 'barby' #create barcodes
gem "ruby-oci8", "~> 2.1.5" #ruby-oci8 is a ruby interface for Oracle using OCI8 API. It is available with Oracle8i, Oracle9i, Oracle10g, Oracle11g and Oracle Instant Client
gem "activerecord-oracle_enhanced-adapter", "~> 1.4.2" #Oracle enhanced ActiveRecord adapter provides Oracle database access from Ruby on Rails applications
gem "multipart-post" #mAdds a streamy multipart form post capability to Net::HTTP To post multiple files or attachments, csv import ma use
gem 'logstasher' #Awesome rails logs
gem 'whenever', :require => false #Clean ruby syntax for writing and deploying cron jobs.
gem 'i18n-js' #It's a small library to provide the Rails I18n translations on the Javascript.
#gem 'jquery-validation-rails'
gem "iconv" #Simple conversion between two charsets. converted_text = Iconv.conv('iso-8859-15', 'utf-8', text)
# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :development do
  gem "pry"
  gem "rspec"
  gem "yard" #YARD is a documentation generation tool for the Ruby programming language. It enables the user to generate consistent, usable documentation that can be exported to a number of formats very easily, and also supports extending for custom Ruby constructs such as custom class level definitions.
  gem "rspec-rails"
  gem "rails_best_practices"
  gem "passenger" #A modern web server and application server for Ruby, Python and Node.js, optimized for performance, low memory usage and ease of use.
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem "awesome_print", require:"ap" #Pretty print your Ruby objects with style -- in full color and with proper indentation
  gem 'meta_request'
end

group :test do
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'capybara'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'database_cleaner'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby #Call JavaScript code and manipulate JavaScript objects from Ruby. Call Ruby code and manipulate Ruby objects from JavaScript.
  gem 'uglifier', '>= 1.0.3' #Uglifier minifies JavaScript files by wrapping UglifyJS to be accessible in Ruby
  gem 'autoprefixer-rails' #Parse CSS and add vendor prefixes to CSS rules using values from the Can I Use website.
end

#gem 'jquery-rails'
#gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
#gem "twitter-bootstrap-rails"

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
gem 'unicorn'
# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem 'bootstrap-sass', '~> 3.3.1'
gem 'sass-rails', '>= 3.2'
gem "browser"
