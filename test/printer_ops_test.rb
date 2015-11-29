require_relative '../cl_format'
require 'minitest/autorun'

class PrinterOpsTest < MiniTest::Test
  def test_tilde_a_plain_string
    assert_equal('hi', '~a'.cl_format('hi'))
  end

  def test_tilde_a_pad_string
    assert_equal('hi   ', '~5a'.cl_format('hi'))
  end

  def test_tilde_a_pad_string_left
    assert_equal('   hi', '~5@a'.cl_format('hi'))
  end

  def test_tilde_a_colinc
    assert_equal('   hi', '~4,3@a'.cl_format('hi'))
  end

  def test_tilde_a_minpad
    assert_equal('   hi', '~4,,3@a'.cl_format('hi'))
  end

  def test_tilde_s
    assert_equal(' "hi"', '~5@s'.cl_format('hi'))
  end
end
