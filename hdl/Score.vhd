library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Score is
    port (
        digit : in  unsigned(3 downto 0);          -- 0..9
        row   : in  integer range 0 to 19;         -- 0..19 (inside character)
        bits  : out std_logic_vector(11 downto 0)  -- 12 pixels for that row (1 = on)
    );
end entity Score;

architecture rtl of Score is
begin
    process(digit, row)
    begin
        bits <= (others => '0');  -- default blank

        case digit is

            -- "0"
            when "0000" =>
                case row is
                    when 0  => bits <= "000111111000";
                    when 1  => bits <= "001111111100";
                    when 2  => bits <= "011100001110";
                    when 3  => bits <= "011000000110";
                    when 4  => bits <= "011000000110";
                    when 5  => bits <= "011000000110";
                    when 6  => bits <= "011000000110";
                    when 7  => bits <= "011000000110";
                    when 8  => bits <= "011000000110";
                    when 9  => bits <= "011000000110";
                    when 10 => bits <= "011000000110";
                    when 11 => bits <= "011000000110";
                    when 12 => bits <= "011000000110";
                    when 13 => bits <= "011000000110";
                    when 14 => bits <= "011000000110";
                    when 15 => bits <= "011100001110";
                    when 16 => bits <= "001111111100";
                    when 17 => bits <= "000111111000";
                    when others => bits <= (others => '0');
                end case;

            -- "1"
            when "0001" =>
                case row is
                    when 0  => bits <= "000001110000";
                    when 1  => bits <= "000011110000";
                    when 2  => bits <= "000111110000";
                    when 3  => bits <= "001111110000";
                    when 4  => bits <= "000011110000";
                    when 5  => bits <= "000011110000";
                    when 6  => bits <= "000011110000";
                    when 7  => bits <= "000011110000";
                    when 8  => bits <= "000011110000";
                    when 9  => bits <= "000011110000";
                    when 10 => bits <= "000011110000";
                    when 11 => bits <= "000011110000";
                    when 12 => bits <= "000011110000";
                    when 13 => bits <= "000011110000";
                    when 14 => bits <= "000011110000";
                    when 15 => bits <= "011111111110";
                    when 16 => bits <= "011111111110";
                    when others => bits <= (others => '0');
                end case;

            -- "2"
            when "0010" =>
                case row is
                    when 0  => bits <= "000111111000";
                    when 1  => bits <= "001111111100";
                    when 2  => bits <= "011100001110";
                    when 3  => bits <= "011000000110";
                    when 4  => bits <= "000000000110";
                    when 5  => bits <= "000000001110";
                    when 6  => bits <= "000000011100";
                    when 7  => bits <= "000000111000";
                    when 8  => bits <= "000001110000";
                    when 9  => bits <= "000011100000";
                    when 10 => bits <= "000111000000";
                    when 11 => bits <= "001110000000";
                    when 12 => bits <= "011100000000";
                    when 13 => bits <= "011000000000";
                    when 14 => bits <= "011000000000";
                    when 15 => bits <= "011111111110";
                    when 16 => bits <= "011111111110";
                    when others => bits <= (others => '0');
                end case;

            -- "3"
            when "0011" =>
                case row is
                    when 0  => bits <= "000111111000";
                    when 1  => bits <= "001111111100";
                    when 2  => bits <= "011100001110";
                    when 3  => bits <= "011000000110";
                    when 4  => bits <= "000000000110";
                    when 5  => bits <= "000000001110";
                    when 6  => bits <= "000011111100";
                    when 7  => bits <= "000011111100";
                    when 8  => bits <= "000000001110";
                    when 9  => bits <= "000000000110";
                    when 10 => bits <= "000000000110";
                    when 11 => bits <= "000000000110";
                    when 12 => bits <= "000000000110";
                    when 13 => bits <= "011000000110";
                    when 14 => bits <= "011100001110";
                    when 15 => bits <= "001111111100";
                    when 16 => bits <= "000111111000";
                    when others => bits <= (others => '0');
                end case;

            -- "4"
            when "0100" =>
                case row is
                    when 0  => bits <= "000000111100";
                    when 1  => bits <= "000001111100";
                    when 2  => bits <= "000011011100";
                    when 3  => bits <= "000110011100";
                    when 4  => bits <= "001100011100";
                    when 5  => bits <= "011000011100";
                    when 6  => bits <= "011000011100";
                    when 7  => bits <= "011000011100";
                    when 8  => bits <= "011111111110";
                    when 9  => bits <= "011111111110";
                    when 10 => bits <= "000000011100";
                    when 11 => bits <= "000000011100";
                    when 12 => bits <= "000000011100";
                    when 13 => bits <= "000000011100";
                    when 14 => bits <= "000000011100";
                    when 15 => bits <= "000000011100";
                    when others => bits <= (others => '0');
                end case;

            -- "5"
            when "0101" =>
                case row is
                    when 0  => bits <= "011111111110";
                    when 1  => bits <= "011111111110";
                    when 2  => bits <= "011000000000";
                    when 3  => bits <= "011000000000";
                    when 4  => bits <= "011000000000";
                    when 5  => bits <= "011000000000";
                    when 6  => bits <= "011111111000";
                    when 7  => bits <= "011111111100";
                    when 8  => bits <= "000000001110";
                    when 9  => bits <= "000000000110";
                    when 10 => bits <= "000000000110";
                    when 11 => bits <= "000000000110";
                    when 12 => bits <= "000000000110";
                    when 13 => bits <= "011000000110";
                    when 14 => bits <= "011100001110";
                    when 15 => bits <= "001111111100";
                    when 16 => bits <= "000111111000";
                    when others => bits <= (others => '0');
                end case;

            -- "6"
            when "0110" =>
                case row is
                    when 0  => bits <= "000111111000";
                    when 1  => bits <= "001111111100";
                    when 2  => bits <= "011100001110";
                    when 3  => bits <= "011000000110";
                    when 4  => bits <= "011000000000";
                    when 5  => bits <= "011000000000";
                    when 6  => bits <= "011111111000";
                    when 7  => bits <= "011111111100";
                    when 8  => bits <= "011100001110";
                    when 9  => bits <= "011000000110";
                    when 10 => bits <= "011000000110";
                    when 11 => bits <= "011000000110";
                    when 12 => bits <= "011000000110";
                    when 13 => bits <= "011000000110";
                    when 14 => bits <= "011100001110";
                    when 15 => bits <= "001111111100";
                    when 16 => bits <= "000111111000";
                    when others => bits <= (others => '0');
                end case;

            -- "7"
            when "0111" =>
                case row is
                    when 0  => bits <= "011111111110";
                    when 1  => bits <= "011111111110";
                    when 2  => bits <= "000000001110";
                    when 3  => bits <= "000000011100";
                    when 4  => bits <= "000000111000";
                    when 5  => bits <= "000001110000";
                    when 6  => bits <= "000011100000";
                    when 7  => bits <= "000111000000";
                    when 8  => bits <= "001110000000";
                    when 9  => bits <= "001110000000";
                    when 10 => bits <= "001110000000";
                    when 11 => bits <= "001110000000";
                    when 12 => bits <= "001110000000";
                    when 13 => bits <= "001110000000";
                    when 14 => bits <= "001110000000";
                    when 15 => bits <= "001110000000";
                    when others => bits <= (others => '0');
                end case;

            -- "8"
            when "1000" =>
                case row is
                    when 0  => bits <= "000111111000";
                    when 1  => bits <= "001111111100";
                    when 2  => bits <= "011100001110";
                    when 3  => bits <= "011000000110";
                    when 4  => bits <= "011000000110";
                    when 5  => bits <= "011000000110";
                    when 6  => bits <= "001111111100";
                    when 7  => bits <= "001111111100";
                    when 8  => bits <= "011000000110";
                    when 9  => bits <= "011000000110";
                    when 10 => bits <= "011000000110";
                    when 11 => bits <= "011000000110";
                    when 12 => bits <= "011000000110";
                    when 13 => bits <= "011000000110";
                    when 14 => bits <= "011100001110";
                    when 15 => bits <= "001111111100";
                    when 16 => bits <= "000111111000";
                    when others => bits <= (others => '0');
                end case;

            -- "9"
            when "1001" =>
                case row is
                    when 0  => bits <= "000111111000";
                    when 1  => bits <= "001111111100";
                    when 2  => bits <= "011100001110";
                    when 3  => bits <= "011000000110";
                    when 4  => bits <= "011000000110";
                    when 5  => bits <= "011000000110";
                    when 6  => bits <= "011100001110";
                    when 7  => bits <= "001111111110";
                    when 8  => bits <= "000111111110";
                    when 9  => bits <= "000000000110";
                    when 10 => bits <= "000000000110";
                    when 11 => bits <= "000000000110";
                    when 12 => bits <= "000000000110";
                    when 13 => bits <= "011000000110";
                    when 14 => bits <= "011100001110";
                    when 15 => bits <= "001111111100";
                    when 16 => bits <= "000111111000";
                    when others => bits <= (others => '0');
                end case;

            when others =>
                bits <= (others => '0');
        end case;
    end process;
end architecture rtl;
