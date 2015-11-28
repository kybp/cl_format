require_relative './format'
require 'minitest/autorun'

class BasicOutputTest < MiniTest::Test
  def test_nothing
    assert_equal('hi', 'hi'.cl_format)
  end

  def test_tilde_c
    assert_equal('hi', '~c~c'.cl_format('h', 'i'))
  end

  def test_tilde_percent
    assert_equal("hi\n", 'hi~%'.cl_format)
  end

  def test_tilde_percent_count
    assert_equal("hi\n\n\nhi", 'hi~3%hi'.cl_format)
  end

  def test_tilde_vertical_bar
    assert_equal("h\fhi", 'h~|hi'.cl_format)
  end

  def test_tilde_tilde
    assert_equal('~hi~~', '~~hi~~~~'.cl_format)
  end
end