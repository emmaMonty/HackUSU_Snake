library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.snake_package.all;

entity game_manager is
    port (
        clk: in std_logic; --expected to be 25MHz-ish (vga clock)
        rst: in std_logic;
        start: in std_logic;
        clk_10mhz: in std_logic;
        clk_50mhz: in std_logic;
        pll_locked: in std_logic;
        audio_out: out std_logic_vector(7 downto 0);
        score: out score_t;
        occupied: out board_bool_t;
        head_pos: out position_board_t;
        apple_pos: out position_board_t;
        apple_valid: out boolean
    );
end game_manager;

architecture behavioral of game_manager is
    type state_t is (PRE_START, RUNNING, OVER);
    signal current_state, next_state: state_t := PRE_START;
    signal score_i, next_score: score_t;
    signal snake_rst: std_logic;

    --joysticks to snake_tracker
    signal command: direction;

    signal apple_pos_i, next_apple_pos: position_board_t;

    signal lfsr1_out, lfsr2_out: std_logic_vector(8 downto 0);

    --stuff that happens
    signal ate: std_logic;
    signal turn: std_logic;
    signal crash: std_logic;

    signal occupied_i: board_bool_t;
	 signal apple_valid_i: boolean;
begin
    snake_rst <= '1' when (rst = '1' or current_state /= RUNNING) else '0';
    score <= score_i;
    apple_pos <= apple_pos_i;
	 apple_valid <= apple_valid_i;
    occupied <= occupied_i;
    snake: entity work.snake_tracker
        port map (
            clk => clk,
            rst => snake_rst,
            command => command,
            apple_pos => apple_pos_i,
            apple_valid => apple_valid_i,
            ate => ate,
            turn => turn,
            crash => crash,
            occupied => occupied_i
        );

    lfsr1: entity work.lfsr
        port map (
            clk => clk,
            rst => rst,
            rand_cell => lfsr1_out
        );
    lfsr2: entity work.lfsr
        port map (
            clk => clk,   
            rst => rst,
            rand_cell => lfsr2_out
        );

    rng: process(lfsr1_out, lfsr2_out)
        variable random_cell: integer;
    begin
        next_apple_pos.row <= to_integer(unsigned(lfsr1_out(3 downto 0)));
        next_apple_pos.col <= to_integer(unsigned(lfsr2_out(4 downto 0)));
    end process;

    score_process: process(ate)
    begin
        if ate = '1' then
            if score_i(0) < 9 then
                next_score(0) <= score_i(0) + 1;
            elsif score_i(1) < 9 then
                next_score(1) <= score_i(1) + 1;
                next_score(0) <= 0;
            elsif score_i(2) < 9 then
                next_score(2) <= score_i(2) + 1;
                next_score(1) <= 0;
                next_score(0) <= 0;
            end if;
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

    clocked: process(clk, rst)
    begin
        if rst = '1' then
            current_state <= PRE_START;
            score_i <= (others => 0);
            apple_pos_i <= (row => 0, col => 0);
        elsif rising_edge(clk) then
            current_state <= next_state;
            score_i <= next_score;
            apple_pos_i <= next_apple_pos;
            apple_valid_i <= true;
            if next_apple_pos.row > NUM_ROWS or next_apple_pos.col > NUM_COLS or occupied_i(next_apple_pos.row, next_apple_pos.col) then
                apple_valid_i <= false;
            end if;
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
