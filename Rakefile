require 'rake/testtask'
lib = File.join(Dir.getwd, 'lib')
$:.unshift lib unless $:.include? lib
require 'cl_format/version'

Rake::TestTask.new do |t|
  sh 'bundle install'
  t.libs.push 'test'
  t.pattern = 'test/*_test.rb'
end

task :build => :test do
  sh 'gem build cl_format.gemspec'
end

task :install => :build do
  sh "gem install cl_format-#{CLFormat::VERSION}.gem"
end

task :default => :test
