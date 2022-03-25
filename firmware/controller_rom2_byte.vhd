
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

     0 => (x"cb",x"49",x"ee",x"cb"),
     1 => (x"a6",x"d0",x"87",x"fd"),
     2 => (x"e6",x"49",x"c7",x"58"),
     3 => (x"98",x"70",x"87",x"ff"),
     4 => (x"6e",x"87",x"c8",x"05"),
     5 => (x"02",x"99",x"c1",x"49"),
     6 => (x"c1",x"87",x"c3",x"c1"),
     7 => (x"7e",x"bf",x"ec",x"4b"),
     8 => (x"bf",x"fb",x"cb",x"c2"),
     9 => (x"87",x"e2",x"e2",x"49"),
    10 => (x"cb",x"49",x"66",x"cc"),
    11 => (x"98",x"70",x"87",x"e1"),
    12 => (x"c2",x"87",x"d8",x"02"),
    13 => (x"49",x"bf",x"f3",x"cb"),
    14 => (x"cb",x"c2",x"b9",x"c1"),
    15 => (x"fd",x"71",x"59",x"f7"),
    16 => (x"ee",x"cb",x"87",x"f8"),
    17 => (x"87",x"fb",x"ca",x"49"),
    18 => (x"c7",x"58",x"a6",x"d0"),
    19 => (x"87",x"fd",x"e5",x"49"),
    20 => (x"ff",x"05",x"98",x"70"),
    21 => (x"49",x"6e",x"87",x"c5"),
    22 => (x"fe",x"05",x"99",x"c1"),
    23 => (x"9b",x"73",x"87",x"fd"),
    24 => (x"ff",x"87",x"d0",x"02"),
    25 => (x"87",x"ca",x"fc",x"49"),
    26 => (x"e5",x"49",x"da",x"c1"),
    27 => (x"a6",x"c8",x"87",x"df"),
    28 => (x"c2",x"78",x"c1",x"48"),
    29 => (x"05",x"bf",x"fb",x"cb"),
    30 => (x"c3",x"87",x"e9",x"c0"),
    31 => (x"cc",x"e5",x"49",x"fd"),
    32 => (x"49",x"fa",x"c3",x"87"),
    33 => (x"74",x"87",x"c6",x"e5"),
    34 => (x"99",x"ff",x"c3",x"49"),
    35 => (x"49",x"c0",x"1e",x"71"),
    36 => (x"74",x"87",x"d9",x"fc"),
    37 => (x"29",x"b7",x"c8",x"49"),
    38 => (x"49",x"c1",x"1e",x"71"),
    39 => (x"c8",x"87",x"cd",x"fc"),
    40 => (x"87",x"f9",x"c7",x"86"),
    41 => (x"ff",x"c3",x"49",x"74"),
    42 => (x"2c",x"b7",x"c8",x"99"),
    43 => (x"9c",x"74",x"b4",x"71"),
    44 => (x"c2",x"87",x"dd",x"02"),
    45 => (x"49",x"bf",x"f7",x"cb"),
    46 => (x"70",x"87",x"d4",x"c9"),
    47 => (x"87",x"c4",x"05",x"98"),
    48 => (x"87",x"d2",x"4c",x"c0"),
    49 => (x"c8",x"49",x"e0",x"c2"),
    50 => (x"cb",x"c2",x"87",x"f9"),
    51 => (x"87",x"c6",x"58",x"fb"),
    52 => (x"48",x"f7",x"cb",x"c2"),
    53 => (x"49",x"74",x"78",x"c0"),
    54 => (x"ce",x"05",x"99",x"c2"),
    55 => (x"49",x"eb",x"c3",x"87"),
    56 => (x"70",x"87",x"ea",x"e3"),
    57 => (x"02",x"99",x"c2",x"49"),
    58 => (x"fb",x"87",x"c2",x"c0"),
    59 => (x"c1",x"49",x"74",x"4d"),
    60 => (x"87",x"ce",x"05",x"99"),
    61 => (x"e3",x"49",x"f4",x"c3"),
    62 => (x"49",x"70",x"87",x"d3"),
    63 => (x"c0",x"02",x"99",x"c2"),
    64 => (x"4d",x"fa",x"87",x"c2"),
    65 => (x"99",x"c8",x"49",x"74"),
    66 => (x"c3",x"87",x"cd",x"05"),
    67 => (x"fc",x"e2",x"49",x"f5"),
    68 => (x"c2",x"49",x"70",x"87"),
    69 => (x"87",x"d9",x"02",x"99"),
    70 => (x"bf",x"e1",x"de",x"c2"),
    71 => (x"87",x"ca",x"c0",x"02"),
    72 => (x"c2",x"88",x"c1",x"48"),
    73 => (x"c0",x"58",x"e5",x"de"),
    74 => (x"4d",x"ff",x"87",x"c2"),
    75 => (x"c1",x"48",x"a6",x"c8"),
    76 => (x"c4",x"49",x"74",x"78"),
    77 => (x"cd",x"c0",x"05",x"99"),
    78 => (x"49",x"f2",x"c3",x"87"),
    79 => (x"70",x"87",x"ce",x"e2"),
    80 => (x"02",x"99",x"c2",x"49"),
    81 => (x"de",x"c2",x"87",x"df"),
    82 => (x"48",x"7e",x"bf",x"e1"),
    83 => (x"03",x"a8",x"b7",x"c7"),
    84 => (x"6e",x"87",x"cb",x"c0"),
    85 => (x"c2",x"80",x"c1",x"48"),
    86 => (x"c0",x"58",x"e5",x"de"),
    87 => (x"4d",x"fe",x"87",x"c2"),
    88 => (x"c1",x"48",x"a6",x"c8"),
    89 => (x"49",x"fd",x"c3",x"78"),
    90 => (x"70",x"87",x"e2",x"e1"),
    91 => (x"02",x"99",x"c2",x"49"),
    92 => (x"c2",x"87",x"d8",x"c0"),
    93 => (x"02",x"bf",x"e1",x"de"),
    94 => (x"c2",x"87",x"c9",x"c0"),
    95 => (x"c0",x"48",x"e1",x"de"),
    96 => (x"87",x"c2",x"c0",x"78"),
    97 => (x"a6",x"c8",x"4d",x"fd"),
    98 => (x"c3",x"78",x"c1",x"48"),
    99 => (x"fc",x"e0",x"49",x"fa"),
   100 => (x"c2",x"49",x"70",x"87"),
   101 => (x"dc",x"c0",x"02",x"99"),
   102 => (x"e1",x"de",x"c2",x"87"),
   103 => (x"b7",x"c7",x"48",x"bf"),
   104 => (x"c9",x"c0",x"03",x"a8"),
   105 => (x"e1",x"de",x"c2",x"87"),
   106 => (x"c0",x"78",x"c7",x"48"),
   107 => (x"4d",x"fc",x"87",x"c2"),
   108 => (x"c1",x"48",x"a6",x"c8"),
   109 => (x"ad",x"b7",x"c0",x"78"),
   110 => (x"87",x"d0",x"c0",x"03"),
   111 => (x"c1",x"4a",x"66",x"c4"),
   112 => (x"02",x"6a",x"82",x"d8"),
   113 => (x"4b",x"87",x"c5",x"c0"),
   114 => (x"0f",x"73",x"49",x"75"),
   115 => (x"de",x"c2",x"4b",x"c0"),
   116 => (x"50",x"c0",x"48",x"dc"),
   117 => (x"c4",x"49",x"ee",x"cb"),
   118 => (x"a6",x"d0",x"87",x"e9"),
   119 => (x"dc",x"de",x"c2",x"58"),
   120 => (x"c1",x"05",x"bf",x"97"),
   121 => (x"49",x"74",x"87",x"de"),
   122 => (x"05",x"99",x"f0",x"c3"),
   123 => (x"c1",x"87",x"cd",x"c0"),
   124 => (x"df",x"ff",x"49",x"da"),
   125 => (x"98",x"70",x"87",x"d7"),
   126 => (x"87",x"c8",x"c1",x"02"),
   127 => (x"bf",x"e8",x"4b",x"c1"),
   128 => (x"ff",x"c3",x"49",x"4c"),
   129 => (x"2c",x"b7",x"c8",x"99"),
   130 => (x"cb",x"c2",x"b4",x"71"),
   131 => (x"ff",x"49",x"bf",x"fb"),
   132 => (x"cc",x"87",x"f7",x"da"),
   133 => (x"f6",x"c3",x"49",x"66"),
   134 => (x"02",x"98",x"70",x"87"),
   135 => (x"c2",x"87",x"c6",x"c0"),
   136 => (x"c1",x"48",x"dc",x"de"),
   137 => (x"dc",x"de",x"c2",x"50"),
   138 => (x"c0",x"05",x"bf",x"97"),
   139 => (x"49",x"74",x"87",x"d6"),
   140 => (x"05",x"99",x"f0",x"c3"),
   141 => (x"c1",x"87",x"c5",x"ff"),
   142 => (x"de",x"ff",x"49",x"da"),
   143 => (x"98",x"70",x"87",x"cf"),
   144 => (x"87",x"f8",x"fe",x"05"),
   145 => (x"c0",x"02",x"9b",x"73"),
   146 => (x"a6",x"cc",x"87",x"e0"),
   147 => (x"e1",x"de",x"c2",x"48"),
   148 => (x"66",x"cc",x"78",x"bf"),
   149 => (x"c4",x"91",x"cb",x"49"),
   150 => (x"80",x"71",x"48",x"66"),
   151 => (x"bf",x"6e",x"7e",x"70"),
   152 => (x"87",x"c6",x"c0",x"02"),
   153 => (x"49",x"66",x"cc",x"4b"),
   154 => (x"66",x"c8",x"0f",x"73"),
   155 => (x"87",x"c8",x"c0",x"02"),
   156 => (x"bf",x"e1",x"de",x"c2"),
   157 => (x"87",x"d5",x"f2",x"49"),
   158 => (x"bf",x"ff",x"cb",x"c2"),
   159 => (x"87",x"dd",x"c0",x"02"),
   160 => (x"87",x"cb",x"c2",x"49"),
   161 => (x"c0",x"02",x"98",x"70"),
   162 => (x"de",x"c2",x"87",x"d3"),
   163 => (x"f1",x"49",x"bf",x"e1"),
   164 => (x"49",x"c0",x"87",x"fb"),
   165 => (x"c2",x"87",x"db",x"f3"),
   166 => (x"c0",x"48",x"ff",x"cb"),
   167 => (x"f2",x"8e",x"f0",x"78"),
   168 => (x"5e",x"0e",x"87",x"f5"),
   169 => (x"0e",x"5d",x"5c",x"5b"),
   170 => (x"c2",x"4c",x"71",x"1e"),
   171 => (x"49",x"bf",x"dd",x"de"),
   172 => (x"4d",x"a1",x"cd",x"c1"),
   173 => (x"69",x"81",x"d1",x"c1"),
   174 => (x"02",x"9c",x"74",x"7e"),
   175 => (x"a5",x"c4",x"87",x"cf"),
   176 => (x"c2",x"7b",x"74",x"4b"),
   177 => (x"49",x"bf",x"dd",x"de"),
   178 => (x"6e",x"87",x"d4",x"f2"),
   179 => (x"05",x"9c",x"74",x"7b"),
   180 => (x"4b",x"c0",x"87",x"c4"),
   181 => (x"4b",x"c1",x"87",x"c2"),
   182 => (x"d5",x"f2",x"49",x"73"),
   183 => (x"02",x"66",x"d4",x"87"),
   184 => (x"de",x"49",x"87",x"c7"),
   185 => (x"c2",x"4a",x"70",x"87"),
   186 => (x"c2",x"4a",x"c0",x"87"),
   187 => (x"26",x"5a",x"c3",x"cc"),
   188 => (x"00",x"87",x"e4",x"f1"),
   189 => (x"00",x"00",x"00",x"00"),
   190 => (x"00",x"00",x"00",x"00"),
   191 => (x"00",x"00",x"00",x"00"),
   192 => (x"1e",x"00",x"00",x"00"),
   193 => (x"c8",x"ff",x"4a",x"71"),
   194 => (x"a1",x"72",x"49",x"bf"),
   195 => (x"1e",x"4f",x"26",x"48"),
   196 => (x"89",x"bf",x"c8",x"ff"),
   197 => (x"c0",x"c0",x"c0",x"fe"),
   198 => (x"01",x"a9",x"c0",x"c0"),
   199 => (x"4a",x"c0",x"87",x"c4"),
   200 => (x"4a",x"c1",x"87",x"c2"),
   201 => (x"4f",x"26",x"48",x"72"),
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

