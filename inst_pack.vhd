--This is autogenerated file. If hand modified, it may be accidentally over written!
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package inst_pack is
	constant memory_depth : positive  := 10;
	type data_array is array (2**memory_depth-1 downto 0) of std_logic_vector(7 downto 0);
	constant memory_byte_0 : data_array :=
	(
		   0=>x"13",   1=>x"23",   2=>x"23",   3=>x"23",   4=>x"23",   5=>x"23",   6=>x"37",   7=>x"37",
		   8=>x"13",   9=>x"EF",  10=>x"13",  11=>x"EF",  12=>x"03",  13=>x"93",  14=>x"EF",  15=>x"13",
		  16=>x"EF",  17=>x"83",  18=>x"93",  19=>x"23",  20=>x"6F",  21=>x"B7",  22=>x"83",  23=>x"33",
		  24=>x"63",  25=>x"37",  26=>x"83",  27=>x"E3",  28=>x"37",  29=>x"83",  30=>x"E3",  31=>x"67",
		  32=>x"B7",  33=>x"03",  34=>x"63",  35=>x"67",  36=>x"83",  37=>x"93",  38=>x"E3",  39=>x"23",
		  40=>x"13",  41=>x"6F",  42=>x"93",  43=>x"B7",  44=>x"13",  45=>x"13",  46=>x"03",  47=>x"13",
		  48=>x"63",  49=>x"63",  50=>x"67",  51=>x"03",  52=>x"33",  53=>x"13",  54=>x"23",  55=>x"6F",
		  56=>x"13",  57=>x"13",  58=>x"93",  59=>x"93",  60=>x"B7",  61=>x"63",  62=>x"67",  63=>x"13",
		  64=>x"93",  65=>x"B3",  66=>x"B3",  67=>x"93",  68=>x"13",  69=>x"63",  70=>x"13",  71=>x"83",
		  72=>x"93",  73=>x"E3",  74=>x"23",  75=>x"6F",  76=>x"13",  77=>x"23",  78=>x"EF",  79=>x"55",
		  80=>x"3A",  81=>x"0A",
		others => (others => '0')
	);
	constant memory_byte_1 : data_array :=
	(
		   0=>x"01",   1=>x"2C",   2=>x"2A",   3=>x"28",   4=>x"26",   5=>x"2E",   6=>x"29",   7=>x"34",
		   8=>x"05",   9=>x"00",  10=>x"05",  11=>x"00",  12=>x"25",  13=>x"05",  14=>x"00",  15=>x"05",
		  16=>x"00",  17=>x"27",  18=>x"C7",  19=>x"20",  20=>x"F0",  21=>x"17",  22=>x"A7",  23=>x"85",
		  24=>x"78",  25=>x"17",  26=>x"27",  27=>x"6E",  28=>x"17",  29=>x"27",  30=>x"EE",  31=>x"80",
		  32=>x"26",  33=>x"47",  34=>x"14",  35=>x"80",  36=>x"C7",  37=>x"F7",  38=>x"8C",  39=>x"80",
		  40=>x"05",  41=>x"F0",  42=>x"07",  43=>x"26",  44=>x"05",  45=>x"06",  46=>x"C7",  47=>x"77",
		  48=>x"14",  49=>x"44",  50=>x"80",  51=>x"C8",  52=>x"87",  53=>x"05",  54=>x"00",  55=>x"F0",
		  56=>x"98",  57=>x"07",  58=>x"95",  59=>x"08",  60=>x"26",  61=>x"14",  62=>x"80",  63=>x"07",
		  64=>x"17",  65=>x"07",  66=>x"57",  67=>x"F7",  68=>x"86",  69=>x"E4",  70=>x"86",  71=>x"C7",
		  72=>x"F7",  73=>x"8C",  74=>x"80",  75=>x"F0",  76=>x"01",  77=>x"26",  78=>x"F0",  79=>x"61",
		  80=>x"20",  81=>x"00",
		others => (others => '0')
	);
	constant memory_byte_2 : data_array :=
	(
		   0=>x"01",   1=>x"81",   2=>x"91",   3=>x"21",   4=>x"31",   5=>x"11",   6=>x"00",   7=>x"00",
		   8=>x"80",   9=>x"00",  10=>x"C0",  11=>x"40",  12=>x"49",  13=>x"40",  14=>x"80",  15=>x"40",
		  16=>x"00",  17=>x"04",  18=>x"F7",  19=>x"F4",  20=>x"1F",  21=>x"00",  22=>x"07",  23=>x"A7",
		  24=>x"F5",  25=>x"00",  26=>x"07",  27=>x"F5",  28=>x"00",  29=>x"07",  30=>x"A7",  31=>x"00",
		  32=>x"00",  33=>x"05",  34=>x"07",  35=>x"00",  36=>x"26",  37=>x"F7",  38=>x"07",  39=>x"E6",
		  40=>x"15",  41=>x"1F",  42=>x"05",  43=>x"00",  44=>x"00",  45=>x"10",  46=>x"16",  47=>x"F7",
		  48=>x"C7",  49=>x"B5",  50=>x"00",  51=>x"06",  52=>x"A7",  53=>x"15",  54=>x"07",  55=>x"DF",
		  56=>x"35",  57=>x"00",  58=>x"15",  59=>x"90",  60=>x"00",  61=>x"B7",  62=>x"00",  63=>x"17",
		  64=>x"27",  65=>x"F8",  66=>x"F5",  67=>x"F7",  68=>x"77",  69=>x"F8",  70=>x"07",  71=>x"26",
		  72=>x"F7",  73=>x"07",  74=>x"C6",  75=>x"9F",  76=>x"01",  77=>x"11",  78=>x"9F",  79=>x"72",
		  80=>x"00",  81=>x"00",
		others => (others => '0')
	);
	constant memory_byte_3 : data_array :=
	(
		   0=>x"FE",   1=>x"00",   2=>x"00",   3=>x"01",   4=>x"01",   5=>x"00",   6=>x"00",   7=>x"00",
		   8=>x"3E",   9=>x"03",  10=>x"13",  11=>x"05",  12=>x"00",  13=>x"00",  14=>x"0A",  15=>x"14",
		  16=>x"04",  17=>x"00",  18=>x"FF",  19=>x"00",  20=>x"FD",  21=>x"00",  22=>x"00",  23=>x"00",
		  24=>x"00",  25=>x"00",  26=>x"00",  27=>x"FE",  28=>x"00",  29=>x"00",  30=>x"FE",  31=>x"00",
		  32=>x"00",  33=>x"00",  34=>x"00",  35=>x"00",  36=>x"00",  37=>x"0F",  38=>x"FE",  39=>x"00",
		  40=>x"00",  41=>x"FE",  42=>x"00",  43=>x"00",  44=>x"00",  45=>x"00",  46=>x"00",  47=>x"0F",
		  48=>x"00",  49=>x"00",  50=>x"00",  51=>x"00",  52=>x"00",  53=>x"00",  54=>x"01",  55=>x"FD",
		  56=>x"00",  57=>x"00",  58=>x"00",  59=>x"00",  60=>x"00",  61=>x"00",  62=>x"00",  63=>x"00",
		  64=>x"00",  65=>x"40",  66=>x"00",  67=>x"00",  68=>x"03",  69=>x"00",  70=>x"03",  71=>x"00",
		  72=>x"0F",  73=>x"FE",  74=>x"00",  75=>x"FC",  76=>x"FF",  77=>x"00",  78=>x"EC",  79=>x"74",
		  80=>x"00",  81=>x"00",
		others => (others => '0')
	);
end inst_pack;
