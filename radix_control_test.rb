require_relative './format'
require 'minitest/autorun'

class RadixControlTest < MiniTest::Test
  def test_tilde_at_r
    assert_equal('MCDLIII', '~@r'.cl_format(1453))
  end

  def test_tilde_colon_at_r
    assert_equal('MCCCCLIII', '~:@r'.cl_format(1453))
  end
end
