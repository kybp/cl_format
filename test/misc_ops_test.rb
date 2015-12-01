require 'test_helper'

class MiscOpsTest < MiniTest::Test
  def test_a
    assert_equal(true, false)
  end

  def test_tilde_p_with_s
    assert_equal('rabbits', 'rabbit~p'.cl_format(2))
  end

  def test_tilde_p_not_number
    assert_equal('rabbits', 'rabbit~p'.cl_format(nil))
  end

  def test_tilde_p_no_s
    assert_equal('rabbit', 'rabbit~p'.cl_format(1))
  end

  def test_tilde_colon_p_with_s
    assert_equal('I have 3 rabbits', 'I have ~d rabbit~:p'.cl_format(3))
  end

  def test_tilde_colon_p_no_s
    assert_equal('I have 1 rabbit', 'I have ~d rabbit~:p'.cl_format(1))
  end

  def test_tilde_at_p_with_s
    assert_equal('flies fly away', 'fl~@p fly away'.cl_format(2))
  end

  def test_tilde_at_p_no_s
    assert_equal('fly fly away', 'fl~@p fly away'.cl_format(1))
  end

  def test_tilde_colon_at_p
    assert_equal('2 flies', '~d fl~:@p'.cl_format(2))
  end
end
