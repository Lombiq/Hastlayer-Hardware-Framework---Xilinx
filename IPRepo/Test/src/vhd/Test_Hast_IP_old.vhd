library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library Hast;
use Hast.SimpleMemory.all;
		
entity Test_Hast_IP is
end Test_Hast_IP;
		
architecture Imp of Test_Hast_IP is
		
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
		
	--component Simple_DualPort_BRAM
	--	port(  
	--		Clock_in        : in  std_logic;
	--		Reset_in        : in  std_logic;
	--		--Data  
	--		Data_in         : in  std_logic_vector(31 downto 0);
	--		Data_out        : out std_logic_vector(31 downto 0);
	--		--Address
	--		WriteAddress_in : in  std_logic_vector(9 downto 0);
	--		ReadAddress_in  : in  std_logic_vector(9 downto 0);
	--		--Control  
	--		ReadEnable_in   : in  std_logic;
	--		WriteEnable_in  : in  std_logic;
	--		Wena            : in  std_logic_vector(3 downto 0);
	--		RegCe_In        : in  std_logic
	--	);
	--end component;
	
	component Simple_BRAM is
		port(
		clk          : in  std_logic;
		readaddress  : in  std_logic_vector(31 downto 0);
		writeaddress : in  std_logic_vector(31 downto 0);
		we           : in  std_logic;
		re           : in  std_logic;
		data_i       : in  std_logic_vector(31 downto 0);
		data_o       : out std_logic_vector(31 downto 0)
	);
	end component;
		
	--component Hast_IP
	--	port(
	--		\Clock\        : in  std_logic;
	--		\MemberId\     : in  integer;
	--		\Reset\        : In  std_logic;
	--		\DataIn\       : in  std_logic_vector(31 downto 0);
	--		\DataOut\      : out std_logic_vector(31 downto 0);
	--		\WriteAddress\ : out std_logic_vector(31 downto 0);
	--		\WriteEnable\  : out std_logic;
	--		\ReadAddress\  : out std_logic_vector(31 downto 0);
	--		\ReadEnable\   : out std_logic;
	--		\CellIndex\    : in  integer;
	--		\Started\      : in  std_logic;
	--		\Finished\     : out std_logic
	--	); 
	--end component;
		
	component Hast_ip_wrapper
	port (
		Hast_IP_Clk_in          : in  std_logic;
		Hast_IP_Rst_in          : in  std_logic;
		Hast_IP_MemberId_in     : in  std_logic_vector(31 downto 0);
		Hast_IP_Data_in         : in  std_logic_vector(31 downto 0);
		Hast_IP_Data_out        : out std_logic_vector(31 downto 0);
		Hast_IP_Read_Addr_out   : out std_logic_vector(31 downto 0);
		Hast_IP_Read_Ena_out    : out std_logic;
		Hast_IP_Write_Addr_out  : out std_logic_vector(31 downto 0);
		Hast_IP_Write_Ena_out   : out std_logic;
		--Hast_IP_CellIndex_in   : in  std_logic_vector(31 downto 0);
		Hast_IP_Started_in      : in  std_logic;
		Hast_IP_FinishedAck_in  : in  std_logic;
		Hast_IP_Finished_out    : out std_logic;
		Hast_IP_Performance_out : out std_logic_vector(31 downto 0)
		--Hast_IP_Debug_out       : out std_logic_vector(255 downto 0)
	);
	end component;
		
	-- Clock period definitions
	constant Clock_period     : time := 10 ns;
	constant Clock_periodDiv2 : time := 5  ns;
		
	constant Counter_width    : natural := 32;
		
	--General purpose signals
	signal Reset                   : std_logic:= '1';
	signal Clock                   : std_logic:= '0';
		                           
	--signal MemberId                : integer := 1;
	signal MemberId                : std_logic_vector(31 downto 0) := x"00000002";
		                               
	--Counter signals              
	signal Rst_Counter             : std_logic := '0';
	signal Reset_Counter           : std_logic := '0';
		                               
	signal Address_Counter_Ena     : std_logic;
	signal Address_Counter_Load    : std_logic := '0';
	signal Address_Counter_UpDown  : std_logic := '1';
	signal Address_Counter_DataIn  : std_logic_vector(31 downto 0);
	signal Address_Counter_DataOut : std_logic_vector(31 downto 0);
		
	signal Data_Counter_Ena        : std_logic;                    
	signal Data_Counter_Load       : std_logic := '1';             
	signal Data_Counter_UpDown     : std_logic := '1';             
	signal Data_Counter_DataIn     : std_logic_vector(31 downto 0);
	signal Data_Counter_DataOut    : std_logic_vector(31 downto 0);
		
	--Simple_DualPort_BRAM signals
	signal BRAM_DataIn             : std_logic_vector(31 downto 0);
	signal BRAM_DataOut            : std_logic_vector(31 downto 0);
	signal BRAM_WriteAddress       : std_logic_vector(31 downto 0);
	signal BRAM_ReadAddress        : std_logic_vector(31 downto 0);
	signal BRAM_ReadEnable         : std_logic;
	signal BRAM_WriteEnable        : std_logic;
	signal BRAM_Wena               : std_logic_vector(3 downto 0);
	signal BRAM_RegCe              : std_logic := '0';
		
	signal BRAM_DataIn_from_HastIP : std_logic_vector(31 downto 0);    
	signal BRAM_WriteAddress_from_HastIP : std_logic_vector(31 downto 0);
	signal Started                 : std_logic := '0';
	signal BRAM_WriteEna           : std_logic := '0';
	signal BRAM_WriteEn            : std_logic := '0';
	--signal CellIndexOut            : integer := 0;
	--signal CellIndex               : std_logic_vector(31 downto 0) := x"00000005";
		
	--State macine states
	type SM_BRAM is (ST00_Idle,
					 ST01_Preload_Data_Counter,
					 ST02_WriteToDDR,
					 ST03_ResetCounter,
					 ST04_CalcProc
					 ); 
	signal state_Hast, next_state_Hast : SM_BRAM;
		                     
begin
		
	--Block Memory Address Counter
	BRAM_Address_Counter: Counter
		generic map(
			width => Counter_width
		)
		port map(
			Clock    => Clock,
			Reset    => Reset_Counter,
			Ena      => Address_Counter_Ena,
			Load     => Address_Counter_Load,
			UpDown   => Address_Counter_UpDown,
			Data_in  => Address_Counter_DataIn, 
			Data_out => Address_Counter_DataOut
		);
		
	--Block Memory Data Counter
	BRAM_Data_Counter: Counter
		generic map(
			width => Counter_width
		)
		port map(
			Clock    => Clock,                                     
			Reset    => Reset_Counter,                             
			Ena      => Data_Counter_Ena,                  
			Load     => Data_Counter_Load,                 
			UpDown   => Data_Counter_UpDown,               
			Data_in  => Data_Counter_DataIn, 
			Data_out => Data_Counter_DataOut               
		);
		
	BRAM_WriteAddress <= Address_Counter_DataOut when Address_Counter_Ena = '1' else BRAM_WriteAddress_from_HastIP;
	BRAM_DataIn       <= Data_Counter_DataOut when Data_Counter_Ena = '1' else BRAM_DataIn_from_HastIP;
	BRAM_WriteEna     <= BRAM_WriteEnable or BRAM_WriteEn;
	Reset_Counter     <= Reset or Rst_Counter;
		
	-- Simple DualPort BRAM peripheral instantiation
	--SDP_BRAM : Simple_DualPort_BRAM
	--	port map(
	--		Clock_in        => Clock,
	--		Reset_in        => Reset,
	--		--Data  
	--		Data_in         => BRAM_DataIn, 
	--		Data_out        => BRAM_DataOut,
	--		--Address
	--		WriteAddress_in => BRAM_WriteAddress(9 downto 0),
	--		ReadAddress_in  => BRAM_ReadAddress(9 downto 0),
	--		--Control  
	--		ReadEnable_in   => BRAM_ReadEnable, 
	--		WriteEnable_in  => BRAM_WriteEna,
	--		Wena            => BRAM_Wena, 
	--		RegCe_In        => BRAM_RegCe
	--	); 
		
	BRAM : Simple_BRAM 
	port map(
		clk          => Clock,
		readaddress  => BRAM_ReadAddress,
		writeaddress => BRAM_WriteAddress,
		we           => BRAM_WriteEna,
		re           => BRAM_ReadEnable,
		data_i       => BRAM_DataIn,
		data_o       => BRAM_DataOut
	);
		
		
	-- UUT peripheral instantiation
	--UUT : Hast_IP
	--	port map(
	--		\Clock\        => Clock,                                
	--		\Reset\        => Reset,                                
	--		\MemberId\     => MemberId,                             
	--		\DataIn\       => BRAM_DataOut,                         
	--		\DataOut\      => BRAM_DataIn_from_HastIP,              
	--		\WriteAddress\ => BRAM_WriteAddress_from_HastIP,        
	--		\WriteEnable\  => BRAM_WriteEnable,                     
	--		\ReadAddress\  => BRAM_ReadAddress,                     
	--		\ReadEnable\   => BRAM_ReadEnable,                      
	--		\CellIndexOut\ => CellIndexOut,                         
	--		\Started\      => Started,                              
	--		\FinishedAck\  => '0',
	--		\Finished\     => open
	--	); 
		
	UUT : Hast_ip_wrapper
	port map (
		Hast_IP_Clk_in          => Clock,
		Hast_IP_Rst_in          => Reset,
		Hast_IP_MemberId_in     => MemberId,
		Hast_IP_Data_in         => BRAM_DataOut,           
		Hast_IP_Data_out        => BRAM_DataIn_from_HastIP,
		Hast_IP_Read_Addr_out   => BRAM_ReadAddress, --BRAM_WriteAddress_from_HastIP,
		Hast_IP_Read_Ena_out    => BRAM_ReadEnable, --BRAM_WriteEnable,
		Hast_IP_Write_Addr_out  => BRAM_WriteAddress_from_HastIP, --BRAM_ReadAddress,
		Hast_IP_Write_Ena_out   => BRAM_WriteEnable, --BRAM_ReadEnable, 
		--Hast_IP_CellIndex_in   => CellIndex,
		Hast_IP_Started_in      => Started,
		Hast_IP_FinishedAck_in  => '0',
		Hast_IP_Finished_out    => open,
		Hast_IP_Performance_out => open
		--Hast_IP_Debug_out       => open
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
		Reset <= '1';
		wait for 100 ns;
		Reset <= '0';
		wait;
	end process;
		
	--SM_BRAM STATE MACHINE---  
	--SYNC Process of SM_BRAM
	SYNC_PROC: process (Clock)
	begin
		if (rising_edge(Clock)) then
			if Reset = '1' then
				state_Hast <= ST00_Idle;
			else
				state_Hast <= next_state_Hast;   
			end if;  
		end if;
	end process;
		
	--NEXT_STATE_DECODE of SM_BRAM
	NEXT_STATE_DECODE: process (state_Hast, Data_Counter_DataOut)
	begin
		next_state_Hast <= state_Hast;  --default is to stay in current state
		case (state_Hast) is
			when ST00_Idle =>
				next_state_Hast <= ST01_Preload_Data_Counter;
			when ST01_Preload_Data_Counter =>
				next_state_Hast <= ST02_WriteToDDR;
			when ST02_WriteToDDR =>                       
				if Data_Counter_DataOut = x"00000040" then--x"000003FF" then
					next_state_Hast <= ST03_ResetCounter;
				end if;
			when ST03_ResetCounter =>
				next_state_Hast <= ST04_CalcProc;
			when others => null;        
		end case;      
	end process; 
		
		
	--OUTPUT_DECODE of SM_BRAM
	OUTPUT_DECODE: process (state_Hast)
	begin
		case (state_Hast) is
			when ST00_Idle               =>
				BRAM_WriteEn        <= '0';
				BRAM_Wena           <= x"0";
				Rst_Counter         <= '1';
				Address_Counter_Ena <= '0';
				Data_Counter_Ena    <= '0';
				Data_Counter_Load   <= '0';
				Data_Counter_DataIn <= (others => '0');
			when ST01_Preload_Data_Counter =>                    
				BRAM_WriteEn        <= '0';          
				BRAM_Wena           <= x"0";         
				Rst_Counter         <= '0';
				Address_Counter_Ena <= '0';
				Data_Counter_Ena    <= '1';   
				Data_Counter_Load   <= '1';
				Data_Counter_DataIn <= x"00000012";  
			when ST02_WriteToDDR         =>                                                       
				BRAM_WriteEn        <= '1';                             
				BRAM_Wena           <= x"F";                            
				Rst_Counter         <= '0';
				Address_Counter_Ena <= '1';
				Data_Counter_Ena    <= '1';   
				Data_Counter_Load   <= '0';
				Data_Counter_DataIn <= (others => '0');                                                            
			when ST03_ResetCounter       =>                                                     
				BRAM_WriteEn        <= '0';                             
				BRAM_Wena           <= x"0";                            
				Address_Counter_Ena <= '0';
				Data_Counter_Ena    <= '0';   
				Data_Counter_Load   <= '0';
				Data_Counter_DataIn <= (others => '0');
				Started             <= '1';
			when ST04_CalcProc          =>
				Started             <= '0';
			when others => null;               
		end case;    
	end process; 
		
end Imp;