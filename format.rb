require_relative 'roman_numeral'

class String
  def cl_format(*args)
    format_loop(self, '', *args)
  end
end

def format_loop(s, acc, *args)
  if s.nil? || s.empty?
    acc
  elsif s[0] != '~'
    format_loop(s[1..-1], acc + s[0], *args)
  else
    tilde_c(s, acc, *args)
  end
end

def tilde_c(s, acc, *args)
  # currently ignores options
  if match = /^~:?@?c/i.match(s)
    arg = args.shift
    if arg.is_a?(String) && arg.length == 1
      format_loop(match.post_match, acc + arg, *args)
    else
      raise ArgumentError, '~C requires a character'
    end
  else
    tilde_percent(s, acc, *args)
  end
end

def tilde_percent(s, acc, *args)
  if match = /^~(?<times>\d*)%/.match(s)
    (match[:times].empty? ? 1 : match[:times].to_i).times { acc += "\n" }
    format_loop(match.post_match, acc, *args)
  else
    tilde_vertical_bar(s, acc, *args)
  end
end

def tilde_vertical_bar(s, acc, *args)
  if match = /^~(?<times>\d*)\|/.match(s)
    (match[:times].empty? ? 1 : match[:times].to_i).times { acc += "\f" }
    format_loop(match.post_match, acc, *args)
  else
    tilde_tilde(s, acc, *args)
  end
end

def tilde_tilde(s, acc, *args)
  if match = /^~(?<times>\d*)~/.match(s)
    (match[:times].empty? ? 1 : match[:times].to_i).times { acc += '~' }
    format_loop(match.post_match, acc, *args)
  else
    tilde_at_r(s, acc, *args)
  end
end

def tilde_at_r(s, acc, *args)
  if match = /^~@r/i.match(s)
    n = args.shift
    raise ArgumentError, 'roman numeral not integer' unless n.is_a?(Integer)
    format_loop(match.post_match, acc + roman_numeral(n), *args)
  else
    tilde_colon_at_r(s, acc, *args)
  end
end

def tilde_colon_at_r(s, acc, *args)
  if match = /^~:@r/i.match(s)
    n = args.shift
    raise ArgumentError, 'roman numeral not integer' unless n.is_a?(Integer)
    format_loop(match.post_match, acc + roman_numeral(n, :old), *args)
  else
    raise ArgumentError, 'unimplmented format directive'
  end
end

# def tilde-a(s)
#   /^~(?<mincol>\d*),(?<colinc>\d*),(?<minpad>\d*),'(?<padchar>.)[aA]/ =~ s
# end
