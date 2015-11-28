require_relative '../format'
require 'minitest/autorun'

class ControlFlowTest < MiniTest::Test
  def test_tilde_asterisk
    assert_equal('123', '~d~d~*~d'.cl_format(1, 2, 2, 3))
  end

  def test_tilde_asterisk_count
    assert_equal('15', '~d~3*~d'.cl_format(1, 2, 3, 4, 5))
  end

  def test_tilde_colon_asterisk
    assert_equal('111', '~d~:*~d~:*~d'.cl_format(1))
  end

  def test_tilde_colon_asterisk_count
    assert_equal('1212', '~d~d~2:*~d~d'.cl_format(1, 2))
  end

  def test_tilde_at_asterisk
    assert_equal('12123', '~d~d~@*~d~d~d'.cl_format(1, 2, 3))
  end

  def test_tilde_at_asterisk_index
    assert_equal('145', '~d~3@*~d~d'.cl_format(1, 2, 3, 4, 5))
  end
end
