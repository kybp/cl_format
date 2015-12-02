require 'test_helper'

class EnglishNumberTest < MiniTest::Test
  def test_bad_type
    assert_raises(ArgumentError) { english_number(1, :english) }
  end

  def test_upper_limit
    assert_raises(ArgumentError) do
      english_number(1000000000000000000000000000000000, :cardinal)
    end
  end

  def test_max
    assert_equal("nine nonillion nine hundred ninety-nine octillion nine hundred ninety-nine septillion nine hundred ninety-nine sextillion nine hundred ninety-nine quintillion nine hundred ninety-nine quadrillion nine hundred ninety-nine trillion nine hundred ninety-nine billion nine hundred ninety-nine million nine hundred ninety-nine thousand nine hundred ninety-nine",
                 english_number(9999999999999999999999999999999, :cardinal))
  end

  def test_1_ordinal
    assert_equal('first', english_number(1, :ordinal))
  end

  def test_2_ordinal
    assert_equal('second', english_number(2, :ordinal))
  end

  def test_3_ordinal
    assert_equal('third', english_number(3, :ordinal))
  end

  def test_4_ordinal
    assert_equal('fourth', english_number(4, :ordinal))
  end

  def test_5_ordinal
    assert_equal('fifth', english_number(5, :ordinal))
  end

  def test_adding_th
    assert_equal('sixth', english_number(6, :ordinal))
  end

  def test_8_ordinal
    assert_equal('eighth', english_number(8, :ordinal))
  end

  def test_9_ordinal
    assert_equal('ninth', english_number(9, :ordinal))
  end

  def test_12_ordinal
    assert_equal('twelfth', english_number(12, :ordinal))
  end

  def test_1_cardinal
    assert_equal('one', english_number(1, :cardinal))
  end

  def test_2_cardinal
    assert_equal('two', english_number(2, :cardinal))
  end

  def test_3_cardinal
    assert_equal('three', english_number(3, :cardinal))
  end

  def test_4_cardinal
    assert_equal('four', english_number(4, :cardinal))
  end

  def test_5_cardinal
    assert_equal('five', english_number(5, :cardinal))
  end

  def test_6_cardinal
    assert_equal('six', english_number(6, :cardinal))
  end

  def test_7_cardinal
    assert_equal('seven', english_number(7, :cardinal))
  end

  def test_8_cardinal
    assert_equal('eight', english_number(8, :cardinal))
  end

  def test_9_cardinal
    assert_equal('nine', english_number(9, :cardinal))
  end

  def test_10_cardinal
    assert_equal('ten', english_number(10, :cardinal))
  end

  def test_11_cardinal
    assert_equal('eleven', english_number(11, :cardinal))
  end

  def test_12_cardinal
    assert_equal('twelve', english_number(12, :cardinal))
  end

  def test_13_cardinal
    assert_equal('thirteen', english_number(13, :cardinal))
  end

  def test_14_cardinal
    assert_equal('fourteen', english_number(14, :cardinal))
  end

  def test_15_cardinal
    assert_equal('fifteen', english_number(15, :cardinal))
  end

  def test_16_cardinal
    assert_equal('sixteen', english_number(16, :cardinal))
  end

  def test_17_cardinal
    assert_equal('seventeen', english_number(17, :cardinal))
  end

  def test_18_cardinal
    assert_equal('eighteen', english_number(18, :cardinal))
  end

  def test_19_cardinal
    assert_equal('nineteen', english_number(19, :cardinal))
  end

  def test_20_cardinal
    assert_equal('twenty', english_number(20, :cardinal))
  end

  def test_30_cardinal
    assert_equal('thirty', english_number(30, :cardinal))
  end

  def test_40_cardinal
    assert_equal('forty', english_number(40, :cardinal))
  end

  def test_50_cardinal
    assert_equal('fifty', english_number(50, :cardinal))
  end

  def test_60_cardinal
    assert_equal('sixty', english_number(60, :cardinal))
  end

  def test_70_cardinal
    assert_equal('seventy', english_number(70, :cardinal))
  end

  def test_80_cardinal
    assert_equal('eighty', english_number(80, :cardinal))
  end

  def test_90_cardinal
    assert_equal('ninety', english_number(90, :cardinal))
  end
end
