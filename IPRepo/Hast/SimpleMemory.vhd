library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
		
package SimpleMemory is
	-- Data conversion functions:
	function ConvertUInt32ToStdLogicVector(input: unsigned(31 downto 0)) return std_logic_vector;
	function ConvertStdLogicVectorToUInt32(input : std_logic_vector) return unsigned;
		
	function ConvertBooleanToStdLogicVector(input: boolean) return std_logic_vector;
	function ConvertStdLogicVectorToBoolean(input : std_logic_vector) return boolean;
		
	function ConvertInt32ToStdLogicVector(input: signed(31 downto 0)) return std_logic_vector;
	function ConvertStdLogicVectorToInt32(input : std_logic_vector) return signed;
		
	function ConvertCharToStdLogicVector(input: character) return std_logic_vector;
	function ConvertStdLogicVectorToChar(input : std_logic_vector) return character;
end SimpleMemory;
		
	package body SimpleMemory is

	function ConvertUInt32ToStdLogicVector(input: unsigned(31 downto 0)) return std_logic_vector is
	begin
		return std_logic_vector(input);
	end ConvertUInt32ToStdLogicVector;
	
	function ConvertStdLogicVectorToUInt32(input : std_logic_vector) return unsigned is
	begin
		return unsigned(input);
	end ConvertStdLogicVectorToUInt32;
	
	function ConvertBooleanToStdLogicVector(input: boolean) return std_logic_vector is 
	begin
		case input is
			when true => return X"FFFFFFFF";
			when false => return X"00000000";
			when others => return X"00000000";
		end case;
	end ConvertBooleanToStdLogicVector;

	function ConvertStdLogicVectorToBoolean(input : std_logic_vector) return boolean is 
	begin
		-- In .NET a false is all zeros while a true is at least one 1 bit (or more), so using the same logic here.
		return not(input = X"00000000");
	end ConvertStdLogicVectorToBoolean;

	function ConvertInt32ToStdLogicVector(input: signed(31 downto 0)) return std_logic_vector is
	begin
		return std_logic_vector(input);
	end ConvertInt32ToStdLogicVector;

	function ConvertStdLogicVectorToInt32(input : std_logic_vector) return signed is
	begin
		return signed(input);
	end ConvertStdLogicVectorToInt32;

	function ConvertCharToStdLogicVector(input: character) return std_logic_vector is
		variable characterIndex : integer;
	begin
		case input is
			when '0' => characterIndex :=  0;
			when '1' => characterIndex :=  1;
			when '2' => characterIndex :=  2;
			when '3' => characterIndex :=  3;
			when '4' => characterIndex :=  4;
			when '5' => characterIndex :=  5;
			when '6' => characterIndex :=  6;
			when '7' => characterIndex :=  7;
			when '8' => characterIndex :=  8;
			when '9' => characterIndex :=  9;
			when 'A' => characterIndex := 10;
			when 'B' => characterIndex := 11;
			when 'C' => characterIndex := 12;
			when 'D' => characterIndex := 13;
			when 'E' => characterIndex := 14;
			when 'F' => characterIndex := 15;
			when 'G' => characterIndex := 16;
			when 'H' => characterIndex := 17;
			when 'I' => characterIndex := 18;
			when 'J' => characterIndex := 19;
			when 'K' => characterIndex := 20;
			when 'L' => characterIndex := 21;
			when 'M' => characterIndex := 22;
			when 'N' => characterIndex := 23;
			when 'O' => characterIndex := 24;
			when 'P' => characterIndex := 25;
			when 'Q' => characterIndex := 26;
			when 'R' => characterIndex := 27;
			when 'S' => characterIndex := 28;
			when 'T' => characterIndex := 29;
			when 'U' => characterIndex := 30;
			when 'V' => characterIndex := 31;
			when 'W' => characterIndex := 32;
			when 'X' => characterIndex := 33;
			when 'Y' => characterIndex := 34;
			when 'Z' => characterIndex := 35;
			when others => characterIndex := 0;
		end case;
			
		return std_logic_vector(to_signed(characterIndex, 32));
	end ConvertCharToStdLogicVector;

	function ConvertStdLogicVectorToChar(input : std_logic_vector) return character is
		variable characterIndex     : integer;
	begin
		characterIndex := to_integer(unsigned(input));
		
		case characterIndex is
			when  0 => return '0';
			when  1 => return '1';
			when  2 => return '2';
			when  3 => return '3';
			when  4 => return '4';
			when  5 => return '5';
			when  6 => return '6';
			when  7 => return '7';
			when  8 => return '8';
			when  9 => return '9';
			when 10 => return 'A';
			when 11 => return 'B';
			when 12 => return 'C';
			when 13 => return 'D';
			when 14 => return 'E';
			when 15 => return 'F';
			when 16 => return 'G';
			when 17 => return 'H';
			when 18 => return 'I';
			when 19 => return 'J';
			when 20 => return 'K';
			when 21 => return 'L';
			when 22 => return 'M';
			when 23 => return 'N';
			when 24 => return 'O';
			when 25 => return 'P';
			when 26 => return 'Q';
			when 27 => return 'R';
			when 28 => return 'S';
			when 29 => return 'T';
			when 30 => return 'U';
			when 31 => return 'V';
			when 32 => return 'W';
			when 33 => return 'X';
			when 34 => return 'Y';
			when 35 => return 'Z';
			when others => return '?';
		end case;
	end ConvertStdLogicVectorToChar;

end SimpleMemory;