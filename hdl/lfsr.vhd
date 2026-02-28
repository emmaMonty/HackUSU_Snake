library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LFSR is 
    generic (
        INIT : unsigned(15 downto 0) := X"800b"
    );
    port (
        clk: in std_logic;
        rst: in std_logic;
        rand_cell: out std_logic_vector(8 downto 0)
    );
end entity LFSR;

architecture behavioral of LFSR is
    signal lfsr: unsigned(15 downto 0);
    signal bit_ch: std_logic;
begin
    process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                --reset
                lfsr <= INIT;
                bit_ch <= '0';
                rand_cell <= "010000111"; -- Starting cell 135
            else
                --taps 16 15 13 4
                bit_ch <= not (lfsr(15) xor lfsr(14) xor lfsr(12) xor lfsr(3));
                lfsr <= bit_ch & lfsr(15 downto 1);
                rand_cell <= std_logic_vector(lfsr(9 downto 1));
            end if;
        end if;
    end process;
end architecture behavioral;
