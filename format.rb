require_relative 'english_number'
require_relative 'roman_numeral'

module CLFormat
  def format_loop(args)
    if args[:string].nil? || args[:string].empty?
      args[:acc]
    elsif args[:string][0] != '~'
      format_loop(args.merge(string: args[:string][1..-1],
                             acc: args[:acc] + args[:string][0]))
    else
      tilde_c(args)
    end
  end

  def tilde_c(args)
    # currently ignores options
    if match = /^~:?@?c/i.match(args[:string])
      arg = args[:left].shift
      args[:used] << arg
      if arg.is_a?(String) && arg.length == 1
        format_loop(args.merge(string: match.post_match,
                               acc: args[:acc] + arg))
      else
        raise ArgumentError, '~C requires a character'
      end
    else
      char_with_repeat(args)
    end
  end

  def char_with_repeat(args)
    if match = /^~(?<times>\d*)(?<directive>[|%~])/.match(args[:string])
      char = { '|' => "\f", '%' => "\n", '~' => '~' }[match[:directive]]
      args[:acc] += char * (match[:times].empty? ? 1 : match[:times].to_i)
      format_loop(args.merge(string: match.post_match))
    else
      tilde_ampersand(args)
    end
  end

  def tilde_ampersand(args)
    if match = /^~(?<times>\d*)&/.match(args[:string])
      times = match[:times].empty? ? 0 : match[:times].to_i - 1
      if match[:times] !~ /^0+$/
        args[:acc] += "\n" if args[:acc][-1] != "\n"
        args[:acc] += "\n" * times
      end
      format_loop(args.merge(string: match.post_match))
    else
      tilde_r_roman(args)
    end
  end

  def tilde_r_roman(args)
    if match = /^~(?<old>:?)@r/i.match(args[:string])
      n = args[:left].shift
      args[:used] << n
      raise TypeError, 'Roman numeral not integer' unless n.is_a?(Integer)
      style = match[:old].empty? ? :new : :old
      format_loop(args.merge(string: match.post_match,
                             acc: args[:acc] + roman_numeral(n, style)))
    else
      tilde_r_english(args)
    end
  end

  def tilde_r_english(args)
    if match = /^~(?<ordinal>:?)r/i.match(args[:string])
      n = args[:left].shift
      args[:used] << n
      raise TypeError, 'English number not integer' unless n.is_a?(Integer)
      english = english_number(n, match[:ordinal].empty? ? :cardinal : :ordinal)
      format_loop(args.merge(string: match.post_match,
                             acc: args[:acc] + english))
    else
      tilde_r(args)
    end
  end

  def tilde_r(args)
    if match = /^~(?<radix>\d*)(,(?<mincol>\d*)(,('(?<padchar>.))?\
(,('(?<commachar>.))?(,(?<comma_interval>\d*))?)?)?)?(?<modifier>:?@?)r/i
               .match(args[:string])
      if match[:radix].empty?
        simplified = "~#{match[:modifier]}r#{match.post_match}"
        if match[:modifier].include?('@')
          tilde_r_roman(args.merge(string: simplified))
        else
          tilde_r_english(args.merge(string: simplified))
        end
      else
        n = args[:left].shift
        args[:used] << n
        raise ArgumentError, '~R needs an integer' unless n.is_a?(Integer)
        radix = match[:radix].to_i
        mincol = match[:mincol].to_i
        padchar = match[:padchar].nil? ? ' ' : match[:padchar]
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
        formatted  = format_number(n, radix, mincol, padchar, commachar,
                                   comma_interval, use_commas, force_sign)
        format_loop(args.merge(string: match.post_match,
                               acc: args[:acc] + formatted))
      end
    else
      tilde_r_shortcuts(args)
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

  def tilde_r_shortcuts(args)
    if match = /^~(?<args>\d*(,('.)?(,('.)?(,\d*)?)?)?:?@?)\
(?<directive>[dbox])/i.match(args[:string])
      base = case match[:directive].downcase
             when 'd'; 10
             when 'b'; 2
             when 'o'; 8
             when 'x'; 16
             end
      tilde_r(args.
               merge(string: "~#{base},#{match[:args]}r#{match.post_match}"))
    else
      tilde_f(args)
    end
  end

  def given?(s)
    !(s.nil? || s.empty?)
  end

  def tilde_f(args)
    if match = /^~(?<w>\d*)(,(?<d>\d*)(,(?<k>\d*)\
(,('(?<overflowchar>.))?(,('(?<padchar>.))?)?)?)?)?\
(?<modifier>@?)f/i.match(args[:string])
      arg = args[:left].shift
      args[:used] << arg
      w = given?(match[:w]) ? match[:w].to_i : nil
      d = given?(match[:d]) ? match[:d].to_i : nil
      k = match[:k].to_i
      overflowchar = match[:overflowchar] || nil
      padchar      = match[:padchar]      || ' '
      force_sign   = match[:modifier].include?('@')
      format_flonum(arg.to_f, w, d, k, overflowchar, padchar, force_sign)
    else
      tilde_a_s(args)
    end
  end

  def format_flonum(arg, w, d, k, overflowchar, padchar, force_sign)
    return arg.to_s if w.nil? && d.nil?

    n = arg * 10 ** k
    c, m = n.to_i, (n % 1).to_f

    if c.zero? && w == d + 1
      result = m.to_s[1..-1]
      if result.length - 1 < w
        return result + '0' * (w - result.length)
      else
        return result[0..w]
      end
    end

    result = c.to_s + '.'
    result = '+' + result if force_sign && c >= 0

    if d
      m_str = m.round(d).to_s[2..-1] || ''
      result += "#{m_str}"
      result += '0' * [0, d - m_str.length].max
    else
      max_d = [0, w - result.length].max
      result += m.round(max_d).to_s[2..-1]
    end

    if result.length > w && overflowchar
      overflowchar * w
    else
      padchar * [0, w - result.length].max + result
    end
  end

  def tilde_a_s(args)
    if match = /^~(?<mincol>\d*)(,(?<colinc>\d*)(,(?<minpad>\d*)\
(,('(?<padchar>.))?)?)?)?(?<modifier>@?)(?<directive>[as])/i
               .match(args[:string])
      arg = args[:left].shift
      args[:used] << arg
      mincol    = match[:mincol].to_i
      colinc    = match[:colinc] ? match[:colinc].to_i : 1
      minpad    = match[:minpad].to_i
      padchar   = match[:padchar].nil? ? ' ' : match[:padchar]
      insert_on = match[:modifier].include?('@') ? :left : :right
      obj = match[:directive] =~ /[Aa]/ ? arg.to_s : arg.inspect
      format_object(obj, mincol, colinc, minpad, padchar, insert_on)
    else
      tilde_asterisk(args)
    end
  end

  def format_object(obj_str, mincol, colinc, minpad, padchar, insert_on)
    pad = padchar * minpad
    pad += padchar * colinc while obj_str.length + pad.length < mincol
    case insert_on
    when :left;  pad + obj_str
    when :right; obj_str + pad
    else raise ArgumentError, 'insert_on must be one of :left or :right'
    end
  end

  def tilde_asterisk(args)
    if match = /^~(?<count>\d*)\*/.match(args[:string])
      n = match[:count].empty? ? 1 : match[:count].to_i
      n.times { args[:used] << args[:left].shift }
      format_loop(args.merge(string: match.post_match))
    else
      tilde_colon_asterisk(args)
    end
  end

  def tilde_colon_asterisk(args)
    if match = /^~(?<count>\d*):\*/.match(args[:string])
      n = match[:count].empty? ? 1 : match[:count].to_i
      n.times { args[:left].unshift(args[:used].pop) }
      format_loop(args.merge(string: match.post_match))
    else
      tilde_at_asterisk(args)
    end
  end

  def tilde_at_asterisk(args)
    if match = /^~(?<index>\d*)@\*/.match(args[:string])
      i = match[:index].to_i
      all_args = args[:used] + args[:left]
      args[:used], args[:left] = all_args[0...i], all_args[i..-1]
      format_loop(args.merge(string: match.post_match))
    else
      tilde_newline(args)
    end
  end

  def tilde_newline(args)
    if match = /\A~\n\s*/m.match(args[:string])
      format_loop(args.merge(string: match.post_match))
    else
      tilde_at_newline(args)
    end
  end

  def tilde_at_newline(args)
    if match = /\A~@\n\s*/m.match(args[:string])
      format_loop(args.merge(string: match.post_match,
                             acc: args[:acc] + "\n"))
    else
      tilde_colon_newline(args)
    end
  end

  def tilde_colon_newline(args)
    if match = /\A~:\n/m.match(args[:string])
      format_loop(args.merge(string: match.post_match))
    else
      tilde_p(args)
    end
  end

  def tilde_p(args)
    if match = /^~p/i.match(args[:string])
      arg = args[:left].shift
      args[:used] << arg
      args[:acc] << 's' unless arg.to_i == 1
      format_loop(args.merge(string: match.post_match))
    else
      tilde_colon_p(args)
    end
  end

  def tilde_colon_p(args)
    if match = /^~:p/i.match(args[:string])
      tilde_colon_asterisk(args.merge(string: "~:*~p#{match.post_match}"))
    else
      tilde_at_p(args)
    end
  end

  def tilde_at_p(args)
    if match = /^~@p/i.match(args[:string])
      arg = args[:left].shift
      args[:used] << arg
      args[:acc] << (arg.to_i == 1 ? 'y' : 'ies')
      format_loop(args.merge(string: match.post_match))
    else
      tilde_colon_at_p(args)
    end
  end

  def tilde_colon_at_p(args)
    if match = /^~:@p/i.match(args[:string])
      tilde_colon_asterisk(args.merge(string: "~:*~@p#{match.post_match}"))
    else
      unimplimented(args)
    end
  end

  def unimplimented(args)
    raise ArgumentError, 'unimplmented format directive'
  end
end
