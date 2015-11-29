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
      tilde_percent(args)
    end
  end

  def tilde_percent(args)
    if match = /^~(?<times>\d*)%/.match(args[:string])
      args[:acc] += "\n" * (match[:times].empty? ? 1 : match[:times].to_i)
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
      tilde_vertical_bar(args)
    end
  end

  def tilde_vertical_bar(args)
    if match = /^~(?<times>\d*)\|/.match(args[:string])
      args[:acc] += "\f" * (match[:times].empty? ? 1 : match[:times].to_i)
      format_loop(args.merge(string: match.post_match))
    else
      tilde_tilde(args)
    end
  end

  def tilde_tilde(args)
    if match = /^~(?<times>\d*)~/.match(args[:string])
      args[:acc] += '~' * (match[:times].empty? ? 1 : match[:times].to_i)
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
        formatted = format_number(n, radix, mincol, padchar, commachar,
                                  comma_interval, use_commas, force_sign)
        format_loop(args.merge(string: match.post_match,
                               acc: args[:acc] + formatted))
      end
    else
      tilde_d(args)
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

  def tilde_d(args)
    if match = /^~(?<args>\d*(,.*?(,.*?(,.*?)?)?)?:?@?)d/.match(args[:string])
      tilde_r(args.merge(string: "~10,#{match[:args]}r#{match.post_match}"))
    else
      tilde_b(args)
    end
  end

  def tilde_b(args)
    if match = /^~(?<args>\d*(,.*?(,.*?(,.*?)?)?)?:?@?)b/.match(args[:string])
      tilde_r(args.merge(string: "~2,#{match[:args]}r#{match.post_match}"))
    else
      tilde_o(args)
    end
  end

  def tilde_o(args)
    if match = /^~(?<args>\d*(,.*?(,.*?(,.*?)?)?)?:?@?)o/.match(args[:string])
      tilde_r(args.merge(string: "~8,#{match[:args]}r#{match.post_match}"))
    else
      tilde_x(args)
    end
  end

  def tilde_x(args)
    if match = /^~(?<args>\d*(,.*?(,.*?(,.*?)?)?)?:?@?)x/.match(args[:string])
      tilde_r(args.merge(string: "~16,#{match[:args]}r#{match.post_match}"))
    else
      tilde_asterisk(args)
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
