library ieee;
use ieee.std_logic_1164.all;

library work;
use work.snake_package.all;

entity game_manager is 
    port (
        clk : in std_logic; --expected to be 25MHz-ish (vga clock)
        rst : in std_logic;
        start : in std_logic;
        clk_10mhz : in std_logic;
        clk_50mhz : in std_logic;
        pll_locked : in std_logic;
        audio_out : out std_logic_vector(7 downto 0);
        score: out integer range 0 to 999999
    );
end game_manager;

architecture behavioral of game_manager is 
    type state_t is (PRE_START, RUNNING, OVER);
    signal current_state, next_state: state_t := PRE_START;
    signal over : boolean := false;
    signal next_score : integer range 0 to 999999 := 0;

    --joysticks to snake_tracker
    signal command : direction;

    signal apple_pos : position_board_t;
    signal apple_valid : boolean := false;

    signal lfsr_out : std_logic_vector(8 downto 0);

    --stuff that happens
    signal ate : std_logic;
    signal turn : std_logic;
    signal crash : std_logic;

    signal occupied : board_bool_t;
begin
    snake: entity work.snake_tracker 
        port map (
            clk => clk,
            rst => rst or state /= RUNNING,
            command => command,
            apple_pos => apple_pos,
            ate => ate,
            turn => turn,
            crash => crash,
            occupied => occupied
        );

    lfsr: entity work.lfsr 
        port map (
            clk => clk,
            rst => rst,
            rand_cell => lfsr_out
        );

    rng: process(lfsr_out) 
        variable next_apple_pos : position_board_t;
    begin
        next_apple_pos.row := lfsr_out / NUM_COLS;
        next_apple_pos.col := lfsr_out mod NUM_COLS;
        if not occupied(next_apple_pos.row, next_apple_pos.col) then
            apple_pos <= next_apple_pos;
            apple_valid <= true;
        else 
            apple_valid <= false;
        end if;
    end process;

    score_process: process(ate)
    begin
        if ate = '1' then
            next_score <= next_score + 1;
        end if;
    end process;

    joysticks: entity work.joysticks
        port map (
            MAX10_CLK1_50 => clk_50mhz,
            PLL_10MHZ => clk_10mhz,
            locked => pll_locked,
            joy1 => command,
            joy2 => open,
            KEY => '0' & (not rst)
        );

    clocked: process(clk, rst) begin
        if rst = '1' then
            current_state <= PRE_START;
        elsif rising_edge(clk) then
            current_state <= next_state;
            score <= next_score;
        end if;
    end process;

    combinatorial: process(start, current_state, crash)
    begin
        case current_state is
            when PRE_START =>
                if start = '1' then
                    next_state <= RUNNING;
                else
                    next_state <= PRE_START;
                end if;
            when RUNNING =>
                if crash = '1' then
                    next_state <= OVER;
                else
                    next_state <= RUNNING;
                end if;
            when OVER =>
                if start = '1' then
                    next_state <= PRE_START;
                else
                    next_state <= OVER;
                end if;
        end case;
    end process;





end behavioral;
