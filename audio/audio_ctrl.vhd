LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity audio_ctrl IS
	port (
        clk         : in  std_logic; -- 50 MHz, 50Mhz / 8kHz = 6250
        rst         : in  std_logic; 

        chompy_appy : in  std_logic; 
        twisty_turn : in  std_logic; 
        ha_loser    : in  std_logic; 

        audio_out   : out std_logic_vector(7 downto 0) -- GPIO(7 downto 0); 
	);
end audio_ctrl;

architecture arch OF audio_out is 

    type sine_table_t is array (0 to 127) of std_logic_vector(7 downto 0);

    constant sLUT : sine_table_t := (
        0 => x"80",  1 => x"86",  2 => x"8C",  3 => x"92",
        4 => x"98",  5 => x"9E",  6 => x"A5",  7 => x"AA",
        8 => x"B0",  9 => x"B6", 10 => x"BC", 11 => x"C1",
        12 => x"C6", 13 => x"CB", 14 => x"D0", 15 => x"D5",
        16 => x"DA", 17 => x"DE", 18 => x"E2", 19 => x"E6",
        20 => x"EA", 21 => x"ED", 22 => x"F0", 23 => x"F3",
        24 => x"F5", 25 => x"F8", 26 => x"FA", 27 => x"FB",
        28 => x"FD", 29 => x"FE", 30 => x"FE", 31 => x"FF",
        32 => x"FF", 33 => x"FF", 34 => x"FE", 35 => x"FE",
        36 => x"FD", 37 => x"FB", 38 => x"FA", 39 => x"F8",
        40 => x"F5", 41 => x"F3", 42 => x"F0", 43 => x"ED",
        44 => x"EA", 45 => x"E6", 46 => x"E2", 47 => x"DE",
        48 => x"DA", 49 => x"D5", 50 => x"D0", 51 => x"CB",
        52 => x"C6", 53 => x"C1", 54 => x"BC", 55 => x"B6",
        56 => x"B0", 57 => x"AA", 58 => x"A5", 59 => x"9E",
        60 => x"98", 61 => x"92", 62 => x"8C", 63 => x"86",
        64 => x"80", 65 => x"79", 66 => x"73", 67 => x"6D",
        68 => x"67", 69 => x"61", 70 => x"5A", 71 => x"55",
        72 => x"4F", 73 => x"49", 74 => x"43", 75 => x"3E",
        76 => x"39", 77 => x"34", 78 => x"2F", 79 => x"2A",
        80 => x"25", 81 => x"21", 82 => x"1D", 83 => x"19",
        84 => x"15", 85 => x"12", 86 => x"0F", 87 => x"0C",
        88 => x"0A", 89 => x"07", 90 => x"05", 91 => x"04",
        92 => x"02", 93 => x"01", 94 => x"01", 95 => x"00",
        96 => x"00", 97 => x"00", 98 => x"01", 99 => x"01",
        100 => x"02",101 => x"04",102 => x"05",103 => x"07",
        104 => x"0A",105 => x"0C",106 => x"0F",107 => x"12",
        108 => x"15",109 => x"19",110 => x"1D",111 => x"21",
        112 => x"25",113 => x"2A",114 => x"2F",115 => x"34",
        116 => x"39",117 => x"3E",118 => x"43",119 => x"49",
        120 => x"4F",121 => x"55",122 => x"5A",123 => x"61",
        124 => x"67",125 => x"6D",126 => x"73",127 => x"79"
    );

    signal clk_div_cnt : integer; 
    signal audio_cnt   : integer; 

begin 

    process(clk, rst) is begin 
        if rst = '1' then 
            audio_out   <= (others => '0');

            clk_div_cnt <= 0; 
            audio_cnt   <= 0; 
        elsif rising_edge(clk) then 
            if clk_cnt = 113636 then -- 6250 for 8 kHz then
                audio_out <= sLUT(audio_cnt);
                audio_cnt <= audio_cnt + 1; 
                clk_cnt <= '0'; 
            else
                clk_cnt <= clk_cnt + 1; 
            end if;             
        end if; 
    end process; 

end architecture arch; 