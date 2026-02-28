library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.snake_package.all;

entity board is
    port (
        clk: in std_logic;
        rst: in std_logic;
        start: in std_logic;
        pixEN: in std_logic;
        row: in integer;
        col: in integer;
        clk_10mhz: in std_logic;
        clk_50mhz: in std_logic;
        pll_locked: in std_logic;
        audio_out: out std_logic_vector(7 downto 0);
        red: out std_logic_vector(3 downto 0);
        blue: out std_logic_vector(3 downto 0);
        green: out std_logic_vector(3 downto 0)
    );
end entity board;

architecture arch of board is
    constant BLACK: std_logic_vector(11 downto 0) := X"000";
    constant WHITE: std_logic_vector(11 downto 0) := X"FFF";
    constant LETBLUE: std_logic_vector(11 downto 0) := X"134";
    constant PURPLE: std_logic_vector(11 downto 0) := X"A0C";
    constant APPLE_RED: std_logic_vector(11 downto 0) := X"F00";

    constant BLUE_OCCUPIED: std_logic_vector(11 downto 0) := x"00d";
    constant BLUE_HEAD: std_logic_vector(11 downto 0) := x"04f";

    constant GREEN_D: std_logic_vector(11 downto 0) := x"9c4";
    constant GREEN_L: std_logic_vector(11 downto 0) := x"ad5";

    constant CHAR_W: integer := 12;
    constant CHAR_H: integer := 20;
    constant SCORE_Y: integer := 2; -- vertical start of digit boxes

    -- your 6 score boxes:
    -- 504-516, 520-532, 536-548, 552-564, 568-580, 584-596
    constant DIGIT5_X: integer := 504; -- most significant digit
    constant DIGIT4_X: integer := 520;
    constant DIGIT3_X: integer := 536;
    constant DIGIT2_X: integer := 552;
    constant DIGIT1_X: integer := 568;
    constant DIGIT0_X: integer := 584; -- least significant digit

    -- score value (0..999999) -> d5..d0
    signal score: score_t;


    -- font ROM interface
    signal cur_digit: unsigned(3 downto 0) := (others => '0');
    signal font_row: integer range 0 to CHAR_H - 1 := 0;
    signal font_bits: std_logic_vector(CHAR_W - 1 downto 0);
    signal score_pix_on: std_logic := '0';

    constant WORD_Y: integer := 2; -- top margin
    constant WORD_X: integer := 20; -- left margin
    constant LETTERS: integer := 7;
    constant GAP: integer := 2;

    signal cur_ch: unsigned(2 downto 0) := (others => '0');
    signal letter_row: integer range 0 to CHAR_H - 1 := 0;
    signal letter_bits: std_logic_vector(CHAR_W - 1 downto 0);
    signal letter_on: std_logic := '0';

    signal occupied: board_bool_t;
    signal head_pos: position_board_t;
    signal apple_pos: position_board_t;
    signal apple_valid: boolean := false;

    signal light_square: boolean := false;
    signal dark_square: boolean := false;
    signal apple_square: boolean := false;
    signal head_square: boolean := false;
    signal occupied_square: boolean := false;
begin
    LettersOverlay: process(row, col, pixEN, letter_bits)
        variable x, y: integer;
        variable idx: integer;
        variable c: integer;
        variable lr: integer;
        variable p: std_logic;
    begin
        p := '0';
        x := col;
        y := row;

        if pixEN = '1' and (y >= WORD_Y) and (y < WORD_Y + CHAR_H) and (x >= WORD_X) and (x < WORD_X + LETTERS * (CHAR_W + GAP)) then
            lr := y - WORD_Y;
            idx := (x - WORD_X) / (CHAR_W + GAP);
            c := (x - WORD_X) mod (CHAR_W + GAP);

            if c < CHAR_W then
                letter_row <= lr;

                -- H A C K U S U
                case idx is
                    when 0 =>
                        cur_ch <= "000"; -- H
                    when 1 =>
                        cur_ch <= "001"; -- A
                    when 2 =>
                        cur_ch <= "010"; -- C
                    when 3 =>
                        cur_ch <= "011"; -- K
                    when 4 =>
                        cur_ch <= "100"; -- U
                    when 5 =>
                        cur_ch <= "101"; -- S
                    when 6 =>
                        cur_ch <= "100"; -- U
                    when others =>
                        cur_ch <= (others => '0');
                end case;

                if letter_bits(CHAR_W - 1 - c) = '1' then
                    p := '1';
                end if;
            end if;
        end if;

        letter_on <= p;
    end process;

    GAME: entity work.game_manager
        port map (
            clk => clk,
            rst => rst,
            start => start,
            clk_10mhz => clk_10mhz,
            clk_50mhz => clk_50mhz,
            pll_locked => pll_locked,
            audio_out => audio_out,
            score => score
        );

    FONT: entity work.Font
        port map (
            ch => cur_ch,
            row => letter_row,
            bits => letter_bits
        );
    ----------------------------------------------------------------
    -- DIGIT FONT ROM INSTANCE  (Score.vhd must be in project)
    ----------------------------------------------------------------
    FONT_ROM: entity work.Score
        port map (
            digit => cur_digit,
            row => font_row,
            bits => font_bits
        );

    ----------------------------------------------------------------
    -- SCORE OVERLAY: decide if current pixel is inside a digit
    ----------------------------------------------------------------
    ScoreOverlay: process(row, col, pixEN, score, font_bits, letter_bits)
        variable x, y: integer;
        variable c: integer;
        variable ld: unsigned(3 downto 0);
        variable lr: integer range 0 to CHAR_H - 1;
        variable p: std_logic;
        variable d0: unsigned(3 downto 0);
        variable d1: unsigned(3 downto 0);
        variable d2: unsigned(3 downto 0);
        variable d3: unsigned(3 downto 0);
        variable d4: unsigned(3 downto 0);
        variable d5: unsigned(3 downto 0);
    begin
        p := '0';
        ld := (others => '0');
        lr := 0;

        x := col;
        y := row;

        d0 := to_unsigned(score(0), 4);
        d1 := to_unsigned(score(1), 4);
        d2 := to_unsigned(score(2), 4);
        d3 := to_unsigned(score(3), 4);
        d4 := to_unsigned(score(4), 4);
        d5 := to_unsigned(score(5), 4);

        if pixEN = '1' then
            -- check vertical digit band
            if (y >= SCORE_Y) and (y < SCORE_Y + CHAR_H) then
                lr := y - SCORE_Y;

                -- which digit horizontally?
                if (x >= DIGIT5_X) and (x < DIGIT5_X + CHAR_W) then
                    ld := d5;
                    c := x - DIGIT5_X;
                elsif (x >= DIGIT4_X) and (x < DIGIT4_X + CHAR_W) then
                    ld := d4;
                    c := x - DIGIT4_X;
                elsif (x >= DIGIT3_X) and (x < DIGIT3_X + CHAR_W) then
                    ld := d3;
                    c := x - DIGIT3_X;
                elsif (x >= DIGIT2_X) and (x < DIGIT2_X + CHAR_W) then
                    ld := d2;
                    c := x - DIGIT2_X;
                elsif (x >= DIGIT1_X) and (x < DIGIT1_X + CHAR_W) then
                    ld := d1;
                    c := x - DIGIT1_X;
                elsif (x >= DIGIT0_X) and (x < DIGIT0_X + CHAR_W) then
                    ld := d0;
                    c := x - DIGIT0_X;
                else
                    c := -1;
                end if;

                if (c >= 0) and (c < CHAR_W) then
                    cur_digit <= ld;
                    font_row <= lr;

                    -- leftmost bit in font_bits is CHAR_W-1
                    if font_bits(CHAR_W - 1 - c) = '1' then
                        p := '1';
                    end if;
                else
                    cur_digit <= (others => '0');
                    font_row <= 0;
                end if;
            else
                cur_digit <= (others => '0');
                font_row <= 0;
            end if;
        else
            cur_digit <= (others => '0');
            font_row <= 0;
        end if;

        score_pix_on <= p;
    end process;
    checkerboard: process(row, col)
        variable r : unsigned(9 downto 0);
        variable c : unsigned(9 downto 0);
    begin
        r := to_unsigned(row-32, 10);
        c := to_unsigned(col, 10);
        if (r(9 downto 5)+c(9 downto 5)) mod 2 = 0 then
            light_square <= true;
            dark_square <= false;
        else
            light_square <= false;
            dark_square <= true;
        end if;
        if row<32 then
            light_square <= false;
            dark_square <= false;
        end if;
    end process;

    apple: process(row, col, apple_pos, apple_valid)
    begin
        if apple_valid and (row >= 32) and ((col / 32) = apple_pos.col) and (((row - 32) / 32) = apple_pos.row) then
            apple_square <= true;
        else
            apple_square <= false;
        end if;
    end process;

    head: process(row, col, head_pos)
    begin
        if (row >= 32) and ((col / 32) = head_pos.col) and (((row - 32) / 32) = head_pos.row) then
            head_square <= true;
        else
            head_square <= false;
        end if;
    end process;

    occ: process(row, col, occupied)
        variable r : unsigned(9 downto 0);
        variable c : unsigned(9 downto 0);
    begin
        r := to_unsigned(row-32, 10);
        c := to_unsigned(col, 10);
        if occupied(to_integer(r(9 downto 5)), to_integer(c(9 downto 5))) = true then
            occupied_square <= true;
        else
            occupied_square <= false;
        end if;
    end process;

    draw: process(clk, rst) is
    begin
        if rst = '1' then
            red <= BLACK(11 downto 8);
            green <= BLACK(7 downto 4);
            blue <= BLACK(3 downto 0);
        elsif rising_edge(clk) then
            if pixEN = '0' then
                red <= BLACK(11 downto 8);
                green <= BLACK(7 downto 4);
                blue <= BLACK(3 downto 0);
            else -- default background
                red <= BLACK(11 downto 8);
                green <= BLACK(7 downto 4);
                blue <= BLACK(3 downto 0);

                -- board outline (your original walls)
                if (((row > 32) and (row < 479)) and (col = 1)) or (((row > 32) and (row < 479)) and (col = 639)) then
                    red <= WHITE(11 downto 8);
                    green <= WHITE(7 downto 4);
                    blue <= WHITE(3 downto 0);
                elsif (((row = 479) or (row = 32)) and ((col > 1) and (col < 639))) then
                    red <= WHITE(11 downto 8);
                    green <= WHITE(7 downto 4);
                    blue <= WHITE(3 downto 0);
                --score
                elsif score_pix_on = '1' then
                    red <= WHITE(11 downto 8);
                    green <= WHITE(7 downto 4);
                    blue <= WHITE(3 downto 0);
                --letter
                elsif letter_on = '1' then
                    red <= LETBLUE(11 downto 8);
                    green <= LETBLUE(7 downto 4);
                    blue <= LETBLUE(3 downto 0);
                end if;
                --square backgrounds
                if light_square = true then
                    red <= GREEN_L(11 downto 8);
                    green <= GREEN_L(7 downto 4);
                    blue <= GREEN_L(3 downto 0);
                elsif dark_square = true then
                    red <= GREEN_D(11 downto 8);
                    green <= GREEN_D(7 downto 4);
                    blue <= GREEN_D(3 downto 0);
                end if;
                --start ones that only draw on part of the square
                if apple_square = true then 
                    if ((row mod 32) > 6 and (row mod 32) < 25) and ((col mod 32) > 6 and (col mod 32) < 25) then
                        red <= APPLE_RED(11 downto 8);
                        green <= APPLE_RED(7 downto 4);
                        blue <= APPLE_RED(3 downto 0);
                    end if;
                elsif head_square = true then 
                    if ((row mod 32) > 3 and (row mod 32) < 28) and ((col mod 32) > 3 and (col mod 32) < 28) then
                        red <= BLUE_HEAD(11 downto 8);
                        green <= BLUE_HEAD(7 downto 4);
                        blue <= BLUE_HEAD(3 downto 0);
                    end if;
                elsif occupied_square = true then
                    if ((row mod 32) > 3 and (row mod 32) < 28) and ((col mod 32) > 3 and (col mod 32) < 28) then
                        red <= BLUE_OCCUPIED(11 downto 8);
                        green <= BLUE_OCCUPIED(7 downto 4);
                        blue <= BLUE_OCCUPIED(3 downto 0);
                    end if;
                else
                    null;
                end if;
            end if;
        end if;
    end process;
end architecture arch;
