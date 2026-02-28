library ieee;
use ieee.std_logic_1164.all;

package snake_package is 

    type direction is (
        UP_DIR, DOWN_DIR, LEFT_DIR, RIGHT_DIR
    );

    type row_t is array (0 to 4) of std_logic;
    type position_board_t is array (0 to 3) of row_t;

end package;
