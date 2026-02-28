library ieee;
use ieee.std_logic_1164.all;

library work;
use work.snake_package.all;

-- Notes:
--  * Replaces the combinational "occupy" rebuild loop with an incremental update
--    of the occupied board, executed over a small FSM.
--  * This removes the giant decoder/OR network that was driving ALUT usage.
entity snake_tracker is
    generic (
        INCREMENT_COUNT_TOP: integer := 30000
    );
    port (
        clk: in std_logic;
        rst: in std_logic;
        command: in direction;
        apple_pos: in position_board_t;
        apple_valid: in boolean;
        ate: out std_logic;
        turn: out std_logic;
        crash: out std_logic;
        occupied: out board_bool_t;
        head_pos: out position_board_t
    );
end snake_tracker;

architecture behavioral of snake_tracker is
    type circ_buffer_t is array (0 to NUM_CELLS - 1) of position_board_t;
    signal circ_buffer: circ_buffer_t;

    subtype cell_t is integer range 0 to NUM_CELLS - 1;
    signal head: cell_t := 0;
    signal tail: cell_t := 0;

    -- Registered occupancy map (2-D), updated incrementally (set new head / clear old tail).
    signal occ_reg : board_bool_t := (others => (others => false));

    -- Slow-step counter
    signal increment_counter: integer range 0 to INCREMENT_COUNT_TOP - 1 := 0;
    signal increment: boolean := false;

    signal over : boolean := false;

    -- FSM to spread work over multiple cycles (you can add more states later if desired)
    type state_t is (S_IDLE, S_UPDATE);
    signal state : state_t := S_IDLE;

    -- Latched move results between S_IDLE -> S_UPDATE
    signal lat_new_head_pos : position_board_t := (row => 0, col => 0);
    signal lat_old_tail_pos : position_board_t := (row => 0, col => 0);
    signal lat_next_head     : cell_t := 0;
    signal lat_next_tail     : cell_t := 0;
    signal lat_eating        : boolean := false;
begin
    -- Outputs
    head_pos <= circ_buffer(head);
    occupied <= occ_reg;

    -- Not used elsewhere in your original code; drive low.
    turn <= '0';

    seq: process(clk, rst)
        -- local helpers
        variable collision   : boolean;
        variable new_head_pos: position_board_t;
        variable eating      : boolean;
        variable next_head_v : cell_t;
        variable next_tail_v : cell_t;
        variable old_tail_pos: position_board_t;
        variable head_now_pos: position_board_t;
        variable next_row    : integer;
        variable next_col    : integer;
    begin
        if rst = '1' then
            head <= 0;
            tail <= 0;
            increment_counter <= 0;
            increment <= false;
            over <= false;
            state <= S_IDLE;

            -- init snake buffer
            circ_buffer <= (others => (row => 0, col => 0));
            circ_buffer(0) <= (row => 6, col => 6);

            -- init occupancy
            occ_reg <= (others => (others => false));
            occ_reg(6, 6) <= true;

            ate <= '0';
            crash <= '0';

            -- clear latches
            lat_new_head_pos <= (row => 0, col => 0);
            lat_old_tail_pos <= (row => 0, col => 0);
            lat_next_head <= 0;
            lat_next_tail <= 0;
            lat_eating <= false;

        elsif rising_edge(clk) then
            -- defaults each cycle
            crash <= '0';
            increment <= false;

            -- advance slow-step counter unless game over
            if over = false then
                if increment_counter = INCREMENT_COUNT_TOP - 1 then
                    increment_counter <= 0;
                    increment <= true;
                else
                    increment_counter <= increment_counter + 1;
                end if;
            end if;

            case state is
                when S_IDLE =>
                    -- Only compute a move when the slow increment pulses.
                    if (increment = true) and (over = false) then
                        collision := false;

                        head_now_pos := circ_buffer(head);
                        new_head_pos := head_now_pos;  -- start with current head

                        -- compute attempted move
                        if command = UP_DIR then
                            next_row := head_now_pos.row - 1;
                            next_col := head_now_pos.col;
                            if head_now_pos.row = 0 then
                                collision := true;
                            end if;

                        elsif command = DOWN_DIR then
                            next_row := head_now_pos.row + 1;
                            next_col := head_now_pos.col;
                            if head_now_pos.row = NUM_ROWS - 1 then
                                collision := true;
                            end if;

                        elsif command = LEFT_DIR then
                            next_row := head_now_pos.row;
                            next_col := head_now_pos.col - 1;
                            if head_now_pos.col = 0 then
                                collision := true;
                            end if;

                        elsif command = RIGHT_DIR then
                            next_row := head_now_pos.row;
                            next_col := head_now_pos.col + 1;
                            if head_now_pos.col = NUM_COLS - 1 then
                                collision := true;
                            end if;

                        else
                            -- default: no move
                            next_row := head_now_pos.row;
                            next_col := head_now_pos.col;
                        end if;

                        -- Apply movement if still in-bounds
                        if collision = false then
                            new_head_pos.row := next_row;
                            new_head_pos.col := next_col;
                        end if;

                        -- Determine whether we're eating
                        eating := apple_valid
                                  and (new_head_pos.col = apple_pos.col)
                                  and (new_head_pos.row = apple_pos.row);

                        -- Tail position used for incremental clear and for collision special-case
                        old_tail_pos := circ_buffer(tail);

                        -- Collision with body:
                        -- Normally: occupied at destination => collision.
                        -- Special case: if not eating, moving into the current tail cell is OK,
                        -- because the tail will be cleared on this move.
                        if collision = false then
                            if occ_reg(new_head_pos.row, new_head_pos.col) = true then
                                if not ((eating = false)
                                        and (new_head_pos.row = old_tail_pos.row)
                                        and (new_head_pos.col = old_tail_pos.col)) then
                                    collision := true;
                                end if;
                            end if;
                        end if;

                        if collision = true then
                            crash <= '1';
                            over <= true;
                            ate <= '0';
                            -- stay in S_IDLE
                        else
                            -- compute wrapped head/tail pointers (avoid MOD to reduce logic)
                            if head = NUM_CELLS - 1 then
                                next_head_v := 0;
                            else
                                next_head_v := head + 1;
                            end if;

                            if eating = true then
                                next_tail_v := tail;  -- grow: don't move tail
                            else
                                if tail = NUM_CELLS - 1 then
                                    next_tail_v := 0;
                                else
                                    next_tail_v := tail + 1;
                                end if;
                            end if;

                            -- latch results for the update phase
                            lat_new_head_pos <= new_head_pos;
                            lat_old_tail_pos <= old_tail_pos;
                            lat_next_head    <= next_head_v;
                            lat_next_tail    <= next_tail_v;
                            lat_eating       <= eating;

                            state <= S_UPDATE;
                        end if;
                    end if;

                when S_UPDATE =>
                    -- Commit the move and update occupancy incrementally.
                    head <= lat_next_head;
                    tail <= lat_next_tail;

                    -- Update snake body buffer
                    circ_buffer(lat_next_head) <= lat_new_head_pos;

                    -- Update occupancy:
                    --  * set new head cell
                    occ_reg(lat_new_head_pos.row, lat_new_head_pos.col) <= true;

                    --  * clear old tail cell if we didn't eat
                    if lat_eating = false then
                        occ_reg(lat_old_tail_pos.row, lat_old_tail_pos.col) <= false;
                    end if;

                    -- ate flag
                    if lat_eating then
                        ate <= '1';
                    else
                        ate <= '0';
                    end if;

                    state <= S_IDLE;
            end case;
        end if;
    end process;
end behavioral;
