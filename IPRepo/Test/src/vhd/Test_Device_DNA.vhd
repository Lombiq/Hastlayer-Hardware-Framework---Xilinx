library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
		
entity Test_Device_DNA is
end Test_Device_DNA;
		
architecture Imp of Test_Device_DNA is
		
	component Device_DNA
		port(
			Clock        : in  std_logic;
			Reset        : in  std_logic;
			DNA_parallel : out std_logic_vector(63 downto 0)
		);
	end component;
		
	-- Clock period definitions
	constant Clock_period     : time := 10 ns;
	constant Clock_periodDiv2 : time := 5  ns;
		
	constant Counter_width    : natural := 32;
		
	--General purpose signals
	signal Reset              : std_logic:= '1';
	signal Clock              : std_logic:= '0';
		
	signal DNA_parallel       : std_logic_vector(63 downto 0);
		                                                    
begin
		
	UUT : Device_DNA
	port map (
		Clock        => Clock,
		Reset        => Reset,
		DNA_parallel => DNA_parallel
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
		Reset <= '1';
		wait for 100 ns;
		Reset <= '0';
		wait;
	end process;
		
end Imp;