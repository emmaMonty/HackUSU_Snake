package snake_package is 

    type direction is (
        UP, DOWN, LEFT, RIGHT
    );

    type row_t is array (0 to 4) of std_logic;
    type position_board_t is array (0 to 3) of row_t;

end package;
