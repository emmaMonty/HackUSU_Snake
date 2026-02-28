library 1eee;
use ieee.std_logic_1164.all;
use ieee.number_std.all;

entity joysticks is
	port(
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
		
		joy1 : out std_logic_vector(1 downto 0); -- 2-bit direction vector - 0123/UDLR
		joy2 : out std_logic_vector(1 downto 0); 
	
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
	
	component pll_10MHz_inst is
		port (
			areset	:
			inclk0	:
			c0			:
			locked	:
		);

--ADC signals 
signal CONNECTED_TO_command_valid			: std_logic:='1'; --valid/always send command
signal CONNECTED_TO_command_channel			: std_logic_vector(4 downto 0); --channel
signal next_channel							: std_logic_vector(4 downto 0); --channel
constant CONNECTED_TO_command_startofpacket	: std_logic:='1';	--IGNORE(?)
constant CONNECTED_TO_command_endofpacket	: std_logic:='1';	--IGNORE(?)
signal CONNECTED_TO_command_ready			: std_logic;
signal CONNECTED_TO_response_valid			: std_logic;
signal CONNECTED_TO_response_channel		: std_logic_vector(4 downto 0);
signal CONNECTED_TO_response_data			: std_logic_vector(11 downto 0);
signal CONNECTED_TO_response_startofpacket	: std_logic;
signal CONNECTED_TO_response_endofpacket	: std_logic;
	
	
begin
	
	adc_u0 : component joystick_adc_2ch
		port map (
			clock_clk              => CONNECTED_TO_clock_clk,              --          clock.clk
			reset_sink_reset_n     => CONNECTED_TO_reset_sink_reset_n,     --     reset_sink.reset_n
			adc_pll_clock_clk      => CONNECTED_TO_adc_pll_clock_clk,      --  adc_pll_clock.clk
			adc_pll_locked_export  => CONNECTED_TO_adc_pll_locked_export,  -- adc_pll_locked.export
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
		
	pll_10MHz_inst : component pll_10MHz 
		PORT MAP (
			areset	 => areset_sig,
			inclk0	 => inclk0_sig,
			c0	 => c0_sig,
			locked	 => locked_sig
		);
	
	
end architecture behavioral;

