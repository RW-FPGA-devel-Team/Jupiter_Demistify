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

     0 => x"cb49eecb",
     1 => x"a6d087fd",
     2 => x"e649c758",
     3 => x"987087ff",
     4 => x"6e87c805",
     5 => x"0299c149",
     6 => x"c187c3c1",
     7 => x"7ebfec4b",
     8 => x"bffbcbc2",
     9 => x"87e2e249",
    10 => x"cb4966cc",
    11 => x"987087e1",
    12 => x"c287d802",
    13 => x"49bff3cb",
    14 => x"cbc2b9c1",
    15 => x"fd7159f7",
    16 => x"eecb87f8",
    17 => x"87fbca49",
    18 => x"c758a6d0",
    19 => x"87fde549",
    20 => x"ff059870",
    21 => x"496e87c5",
    22 => x"fe0599c1",
    23 => x"9b7387fd",
    24 => x"ff87d002",
    25 => x"87cafc49",
    26 => x"e549dac1",
    27 => x"a6c887df",
    28 => x"c278c148",
    29 => x"05bffbcb",
    30 => x"c387e9c0",
    31 => x"cce549fd",
    32 => x"49fac387",
    33 => x"7487c6e5",
    34 => x"99ffc349",
    35 => x"49c01e71",
    36 => x"7487d9fc",
    37 => x"29b7c849",
    38 => x"49c11e71",
    39 => x"c887cdfc",
    40 => x"87f9c786",
    41 => x"ffc34974",
    42 => x"2cb7c899",
    43 => x"9c74b471",
    44 => x"c287dd02",
    45 => x"49bff7cb",
    46 => x"7087d4c9",
    47 => x"87c40598",
    48 => x"87d24cc0",
    49 => x"c849e0c2",
    50 => x"cbc287f9",
    51 => x"87c658fb",
    52 => x"48f7cbc2",
    53 => x"497478c0",
    54 => x"ce0599c2",
    55 => x"49ebc387",
    56 => x"7087eae3",
    57 => x"0299c249",
    58 => x"fb87c2c0",
    59 => x"c149744d",
    60 => x"87ce0599",
    61 => x"e349f4c3",
    62 => x"497087d3",
    63 => x"c00299c2",
    64 => x"4dfa87c2",
    65 => x"99c84974",
    66 => x"c387cd05",
    67 => x"fce249f5",
    68 => x"c2497087",
    69 => x"87d90299",
    70 => x"bfe1dec2",
    71 => x"87cac002",
    72 => x"c288c148",
    73 => x"c058e5de",
    74 => x"4dff87c2",
    75 => x"c148a6c8",
    76 => x"c4497478",
    77 => x"cdc00599",
    78 => x"49f2c387",
    79 => x"7087cee2",
    80 => x"0299c249",
    81 => x"dec287df",
    82 => x"487ebfe1",
    83 => x"03a8b7c7",
    84 => x"6e87cbc0",
    85 => x"c280c148",
    86 => x"c058e5de",
    87 => x"4dfe87c2",
    88 => x"c148a6c8",
    89 => x"49fdc378",
    90 => x"7087e2e1",
    91 => x"0299c249",
    92 => x"c287d8c0",
    93 => x"02bfe1de",
    94 => x"c287c9c0",
    95 => x"c048e1de",
    96 => x"87c2c078",
    97 => x"a6c84dfd",
    98 => x"c378c148",
    99 => x"fce049fa",
   100 => x"c2497087",
   101 => x"dcc00299",
   102 => x"e1dec287",
   103 => x"b7c748bf",
   104 => x"c9c003a8",
   105 => x"e1dec287",
   106 => x"c078c748",
   107 => x"4dfc87c2",
   108 => x"c148a6c8",
   109 => x"adb7c078",
   110 => x"87d0c003",
   111 => x"c14a66c4",
   112 => x"026a82d8",
   113 => x"4b87c5c0",
   114 => x"0f734975",
   115 => x"dec24bc0",
   116 => x"50c048dc",
   117 => x"c449eecb",
   118 => x"a6d087e9",
   119 => x"dcdec258",
   120 => x"c105bf97",
   121 => x"497487de",
   122 => x"0599f0c3",
   123 => x"c187cdc0",
   124 => x"dfff49da",
   125 => x"987087d7",
   126 => x"87c8c102",
   127 => x"bfe84bc1",
   128 => x"ffc3494c",
   129 => x"2cb7c899",
   130 => x"cbc2b471",
   131 => x"ff49bffb",
   132 => x"cc87f7da",
   133 => x"f6c34966",
   134 => x"02987087",
   135 => x"c287c6c0",
   136 => x"c148dcde",
   137 => x"dcdec250",
   138 => x"c005bf97",
   139 => x"497487d6",
   140 => x"0599f0c3",
   141 => x"c187c5ff",
   142 => x"deff49da",
   143 => x"987087cf",
   144 => x"87f8fe05",
   145 => x"c0029b73",
   146 => x"a6cc87e0",
   147 => x"e1dec248",
   148 => x"66cc78bf",
   149 => x"c491cb49",
   150 => x"80714866",
   151 => x"bf6e7e70",
   152 => x"87c6c002",
   153 => x"4966cc4b",
   154 => x"66c80f73",
   155 => x"87c8c002",
   156 => x"bfe1dec2",
   157 => x"87d5f249",
   158 => x"bfffcbc2",
   159 => x"87ddc002",
   160 => x"87cbc249",
   161 => x"c0029870",
   162 => x"dec287d3",
   163 => x"f149bfe1",
   164 => x"49c087fb",
   165 => x"c287dbf3",
   166 => x"c048ffcb",
   167 => x"f28ef078",
   168 => x"5e0e87f5",
   169 => x"0e5d5c5b",
   170 => x"c24c711e",
   171 => x"49bfddde",
   172 => x"4da1cdc1",
   173 => x"6981d1c1",
   174 => x"029c747e",
   175 => x"a5c487cf",
   176 => x"c27b744b",
   177 => x"49bfddde",
   178 => x"6e87d4f2",
   179 => x"059c747b",
   180 => x"4bc087c4",
   181 => x"4bc187c2",
   182 => x"d5f24973",
   183 => x"0266d487",
   184 => x"de4987c7",
   185 => x"c24a7087",
   186 => x"c24ac087",
   187 => x"265ac3cc",
   188 => x"0087e4f1",
   189 => x"00000000",
   190 => x"00000000",
   191 => x"00000000",
   192 => x"1e000000",
   193 => x"c8ff4a71",
   194 => x"a17249bf",
   195 => x"1e4f2648",
   196 => x"89bfc8ff",
   197 => x"c0c0c0fe",
   198 => x"01a9c0c0",
   199 => x"4ac087c4",
   200 => x"4ac187c2",
   201 => x"4f264872",
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
