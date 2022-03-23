
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"bf",x"c3",x"cc",x"c2"),
     1 => (x"87",x"ca",x"e3",x"49"),
     2 => (x"cb",x"49",x"ee",x"cb"),
     3 => (x"a6",x"d0",x"87",x"fd"),
     4 => (x"e6",x"49",x"c7",x"58"),
     5 => (x"98",x"70",x"87",x"ff"),
     6 => (x"6e",x"87",x"c8",x"05"),
     7 => (x"02",x"99",x"c1",x"49"),
     8 => (x"c1",x"87",x"c3",x"c1"),
     9 => (x"7e",x"bf",x"ec",x"4b"),
    10 => (x"bf",x"c3",x"cc",x"c2"),
    11 => (x"87",x"e2",x"e2",x"49"),
    12 => (x"cb",x"49",x"66",x"cc"),
    13 => (x"98",x"70",x"87",x"e1"),
    14 => (x"c2",x"87",x"d8",x"02"),
    15 => (x"49",x"bf",x"fb",x"cb"),
    16 => (x"cb",x"c2",x"b9",x"c1"),
    17 => (x"fd",x"71",x"59",x"ff"),
    18 => (x"ee",x"cb",x"87",x"f8"),
    19 => (x"87",x"fb",x"ca",x"49"),
    20 => (x"c7",x"58",x"a6",x"d0"),
    21 => (x"87",x"fd",x"e5",x"49"),
    22 => (x"ff",x"05",x"98",x"70"),
    23 => (x"49",x"6e",x"87",x"c5"),
    24 => (x"fe",x"05",x"99",x"c1"),
    25 => (x"9b",x"73",x"87",x"fd"),
    26 => (x"ff",x"87",x"d0",x"02"),
    27 => (x"87",x"ca",x"fc",x"49"),
    28 => (x"e5",x"49",x"da",x"c1"),
    29 => (x"a6",x"c8",x"87",x"df"),
    30 => (x"c2",x"78",x"c1",x"48"),
    31 => (x"05",x"bf",x"c3",x"cc"),
    32 => (x"c3",x"87",x"e9",x"c0"),
    33 => (x"cc",x"e5",x"49",x"fd"),
    34 => (x"49",x"fa",x"c3",x"87"),
    35 => (x"74",x"87",x"c6",x"e5"),
    36 => (x"99",x"ff",x"c3",x"49"),
    37 => (x"49",x"c0",x"1e",x"71"),
    38 => (x"74",x"87",x"d9",x"fc"),
    39 => (x"29",x"b7",x"c8",x"49"),
    40 => (x"49",x"c1",x"1e",x"71"),
    41 => (x"c8",x"87",x"cd",x"fc"),
    42 => (x"87",x"f9",x"c7",x"86"),
    43 => (x"ff",x"c3",x"49",x"74"),
    44 => (x"2c",x"b7",x"c8",x"99"),
    45 => (x"9c",x"74",x"b4",x"71"),
    46 => (x"c2",x"87",x"dd",x"02"),
    47 => (x"49",x"bf",x"ff",x"cb"),
    48 => (x"70",x"87",x"d4",x"c9"),
    49 => (x"87",x"c4",x"05",x"98"),
    50 => (x"87",x"d2",x"4c",x"c0"),
    51 => (x"c8",x"49",x"e0",x"c2"),
    52 => (x"cc",x"c2",x"87",x"f9"),
    53 => (x"87",x"c6",x"58",x"c3"),
    54 => (x"48",x"ff",x"cb",x"c2"),
    55 => (x"49",x"74",x"78",x"c0"),
    56 => (x"ce",x"05",x"99",x"c2"),
    57 => (x"49",x"eb",x"c3",x"87"),
    58 => (x"70",x"87",x"ea",x"e3"),
    59 => (x"02",x"99",x"c2",x"49"),
    60 => (x"fb",x"87",x"c2",x"c0"),
    61 => (x"c1",x"49",x"74",x"4d"),
    62 => (x"87",x"ce",x"05",x"99"),
    63 => (x"e3",x"49",x"f4",x"c3"),
    64 => (x"49",x"70",x"87",x"d3"),
    65 => (x"c0",x"02",x"99",x"c2"),
    66 => (x"4d",x"fa",x"87",x"c2"),
    67 => (x"99",x"c8",x"49",x"74"),
    68 => (x"c3",x"87",x"cd",x"05"),
    69 => (x"fc",x"e2",x"49",x"f5"),
    70 => (x"c2",x"49",x"70",x"87"),
    71 => (x"87",x"d9",x"02",x"99"),
    72 => (x"bf",x"e9",x"de",x"c2"),
    73 => (x"87",x"ca",x"c0",x"02"),
    74 => (x"c2",x"88",x"c1",x"48"),
    75 => (x"c0",x"58",x"ed",x"de"),
    76 => (x"4d",x"ff",x"87",x"c2"),
    77 => (x"c1",x"48",x"a6",x"c8"),
    78 => (x"c4",x"49",x"74",x"78"),
    79 => (x"cd",x"c0",x"05",x"99"),
    80 => (x"49",x"f2",x"c3",x"87"),
    81 => (x"70",x"87",x"ce",x"e2"),
    82 => (x"02",x"99",x"c2",x"49"),
    83 => (x"de",x"c2",x"87",x"df"),
    84 => (x"48",x"7e",x"bf",x"e9"),
    85 => (x"03",x"a8",x"b7",x"c7"),
    86 => (x"6e",x"87",x"cb",x"c0"),
    87 => (x"c2",x"80",x"c1",x"48"),
    88 => (x"c0",x"58",x"ed",x"de"),
    89 => (x"4d",x"fe",x"87",x"c2"),
    90 => (x"c1",x"48",x"a6",x"c8"),
    91 => (x"49",x"fd",x"c3",x"78"),
    92 => (x"70",x"87",x"e2",x"e1"),
    93 => (x"02",x"99",x"c2",x"49"),
    94 => (x"c2",x"87",x"d8",x"c0"),
    95 => (x"02",x"bf",x"e9",x"de"),
    96 => (x"c2",x"87",x"c9",x"c0"),
    97 => (x"c0",x"48",x"e9",x"de"),
    98 => (x"87",x"c2",x"c0",x"78"),
    99 => (x"a6",x"c8",x"4d",x"fd"),
   100 => (x"c3",x"78",x"c1",x"48"),
   101 => (x"fc",x"e0",x"49",x"fa"),
   102 => (x"c2",x"49",x"70",x"87"),
   103 => (x"dc",x"c0",x"02",x"99"),
   104 => (x"e9",x"de",x"c2",x"87"),
   105 => (x"b7",x"c7",x"48",x"bf"),
   106 => (x"c9",x"c0",x"03",x"a8"),
   107 => (x"e9",x"de",x"c2",x"87"),
   108 => (x"c0",x"78",x"c7",x"48"),
   109 => (x"4d",x"fc",x"87",x"c2"),
   110 => (x"c1",x"48",x"a6",x"c8"),
   111 => (x"ad",x"b7",x"c0",x"78"),
   112 => (x"87",x"d0",x"c0",x"03"),
   113 => (x"c1",x"4a",x"66",x"c4"),
   114 => (x"02",x"6a",x"82",x"d8"),
   115 => (x"4b",x"87",x"c5",x"c0"),
   116 => (x"0f",x"73",x"49",x"75"),
   117 => (x"de",x"c2",x"4b",x"c0"),
   118 => (x"50",x"c0",x"48",x"e4"),
   119 => (x"c4",x"49",x"ee",x"cb"),
   120 => (x"a6",x"d0",x"87",x"e9"),
   121 => (x"e4",x"de",x"c2",x"58"),
   122 => (x"c1",x"05",x"bf",x"97"),
   123 => (x"49",x"74",x"87",x"de"),
   124 => (x"05",x"99",x"f0",x"c3"),
   125 => (x"c1",x"87",x"cd",x"c0"),
   126 => (x"df",x"ff",x"49",x"da"),
   127 => (x"98",x"70",x"87",x"d7"),
   128 => (x"87",x"c8",x"c1",x"02"),
   129 => (x"bf",x"e8",x"4b",x"c1"),
   130 => (x"ff",x"c3",x"49",x"4c"),
   131 => (x"2c",x"b7",x"c8",x"99"),
   132 => (x"cc",x"c2",x"b4",x"71"),
   133 => (x"ff",x"49",x"bf",x"c3"),
   134 => (x"cc",x"87",x"f7",x"da"),
   135 => (x"f6",x"c3",x"49",x"66"),
   136 => (x"02",x"98",x"70",x"87"),
   137 => (x"c2",x"87",x"c6",x"c0"),
   138 => (x"c1",x"48",x"e4",x"de"),
   139 => (x"e4",x"de",x"c2",x"50"),
   140 => (x"c0",x"05",x"bf",x"97"),
   141 => (x"49",x"74",x"87",x"d6"),
   142 => (x"05",x"99",x"f0",x"c3"),
   143 => (x"c1",x"87",x"c5",x"ff"),
   144 => (x"de",x"ff",x"49",x"da"),
   145 => (x"98",x"70",x"87",x"cf"),
   146 => (x"87",x"f8",x"fe",x"05"),
   147 => (x"c0",x"02",x"9b",x"73"),
   148 => (x"a6",x"cc",x"87",x"e0"),
   149 => (x"e9",x"de",x"c2",x"48"),
   150 => (x"66",x"cc",x"78",x"bf"),
   151 => (x"c4",x"91",x"cb",x"49"),
   152 => (x"80",x"71",x"48",x"66"),
   153 => (x"bf",x"6e",x"7e",x"70"),
   154 => (x"87",x"c6",x"c0",x"02"),
   155 => (x"49",x"66",x"cc",x"4b"),
   156 => (x"66",x"c8",x"0f",x"73"),
   157 => (x"87",x"c8",x"c0",x"02"),
   158 => (x"bf",x"e9",x"de",x"c2"),
   159 => (x"87",x"d5",x"f2",x"49"),
   160 => (x"bf",x"c7",x"cc",x"c2"),
   161 => (x"87",x"dd",x"c0",x"02"),
   162 => (x"87",x"cb",x"c2",x"49"),
   163 => (x"c0",x"02",x"98",x"70"),
   164 => (x"de",x"c2",x"87",x"d3"),
   165 => (x"f1",x"49",x"bf",x"e9"),
   166 => (x"49",x"c0",x"87",x"fb"),
   167 => (x"c2",x"87",x"db",x"f3"),
   168 => (x"c0",x"48",x"c7",x"cc"),
   169 => (x"f2",x"8e",x"f0",x"78"),
   170 => (x"5e",x"0e",x"87",x"f5"),
   171 => (x"0e",x"5d",x"5c",x"5b"),
   172 => (x"c2",x"4c",x"71",x"1e"),
   173 => (x"49",x"bf",x"e5",x"de"),
   174 => (x"4d",x"a1",x"cd",x"c1"),
   175 => (x"69",x"81",x"d1",x"c1"),
   176 => (x"02",x"9c",x"74",x"7e"),
   177 => (x"a5",x"c4",x"87",x"cf"),
   178 => (x"c2",x"7b",x"74",x"4b"),
   179 => (x"49",x"bf",x"e5",x"de"),
   180 => (x"6e",x"87",x"d4",x"f2"),
   181 => (x"05",x"9c",x"74",x"7b"),
   182 => (x"4b",x"c0",x"87",x"c4"),
   183 => (x"4b",x"c1",x"87",x"c2"),
   184 => (x"d5",x"f2",x"49",x"73"),
   185 => (x"02",x"66",x"d4",x"87"),
   186 => (x"de",x"49",x"87",x"c7"),
   187 => (x"c2",x"4a",x"70",x"87"),
   188 => (x"c2",x"4a",x"c0",x"87"),
   189 => (x"26",x"5a",x"cb",x"cc"),
   190 => (x"00",x"87",x"e4",x"f1"),
   191 => (x"00",x"00",x"00",x"00"),
   192 => (x"00",x"00",x"00",x"00"),
   193 => (x"00",x"00",x"00",x"00"),
   194 => (x"1e",x"00",x"00",x"00"),
   195 => (x"c8",x"ff",x"4a",x"71"),
   196 => (x"a1",x"72",x"49",x"bf"),
   197 => (x"1e",x"4f",x"26",x"48"),
   198 => (x"89",x"bf",x"c8",x"ff"),
   199 => (x"c0",x"c0",x"c0",x"fe"),
   200 => (x"01",x"a9",x"c0",x"c0"),
   201 => (x"4a",x"c0",x"87",x"c4"),
   202 => (x"4a",x"c1",x"87",x"c2"),
   203 => (x"4f",x"26",x"48",x"72"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;

