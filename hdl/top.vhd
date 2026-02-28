library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.snake_package.all;

entity top is
	port(
		MAX10_CLK1_50 : in std_logic;
		KEY : in std_logic_vector(1 downto 0);

--		VGA_B : out std_logic_vector(3 downto 0);
--		VGA_G : out std_logic_vector(3 downto 0);
--		VGA_R : out std_logic_vector(3 downto 0);
--		VGA_HS : out std_logic;
--		VGA_VS : out std_logic
		LEDR	: out std_logic_vector(3 downto 0)
	);
end entity top;

architecture arch of top is

	--ADC signals
	signal c0 : std_logic;
	signal joy1_dir : direction;
	signal joy2_dir : direction;

	signal clock : std_logic;
	signal locked_sig : std_logic;
--	component VGA
--	port(
--		clk : in std_logic;
--		rst : in std_logic;
--
--		blue : out std_logic_vector(3 downto 0);
--		green : out std_logic_vector(3 downto 0);
--		red : out std_logic_vector(3 downto 0);
--		vgaHS : out std_logic;
--		vgaVS : out std_logic
--	);
--	end component;
	
	component pll
	PORT(
		areset : in std_logic;
		inclk0 : in std_logic;
		c0 : out std_logic;
		c1 : out std_logic;
		locked : out std_logic
	);
	end component;
	
	component joysticks
		PORT(
			MAX10_CLK1_50 : in std_logic;
			PLL_10MHz  : in std_logic;
			locked	  : in std_logic;
			joy1 : out direction; -- 2-bit direction vector - 0123/UDLR
			joy2 : out direction;
			KEY: in std_logic_vector(1 downto 0)
		);
	end component;
		
	begin
	
	pll_inst : pll
	PORT MAP(	
		areset => not KEY(0),
		inclk0 => MAX10_CLK1_50,
		c0 => c0,		
		c1 => clock,
		locked => locked_sig
	);

--	VGATOP : VGA
--	PORT MAP(
--		clk => clock,
--		rst => not KEY(0),
--
--		blue => VGA_B,
--		green => VGA_G,
--		red => VGA_R,
--		vgaHS => VGA_HS,
--		vgaVS => VGA_VS
--	);
	
	JOYSTICK_inst : joysticks
	PORT MAP(
			MAX10_CLK1_50 	=> MAX10_CLK1_50,
			PLL_10MHz 		=> c0,
			locked 			=> locked_sig,	
			joy1 => joy1_dir,
			joy2 => joy2_dir,
			KEY => KEY
	);
	
end architecture arch;
