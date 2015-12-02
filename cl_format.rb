# RubyVM::InstructionSequence
#   .compile_file('format.rb',
#                 tailcall_optimization: true,
#                 trace_instruction:     false)
#   .eval
require_relative 'format'
class String
  include CLFormat
end
