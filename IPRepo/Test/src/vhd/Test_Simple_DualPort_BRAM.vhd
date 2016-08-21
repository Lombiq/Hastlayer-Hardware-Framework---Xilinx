library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
		
entity Test_Simple_DualPort_BRAM is
end Test_Simple_DualPort_BRAM;
		
architecture Imp of Test_Simple_DualPort_BRAM is
		
	component Counter
		generic(
			width : natural:= 32
		);
		port(
			Clock    : in  std_logic;
			Reset    : in  std_logic;
			Ena      : in  std_logic;
			Load     : in  std_logic;
			UpDown   : in  std_logic;
			Data_in  : in  std_logic_vector(width-1 downto 0);
			Data_out : out std_logic_vector(width-1 downto 0)
		);
	end component;
		
	component Simple_DualPort_BRAM
		port(  
			Clock_in        : in  std_logic;
			Reset_in        : in  std_logic;
			--Data  
			Data_in         : in  std_logic_vector(31 downto 0);
			Data_out        : out std_logic_vector(31 downto 0);
			--Address
			WriteAddress_in : in  std_logic_vector(9 downto 0);
			ReadAddress_in  : in  std_logic_vector(9 downto 0);
			--Control  
			ReadEnable_in   : in  std_logic;
			WriteEnable_in  : in  std_logic;
			Wena            : in  std_logic_vector(3 downto 0);
			RegCe_In        : in  std_logic
		);
	end component;
		
	-- Clock period definitions
	constant Clock_period     : time := 10 ns;
	constant Clock_periodDiv2 : time := 5  ns;
		
	constant Counter_width    : natural := 32;
		
	--General purpose signals
	signal Reset        : std_logic:= '1';
	signal Clock        : std_logic:= '0';
		
	--Counter signals
	signal Counter_Ena      : std_logic;-- := '0';
	signal Counter_Load     : std_logic := '0';
	signal Counter_Data_in  : std_logic_vector(31 downto 0) := (others => '0');
	signal Counter_Data_Out : std_logic_vector(31 downto 0);-- := (others => '0');
	signal Rst_Counter      : std_logic := '0';
	signal Reset_Counter    : std_logic := '0';
		
	--Simple_DualPort_BRAM signals
	signal DataIn       : std_logic_vector(31 downto 0) := (others => '0');
	signal DataOut      : std_logic_vector(31 downto 0) := (others => '0');
	signal WriteAddress : std_logic_vector(31 downto 0) := (others => '0');
	signal ReadAddress  : std_logic_vector(31 downto 0) := (others => '0');
	signal ReadEnable   : std_logic := '0';
	signal WriteEnable  : std_logic := '0';
	signal Wena         : std_logic_vector(3 downto 0) := (others => '0');
	signal RegCe        : std_logic := '0';
		
	--State macine states
	type SM_BRAM is (ST00_Idle,
					 ST01_WriteToDDR,
					 ST02_ResetCounter,
					 ST03_ReadFromDDR); 
	signal state_BRAM, next_state_BRAM : SM_BRAM; 
		
begin
		
	--Counter
	BRAM_Counter: Counter
		generic map(
			width => Counter_width
		)
		port map(
			Clock    => Clock,
			Reset    => Reset_Counter,
			Ena      => Counter_Ena,
			Load     => Counter_Load,
			UpDown   => '1',
			Data_in  => Counter_Data_in,
			Data_out => Counter_Data_Out
		);
		
	WriteAddress  <= Counter_Data_Out;
	ReadAddress   <= Counter_Data_Out;
	DataIn        <= Counter_Data_Out;
	Reset_Counter <= Reset or Rst_Counter;
		
	-- Unit Under Test
	UUT : Simple_DualPort_BRAM
		port map(
			Clock_in        => Clock,
			Reset_in        => Reset,
			--Data  
			Data_in         => DataIn, 
			Data_out        => DataOut,
			--Address
			WriteAddress_in => WriteAddress(9 downto 0),
			ReadAddress_in  => ReadAddress(9 downto 0),
			--Control  
			ReadEnable_in   => ReadEnable, 
			WriteEnable_in  => WriteEnable,
			Wena            => Wena, 
			RegCe_In        => RegCe
		); 
		
	Clock_process :process
	begin
		Clock <= '0';
		wait for Clock_periodDiv2;
		Clock <= '1';
		wait for Clock_periodDiv2;
	end process; 
		
	-- Stimulus process
	Stim_proc: process
	begin
		-- hold reset state for 100 ns.
		wait for 105 ns;
		--Reset <= '1';
		wait for 100 ns;
		Reset <= '0';
		wait for 20 ns;
	end process;
		
	--SM_BRAM STATE MACHINE---  
	--SYNC Process of SM_BRAM
	SYNC_PROC: process (Clock)
	begin
		if (rising_edge(Clock)) then
			if Reset = '1' then
				state_BRAM <= ST00_Idle;
			else
				state_BRAM <= next_state_BRAM;   
			end if;  
		end if;
	end process;
	
	--NEXT_STATE_DECODE of SM_BRAM
	NEXT_STATE_DECODE: process (state_BRAM, Counter_Data_Out)
	begin
		next_state_BRAM <= state_BRAM;  --default is to stay in current state
		case (state_BRAM) is
			when ST00_Idle =>
				next_state_BRAM <= ST01_WriteToDDR;
			when ST01_WriteToDDR =>                       
				if Counter_Data_Out = x"000003FF" then
					next_state_BRAM <= ST02_ResetCounter;
				end if;
			when ST02_ResetCounter =>
				next_state_BRAM <= ST03_ReadFromDDR;
			when ST03_ReadFromDDR =>
				if Counter_Data_Out = x"000003FF" then
					next_state_BRAM <= ST00_Idle;
				end if;
			when others => null;        
		end case;      
	end process; 
		
		
	--OUTPUT_DECODE of SM_BRAM
	OUTPUT_DECODE: process (state_BRAM)
	begin
		case (state_BRAM) is
			when ST00_Idle               =>
				ReadEnable   <= '0';
				WriteEnable  <= '0';
				Wena         <= x"0";
				Counter_Ena  <= '0';
				Rst_Counter  <= '0';
			when ST01_WriteToDDR         =>
				ReadEnable   <= '0';
				WriteEnable  <= '1';
				Wena         <= x"F";
				Counter_Ena  <= '1';
				Rst_Counter  <= '0';
			when ST02_ResetCounter       =>
				ReadEnable   <= '0';
				WriteEnable  <= '0';
				Wena         <= x"0";
				Counter_Ena  <= '0';
				Rst_Counter  <= '1';
			when ST03_ReadFromDDR        =>
				ReadEnable   <= '1';
				WriteEnable  <= '0';
				Wena         <= x"0";
				Counter_Ena  <= '1';
				Rst_Counter  <= '0';
			when others => null;               
		end case;       
	end process; 
		
end Imp;