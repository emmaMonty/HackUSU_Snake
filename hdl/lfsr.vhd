library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LFSR is
    port (
        clk: in std_logic;
        rst: in std_logic;
        rand_cell: out std_logic_vector(8 downto 0)
    );
end entity LFSR;

architecture behavioral of LFSR is
    signal lfsr: unsigned(15 downto 0);
    signal bit_ch: std_logic;
    signal rand_cell_i: std_logic_vector(8 downto 0);
    signal prev_cell: std_logic_vector(8 downto 0);
begin
    rand_cell <= rand_cell_i;

    process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                --reset
                lfsr <= X"800b";
                bit_ch <= '0';
                rand_cell_i <= "010000111"; -- Starting cell 135
                prev_cell <= "010000111";
            else
                --taps 16 15 13 4
                bit_ch <= not (lfsr(15) xor lfsr(14) xor lfsr(12) xor lfsr(3));
                lfsr <= bit_ch & lfsr(15 downto 1);

                if (to_integer(lfsr(9 downto 1)) < 280) then
                    rand_cell_i <= std_logic_vector(lfsr(9 downto 1));
                else
                    rand_cell_i <= prev_cell;
                end if;
                prev_cell <= rand_cell_i;
            end if;
        end if;
    end process;
end architecture behavioral;
