library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA is
    generic(
        hFrontPorch : integer := 16;
        hSyncPulse  : integer := 96;
        hBackPorch  : integer := 48;
        hData       : integer := 640;
        vFrontPorch : integer := 10;
        vSyncPulse  : integer := 2;
        vBackPorch  : integer := 33;
        vData       : integer := 480
    );
    port(
        clk : in std_logic;
        rst : in std_logic;

        blue : out std_logic_vector(3 downto 0);
        green : out std_logic_vector(3 downto 0);
        red : out std_logic_vector(3 downto 0);
        vgaHS : out std_logic;
        vgaVS : out std_logic
    );
end VGA;

architecture arch of VGA is
    signal row : integer := 0;
    signal col : integer := 0;
    signal pixEN: std_logic;
    signal hCounter : integer := 0;
    signal vCounter : integer := 0;

    component board 
    port(
        clk      : in  std_logic;
        rst      : in  std_logic; 
        pixEN   : in  std_logic;
        row      : in  integer;
        col      : in  integer;
        red      : out std_logic_vector(3 downto 0);
        green    : out std_logic_vector(3 downto 0);
        blue     : out std_logic_vector(3 downto 0)
    );
    end component board;

    begin
        counter : process(clk, rst) is begin
            if rst = '1' then   
                hCounter <= 0;
                vCounter <= 0;
                row      <= 0;
                col      <= 0;
            elsif rising_edge(clk) then
                if hCounter >= (hFrontPorch + hSyncPulse + hBackPorch + hData -1) then
                    hCounter <= 0;
                    col <= 0;
                if vCounter >= (vFrontPorch + vSyncPulse + vBackPorch + vData -1) then
                        vCounter <= 0;
                        row <= 0;
                    else
                        vCounter <= vCounter + 1;
                        if vCounter >= (vFrontPorch + vSyncPulse + vBackPorch -1) then
                            row <= row + 1;
                        end if;
                    end if;
                else
                    hCounter <= hCounter + 1;
                    if hCounter >= (hFrontPorch + hSyncPulse + hBackPorch -1) then
                        col <= col + 1;
                    end if;
                end if;
            end if;
        end process counter;

        sync : process(clk, rst) is begin
            if rst = '1' then
                vgaHS <= '1';
                vgaVS <= '1';
            elsif rising_edge(clk) then
                if hCounter >= 0 and hCounter <hFrontPorch then
                    vgaHS <= '1';
                elsif hCounter >= (hFrontPorch -1) and hCounter < (hFrontPorch + hSyncPulse + hBackPorch -1) then
                    vgaHS <= '0';
                elsif hCounter >= (hFrontPorch + hSyncPulse -1) and hCounter < (hFrontPorch + hSyncPulse + hBackPorch  -1) then
                    vgaHS <= '1';
                else
                    vgaHS <= '1';
                end if;

                if vCounter >= 0 and vCounter < vFrontPorch - 1 then
                    vgaVS <= '1';
                elsif vCounter >= vFrontPorch - 1 and vCounter < (vFrontPorch + vSyncPulse + vBackPorch -1) then
                    vgaVS <= '0';
                elsif vCounter >= (vFrontPorch + vSyncPulse -1) and hCounter >= (hFrontPorch + hSyncPulse + hBackPorch -1) then
                    vgaVS <= '1';
                else
                    vgaVS <= '1';
                end if;
                if vCounter >= (vFrontPorch + vSyncPulse + vBackPorch -1) and hCounter >= (hFrontPorch + hSyncPulse + hBackPorch -1) then
                    pixEN <= '1';
                else
                    pixEN <= '0';
                end if;
            end if;
        end process sync;

    GBOARD: board 
    port map(
        clk      => clk,
        rst      => rst, 
        pixEN   => pixEN,
        row      => row, 
        col      => col,
        red      => red, 
        green    => green,
        blue     => blue
    );
end architecture arch;