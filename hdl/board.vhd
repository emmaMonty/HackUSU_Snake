library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity board is
    port(
        clk   : in std_logic;
        rst   : in std_logic;
        start : in std_logic;
        pixEN: in std_logic;
        row   : in integer;
        col   : in integer;
        red   : out std_logic_vector(3 downto 0);
        blue  : out std_logic_vector(3 downto 0);
        green : out std_logic_vector(3 downto 0)
    );
end entity board;

architecture arch of board is
    constant BLACK      : std_logic_vector(11 downto 0) := X"000";
    constant WHITE      : std_logic_vector(11 downto 0) := X"FFF";
    constant BOARDBLUE               : std_logic_vector(11 downto 0) := X"036";
	 begin
    process(clk, rst) is begin
        if rst = '1' then
            red   <= BLACK(11 downto 8);
            green <= BLACK(7  downto 4);
            blue  <= BLACK(3  downto 0);  
        elsif rising_edge(clk) then
            if pixEN = '0' then
                red   <= BLACK(11 downto 8);
                green <= BLACK(7  downto 4);
                blue  <= BLACK(3  downto 0);  
            else                        -- default background
                        red   <= BLACK(11 downto 8);
                        green <= BLACK(7  downto 4);
                        blue  <= BLACK(3  downto 0);

                        -- board outline (your original walls)
                        if (((row > 16) and  (row < 464)) and (col = 1)) or
                           (((row > 16) and  (row < 464)) and (col = 639)) then
                            red   <= WHITE(11 downto 8);
                            green <= WHITE(7  downto 4);
                            blue  <= WHITE(3  downto 0);

                        elsif ((row = 480) and ((col > 1) and (col < 639))) then
                            red   <= WHITE(11 downto 8);
                            green <= WHITE(7  downto 4);
                            blue  <= WHITE(3  downto 0);
                        else
                            null;
                        end if;
            end if;
        end if;
    end process;
end architecture arch;
