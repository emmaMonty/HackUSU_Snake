library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LFSR is
	port(
		ADC_CLK_10 	: in std_logic;
		KEY_0			: in std_logic;
		rand_cell  	: out std_logic_vector(8 downto 0)
	);
end entity LFSR;

architecture behavioral of LFSR is

	signal lfsr : unsigned(15 downto 0);
	signal bit_ch : std_logic;
	signal prev_cell : std_logic_vector(8 downto 0);
	
begin

	process(ADC_CLK_10, KEY_0)
	begin
		if rising_edge(ADC_CLK_10) then
			if KEY_0 = '0' then
				--reset
				lfsr <= X"800b";
				bit_ch <= '0';
				rand_cell <= "10000111"; -- Starting cell 135
				prev_cell <= "10000111";
			else
				--taps 16 15 13 4
				bit_ch <= NOT (lsfr(15) XOR lsfr(14) XOR lsfr(12) XOR lsfr(3));
				lfsr <= bit_ch & lsfr(15 downto 1);
				
				if(to_integer(lfsr(9 downto 1)) < 280) then
					rand_cell <= lfsr(9 downto 1);
				else
					rand_cell <= prev_cell;
				end if;
			end if;
		end if;
	
	end process;

	process(rand_cell)
	begin
			prev_cell <= rand_cell;		
	end process;


end architecture behavioral;