RubyVM::InstructionSequence
  .compile_file('format.rb',
                tailcall_optimization: true,
                trace_instruction: false).eval

class String
  include CLFormat
  def cl_format(*args)
    format_loop(string: self, acc: '', used: [], left: args)
  end
end
