require_relative 'english_number'
require_relative 'roman_numeral'

module CLFormat
  class CLFormatter
    @@unescaped = /((?<!~)|(?<=~{2})+)/

    def given?(s)
      !(s.nil? || s.empty?)
    end

    def format_loop(args)
      modifiers = /(?<modifiers>(@:|:@|:|@)?)/
      while given?(args[:string])
        if m = /^~#{modifiers}[Cc]/.match(args[:string])
          # TODO: add modifier support
          args[:string] = m.post_match
          format_character(args)

        elsif m = /^~(?<n>\d*)(?<directive>[|%~])/.match(args[:string])
          args[:string] = m.post_match
          repeat_char(m[:directive], m[:n], args)

        elsif m = /^~(?<n>\d*)&/.match(args[:string])
          args[:string] = m.post_match
          fresh_line(m[:n], args)

        elsif m = /^~(?<old>:?)@r/.match(args[:string])
          args[:string] = m.post_match
          format_roman(m[:old].empty?, args)

        elsif m = /^~(?<cardinal>:?)r/.match(args[:string])
          args[:string] = m.post_match
          format_english(m[:cardinal].empty?, args)

        elsif m = /^~(?<r>\d*)(,(?<m>\d*)(,('(?<p>.))?(,('(?<cc>.))?(,(?<ci>\d*))?)?)?)?#{modifiers}[Rr]/.match(args[:string])
          # If no radix is specified, the other arguments are meaningless
          if m[:r].empty?
            args[:string] = "~#{m[:modifiers]}r#{m.post_match}"
          else
            args[:string] = m.post_match
            format_radix(m[:r], m[:m], m[:p], m[:cc], m[:ci],
                         m[:modifiers], args)
          end

        elsif m = /^~(?<args>\d*(,('.)?(,('.)?(,\d*)?)?)?#{modifiers})(?<directive>[dbox])/i.match(args[:string])
          radix = { 'd' => 10, 'b' => 2, 'o' => 8, 'x' => 16}[m[:directive]]
          args[:string] = "~#{radix},#{m[:args]}r#{m.post_match}"

        elsif m = /^~(?<w>\d*)(,(?<d>\d*)(,(?<k>\d*)(,('(?<overflowchar>.))?(,('(?<padchar>.))?)?)?)?)?(?<modifier>@?)f/.match(args[:string])
          args[:string] = m.post_match
          format_fixed(m[:w], m[:d], m[:k], m[:overflowchar],
                       m[:padchar], m[:modifier] == '@', args)

        elsif m = /^~(?<d>\d*)(,(?<n>\d*)(,(?<w>\d*)(,('(?<padchar>.))?)?)?)?#{modifiers}\$/.match(args[:string])
          args[:string] = m.post_match
          format_monetary(m[:d], m[:n], m[:w], m[:padchar],
                          m[:modifiers], args)

        elsif m = /^~(?<mc>\d*)(,(?<ci>\d*)(,(?<mp>\d*)(,('(?<pc>.))?)?)?)?(?<on_left>@?)(?<directive>[as])/i.match(args[:string])
          args[:string] = m.post_match
          format_object(m[:mc], m[:ci], m[:mp], m[:pc],
                        m[:on_left].empty? ? :right : :left, m[:directive],
                        args)

        elsif m = /^~(?<n>\d*)\*/.match(args[:string])
          args[:string] = m.post_match
          forward_arg(m[:n].empty? ? 1 : m[:n].to_i, args)

        elsif m = /^~(?<n>\d*):\*/.match(args[:string])
          args[:string] = m.post_match
          backward_arg(m[:n].empty? ? 1 : m[:n].to_i, args)

        elsif m = /^~(?<i>\d*)@\*/.match(args[:string])
          args[:string] = m.post_match
          goto_arg(m[:i].to_i, args)

        elsif m = /\A~\n\s*/m.match(args[:string])
          args[:string] = m.post_match

        elsif m = /\A~:\n/m.match(args[:string])
          args[:string] = m.post_match

        elsif m = /\A~@\n\s*/m.match(args[:string])
          args[:string] = m.post_match
          args[:acc] += "\n"

        elsif m = /^~#{modifiers}\(/.match(args[:string])
          convert_case(m.post_match, m[:modifiers], args)

        elsif /^~\)/.match(args[:string])
          raise 'unmatched "~)"'

        elsif m = /^~#{modifiers}[Pp]/.match(args[:string])
          args[:string] = m.post_match
          backward_arg(1, args) if m[:modifiers].include?(':')
          format_plural(m[:modifiers].include?('@'), args)

        elsif m = /^~\?/.match(args[:string])
          args[:string] = m.post_match
          substr = args[:left].shift
          args[:used] << substr
          subargs = args[:left].shift
          args[:used] << subargs
          args[:acc] += substr.cl_format(*subargs)

        elsif m = /^~@\?/.match(args[:string])
          substr = args[:left].shift
          args[:used] << substr
          args[:string] = substr + m.post_match

        elsif m = /^~#{modifiers}{/.match(args[:string])
          args[:string] = m.post_match
          use_sublists = m[:modifiers].include?(':')
          use_all_args = m[:modifiers].include?('@')
          format_iteration(use_sublists, use_all_args, args)

        elsif /^~:?}/.match(args[:string])
          raise 'unmatched "~}"'

        elsif m = /^~\^/.match(args[:string])
          args[:string] = args[:left].empty? ? nil : m.post_match

        elsif /^~/.match(args[:string])
          raise "unimplemented format directive at start of: #{args[:string]}"

        else
          str = args[:string]
          args.merge!(string: str[1..-1], acc: args[:acc] + str[0])
        end
      end
      args
    end

    def format_character(args)
      # currently ignores options
      arg = args[:left].shift
      args[:used] << arg
      if arg.is_a?(String) && arg.length == 1
        args[:acc] += arg
      else
        raise TypeError, "~C got #{arg}"
      end
    end

    def repeat_char(char, times, args)
      c = { '|' => "\f", '%' => "\n", '~' => '~' }[char]
      args[:acc] += c * (times.empty? ? 1 : times.to_i)
    end

    def fresh_line(times, args)
      return args if times =~ /^0+$/
      args[:acc] += "\n" if args[:acc][-1] != "\n"
      args[:acc] += "\n" * (times.empty? ? 0 : times.to_i - 1)
    end

    def format_roman(new, args)
      n = args[:left].shift
      args[:used] << n
      raise TypeError, 'Roman numeral not integer' unless n.is_a?(Integer)
      args[:acc] += roman_numeral(n, new ? :new : :old)
    end

    def format_english(cardinal, args)
      n = args[:left].shift
      args[:used] << n
      raise TypeError, 'English number not integer' unless n.is_a?(Integer)
      args[:acc] += english_number(n, cardinal ? :cardinal : :ordinal)
    end

    def format_radix(radix, mincol, padchar, commachar, comma_interval,
                     modifiers, args)
      n = args[:left].shift
      args[:used] << n
      raise TypeError, "~R got #{n}" unless n.is_a?(Integer)
      radix          = radix.to_i
      mincol         = mincol.to_i
      padchar        = padchar.nil? ? ' ' : padchar
      commachar      = given?(commachar) ? commachar : ','
      comma_interval = given?(comma_interval) ? comma_interval.to_i : 3
      use_commas     = modifiers.include?(':')
      force_sign     = modifiers.include?('@')
      args[:acc] += format_int(n, radix, mincol, padchar, commachar,
                               comma_interval, use_commas, force_sign)
    end

    def format_int(n, radix, mincol, padchar, commachar,
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

    def format_fixed(w, d, k, overflowchar, padchar, force_sign, args)
      arg = args[:left].shift
      args[:used] << arg
      w = given?(w) ? w.to_i : nil
      d = given?(d) ? d.to_i : nil
      overflowchar ||= overflowchar
      padchar      ||= ' '
      args[:acc] += format_flonum(arg.to_f, 0, w, d, k.to_i, overflowchar,
                                  padchar, force_sign)
    end

    def format_flonum(arg, n, w, d, k, overflowchar, padchar, force_sign)
      return arg.to_s if w.nil? && d.nil?

      scaled = arg * 10 ** k
      c, m = scaled.to_i, (scaled % 1).to_f

      if c.zero? && w == d + 1
        result = m.to_s[1..-1]
        if result.length - 1 < w
          return result + '0' * (w - result.length)
        else
          return result[0..w]
        end
      end

      result = c.to_s
      result = '0' * [0, n - result.length].max + "#{result}."
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

    def format_monetary(d, n, w, padchar, modifiers, args)
      arg = args[:left].shift
      args[:used] << arg
      d = given?(d) ? d.to_i : 2
      n = given?(n) ? n.to_i : 1
      w = w.to_i
      padchar ||= ' '
      force_sign = modifiers.include?('@')
      if modifiers.include?(':')
        f = arg.to_f
        sign = f < 0 ? '-' : force_sign ? '+' : ''
        formatted = format_flonum(f, n, [0, w - 1].max, d, 0, nil,
                                  padchar, false)
        args[:acc] += sign + formatted
      else
        formatted = format_flonum(arg.to_f, n, w, d, 0, nil,
                                  padchar, force_sign)
        args[:acc] += formatted
      end
    end

    def format_object(mincol, colinc, minpad, padchar, side, directive, args)
      arg = args[:left].shift
      args[:used] << arg
      obj_str = case directive.downcase
                when 'a'; arg.to_s
                when 's'; arg.inspect
                end
      mincol = mincol.to_i
      colinc = colinc ? colinc.to_i : 1
      padchar ||= ' '
      pad = padchar * minpad.to_i
      pad += padchar * colinc while obj_str.length + pad.length < mincol
      args[:acc] += case side
                    when :left;  pad + obj_str
                    when :right; obj_str + pad
                    end
    end

    def forward_arg(n, args)
      n.times { args[:used] << args[:left].shift }
    end

    def backward_arg(n, args)
      n.times { args[:left].unshift(args[:used].pop) }
    end

    def goto_arg(i, args)
      all_args = args[:used] + args[:left]
      args[:used], args[:left] = all_args[0...i], all_args[i..-1]
    end

    def convert_case(rest, modifiers, args)
      args[:string] = rest.sub(/(.*)#{@@unescaped}~\)/) do
        text = $1
        if modifiers.include?(':') && modifiers.include?('@')
          text.upcase
        elsif modifiers.include?(':')
          text.split.map(&:capitalize).join(' ')
        elsif modifiers.include?('@')
          text.downcase.sub(/[a-zA-Z]/, &:upcase)
        else
          text.downcase
        end
      end
    end

    def format_plural(y_word, args)
      n = args[:left].shift
      args[:used] << n
      singular, plural = y_word ? ['y', 'ies'] : ['', 's']
      args[:acc] += (n.to_i == 1 ? singular : plural)
    end

    def format_iteration(use_sublists, use_all_args, args)
      if m = /(?<body>.*)#{@@unescaped}~(?<once>:?)}/.match(args[:string])
        args[:string] = m.post_match
        no_force = m[:once].empty?
        if use_all_args
          loop_args, used = args[:left], args[:used]
        else
          loop_args, used = args[:left].shift, []
          args[:used] << loop_args
        end
        left = loop_args
        until left.empty? && no_force
          no_force = true
          if use_sublists && !left[0].is_a?(Array)
            raise TypeError, "~:{ expected Array and got: #{left[0]}"
          else
            given = use_sublists ? left[0] : left
          end
          formatted = format_loop(string: m[:body], used: used,
                                  left: given, acc: '')
          used = formatted[:used]
          left = use_sublists ? left.drop(1) : formatted[:left]
          args[:acc] += formatted[:acc]
        end
        args[:used], args[:left] = used, left if use_all_args
      else
        raise 'unmatched ~{'
      end
    end
  end

  def cl_format(*args)
    c = CLFormatter.new
    result = c.format_loop(string: self, acc: '', used: [], left: args)
    result[:acc]
  end
end

class String
  include CLFormat
end
