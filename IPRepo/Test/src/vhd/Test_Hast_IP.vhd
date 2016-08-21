library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library Hast;
use Hast.SimpleMemory.all;
		
entity Test_Hast_IP is
end Test_Hast_IP;
		
architecture Imp of Test_Hast_IP is 
		
	-- Component Declaration
	component Hast_IP is
	port(
			\Clock\        : In  std_logic;
			\Reset\        : In  std_logic;
			\MemberId\     : In  integer;
			\DataIn\       : In  std_logic_vector(31 downto 0);
			\DataOut\      : Out std_logic_vector(31 downto 0);
			\ReadEnable\   : Out boolean;
			\WriteEnable\  : Out boolean;
			\CellIndex\    : Out integer;
			\Started\      : In  boolean;
			\Finished\     : Out boolean;
			\ReadsDone\    : in  boolean;
			\WritesDone\   : in  boolean
			);
	 end component;
		
	signal Clock        : std_logic := '0';
	signal Reset        : std_logic := '1';
	signal DataIn       : std_logic_vector(31 downto 0) := X"00000000";
	signal Started      : boolean := false;
	signal ReadsDone    : boolean := false;
	signal WritesDone   : boolean := false;
		
	signal ReadEnable   : boolean;
	signal WriteEnable  : boolean;
	signal DataOut      : std_logic_vector(31 downto 0);
	signal CellIndex    : integer;
	signal Finished     : boolean;
	signal ReadCount    : integer := 0;
	signal MemberId     : integer := 0;
	
	--Performance Counter signals 
	signal Cnt                  : unsigned(63 downto 0);
	signal sig_hast_performance : std_logic_vector(63 downto 0);
	
	--State macine states
	type SM_PERFORMANCE_CNTR is (ST00_Idle,
								 ST01_Start,
								 ST02_Stop
								 ); 
	signal state_PerformanceCnt : SM_PERFORMANCE_CNTR;
		
begin
		
	-- Component Instantiation
	UUT: Hast_IP port map (
		\Clock\        => Clock,
		\Reset\        => Reset,
		\MemberId\     => MemberId,
		\DataIn\       => DataIn,
		\Started\      => Started,
		\ReadsDone\    => ReadsDone,
		\WritesDone\   => WritesDone,
		
		\DataOut\      => DataOut,  
		\ReadEnable\   => ReadEnable,
		\WriteEnable\  => WriteEnable,
		\CellIndex\    => CellIndex,
		\Finished\     => Finished
		);
		
	Clock <= not Clock after 10 ns;
		
	ReadEnable_proc : process
	begin
		ReadsDone <= false;
		loop
			 wait until ReadEnable = true;
			 ReadsDone <= false;
			 wait for 1000 ns;
			 ReadsDone <= true;
			
			case (ReadCount) is
				when 0 => DataIn <= X"00000005";
				when 1 => DataIn <= X"00000007";
				when 2 => DataIn <= X"00000003";
				when 3 => DataIn <= X"00000008";
				when 4 => DataIn <= X"0000000d";
				when 5 => DataIn <= X"00000004";
				when others => DataIn <= X"00000000";
			end case; 
			
			ReadCount <= ReadCount + 1;
			wait until ReadEnable = false;
		end loop;
	end process;
		
		
	WriteEnable_proc : process
	begin
		WritesDone <= false;
		loop
			wait until WriteEnable = true;
			WritesDone <= false;
			wait for 1000 ns;
			WritesDone <= true;
			wait until WriteEnable = false;
		end loop;
	end process;
		
	-- Stimulus process
	Stim_proc: process
	begin
		-- hold Reset state for 100 ns.
		wait for 100 ns;
		Reset <= '1';
		wait for 100 ns;
		Reset <= '0';
		wait;
	end process;
		
	--Test bench statements
	Test : process(Clock)
	begin
		if (rising_edge(Clock)) then
			if Reset = '1' then
				Started <= false;
			else
				Started <= true;
			end if;
		end if;
	end process;
		
		
	--SM_PERFORMANCE_CNTR
	SM_Performance_Counter: process (Clock)
	begin
		if (rising_edge(Clock)) then
			if Reset = '1' then
				Cnt <= (others => '0');
			else
				case (state_PerformanceCnt) is
					when ST00_Idle =>
						--Cnt <= (others => '0');
						if Started = true then
							Cnt <= (others => '0');
							state_PerformanceCnt <= ST01_Start;
						end if;
					when ST01_Start =>
						Cnt <= Cnt + 1;
						if Finished = true then
							state_PerformanceCnt <= ST02_Stop;
						else
							state_PerformanceCnt <= ST01_Start;
						end if;
					when ST02_Stop =>
						if Started = false then
							state_PerformanceCnt <= ST00_Idle;
						end if;               
					when others => null;        
				end case;  
			end if;
		end if;    
	end process; 
		
	--Performance Counter
	--process (Clock)
	--begin
	--	if (rising_edge(Clock)) then
	--		if Reset = '1' or Started = '0' or Finished = '1' then
	--			Cnt <= (others => '0');
	--		elsif Started = '1' and Finished = '0' then
	--			Cnt <= Cnt + 1;
	--		end if;
	--	end if;
	--end process;
		
	sig_hast_performance <= std_logic_vector(Cnt);
		
end Imp;
