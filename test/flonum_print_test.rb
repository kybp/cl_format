require 'test_helper'

class FlonumPrintTest < MiniTest::Test
  def test_tilde_f_plain
    assert_equal('1.23', '~f'.cl_format(1.23))
  end

  def test_tilde_at_f
    assert_equal('+1.23', '~5@f'.cl_format(1.23))
  end

  def test_tilde_f_d0
    assert_equal(' 3.', '~3,0f'.cl_format(3))
  end

  def test_tilde_f_ignore_args
    assert_equal('1.23', "~,,10,,@f".cl_format(1.23))
  end

  def test_tilde_f_overflowchar
    assert_equal('##', "~2,3,,'#f".cl_format(1))
  end

  def test_tilde_f_padchar
    assert_equal('/1.23', "~5,,,,'/f".cl_format(1.23))
  end

  def test_tilde_f_drop_leading_zero
    assert_equal('.11', '~3,2f'.cl_format(0.11))
  end

  def test_tilde_f_newline
    assert_equal("xxx\n", "~3,4,,'xf~%".cl_format(1))
  end

  def test_tilde_f_no_colon
    assert_raises(RuntimeError) { '~:f'.cl_format(2.3) }
  end

  def test_tilde_dollarsign
    assert_equal('3.00', '~$'.cl_format(3))
  end

  def test_tilde_dollarsign_n
    assert_equal('003.00', '~,3$'.cl_format(3))
  end

  def test_tilde_dollarsign_full
    assert_equal('+xxxx003.2', "~1,3,10,'x:@$".cl_format(3.19))
  end
end
