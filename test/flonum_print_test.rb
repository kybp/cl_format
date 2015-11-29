require_relative '../cl_format'

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
end
