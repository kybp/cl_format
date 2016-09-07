lib = File.join(Dir.getwd, 'lib')
$:.unshift lib unless $:.include? lib
require 'cl_format/version'

Gem::Specification.new do |s|
  s.name        = 'cl_format'
  s.version     = CLFormat::VERSION
  s.date        = '2016-09-07'
  s.authors     = ["Kyle Brown"]
  s.email       = 'picokyle@gmail.com'
  s.files       = ["lib/cl_format.rb"]
  s.homepage    = 'https://github.com/kybp/cl_format'
  s.license     = 'GPL-3.0'
  s.summary     = "Common Lisp's FORMAT function for Ruby"
  s.add_dependency 'human_numbers'
  s.add_dependency 'unicode_utils'
  s.add_development_dependency 'simplecov', '~> 0.12.0'
  s.add_development_dependency 'minitest-reporters', '~> 1.1.11', '>= 1.1.11'
end
