LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity temp_top IS
	port
	(
        MAX10_CLK1_50 : in    std_logic; 

        KEY           : in    std_logic_vector(1 downto 0); 

        
        GPIO          : inout std_logic_vector(35 downto 0)
	);
end temp_top;

architecture arch OF temp_top is 

    component audio_ctrl
        port (
            clk         : in  std_logic; -- 50 MHz, 50Mhz / 8kHz = 6250
            rst         : in  std_logic; 

            chompy_appy : in  std_logic; 
            twisty_turn : in  std_logic; 
            ha_loser    : in  std_logic; 

            audio_out   : out std_logic_vector(7 downto 0) -- GPIO(7 downto 0); 
        );
    end component audio_ctrl;

begin 

        audio_inst : audio_ctrl
            port map (
                clk         => MAX10_CLK1_50,
                rst         => not key(0), 

                chompy_appy => GPIO(8),
                twisty_turn => GPIO(9),
                ha_loser    => GPIO(10), 

                audio_out   => GPIO(7 downto 0)
            );


end architecture arch; 