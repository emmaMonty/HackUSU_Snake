library ieee;
use ieee.std_logic_1164.all;

package snake_package is 

    type direction is (
        UP_DIR, DOWN_DIR, LEFT_DIR, RIGHT_DIR
    );
	 
	 constant NUM_ROWS: integer := 14;
    constant NUM_COLS: integer := 20;
    constant NUM_CELLS: integer := NUM_ROWS * NUM_COLS;

    type position_board_t is record
        row : integer range 0 to NUM_ROWS-1;
        col : integer range 0 to NUM_COLS-1;
    end record;

    type board_bool_t is array (0 to NUM_ROWS-1, 0 to NUM_COLS-1) of boolean;

end package;
