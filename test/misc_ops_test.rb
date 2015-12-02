require 'test_helper'

class MiscOpsTest < MiniTest::Test
  def test_tilde_left_paren
    assert_equal('hi hi hi hi', '~(hi hI Hi HI~)'.cl_format)
  end

  def test_tilde_colon_left_paren
    assert_equal('Hi Hi Hi Hi', '~:(hi hI Hi HI~)'.cl_format)
  end

  def test_tilde_at_left_paren
    assert_equal('Hi hi hi hi', '~@(hi hI Hi HI~)'.cl_format)
  end

  def test_tilde_at_left_paren_ignore_non_alpha
    assert_equal('1 Hi', '~@(1 hi~)'.cl_format)
  end

  def test_tilde_colon_at_left_paren
    assert_equal('HI HI HI HI', '~:@(hi hI Hi HI~)'.cl_format)
  end

  def test_tilde_colon_escaped_close
    assert_equal('HI ~) HI.', '~:@(hi ~~) hi.~)'.cl_format)
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
