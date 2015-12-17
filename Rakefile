# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "ripple-light"
  gem.homepage = "http://github.com/stefan_mees/ripple-light"
  gem.license = "MIT"
  gem.summary = %Q{TODO: one-line summary of your gem}
  gem.description = %Q{TODO: longer description of your gem}
  gem.email = "stefan.mees@wooga.net"
  gem.authors = ["Stefan Mees"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'

desc "Run Unit Specs Only"
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = %w[--profile --tag ~integration]
end

namespace :spec do
  desc "Run All Specs"
  RSpec::Core::RakeTask.new(:all) do |spec|
    spec.rspec_opts = %w[--profile]
  end
end

task :default => "spec:all"