library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
		
library unisim;
use unisim.vcomponents.all;
		
entity Device_DNA is
	port(
		Clock        : in  std_logic;
		Reset        : in  std_logic;
		DNA_parallel : out std_logic_vector(63 downto 0)
		);
end;
		
architecture Imp of Device_DNA is
		
	--Device DNA signals
	signal sig_dna_serial   : std_logic;
	signal sig_dna_tmp      : std_logic_vector(56 downto 0); 
	signal serial_count     : unsigned(5 downto 0);
		
begin
		
	-- DNA_PORT: Device DNA Access Port for Artix-7
	DNA_PORT_inst : DNA_PORT
	generic map (
		SIM_DNA_VALUE => X"123456789ABCDEF"  -- Specifies a sample 57-bit DNA value for simulation     
	)
	port map (
		DOUT  => sig_dna_serial, -- 1-bit output: DNA output data.
		CLK   => Clock,          -- 1-bit input: Clock input.
		DIN   => '0',            -- 1-bit input: User data input pin.
		READ  => Reset,          -- 1-bit input: Active high load DNA, active low read input.
		SHIFT => '1'             -- 1-bit input: Active high shift enable input.
		);
		
	-- Serial -> Parallel Shift Register for Device DNA output
	process (Clock) 
	begin  
		if (rising_edge(Clock)) then
			if Reset = '1' then
				sig_dna_tmp  <= (others => '0');
				serial_count <= (others => '0');
			elsif serial_count < X"39" then
				sig_dna_tmp <= sig_dna_tmp(55 downto 0)& sig_dna_serial; 
				serial_count <= serial_count + 1;
			else sig_dna_tmp <= sig_dna_tmp;
			end if;
		end if; 
	end process; 
		
	DNA_parallel <= X"0" & "000" & sig_dna_tmp; 
		
end;
