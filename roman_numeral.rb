def roman_numeral(n, style=:new)
  if n <= 0 || style == :new && n >= 4000 || style == :old && n >= 5000
    raise ArgumentError, '#{n} out of range for Roman numeral'
  else
    roman_numeral_helper(n, style, '')
  end
end

def roman_numeral_helper(n, style, acc)
  if n >= 1000
    roman_numeral_helper(n - 1000, style, acc + 'M')
  elsif n >= 900 && style == :new
    roman_numeral_helper(n - 900,  style, acc + 'CM')
  elsif n >= 500
    roman_numeral_helper(n - 500,  style, acc + 'D')
  elsif n >= 400 && style == :new
    roman_numeral_helper(n - 400,  style, acc + 'CD')
  elsif n >= 100
    roman_numeral_helper(n - 100,  style, acc + 'C')
  elsif n >= 90  && style == :new
    roman_numeral_helper(n - 90,   style, acc + 'XC')
  elsif n >= 50
    roman_numeral_helper(n - 50,   style, acc + 'L')
  elsif n >= 40  && style == :new
    roman_numeral_helper(n - 40,   style, acc + 'XL')
  elsif n >= 10
    roman_numeral_helper(n - 10,   style, acc + 'X')
  elsif n >= 9   && style == :new
    roman_numeral_helper(n - 9,    style, acc + 'IX')
  elsif n >= 5
    roman_numeral_helper(n - 5,    style, acc + 'V')
  elsif n >= 4   && style == :new
    roman_numeral_helper(n - 4,    style, acc + 'IV')
  else
    n.times { acc += 'I' }
    acc
  end
end
