library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.snake_package.all;

entity joysticks is
	port(
--		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		PLL_10MHz  : in std_logic;
		locked	  : in std_logic;
			
		joy1 : out direction; -- 2-bit direction vector - 0123/UDLR
		joy2 : out direction; 

		KEY: in std_logic_vector(1 downto 0)
--		LEDR: out std_logic_vector(1 downto 0) --debugging
	);
end entity joysticks;

architecture behavioral of joysticks is

	signal adc0_val : std_logic_vector(11 downto 0);
	signal adc0_nxt : std_logic_vector(11 downto 0);
	signal adc1_val : std_logic_vector(11 downto 0);
	signal adc1_nxt : std_logic_vector(11 downto 0);
	signal adc2_val : std_logic_vector(11 downto 0);
	signal adc2_nxt : std_logic_vector(11 downto 0);
	signal adc3_val : std_logic_vector(11 downto 0);
	signal adc3_nxt : std_logic_vector(11 downto 0);
	
	signal joy1_V : std_logic_vector(1 downto 0); -- ADC0 0:L, 1:M, 2:H, 3:N/A
	signal joy1_H : std_logic_vector(1 downto 0); -- ADC1 
	signal joy2_V : std_logic_vector(1 downto 0); -- ADC2
	signal joy2_H : std_logic_vector(1 downto 0); -- ADC3
	
	signal joy1_nxt : direction;
	signal joy2_nxt : direction;
	signal joy1_lst : direction;
	signal joy2_lst : direction;
	
	constant DELAY_2     : integer:=500;	--adc channel swap delay
	signal sample_delay  : integer range 0 to DELAY_2;
	signal nsample_delay : integer range 0 to DELAY_2;
	
	type state_type_adc is (READ_CH0, WAIT0, READ_CH1, WAIT1, READ_CH2, WAIT2, READ_CH3, WAIT3);
	signal state, next_state : state_type_adc;

	--ADC signals 
	signal CONNECTED_TO_command_valid				: std_logic:='1'; --valid/always send command
	signal CONNECTED_TO_command_channel				: std_logic_vector(4 downto 0); --channel
	signal next_channel									: std_logic_vector(4 downto 0); --channel
	constant CONNECTED_TO_command_startofpacket	: std_logic:='1';	--IGNORE(?)
	constant CONNECTED_TO_command_endofpacket		: std_logic:='1';	--IGNORE(?)
	signal CONNECTED_TO_command_ready				: std_logic;
	signal CONNECTED_TO_response_valid				: std_logic;
	signal CONNECTED_TO_response_channel			: std_logic_vector(4 downto 0);
	signal CONNECTED_TO_response_data				: std_logic_vector(11 downto 0);
	signal CONNECTED_TO_response_startofpacket	: std_logic;
	signal CONNECTED_TO_response_endofpacket		: std_logic;
		
	
	component joystick_adc_2ch is
		port (
			clock_clk              : in  std_logic                     := 'X';             -- clk
			reset_sink_reset_n     : in  std_logic                     := 'X';             -- reset_n
			adc_pll_clock_clk      : in  std_logic                     := 'X';             -- clk
			adc_pll_locked_export  : in  std_logic                     := 'X';             -- export
			command_valid          : in  std_logic                     := 'X';             -- valid
			command_channel        : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- channel
			command_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
			command_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
			command_ready          : out std_logic;                                        -- ready
			response_valid         : out std_logic;                                        -- valid
			response_channel       : out std_logic_vector(4 downto 0);                     -- channel
			response_data          : out std_logic_vector(11 downto 0);                    -- data
			response_startofpacket : out std_logic;                                        -- startofpacket
			response_endofpacket   : out std_logic                                         -- endofpacket
		);
	end component joystick_adc_2ch;
	
	
begin --architecture
	
	joystick_adc_2ch_inst : component joystick_adc_2ch
		port map (
			clock_clk              => MAX10_CLK1_50,              --          clock.clk
			reset_sink_reset_n     => KEY(0),     --     reset_sink.reset_n
			adc_pll_clock_clk      => PLL_10MHz,      --  adc_pll_clock.clk
			adc_pll_locked_export  => locked,  -- adc_pll_locked.export
			command_valid          => CONNECTED_TO_command_valid,          --        command.valid
			command_channel        => CONNECTED_TO_command_channel,        --               .channel
			command_startofpacket  => CONNECTED_TO_command_startofpacket,  --               .startofpacket
			command_endofpacket    => CONNECTED_TO_command_endofpacket,    --               .endofpacket
			command_ready          => CONNECTED_TO_command_ready,          --               .ready
			response_valid         => CONNECTED_TO_response_valid,         --       response.valid
			response_channel       => CONNECTED_TO_response_channel,       --               .channel
			response_data          => CONNECTED_TO_response_data,          --               .data
			response_startofpacket => CONNECTED_TO_response_startofpacket, --               .startofpacket
			response_endofpacket   => CONNECTED_TO_response_endofpacket    --               .endofpacket
		);
	
	
	process (MAX10_CLK1_50, KEY(0))
	begin

		if KEY(0) = '0' then
			--reset
			state <= READ_CH0;
			adc0_val <= X"100";
			adc1_val <= X"100";
			adc2_val <= X"100";
			adc3_val <= X"100";
			sample_delay <= 0;

			--areset <= '1'; --reset PLL(?)

			joy1 <= RIGHT_DIR; --Default is RIGHT
			joy2 <= RIGHT_DIR;
						
--			LEDR <= (others => '0');
			
		elsif rising_edge(MAX10_CLK1_50) then
			--clocked processes
			--areset <= '0'; 
			
			state <= next_state;
			CONNECTED_TO_command_channel <= next_channel;
			
			--Read in ADC channel
			if(CONNECTED_TO_response_valid = '1') then
				if (CONNECTED_TO_response_channel = "00001") then
					adc0_val <= CONNECTED_TO_response_data;
					adc1_val <= adc1_nxt;
					adc2_val <= adc2_nxt;
					adc3_val <= adc3_nxt;
				elsif (CONNECTED_TO_response_channel = "00010") then
					adc0_val <= adc0_nxt;
					adc1_val <= CONNECTED_TO_response_data;
					adc2_val <= adc2_nxt;
					adc3_val <= adc3_nxt;
				elsif (CONNECTED_TO_response_channel = "00011") then
					adc0_val <= adc0_nxt;
					adc1_val <= adc1_nxt;
					adc2_val <= CONNECTED_TO_response_data;
					adc3_val <= adc3_nxt;
				elsif (CONNECTED_TO_response_channel = "00100") then
					adc0_val <= adc0_nxt;
					adc1_val <= adc1_nxt;
					adc2_val <= adc2_nxt;
					adc3_val <= CONNECTED_TO_response_data;
				else
					adc0_val <= adc0_nxt;
					adc1_val <= adc1_nxt;
					adc2_val <= adc2_nxt;
					adc3_val <= adc3_nxt;				
				end if; --read in channels
			end if;
			
			--turn off leds(?)
--			LEDR <= (others => '0');
			
			--timer incrementing
			sample_delay <= nsample_delay;
			
			--update joystick output
			joy1 <= joy1_nxt;
			joy2 <= joy2_nxt;
			joy1_lst <= joy1_nxt;
			joy2_lst <= joy2_nxt;
			
			
			
		end if;
	end process; --10MHz
	
	
	
	
	process (CONNECTED_TO_command_ready, CONNECTED_TO_response_valid, CONNECTED_TO_response_channel, CONNECTED_TO_response_data)
	begin
		
		--State machine: adc channel swapping
			--command always valid - continuous reading
		case state is
			--idle
			--set channel to CH0
			when READ_CH0 =>
				nsample_delay <= 0;
				if CONNECTED_TO_command_ready = '1' then
					next_state <= WAIT0;
					next_channel <= "00001";
				else
					next_state <= READ_CH0;
					next_channel <= "00001";
				end if;
			--wait for CH1 to read
			when WAIT0 =>
				next_channel <= "00001";
				if CONNECTED_TO_command_ready = '0' and sample_delay = DELAY_2 then --start of reading adc block
					next_state <= WAIT0;
					nsample_delay <= sample_delay +1;
				else
					next_state <= READ_CH1;
					nsample_delay <= 0;
				end if;
			
			--set channel to CH1
			when READ_CH1 =>
				nsample_delay <= 0;
				if CONNECTED_TO_command_ready = '1' then
					next_state <= WAIT1;
					next_channel <= "00010";
				else
					next_state <= READ_CH1;
					next_channel <= "00010";
				end if;
			--wait for CH1 to read
			when WAIT1 =>
				next_channel <= "00010";
				nsample_delay <= 0;
				if CONNECTED_TO_command_ready = '1' then
					next_state <= WAIT1;
				else
					next_state <= READ_CH2;
					nsample_delay <= 0;
				end if;			
				

				when READ_CH2 =>
				nsample_delay <= 0;
				if CONNECTED_TO_command_ready = '1' then
					next_state <= WAIT2;
					next_channel <= "00011";
				else
					next_state <= READ_CH2;
					next_channel <= "00011";
				end if;
			when WAIT2 =>
				next_channel <= "00011";
				nsample_delay <= 0;
				if CONNECTED_TO_command_ready = '1' then
					next_state <= WAIT2;
				else
					next_state <= READ_CH3;
					nsample_delay <= 0;
				end if;			

				
				when READ_CH3 =>
				nsample_delay <= 0;
				if CONNECTED_TO_command_ready = '1' then
					next_state <= WAIT3;
					next_channel <= "00100";
				else
					next_state <= READ_CH3;
					next_channel <= "00100";
				end if;
			when WAIT3 =>
				next_channel <= "00011";
				nsample_delay <= 0;
				if CONNECTED_TO_command_ready = '1' then
					next_state <= WAIT3;
				else
					next_state <= READ_CH0;
					nsample_delay <= 0;
				end if;								
			
			when others =>
				nsample_delay <= 0;
				next_state <= READ_CH0;
				next_channel <= "00001";
		end case;
	
	--Hold previous values
	adc0_nxt <= adc0_val;
	adc1_nxt <= adc1_val;
	adc2_nxt <= adc2_val;
	adc3_nxt <= adc3_val;
	
	--additional timer???		

	end process; --channel updates
		
	process(adc0_val, adc1_val, adc2_val, adc3_val, KEY(0))
	begin
		if KEY(0) = '0' then
			joy1_nxt <= RIGHT_DIR;
			joy2_nxt <= RIGHT_DIR;

		else
		
			--JOYSTICK #1 - adc0 & adc1
			if (adc0_val >= X"000" AND adc0_val < x"500") then --joy1 down case
				if (adc0_val < adc1_val) then		--if DOWN
					joy1_nxt <= DOWN_DIR;
				else										--if LEFT
					joy1_nxt <= LEFT_DIR;
				end if;
				
			elsif (adc0_val > X"900" AND adc0_val <= x"FFF") then --joy1 up case
				if (adc0_val > adc1_val) then		--if UP
					joy1_nxt <= UP_DIR;
				else										--if RIGHT
					joy1_nxt <= RIGHT_DIR;
				end if;
				
			else
				if (adc1_val >= X"000" AND adc1_val < x"500") then	--joy1 LEFT mid
					joy1_nxt <= LEFT_DIR;
				elsif (adc1_val > X"900" AND adc1_val <= x"FFF") then	--joy1 RIGHT mid
					joy1_nxt <= RIGHT_DIR;
				else
					joy1_nxt <= joy1_lst; --middle: retain last direction
				end if;				
			end if;

			
			--JOYSTICK #2 - adc2 & adc3
			if (adc2_val >= X"000" AND adc2_val < x"500") then --joy2 down case
				if (adc2_val < adc3_val) then		--if DOWN
					joy2_nxt <= DOWN_DIR;
				else										--if LEFT
					joy2_nxt <= LEFT_DIR;
				end if;
				
			elsif (adc2_val > X"900" AND adc2_val <= x"FFF") then --joy2 up case
				if (adc2_val > adc3_val) then		--if UP
					joy2_nxt <= UP_DIR;
				else										--if RIGHT
					joy2_nxt <= RIGHT_DIR;
				end if;
				
			else
				if (adc3_val >= X"000" AND adc3_val < x"500") then	--joy2 LEFT mid
					joy2_nxt <= LEFT_DIR;
				elsif (adc3_val > X"900" AND adc3_val <= x"FFF") then	--joy2 RIGHT mid
					joy2_nxt <= RIGHT_DIR;
				else
					joy2_nxt <= joy2_lst; --middle: retain last direction
				end if;				
			end if;
			
			
		end if;
	
	end process;

	
end architecture behavioral;