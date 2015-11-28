def english_number(n, style)
  (n < 0 ? 'negative ' : '') +
    case style
    when :ordinal;  ordinal_number(n.abs)
    when :cardinal; cardinal_number(n.abs)
    else raise ArgumentError
    end
end

def cardinal_factor(n, name, factor)
  cardinal_number(n / factor) + " #{name}" + cardinal_number(n % factor, ' ')
end

def cardinal_number(n, prefix='')
  return prefix.empty? ? 'zero' : '' if n.zero?

  prefix + if false
  elsif n >= 1_000_000_000_000_000_000_000_000_000_000
    cardinal_factor(n, 'nonillion',   1_000_000_000_000_000_000_000_000_000_000)
  elsif n >= 1_000_000_000_000_000_000_000_000_000
    cardinal_factor(n, 'octillion',   1_000_000_000_000_000_000_000_000_000)
  elsif n >= 1_000_000_000_000_000_000_000_000
    cardinal_factor(n, 'septillion',  1_000_000_000_000_000_000_000_000)
  elsif n >= 1_000_000_000_000_000_000_000
    cardinal_factor(n, 'sextillion',  1_000_000_000_000_000_000_000)
  elsif n >= 1_000_000_000_000_000_000
    cardinal_factor(n, 'quintillion', 1_000_000_000_000_000_000)
  elsif n >= 1_000_000_000_000_000
    cardinal_factor(n, 'quadrillion', 1_000_000_000_000_000)
  elsif n >= 1_000_000_000_000
    cardinal_factor(n, 'trillion',    1_000_000_000_000)
  elsif n >= 1_000_000_000
    cardinal_factor(n, 'billion',     1_000_000_000)
  elsif n >= 1_000_000
    cardinal_factor(n, 'million',     1_000_000)
  elsif n >= 1000
    cardinal_factor(n, 'thousand',    1000)
  elsif n >= 100
    cardinal_factor(n, 'hundred',     100)
  elsif n >= 20
    simple_cardinal(n / 10 * 10) + simple_cardinal(n % 10, '-')
  else
    simple_cardinal(n)
  end
end

def simple_cardinal(n, prefix='')
  if n.zero?
    ''
  else
    prefix + case n
             when  1; 'one'
             when  2; 'two'
             when  3; 'three'
             when  4; 'four'
             when  5; 'five'
             when  6; 'six'
             when  7; 'seven'
             when  8; 'eight'
             when  9; 'nine'
             when 10; 'ten'
             when 11; 'eleven'
             when 12; 'twelve'
             when 13; 'thirteen'
             when 14; 'fourteen'
             when 15; 'fifteen'
             when 16; 'sixteen'
             when 17; 'seventeen'
             when 18; 'eighteen'
             when 19; 'nineteen'
             when 20; 'twenty'
             when 30; 'thirty'
             when 40; 'forty'
             when 50; 'fifty'
             when 60; 'sixty'
             when 70; 'seventy'
             when 80; 'eighty'
             when 90; 'ninety'
             else raise ArgumentError
             end
  end
end

def ordinal_number(n)
  case n
  when 1; 'first'
  when 2; 'second'
  when 3; 'third'
  when 4; 'fourth'
  when 5; 'fifth'
  when 8; 'eighth'
  when 9; 'ninth'
  when 12; 'twelfth'
  else
    if n > 10 && n < 100 && n % 10 == 0
      simple_cardinal(n)[0..-2] + 'ieth'
    elsif n >= 20 && n < 100
      simple_cardinal(n / 10 * 10) + '-' + ordinal_number(n % 10)
    elsif n > 100
      rem = n % 100
      cardinal_number(n / 100 * 100) +
        (rem.zero? ? 'th' : ' ' + ordinal_number(rem))
    else
      cardinal_number(n) + 'th'
    end
  end
end
