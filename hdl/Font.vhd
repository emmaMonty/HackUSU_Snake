library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Font is
    port (
        ch : in  unsigned(2 downto 0);          
        row   : in  integer range 0 to 19;        
        bits  : out std_logic_vector(11 downto 0)  
    );
end entity Font;
architecture arch of Font is
    begin
        process(ch, row)
        begin
            case ch is
                when "000" =>  -- 'H"
                case row is 
                    when 1  => bits <= "111000000111";
                    when 2  => bits <= "111000000111";
                    when 3  => bits <= "111000000111";
                    when 4  => bits <= "111000000111";
                    when 5  => bits <= "111000000111";
                    when 6  => bits <= "111000000111";
                    when 7  => bits <= "111000000111";
                    when 8  => bits <= "111111111111";
                    when 9  => bits <= "111111111111";
                    when 10 => bits <= "111111111111";
                    when 11 => bits <= "111000000111";
                    when 12 => bits <= "111000000111";
                    when 13 => bits <= "111000000111";
                    when 14 => bits <= "111000000111";
                    when 15 => bits <= "111000000111";
                    when 16 => bits <= "111000000111";
                    when others => bits <= (others => '0');
                end case;
                
                when "001" =>  -- 'A'
                case row is 
                    when 1  => bits <= "111111111111";
                    when 2  => bits <= "111111111111";
                    when 3  => bits <= "111000000111";
                    when 4  => bits <= "111000000111";
                    when 5  => bits <= "111000000111";
                    when 6  => bits <= "111000000111";
                    when 7  => bits <= "111000000111";
                    when 8  => bits <= "111000000111";
                    when 9  => bits <= "111111111111";
                    when 10 => bits <= "111111111111";
                    when 11 => bits <= "111000000111";
                    when 12 => bits <= "111000000111";
                    when 13 => bits <= "111000000111";
                    when 14 => bits <= "111000000111";
                    when 15 => bits <= "111000000111";
                    when 16 => bits <= "111000000111";
                    when others => bits <= (others => '0');
                end case;
                when "010" =>  -- 'C'
                case row is 
                    when 1  => bits <= "111111111111";
                    when 2  => bits <= "111111111111";
                    when 3  => bits <= "111000000111";
                    when 4  => bits <= "111000000000";
                    when 5  => bits <= "111000000000";
                    when 6  => bits <= "111000000000";
                    when 7  => bits <= "111000000000";
                    when 8  => bits <= "111000000000";
                    when 9  => bits <= "111000000000";
                    when 10 => bits <= "111000000000";
                    when 11 => bits <= "111000000000";
                    when 12 => bits <= "111000000000";
                    when 13 => bits <= "111000000000";
                    when 14 => bits <= "111000000111";
                    when 15 => bits <= "111111111111";
                    when 16 => bits <= "111111111111";
                    when others => bits <= (others => '0');
                end case;
                when "011" =>  -- 'k'
                case row is    
                    when 1  => bits <= "111000000111";
                    when 2  => bits <= "111000001110";
                    when 3  => bits <= "111000011100";
                    when 4  => bits <= "111000111000";
                    when 5  => bits <= "111001110000";
                    when 6  => bits <= "111111100000";
                    when 7  => bits <= "111111000000";
                    when 8  => bits <= "111100000000";
                    when 9  => bits <= "111100000000";
                    when 10 => bits <= "111111000000";
                    when 11 => bits <= "111011100000";
                    when 12 => bits <= "111001110000";
                    when 13 => bits <= "111000111000";
                    when 14 => bits <= "111000011100";
                    when 15 => bits <= "111000001110";
                    when 16 => bits <= "111000000111";
                    when others => bits <= (others => '0');
                end case;
                when "100" =>  -- 'U'
                case row is
                    when 1  => bits <= "111000000111";
                    when 2  => bits <= "111000000111";
                    when 3  => bits <= "111000000111";
                    when 4  => bits <= "111000000111";
                    when 5  => bits <= "111000000111";
                    when 6  => bits <= "111000000111";
                    when 7  => bits <= "111000000111";
                    when 8  => bits <= "111000000111";
                    when 9  => bits <= "111000000111";
                    when 10 => bits <= "111000000111";
                    when 11 => bits <= "111000000111";
                    when 12 => bits <= "111000000111";
                    when 13 => bits <= "111000000111";
                    when 14 => bits <= "111000000111";
                    when 15 => bits <= "111111111111";
                    when 16 => bits <= "111111111111";
                    when others => bits <= (others => '0');
                end case;
                when "101" =>  -- 'S'
                case row is
                    when 1  => bits <= "111111111111";
                    when 2  => bits <= "111111111111";
                    when 3  => bits <= "110000000000";
                    when 4  => bits <= "110000000000";
                    when 5  => bits <= "110000000000";
                    when 6  => bits <= "110000000000";
                    when 7  => bits <= "110000000000";
                    when 8  => bits <= "111111111111";
                    when 9  => bits <= "111111111111";
                    when 10 => bits <= "000000000011";
                    when 11 => bits <= "000000000011";
                    when 12 => bits <= "000000000011";
                    when 13 => bits <= "000000000011";
                    when 14 => bits <= "000000000011";
                    when 15 => bits <= "111111111111";
                    when 16 => bits <= "111111111111";
                    when others => bits <= (others => '0');
                end case;
			    when others =>
                    bits <= (others => '0');
                end case;
        end process;    

end architecture arch;