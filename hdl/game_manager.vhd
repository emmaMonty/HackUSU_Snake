library ieee;
use ieee.std_logic_1164.all;

library work;
use work.snake_package.all;

entity game_manager is 
    port (
        clk : in std_logic;
        rst : in std_logic;
        start : in std_logic;
    );
end game_manager;

architecture behavioral of game_manager is 
    type state_t is (PRE_START, RUNNING, OVER);
    signal current_state, next_state: state_t := PRE_START;
    signal over
begin
    clocked: process(clk, rst) begin
        if rst = '1' then
            current_state <= PRE_START;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    combinatorial: process(start, current_state)
    begin
        case current_state is
            when PRE_START =>
                if start = '1' then
                    next_state <= RUNNING;
                else
                    next_state <= PRE_START;
                end if;
            when RUNNING =>
                -- Add conditions for transitioning to OVER state if needed
                next_state <= RUNNING;
            when OVER =>
                -- Add conditions for transitioning to PRE_START state if needed
                next_state <= OVER;
        end case;
    end process;

    



end behavioral;
