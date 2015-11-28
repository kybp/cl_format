def english_number(n)
  (n < 0 ? 'negative ' : '') + ordinal_number(n)
end

def ordinal_factor(n, name, factor)
  ordinal_number(n / factor) + " #{name}" + ordinal_number(n % factor, ' ')
end

def ordinal_number(n, prefix='')
  return prefix.empty? ? 'zero' : '' if n.zero?

  prefix + if false
  elsif n >= 1_000_000_000_000_000_000_000_000_000_000
    ordinal_factor(n, 'nonillion',   1_000_000_000_000_000_000_000_000_000_000)
  elsif n >= 1_000_000_000_000_000_000_000_000_000
    ordinal_factor(n, 'octillion',   1_000_000_000_000_000_000_000_000_000)
  elsif n >= 1_000_000_000_000_000_000_000_000
    ordinal_factor(n, 'septillion',  1_000_000_000_000_000_000_000_000)
  elsif n >= 1_000_000_000_000_000_000_000
    ordinal_factor(n, 'sextillion',  1_000_000_000_000_000_000_000)
  elsif n >= 1_000_000_000_000_000_000
    ordinal_factor(n, 'quintillion', 1_000_000_000_000_000_000)
  elsif n >= 1_000_000_000_000_000
    ordinal_factor(n, 'quadrillion', 1_000_000_000_000_000)
  elsif n >= 1_000_000_000_000
    ordinal_factor(n, 'trillion',    1_000_000_000_000)
  elsif n >= 1_000_000_000
    ordinal_factor(n, 'billion',     1_000_000_000)
  elsif n >= 1_000_000
    ordinal_factor(n, 'million',     1_000_000)
  elsif n >= 1000
    ordinal_factor(n, 'thousand',    1000)
  elsif n >= 100
    ordinal_factor(n, 'hundred',     100)
  elsif n >= 20
    simple_ordinal(n / 10 * 10) + simple_ordinal(n % 10, '-')
  else
    simple_ordinal(n)
  end
end

def simple_ordinal(n, prefix='')
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
