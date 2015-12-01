require 'test_helper'

class MiscPseudoOpsTest < MiniTest::Test
  def test_tilde_newline
    assert_equal('hi', 'h~
                        i'.cl_format)
  end

  def test_tilde_at_newline
    assert_equal("h\ni", 'h~@
                          i'.cl_format)
  end

  def test_tilde_newline_colon_then_at
    assert_equal("h i\nhi", 'h~:
 i~@
    hi'.cl_format)
  end
end
