library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Counter is
	generic (width : natural:= 16);
	port(
		Clock    : in  std_logic;
		Reset    : in  std_logic;
		Ena      : in  std_logic;
		Load     : in  std_logic;
		UpDown   : in  std_logic;
		Data_in  : in  std_logic_vector(width-1 downto 0);
		Data_out : out std_logic_vector(width-1 downto 0)
		);
end;

architecture Imp of Counter is
		
	signal Cnt: unsigned(width-1 downto 0);
		
begin
		
	process (Clock, Reset)
	begin
		if Rising_edge(Clock) then
			if Reset = '1' then
				Cnt <= (others=>'0');
			elsif Ena = '1' then
				if Load = '1' then
					Cnt <= unsigned(Data_in);
				else
					if UpDown = '1' then
						Cnt <= Cnt + 1;
					else
						Cnt <= Cnt - 1;
					end if;
				end if;
			end if;
		end if;
	end process;
		
	Data_out <= std_logic_vector(Cnt);
		
end;
