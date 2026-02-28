library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port(
        MAX10_CLK1_50 : in std_logic;
        KEY : in std_logic_vector(1 downto 0);
    
        VGA_B  : out std_logic_vector(3 downto 0);
        VGA_G  : out std_logic_vector(3 downto 0);
        VGA_R  : out std_logic_vector(3 downto 0);
        VGA_HS : out std_logic;
        VGA_VS : out std_logic
    );
end entity top;
architecture arch of top is

    signal Start : std_logic;
    signal clock: std_logic;
	 signal other_clock: std_logic;
    signal locked_sig : std_logic;

    component VGA
    port(
	clk       : in  std_logic;
    rst       : in  std_logic;
    red       : out std_logic_vector(3 downto 0);
    green     : out std_logic_vector(3 downto 0);
    blue      : out std_logic_vector(3 downto 0);
    vgaHS     : out std_logic;
    vgaVS     : out std_logic
    );
    end component VGA;

    component pll
    PORT(
        areset : IN STD_LOGIC := '0';
        inclk0 : IN STD_LOGIC := '0';
        c0     : OUT STD_LOGIC;
		  c1     : OUT STD_LOGIC;
        locked : OUT STD_LOGIC
    );
    end component pll;

    begin
        PLL_INST : pll
        PORT MAP(
            areset => not KEY(0),
            inclk0 => MAX10_CLK1_50,
            c0     => other_clock,
				c1     => clock,
            locked => locked_sig
        );

        VGATOP : VGA
        port map(
            clk     => clock,
            rst     => not KEY(0),
            red     => VGA_R,
            green   => VGA_G,
            blue    => VGA_B,
            vgaHS   => VGA_HS,
            vgaVS   => VGA_VS
        );

end architecture arch; 