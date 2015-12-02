require 'test_helper'

class RomanNumeralTest < MiniTest::Test
  def test_negative
    assert_raises(ArgumentError) { '~@r'.cl_format(-1) }
  end

  def test_zero
    assert_raises(ArgumentError) { '~@r'.cl_format(0) }
  end

  def test_new_style_4000
    assert_raises(ArgumentError) { '~@r'.cl_format(4000) }
  end

  def test_new_style_3999
    assert_equal('MMMCMXCIX', '~@r'.cl_format(3999))
  end

  def test_old_style_5000
    assert_raises(ArgumentError) { '~:@r'.cl_format(5000) }
  end

  def test_old_style_4999
    assert_equal('MMMMDCCCCLXXXXVIIII', '~:@r'.cl_format(4999))
  end

  def test_new_style_900
    assert_equal('CM', '~@r'.cl_format(900))
  end

  def test_new_style_94
    assert_equal('XCIV', '~@r'.cl_format(94))
  end

  def test_new_style_49
    assert_equal('XLIX', '~@r'.cl_format(49))
  end

  def test_406
    assert_equal('CDVI', '~@r'.cl_format(406))
  end
end
