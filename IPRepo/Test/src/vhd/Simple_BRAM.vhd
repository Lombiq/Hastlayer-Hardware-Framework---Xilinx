library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
	
entity Simple_BRAM is
	port(
		clk          : in  std_logic;
		readaddress  : in  std_logic_vector(31 downto 0);
		writeaddress : in  std_logic_vector(31 downto 0);
		we           : in  std_logic;     
		re           : in  std_logic;
		data_i       : in  std_logic_vector(31 downto 0);
		data_o       : out std_logic_vector(31 downto 0)
	);
end Simple_BRAM;
		
architecture Behavioral of Simple_BRAM is
		
	--Declaration of type and signal of a 256 element RAM
	--with each element being 8 bit wide.
	type ram_t is array (0 to 255) of std_logic_vector(31 downto 0);
	signal ram : ram_t := (others => (others => '0'));
	signal readaddress_int  : integer;
	signal writeaddress_int : integer;
		
begin
		
	readaddress_int <= to_integer(unsigned(readaddress(31 downto 0)));
	writeaddress_int <= to_integer(unsigned(writeaddress(31 downto 0)));
	--process for read and write operation.
	process(clk)
	begin
		if(rising_edge(clk)) then
			if (we = '1') then
				ram(writeaddress_int) <= data_i;
			end if;
			if (re = '1') then
				data_o <= ram(readaddress_int);
			end if;
		end if;
	end process;
		
end Behavioral;