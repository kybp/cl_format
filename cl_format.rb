require 'unicode_utils/char_name'
require_relative 'english_number'
require_relative 'roman_numeral'

module CLFormat
  class CLFormatter
    @@unescaped = /((?<!~)|(?<=~{2})+)/

    def next_arg(args)
      arg = args[:left].shift
      args[:used] << arg
      arg
    end

    def read_format_directive(string)
      return nil if string.empty? or string[0] != '~'
      raise 'unexpected end of format string' unless string.length > 1
      full   = string
      string = full[1..-1]
      args   = []
      loop do
        if string[0] == ','
          args << nil
          string = string[1..-1]
        elsif m = /\A([+-]?\d+),?/.match(string)
          args << m[1]
          string = m.post_match
        elsif m = /\A('.),?/.match(string)
          args << m[1]
          string = m.post_match
        elsif m = /\A(?<flags>(@:|:@|:|@)?)(?<directive>.)/m.match(string)
          return { args: args, flags: m[:flags], directive: m[:directive],
                   remaining: m.post_match }
        else
          raise "invalid format directive"
        end
      end
    end

    def flag_error(directive, expected, given)
      case expected
      when :no_flags
        raise "#{directive} does not take flags, given: #{given}"
      when :not_both
        raise "#{directive} does not take : and @ at the same time"
      else
        raise "#{directive} does not take a #{given} flag"
      end
    end

    def arg_error(directive, expected, given)
      raise "#{directive} expected #{expected}, given: #{given}"
    end

    def normalize_args(directive, input, spec)
      if input.length > spec.length
        raise "#{directive} takes at most #{spec.length} arguments, " +
              "given #{input.length}"
      end
      spec.map do |type, default|
        x = input.shift
        if x.nil?
          default
        else
          case type
          when :int
            arg_error(directive, :int, x) unless x =~ /^[+-]?\d+/
            x.to_i
          when :char
            if x.is_a?(String) and x =~ /^'(.)$/
              $1
            else
              arg_error(directive, :char, x)
            end
          end
        end
      end
    end

    def format_loop(args)
      while !(args[:string].nil? || args[:string].empty?)
        if d = read_format_directive(args[:string])
          args[:string] = d[:remaining]

          case d[:directive].downcase
          when 'c'
            if d[:args].empty?
              format_character(d[:flags].include?(':'),
                               d[:flags].include?('@'),
                               args)
            else
              raise "~C does not take arguments, given: #{d[:args]}"
            end

          when /[|%~]/
            if !d[:flags].empty?
              flag_error(d[:directive], :no_flags, d[:flags])
            else
              norm = normalize_args(d[:directive], d[:args], [[:int, 1]])
              repeat_char(d[:directive], norm[0], args)
            end

          when '&'
            if !d[:flags].empty?
              flag_error(d[:directive], :no_flags, d[:flags])
            else
              norm = normalize_args(d[:directive], d[:args], [[:int, 1]])
              fresh_line(norm[0], args)
            end

          when 'r'
            norm = normalize_args('r', d[:args],
                                  [[:int,  nil], [:int, 0], [:char, ' '],
                                   [:char, ','], [:int, 3]])
            if norm[0].nil?
              if d[:flags].include?('@')
                format_roman(d[:flags].include?(':'), args)
              else
                format_english(d[:flags].include?(':'), args)
              end
            else
              format_radix(*norm, d[:flags], args)
            end
          when /[dbox]/
            norm = normalize_args(d[:directive], d[:args],
                                  [[:int, 0], [:char, ' '], [:char, ','],
                                   [:int, 3]])
            radix = { 'd' => 10, 'b' => 2, 'o' => 8, 'x' => 16}[d[:directive]]
            format_radix(radix, *norm, d[:flags], args)
          when 'f'
            norm = normalize_args(d[:directive], d[:args],
                                  [[:int,  nil], [:int,  nil], [:int, 0],
                                   [:char, nil], [:char, ' ']])
            flag_error(d[:directive], '@', d[:flags]) if d[:flags].include?(':')
            format_fixed(*norm, d[:flags].include?('@'), args)
          when '$'
            norm = normalize_args(d[:directive], d[:args],
                                  [[:int, 2], [:int, 1], [:int, 0],
                                   [:char, ' ']])
            format_monetary(*norm, d[:flags], args)
          when /[as]/
            norm = normalize_args(d[:directive], d[:args],
                                  [[:int, 0], [:int, 1], [:int, 0],
                                   [:char, ' ']])
            flag_error(d[:directive], '@', d[:flags]) if d[:flags].include?(':')
            side = d[:flags].include?('@') ? :left : :right
            format_object(*norm, side, d[:directive], args)
          when '*'
            if d[:flags].include?('@') && d[:flags].include?(':')
              flag_error(d[:directive], :not_both, d[:flags])
            elsif d[:flags].include?('@')
              norm = normalize_args(d[:directive], d[:args], [[:int, 0]])
              goto_arg(norm[0], args)
            else
              norm = normalize_args(d[:directive], d[:args], [[:int, 1]])
              if d[:flags].include?(':')
                backward_arg(norm[0], args)
              else
                forward_arg(norm[0], args)
              end
            end
          when "\n"
            normalize_args('~\n', d[:args], [])
            if d[:flags].include?(':') && d[:flags].include?('@')
              flag_error('newline', :not_both, d[:flags])
            elsif d[:flags].include?(':')
            # keep space after newline, ie, do nothing
            elsif d[:flags].include?('@')
              args[:string].sub!(/\A\s*/, '')
              args[:acc] += "\n"
            else
              args[:string].sub!(/\A\s*/, '')
            end
          when '('
            normalize_args('~(', d[:args], [])
            convert_case(args[:string], d[:flags], args)
          when ')'
            raise 'unmatched "~)"'
          when 'p'
            normalize_args('~P', d[:args], [])
            backward_arg(1, args) if d[:flags].include?(':')
            format_plural(d[:flags].include?('@'), args)
          when '?'
            if d[:flags].include?(':')
              flag_error('~?', '@', ':')
            elsif d[:flags].empty?
              substr  = next_arg(args)
              subargs = next_arg(args)
              args[:acc] += substr.cl_format(*subargs)
            else
              substr = next_arg(args)
              args[:string] = substr + args[:string]
            end
          when '{'
            use_sublists = d[:flags].include?(':')
            use_all_args = d[:flags].include?('@')
            format_iteration(use_sublists, use_all_args, args)
          when '}'
            raise 'unmatched "~}"'
          when '^'
            args[:string] = nil if args[:left].empty?
          when '['
            if d[:flags].include?(':') and d[:flags].include?('@')
              flag_error('newline', :not_both, d[:flags])
            elsif d[:flags].include?(':')
              format_conditional(args)
            elsif d[:flags].include?('@')
              args[:string] = "~:[~;~:*#{args[:string]}"
            else
              norm = normalize_args('~[', d[:args], [[:int, nil]])
              format_indexed(norm[0], args)
            end
          when ']'
            raise 'unmatched "~]"'
          else
            raise "unimplemented format directive: ~#{d[:directive]}"
          end
        else
          str = args[:string]
          args.merge!(string: str[1..-1], acc: args[:acc] + str[0])
        end
      end
      args
    end

    def format_character(name_non_printing, at_sign, args)
      arg = next_arg(args)
      if !( arg.is_a?(String) && arg.length == 1)
        raise TypeError, "~C got #{arg}"
      end

      if at_sign and not name_non_printing
        args[:acc] += arg.inspect
      elsif name_non_printing and arg !~ /[[:graph:]]/
        args[:acc] += UnicodeUtils.char_name(arg).capitalize
      else
        args[:acc] += arg
      end
    end

    def repeat_char(char, times, args)
      c = { '|' => "\f", '%' => "\n", '~' => '~' }[char]
      args[:acc] += c * times
    end

    def fresh_line(times, args)
      return if times.zero?
      args[:acc] += "\n" if args[:acc][-1] != "\n"
      args[:acc] += "\n" * (times - 1)
    end

    def format_roman(old, args)
      n = next_arg(args)
      raise TypeError, 'Roman numeral not integer' unless n.is_a?(Fixnum)
      args[:acc] += roman_numeral(n, old ? :old : :new)
    end

    def format_english(ordinal, args)
      n = next_arg(args)
      raise TypeError, 'English number not integer' unless n.is_a?(Fixnum)
      args[:acc] += english_number(n, ordinal ? :ordinal : :cardinal)
    end

    def format_radix(radix, mincol, padchar, commachar, comma_interval,
                     flags, args)
      n = next_arg(args)
      raise TypeError, "~R got #{n.inspect}" unless n.is_a?(Fixnum)
      use_commas  = flags.include?(':')
      force_sign  = flags.include?('@')
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
      arg = next_arg(args)
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

    def format_monetary(d, n, w, padchar, flags, args)
      arg = next_arg(args)
      force_sign = flags.include?('@')
      if flags.include?(':')
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
      arg = next_arg(args)
      obj_str = case directive.downcase
                when 'a'; arg.to_s
                when 's'; arg.inspect
                end
      pad = padchar * minpad
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

    def convert_case(rest, flags, args)
      args[:string] = rest.sub(/(.*)#{@@unescaped}~\)/) do
        text = $1
        if flags.include?(':') && flags.include?('@')
          text.upcase
        elsif flags.include?(':')
          text.split.map(&:capitalize).join(' ')
        elsif flags.include?('@')
          text.downcase.sub(/[a-zA-Z]/, &:upcase)
        else
          text.downcase
        end
      end
    end

    def format_plural(y_word, args)
      n = next_arg(args)
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
          loop_args = next_arg(args)
          used = []
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

    def format_conditional(args)
      c = split_clauses(args[:string])
      clauses, after = c[:clauses], c[:after]
      arg = next_arg(args)
      args[:string] = "#{c[:clauses][arg ? 1 : 0]}#{c[:after]}"
    end

    def format_indexed(i, args)
      c = split_clauses(args[:string])
      clauses = c[:clauses]
      arg = next_arg(args) unless i
      raise TypeError, 'non-numeric index' unless i || arg.is_a?(Fixnum)
      clause = clauses[i || arg] || c[:default]
      args[:string] = "#{clause}#{c[:after]}"
    end

    def split_clauses(string)
      open    = /#{@@unescaped}~\[/
      close   = /#{@@unescaped}~\]/
      sep     = /#{@@unescaped}~:?;/
      clause  = /(?<clause>.*?(?<cond>#{open}.*?\g<cond>*#{close})*.*?)/
      finish  = /(?<finish>#{sep}|#{close})/
      clauses, default = [], nil
      get_default = false
      loop do
        if m = /#{clause}#{finish}/.match(string)
          clauses << m[:clause]
          if get_default
            default = m[:clause]
            get_default = false
          end
          if m[:finish] =~ close
            return { clauses: clauses, after: m.post_match, default: default }
          else
            get_default = m[:finish].include?(':')
            string = m.post_match
          end
        else
          raise 'unmatched ~['
        end
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
