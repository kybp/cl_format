require_relative 'english_number'
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
    acc += "\n" * (match[:times].empty? ? 1 : match[:times].to_i)
    format_loop(match.post_match, acc, *args)
  else
    tilde_ampersand(s, acc, *args)
  end
end

def tilde_ampersand(s, acc, *args)
  if match = /^~(?<times>\d*)&/.match(s)
    times = match[:times].empty? ? 0 : match[:times].to_i - 1
    if match[:times] !~ /^0+$/
      acc += "\n" if acc[-1] != "\n"
      acc += "\n" * times
    end
    format_loop(match.post_match, acc, *args)
  else
    tilde_vertical_bar(s, acc, *args)
  end
end

def tilde_vertical_bar(s, acc, *args)
  if match = /^~(?<times>\d*)\|/.match(s)
    acc += "\f" * (match[:times].empty? ? 1 : match[:times].to_i)
    format_loop(match.post_match, acc, *args)
  else
    tilde_tilde(s, acc, *args)
  end
end

def tilde_tilde(s, acc, *args)
  if match = /^~(?<times>\d*)~/.match(s)
    acc += '~' * (match[:times].empty? ? 1 : match[:times].to_i)
    format_loop(match.post_match, acc, *args)
  else
    tilde_r_roman(s, acc, *args)
  end
end

def tilde_r_roman(s, acc, *args)
  if match = /^~(?<old>:?)@r/i.match(s)
    n = args.shift
    raise TypeError, 'Roman numeral not integer' unless n.is_a?(Integer)
    style = match[:old].empty? ? :new : :old
    format_loop(match.post_match, acc + roman_numeral(n, style), *args)
  else
    tilde_r_english(s, acc, *args)
  end
end

def tilde_r_english(s, acc, *args)
  if match = /^~(?<ordinal>:?)r/i.match(s)
    n = args.shift
    raise TypeError, 'English number not integer' unless n.is_a?(Integer)
    english = english_number(n, match[:ordinal].empty? ? :cardinal : :ordinal)
    format_loop(match.post_match, acc + english, *args)
  else
    tilde_r(s, acc, *args)
  end
end

def tilde_r(s, acc, *args)
  if match = /^~(?<radix>\d*)(,(?<mincol>\d*)(,('(?<padchar>.))?\
(,('(?<commachar>.))?(,(?<comma_interval>\d*))?)?)?)?(?<modifier>:?@?)r/i
             .match(s)
    if match[:radix].empty?
      simplified = "~#{match[:modifier]}r#{match.post_match}"
      if match[:modifier].include?('@')
        tilde_r_roman(simplified, acc, *args)
      else
        tilde_r_english(simplified, acc, *args)
      end
    else
      n = args.shift
      radix = match[:radix].to_i
      mincol = match[:mincol].to_i
      padchar = match[:padchar].nil? ? '' : match[:padchar]
      commachar =
        if match[:commachar].nil? || match[:commachar].empty?
          ','
        else
          match[:commachar]
        end
      comma_interval =
        if match[:comma_interval].nil? || match[:comma_interval].empty?
          3
        else
          match[:comma_interval].to_i
        end
      use_commas = match[:modifier].include?(':')
      force_sign = match[:modifier].include?('@')
      formatted = format_number(n, radix, mincol, padchar, commachar,
                                comma_interval, use_commas, force_sign)
      format_loop(match.post_match, acc + formatted, args)
    end
  else
    tilde_d(s, acc, *args)
  end
end

def format_number(n, radix, mincol, padchar, commachar,
                  comma_interval, use_commas, force_sign)
  result = []
  str = n.abs.to_s(radix).upcase
  str.reverse.split('').each_with_index do |x, i|
    result.unshift(x)
    if use_commas && (i + 1) % comma_interval == 0
      result.unshift(commachar) unless i + 1 == str.length
    end
  end
  result.unshift('+') if n >= 0 && force_sign
  result.unshift('-') if n <  0
  (padchar * [mincol - result.length, 0].max) + result.join
end

def tilde_d(s, acc, *args)
  if match = /^~(?<args>\d*(,.*?(,.*?(,.*?)?)?)?:?@?)d/.match(s)
    tilde_r("~10,#{match[:args]}r#{match.post_match}", acc, *args)
  else
    raise ArgumentError, 'unimplmented format directive'
  end
end
