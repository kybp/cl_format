require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs.push 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = false
end

task :default => :test

task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['test'].execute
end
