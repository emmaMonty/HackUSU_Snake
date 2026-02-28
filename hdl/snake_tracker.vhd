library ieee;
use ieee.std_logic_1164.all;

library work;
use work.snake_package.all;

entity snake_tracker is
    generic (
        INCREMENT_COUNT_TOP: integer := 30000
    );
    port (
        clk: in std_logic;
        rst: in std_logic;
        command: in direction;
        apple_pos: in position_board_t;
        ate: out std_logic;
        turn: out std_logic;
        crash: out std_logic;
        occupied: out board_bool_t
    );
end snake_tracker;

architecture behavioral of snake_tracker is
    type circ_buffer_t is array (0 to NUM_CELLS - 1) of position_board_t;
    signal circ_buffer: circ_buffer_t;
    subtype cell_t is integer range 0 to NUM_CELLS - 1;
    signal head, next_head: cell_t := 0;
    signal tail, next_tail: cell_t := 0;
    signal next_ate: boolean;
    signal increment_counter: integer range 0 to INCREMENT_COUNT_TOP - 1 := 0;
    signal increment: boolean := false;
    signal next_occupied : board_bool_t := (others => (others => false));
    signal over : boolean := false;
begin
    occupy: process(circ_buffer, head, tail)
        variable i: integer;
    begin
        if head >= tail then
            for i in tail to head loop
                next_occupied(circ_buffer(i).row, circ_buffer(i).col) <= true;
            end loop;
        else
            for i in tail to NUM_CELLS - 1 loop
                next_occupied(circ_buffer(i).row, circ_buffer(i).col) <= true;
            end loop;
            for i in 0 to head loop
                next_occupied(circ_buffer(i).row, circ_buffer(i).col) <= true;
            end loop;
        end if;
    end process;

    inc: process(clk, rst)
    begin
        if rst = '1' then
            head <= 0;
            tail <= 0;
            increment_counter <= 0;
            circ_buffer <= (others => (row => 0, col => 0));
            circ_buffer(0) <= (row => 6, col => 6);
        elsif rising_edge(clk) then
            if over = false then
                increment_counter <= increment_counter + 1;
            end if;
            if increment_counter = INCREMENT_COUNT_TOP - 1 then
                increment <= true;
                increment_counter <= 0;
            else
                increment <= false;
            end if;
            head <= next_head;
            tail <= next_tail;
            ate <= next_ate;
            occupied <= next_occupied;
        end if;
    end process;

    step: process(increment)
        variable collision: boolean := false;
        variable new_head_pos: position_board_t := circ_buffer(head);
        variable new_head: cell_t := head;
        variable eating: boolean := false;
    begin
        if increment = '1' then
            if command = UP then
                if circ_buffer(head).col = 0 then
                    collision := true;
                elsif next_occupied(circ_buffer(head).row - 1, circ_buffer(head).col) = true then
                    collision := true;
                else
                    new_head_pos.row := circ_buffer(head).row - 1;
                end if;
            end if;
            if command = DOWN then
                if circ_buffer(head).row = NUM_ROWS - 1 then
                    collision := true;
                elsif next_occupied(circ_buffer(head).row + 1, circ_buffer(head).col) = true then
                    collision := true;
                else
                    new_head_pos.row := circ_buffer(head).row + 1;
                end if;
            end if;
            if command = LEFT then
                if circ_buffer(head).col = 0 then
                    collision := true;
                elsif next_occupied(circ_buffer(head).row, circ_buffer(head).col - 1) = true then
                    collision := true;
                else
                    new_head_pos.col := circ_buffer(head).col - 1;
                end if;
            end if;
            if command = RIGHT then
                if circ_buffer(head).col = NUM_COLS - 1 then
                    collision := true;
                elsif next_occupied(circ_buffer(head).row, circ_buffer(head).col + 1) = true then
                    collision := true;
                else
                    new_head_pos.col := circ_buffer(head).col + 1;
                end if;
            end if;
            eating := new_head_pos = apple_pos;
            if collision = false then
                new_head := (head + 1) mod NUM_CELLS;
                circ_buffer(new_head) <= new_head_pos;
                next_ate <= eating;
                if eating = true then
                    next_tail <= tail;
                else
                    next_tail <= (tail + 1) mod NUM_CELLS;
                end if;
            else
                crash <= '1';
                over <= true;
            end if;
        end if;
    end process;
end behavioral;
