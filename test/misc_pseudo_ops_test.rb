require 'test_helper'

class MiscPseudoOpsTest < MiniTest::Test
  def test_tilde_newline
    assert_equal('hi', "h~\n     i".cl_format)
  end

  def test_tilde_at_newline
    assert_equal("h\ni", "h~@\n     i".cl_format)
  end

  def test_tilde_newline_colon_then_at
    assert_equal("h i\nhi", "h~:\n i~@\n    hi".cl_format)
  end
  
  def test_no_colon_at_newline
    assert_raises(RuntimeError) { "~:@\n  ".cl_format }
  end
end
