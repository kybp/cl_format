require 'test_helper'

class ControlFlowTest < MiniTest::Test
  def test_tilde_asterisk
    assert_equal('123', '~d~d~*~d'.cl_format(1, 2, 2, 3))
  end

  def test_tilde_asterisk_count
    assert_equal('15', '~d~3*~d'.cl_format(1, 2, 3, 4, 5))
  end

  def test_tilde_colon_asterisk
    assert_equal('111', '~d~:*~d~:*~d'.cl_format(1))
  end

  def test_tilde_colon_asterisk_count
    assert_equal('1212', '~d~d~2:*~d~d'.cl_format(1, 2))
  end

  def test_tilde_at_asterisk
    assert_equal('12123', '~d~d~@*~d~d~d'.cl_format(1, 2, 3))
  end

  def test_tilde_at_asterisk_index
    assert_equal('145', '~d~3@*~d~d'.cl_format(1, 2, 3, 4, 5))
  end

  def test_tilde_question_mark
    assert_equal('<Foo 5> 7', '~? ~d'.cl_format('<~a ~d>', ['Foo', 5], 7))
  end

  def test_tilde_question_mark_ignore_extra_args
    assert_equal('<Foo 5> 7', '~? ~d'.cl_format('<~a ~d>', ['Foo', 5, 14], 7))
  end

  def test_tilde_at_question_mark
    assert_equal('<Foo 5> 7', '~@? ~d'.cl_format('<~a ~d>', 'Foo', 5, 7))
  end

  def test_tilde_left_brace
    assert_equal('123', '~{~a~}'.cl_format([1,2,3]))
  end

  def test_tilde_left_brace_escape
    assert_equal('1, 2, 3', '~{~a~^, ~}'.cl_format([1,2,3]))
  end

  def test_unmatched_tilde_left_brace
    assert_raises(RuntimeError) { '~{~a'.cl_format([2]) }
  end

  def test_unmatched_tilde_right_brace
    assert_raises(RuntimeError) { '~a ~}'.cl_format(2) }
  end

  def test_nested_iteration
    assert_equal('1234', '~{~{~a~}~}'.cl_format([[1,2],[3,4]]))
  end

  def test_nested_iteration_escapes
    assert_equal('1-2 | 3-4 | 5-6',
                 '~{~{~a~^-~}~^ | ~}'.cl_format([[1,2],[3,4],[5,6]]))
  end

  def test_multiple_arguments_per_loop
    assert_equal('1:2 3:4 5:6', '~{~a:~a~^ ~}'.cl_format([1,2,3,4,5,6]))
  end

  def test_tilde_at_left_brace
    assert_equal('1:2 3:4 5:6', '~@{~a:~a~^ ~}'.cl_format(1,2,3,4,5,6))
  end

  def test_tilde_at_left_brace_save_args
    assert_equal('1 2 3 4.', '~s ~@{~s~^ ~}.'.cl_format(1,2,3,4))
  end

  def test_tilde_colon_left_brace
    assert_equal('<1:23:45:6>', '<~:{~a:~a~}>'.cl_format([[1,2],[3,4],[5,6]]))
  end

  def test_tilde_colon_at_left_brace
    assert_equal('1:23:4', '~:@{~s:~s~}'.cl_format([1,2],[3,4]))
  end

  def test_tilde_colon_right_brace
    assert_equal('1 hi', '~a ~@{hi~:}'.cl_format(1))
  end
end
