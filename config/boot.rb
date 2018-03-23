require 'rubygems'
require 'net/https'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
ENV['NLS_LANG'] = 'AMERICAN_AMERICA.WE8MSWIN1252'

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
