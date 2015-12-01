require 'minitest/autorun'
require 'minitest/reporters'

class BrightReporter < MiniTest::Reporters::DefaultReporter
  def initialize
    super color: true
  end

  def red(string)
    "\e[1;31m#{string}\e[m"
  end
end

MiniTest::Reporters.use! [BrightReporter.new]

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'test'
  end
end

require_relative '../cl_format'
