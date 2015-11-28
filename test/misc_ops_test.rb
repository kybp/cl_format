require_relative '../cl_format'
require 'minitest/autorun'

class MiscOpsTest < MiniTest::Test
  def test_tilde_p_with_s
    assert_equal('rabbits', 'rabbit~p'.cl_format(2))
  end

  def test_tilde_p_not_number
    assert_equal('rabbits', 'rabbit~p'.cl_format(nil))
  end

  def test_tilde_p_no_s
    assert_equal('rabbit', 'rabbit~p'.cl_format(1))
  end

  def test_tilde_colon_p_no_s
    assert_equal('I have 1 rabbit', 'I have ~d rabbit~:p'.cl_format(1))
  end

  def test_tilde_colon_p_with_s
    assert_equal('I have 3 rabbits', 'I have ~d rabbit~:p'.cl_format(3))
  end
end
