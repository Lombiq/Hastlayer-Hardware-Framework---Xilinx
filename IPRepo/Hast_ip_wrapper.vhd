library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Hast_ip_wrapper is
	port (
		Hast_IP_Clk_in          : in  std_logic;
		Hast_IP_Rst_in          : in  std_logic;
		Hast_IP_MemberID_in     : in  std_logic_vector(31 downto 0);
		Hast_IP_Data_in         : in  std_logic_vector(31 downto 0);
		Hast_IP_Data_out        : out std_logic_vector(31 downto 0);
		Hast_IP_Read_Addr_out   : out std_logic_vector(31 downto 0);
		Hast_IP_Read_Ena_out    : out std_logic;
		Hast_IP_Write_Addr_out  : out std_logic_vector(31 downto 0);
		Hast_IP_Write_Ena_out   : out std_logic;
		Hast_IP_Started_in      : in  std_logic;
		Hast_IP_FinishedAck_in  : in  std_logic;
		Hast_IP_Finished_out    : out std_logic;
		Hast_IP_Performance_out : out std_logic_vector(31 downto 0);
		Hast_IP_reads_done      : in  std_logic;
		Hast_IP_writes_done     : in  std_logic
	);
end Hast_ip_wrapper;
		
architecture Imp of Hast_ip_wrapper is
		
	signal Hast_IP_MemberID          : std_logic_vector(31 downto 0);
	signal Hast_IP_MemberID_int      : integer;
	signal Hast_IP_CellIndex_out_sig : std_logic_vector(31 downto 0);
	
	signal Hast_IP_Started_in_sig     : std_logic;
	signal Hast_IP_Finished_out_sig   : std_logic;
	signal Hast_IP_Data_out_sig       : std_logic_vector(31 downto 0);
	signal Hast_IP_Read_Ena_out_sig   : std_logic; 
	signal Hast_IP_Write_Ena_out_sig  : std_logic;
	signal Hast_IP_Read_Addr_out_sig  : std_logic_vector(31 downto 0);
	signal Hast_IP_Write_Addr_out_sig : std_logic_vector(31 downto 0);
	
	--Performance Counter signals 
	signal Performance_Counter_Ena    : std_logic;
	signal Cnt                        : unsigned(31 downto 0);
	
	signal Hast_IP_CellIndex_out_int  : integer;
		
	component Hast_IP
		port(
			\Clock\        : in  std_logic;
			\Reset\        : in  std_logic;
			\MemberID\     : in  integer;
			\DataIn\       : in  std_logic_vector(31 downto 0);
			\DataOut\      : out std_logic_vector(31 downto 0);
			\ReadEnable\   : out std_logic;
			\WriteEnable\  : out std_logic;
			\CellIndexOut\ : out integer;
			\Started\      : in  std_logic;
			\FinishedAck\  : In  std_logic;
			\Finished\     : out std_logic;
			\ReadsDone\    : in  std_logic;
			\WritesDone\   : in  std_logic
			);
	end component;
		
begin
		
	--Typecast 
	Hast_IP_MemberID_int     <= to_integer(unsigned(Hast_IP_MemberID(31 downto 0)));
		
	Hast_IP_inst : Hast_IP
	port map(
		\Clock\        => Hast_IP_Clk_in,                    
		\Reset\        => Hast_IP_Rst_in,                    
		\MemberID\     => Hast_IP_MemberID_int,              
		\DataIn\       => Hast_IP_Data_in,                   
		\DataOut\      => Hast_IP_Data_out_sig,              
		\ReadEnable\   => Hast_IP_Read_Ena_out_sig,          
		\WriteEnable\  => Hast_IP_Write_Ena_out_sig,                      
		\CellIndexOut\ => Hast_IP_CellIndex_out_int,                                   
		\Started\      => Hast_IP_Started_in_sig, 
		\FinishedAck\  => Hast_IP_FinishedAck_in,               
		\Finished\     => Hast_IP_Finished_out_sig,
		\ReadsDone\    => Hast_IP_reads_done,   
		\WritesDone\   => Hast_IP_writes_done      
	);                                                       
		                                                     
	Hast_IP_Started_in_sig    <= Hast_IP_Started_in;       
	Hast_IP_Finished_out      <= Hast_IP_Finished_out_sig;                                            
	Hast_IP_Data_out          <= Hast_IP_Data_out_sig;
	Hast_IP_MemberID          <= Hast_IP_MemberID_in;
	
	Hast_IP_Read_Ena_out      <= Hast_IP_Read_Ena_out_sig; 
	Hast_IP_Write_Ena_out     <= Hast_IP_Write_Ena_out_sig;
	
	Hast_IP_CellIndex_out_sig <= std_logic_vector(to_unsigned(Hast_IP_CellIndex_out_int,32)); 
	
	Read_Write_Address_Choice : process(Hast_IP_Read_Ena_out_sig, Hast_IP_Write_Ena_out_sig, Hast_IP_CellIndex_out_sig)
	begin
		if Hast_IP_Read_Ena_out_sig = '1' then
			Hast_IP_Read_Addr_out_sig <= Hast_IP_CellIndex_out_sig;
		elsif Hast_IP_Write_Ena_out_sig = '1' then
			Hast_IP_Write_Addr_out_sig <= Hast_IP_CellIndex_out_sig;
		end if;
	end process;
		
	Hast_IP_Read_Addr_out  <= Hast_IP_Read_Addr_out_sig; 
	Hast_IP_Write_Addr_out <= Hast_IP_Write_Addr_out_sig;
		
	--Performance Counter
	process (Hast_IP_Clk_in, Hast_IP_Rst_in)
	begin
		if Rising_edge(Hast_IP_Clk_in) then
			if Hast_IP_Rst_in = '1' then
				Cnt <= (others=>'0');
			elsif Performance_Counter_Ena = '1' then
				Cnt <= Cnt + 1;
			end if;
		end if;
	end process;
		
	Hast_IP_Performance_out <= std_logic_vector(Cnt);
	
	Performance_Counter_Ena <= '1' when Hast_IP_Started_in_sig = '1' else
						   '0' when Hast_IP_Finished_out_sig = '1';
		   
	
end Imp;
