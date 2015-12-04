require 'test_helper'

class BasicOutputTest < MiniTest::Test
  def test_nothing
    assert_equal('', ''.cl_format)
  end
  
  def test_non_existent_directive
    assert_raises(RuntimeError) { '~h'.cl_format(0) }
  end

  def test_simple
    assert_equal('hi', 'hi'.cl_format)
  end

  def test_tilde_c
    assert_equal('hi', '~c~c'.cl_format('h', 'i'))
  end

  def test_tilde_c_not_char
    assert_raises(TypeError) { '~c'.cl_format('hi') }
  end

  def test_tilde_c_no_args
    assert_raises(RuntimeError) { '~1,c'.cl_format('x') }
  end

  def test_tilde_percent
    assert_equal("hi\n", 'hi~%'.cl_format)
  end

  def test_tilde_percent_count
    assert_equal("hi\n\n\nhi", 'hi~3%hi'.cl_format)
  end

  def test_tilde_ampersand_zero
    assert_equal('hi', '~0&h~0&~0&i~0&'.cl_format)
  end

  def test_tilde_ampersand_count
    assert_equal("hi\n\n", 'hi~%~2&'.cl_format)
  end

  def test_tilde_ampersand_plain
    assert_equal("hi\n", 'hi~&'.cl_format)
  end

  def test_tilde_ampersand_flags
    assert_raises(RuntimeError) { '~:&'.cl_format }
  end

  def test_tilde_vertical_bar
    assert_equal("h\fhi", 'h~|hi'.cl_format)
  end

  def test_tilde_tilde
    assert_equal('~hi~~', '~~hi~~~~'.cl_format)
  end
  
  def test_tilde_tilde_flags
    assert_raises(RuntimeError) { '~:~'.cl_format }
  end
end
