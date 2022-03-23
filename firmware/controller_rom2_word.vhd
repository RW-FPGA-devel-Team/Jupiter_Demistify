library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic	(
	ADDR_WIDTH : integer := 8; -- ROM's address width (words, not bytes)
	COL_WIDTH  : integer := 8;  -- Column width (8bit -> byte)
	NB_COL     : integer := 4  -- Number of columns in memory
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

architecture arch of controller_rom2 is

-- type word_t is std_logic_vector(31 downto 0);
type ram_type is array (0 to 2 ** ADDR_WIDTH - 1) of std_logic_vector(NB_COL * COL_WIDTH - 1 downto 0);

signal ram : ram_type :=
(

     0 => x"bfc3ccc2",
     1 => x"87cae349",
     2 => x"cb49eecb",
     3 => x"a6d087fd",
     4 => x"e649c758",
     5 => x"987087ff",
     6 => x"6e87c805",
     7 => x"0299c149",
     8 => x"c187c3c1",
     9 => x"7ebfec4b",
    10 => x"bfc3ccc2",
    11 => x"87e2e249",
    12 => x"cb4966cc",
    13 => x"987087e1",
    14 => x"c287d802",
    15 => x"49bffbcb",
    16 => x"cbc2b9c1",
    17 => x"fd7159ff",
    18 => x"eecb87f8",
    19 => x"87fbca49",
    20 => x"c758a6d0",
    21 => x"87fde549",
    22 => x"ff059870",
    23 => x"496e87c5",
    24 => x"fe0599c1",
    25 => x"9b7387fd",
    26 => x"ff87d002",
    27 => x"87cafc49",
    28 => x"e549dac1",
    29 => x"a6c887df",
    30 => x"c278c148",
    31 => x"05bfc3cc",
    32 => x"c387e9c0",
    33 => x"cce549fd",
    34 => x"49fac387",
    35 => x"7487c6e5",
    36 => x"99ffc349",
    37 => x"49c01e71",
    38 => x"7487d9fc",
    39 => x"29b7c849",
    40 => x"49c11e71",
    41 => x"c887cdfc",
    42 => x"87f9c786",
    43 => x"ffc34974",
    44 => x"2cb7c899",
    45 => x"9c74b471",
    46 => x"c287dd02",
    47 => x"49bfffcb",
    48 => x"7087d4c9",
    49 => x"87c40598",
    50 => x"87d24cc0",
    51 => x"c849e0c2",
    52 => x"ccc287f9",
    53 => x"87c658c3",
    54 => x"48ffcbc2",
    55 => x"497478c0",
    56 => x"ce0599c2",
    57 => x"49ebc387",
    58 => x"7087eae3",
    59 => x"0299c249",
    60 => x"fb87c2c0",
    61 => x"c149744d",
    62 => x"87ce0599",
    63 => x"e349f4c3",
    64 => x"497087d3",
    65 => x"c00299c2",
    66 => x"4dfa87c2",
    67 => x"99c84974",
    68 => x"c387cd05",
    69 => x"fce249f5",
    70 => x"c2497087",
    71 => x"87d90299",
    72 => x"bfe9dec2",
    73 => x"87cac002",
    74 => x"c288c148",
    75 => x"c058edde",
    76 => x"4dff87c2",
    77 => x"c148a6c8",
    78 => x"c4497478",
    79 => x"cdc00599",
    80 => x"49f2c387",
    81 => x"7087cee2",
    82 => x"0299c249",
    83 => x"dec287df",
    84 => x"487ebfe9",
    85 => x"03a8b7c7",
    86 => x"6e87cbc0",
    87 => x"c280c148",
    88 => x"c058edde",
    89 => x"4dfe87c2",
    90 => x"c148a6c8",
    91 => x"49fdc378",
    92 => x"7087e2e1",
    93 => x"0299c249",
    94 => x"c287d8c0",
    95 => x"02bfe9de",
    96 => x"c287c9c0",
    97 => x"c048e9de",
    98 => x"87c2c078",
    99 => x"a6c84dfd",
   100 => x"c378c148",
   101 => x"fce049fa",
   102 => x"c2497087",
   103 => x"dcc00299",
   104 => x"e9dec287",
   105 => x"b7c748bf",
   106 => x"c9c003a8",
   107 => x"e9dec287",
   108 => x"c078c748",
   109 => x"4dfc87c2",
   110 => x"c148a6c8",
   111 => x"adb7c078",
   112 => x"87d0c003",
   113 => x"c14a66c4",
   114 => x"026a82d8",
   115 => x"4b87c5c0",
   116 => x"0f734975",
   117 => x"dec24bc0",
   118 => x"50c048e4",
   119 => x"c449eecb",
   120 => x"a6d087e9",
   121 => x"e4dec258",
   122 => x"c105bf97",
   123 => x"497487de",
   124 => x"0599f0c3",
   125 => x"c187cdc0",
   126 => x"dfff49da",
   127 => x"987087d7",
   128 => x"87c8c102",
   129 => x"bfe84bc1",
   130 => x"ffc3494c",
   131 => x"2cb7c899",
   132 => x"ccc2b471",
   133 => x"ff49bfc3",
   134 => x"cc87f7da",
   135 => x"f6c34966",
   136 => x"02987087",
   137 => x"c287c6c0",
   138 => x"c148e4de",
   139 => x"e4dec250",
   140 => x"c005bf97",
   141 => x"497487d6",
   142 => x"0599f0c3",
   143 => x"c187c5ff",
   144 => x"deff49da",
   145 => x"987087cf",
   146 => x"87f8fe05",
   147 => x"c0029b73",
   148 => x"a6cc87e0",
   149 => x"e9dec248",
   150 => x"66cc78bf",
   151 => x"c491cb49",
   152 => x"80714866",
   153 => x"bf6e7e70",
   154 => x"87c6c002",
   155 => x"4966cc4b",
   156 => x"66c80f73",
   157 => x"87c8c002",
   158 => x"bfe9dec2",
   159 => x"87d5f249",
   160 => x"bfc7ccc2",
   161 => x"87ddc002",
   162 => x"87cbc249",
   163 => x"c0029870",
   164 => x"dec287d3",
   165 => x"f149bfe9",
   166 => x"49c087fb",
   167 => x"c287dbf3",
   168 => x"c048c7cc",
   169 => x"f28ef078",
   170 => x"5e0e87f5",
   171 => x"0e5d5c5b",
   172 => x"c24c711e",
   173 => x"49bfe5de",
   174 => x"4da1cdc1",
   175 => x"6981d1c1",
   176 => x"029c747e",
   177 => x"a5c487cf",
   178 => x"c27b744b",
   179 => x"49bfe5de",
   180 => x"6e87d4f2",
   181 => x"059c747b",
   182 => x"4bc087c4",
   183 => x"4bc187c2",
   184 => x"d5f24973",
   185 => x"0266d487",
   186 => x"de4987c7",
   187 => x"c24a7087",
   188 => x"c24ac087",
   189 => x"265acbcc",
   190 => x"0087e4f1",
   191 => x"00000000",
   192 => x"00000000",
   193 => x"00000000",
   194 => x"1e000000",
   195 => x"c8ff4a71",
   196 => x"a17249bf",
   197 => x"1e4f2648",
   198 => x"89bfc8ff",
   199 => x"c0c0c0fe",
   200 => x"01a9c0c0",
   201 => x"4ac087c4",
   202 => x"4ac187c2",
   203 => x"4f264872",
  others => ( x"00000000")
);

-- Xilinx Vivado attributes
attribute ram_style: string;
attribute ram_style of ram: signal is "block";

signal q_local : std_logic_vector((NB_COL * COL_WIDTH)-1 downto 0);

signal wea : std_logic_vector(NB_COL - 1 downto 0);

begin

	output:
	for i in 0 to NB_COL - 1 generate
		q((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH) <= q_local((i+1) * COL_WIDTH - 1 downto i * COL_WIDTH);
	end generate;
    
    -- Generate write enable signals
    -- The Block ram generator doesn't like it when the compare is done in the if statement it self.
    wea <= bytesel when we = '1' else (others => '0');

    process(clk)
    begin
        if rising_edge(clk) then
            q_local <= ram(to_integer(unsigned(addr)));
            for i in 0 to NB_COL - 1 loop
                if (wea(NB_COL-i-1) = '1') then
                    ram(to_integer(unsigned(addr)))((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH) <= d((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH);
                end if;
            end loop;
        end if;
    end process;

end arch;
