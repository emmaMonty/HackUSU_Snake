library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        MAX10_CLK1_50: in std_logic;
        KEY: in std_logic_vector(1 downto 0);
        VGA_B: out std_logic_vector(3 downto 0);
        VGA_G: out std_logic_vector(3 downto 0);
        VGA_R: out std_logic_vector(3 downto 0);
        VGA_HS: out std_logic;
        VGA_VS: out std_logic
    );
end entity top;

architecture arch of top is
    signal Start: std_logic;
    signal vga_clock: std_logic;
    signal ten_mhz_clock: std_logic;
    signal pll_locked: std_logic;

    component VGA
        port (
            clk: in std_logic;
            rst: in std_logic;
            clk_10mhz: in std_logic;
            pll_locked: in std_logic;
            red: out std_logic_vector(3 downto 0);
            green: out std_logic_vector(3 downto 0);
            blue: out std_logic_vector(3 downto 0);
            vgaHS: out std_logic;
            vgaVS: out std_logic
        );
    end component VGA;

    component pll
        port (
            areset: in STD_LOGIC := '0';
            inclk0: in STD_LOGIC := '0';
            c0: out STD_LOGIC;
            c1: out STD_LOGIC;
            locked: out STD_LOGIC
        );
    end component pll;
begin
    PLL_INST: pll
        port map (
            areset => not KEY(0),
            inclk0 => MAX10_CLK1_50,
            c0 => ten_mhz_clock,
            c1 => vga_clock,
            locked => pll_locked
        );

    VGATOP: VGA
        port map (
            clk => vga_clock,
            clk_10mhz => ten_mhz_clock,
            pll_locked => pll_locked,
            rst => not KEY(0),
            red => VGA_R,
            green => VGA_G,
            blue => VGA_B,
            vgaHS => VGA_HS,
            vgaVS => VGA_VS
        );
end architecture arch;
