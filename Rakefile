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
  gem.name = "activemerchant-payway"
  gem.homepage = "http://github.com/thefrontiergroup/activemerchant-payway"
  gem.license = "MIT"
  gem.summary = %Q{ActiveMerchant PayWay Plugin}
  gem.description = %Q{ActiveMerchant PayWay Plugin}
  gem.email = "dk@dirkkelly.com"
  gem.authors = ["Matt Lambie", "Dan Galipo", "Dirk Kelly"]
  gem.add_dependency 'activemerchant', '>= 1.9.1'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end