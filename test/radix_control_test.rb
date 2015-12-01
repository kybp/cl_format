require 'test_helper'

class RadixControlTest < MiniTest::Test
  def test_tilde_at_r
    assert_equal('MCDLIII', '~@r'.cl_format(1453))
  end

  def test_tilde_colon_at_r
    assert_equal('MCCCCLIII', '~:@r'.cl_format(1453))
  end

  def test_tilde_colon_r
    assert_equal('five hundred twenty-sixth', '~:r'.cl_format(526))
  end

  def test_tilde_r_plain
    assert_equal('five hundred twenty-six', '~r'.cl_format(526))
  end

  def test_tilde_r_negative_zero
    assert_equal('zero', '~r'.cl_format(-0))
  end

  def test_tilde_r_negative_ninety
    assert_equal('negative ninetieth', '~:r'.cl_format(-90))
  end

  def test_tilde_r_simplify_roman
    assert_equal('X', "~,9,'9,,@r".cl_format(10))
  end

  def test_tilde_r_simplify_english
    assert_equal('fourth', "~,9,'9,,:r".cl_format(4))
  end

  def test_tilde_r_pad_w_sign
    assert_equal('&+2', "~10,3,'&@r".cl_format(2))
  end

  def test_tilde_r_comma
    assert_equal('DEAD_BEEF', "~16,,,'_,4:r".cl_format(3735928559))
  end

  def test_tilde_r_default_padding
    assert_equal('    5', '~5d'.cl_format(5))
  end

  def test_tilde_r_insignficant_padding
    assert_equal('123', '~2d'.cl_format(123))
  end

  def test_tilde_d_simple
    assert_equal("~10r".cl_format(312), "~d".cl_format(312))
  end

  def test_tilde_d
    assert_equal("~10,12,'x,'o,1:@r".cl_format(12345),
                    "~12,'x,'o,1:@d".cl_format(12345))
  end

  def test_tilde_b
    assert_equal("~2r".cl_format(123), "~b".cl_format(123))
  end

  def test_tilde_o
    assert_equal("~8r".cl_format(123), "~o".cl_format(123))
  end

  def test_tilde_x
    assert_equal("~16r".cl_format(123), "~x".cl_format(123))
  end
end
