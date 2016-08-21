library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
		
entity Test_Simple_BRAM_v1_0 is
end Test_Simple_BRAM_v1_0;
		
architecture Imp of Test_Simple_BRAM_v1_0 is
		
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
		
	component Simple_BRAM_v1_0 is
		generic (
			-- Users to add parameters here
			
			-- User parameters ends
			-- Do not modify the parameters beyond this line
			
			-- Parameters of Axi Slave Bus Interface S00_AXI
			C_S00_AXI_DATA_WIDTH : integer := 32;
			C_S00_AXI_ADDR_WIDTH : integer := 32
		);
		port 
		(
			-- Users to add ports here
			
			-- User ports ends
			-- Do not modify the ports beyond this line
			
			-- Ports of Axi Slave Bus Interface S00_AXI
			s00_axi_aclk    : in  std_logic;
			s00_axi_aresetn : in  std_logic;
			s00_axi_awaddr  : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
			s00_axi_awprot  : in  std_logic_vector(2 downto 0);
			s00_axi_awvalid : in  std_logic;
			s00_axi_awready : out std_logic;
			s00_axi_wdata   : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
			s00_axi_wstrb   : in  std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
			s00_axi_wvalid  : in  std_logic;
			s00_axi_wready  : out std_logic;
			s00_axi_bresp   : out std_logic_vector(1 downto 0);
			s00_axi_bvalid  : out std_logic;
			s00_axi_bready  : in  std_logic;
			s00_axi_araddr  : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
			s00_axi_arprot  : in  std_logic_vector(2 downto 0);
			s00_axi_arvalid : in  std_logic;
			s00_axi_arready : out std_logic;
			s00_axi_rdata   : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
			s00_axi_rresp   : out std_logic_vector(1 downto 0);
			s00_axi_rvalid  : out std_logic;
			s00_axi_rready  : in  std_logic
		);
	end component;
		
	-- Clock period definitions
	constant Clock_period     : time := 10 ns;
	constant Clock_periodDiv2 : time := 5  ns;
		
	constant Counter_width    : natural := 32;
		
	--General purpose signals
	signal Reset        : std_logic:= '1';
	signal Clock        : std_logic:= '0';
	signal start        : std_logic:= '0';
		
	--Counter signals
	signal Counter_Ena      : std_logic;-- := '0';
	signal Counter_Load     : std_logic := '0';
	signal Counter_Data_in  : std_logic_vector(31 downto 0) := (others => '0');
	signal Counter_Data_Out : std_logic_vector(31 downto 0);-- := (others => '0');
	signal Rst_Counter      : std_logic := '0';
	signal Reset_Counter    : std_logic := '0';
		
	--AXI MM Interface signals
	constant C_M_AXI_ADDR_WIDTH     : integer := 32;   
	constant C_M_AXI_DATA_WIDTH     : integer := 32;     
		
	signal M_AXI_ARESETN            : std_logic;
		
	--AXI Master Interface Write Address
	signal M_AXI_AWADDR            : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0); 
	--signal M_AXI_AWPROT            : std_logic_vector(2 downto 0); 
	signal M_AXI_AWVALID           : std_logic; 
	signal M_AXI_AWREADY           : std_logic; 
		                      
	--AXI Master Interface Write Data
	signal M_AXI_WDATA             :  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0); 
	--signal M_AXI_WSTRB             :  std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0); 
	signal M_AXI_WVALID            :  std_logic;
	signal M_AXI_WREADY            :  std_logic; 
		 
	--AXI Master Interface Write Response
	signal M_AXI_BRESP             : std_logic_vector(1 downto 0); 
	signal M_AXI_BVALID            : std_logic; 
	signal M_AXI_BREADY            : std_logic;
		 
	--AXI Master Interface Read Address
	signal M_AXI_ARADDR            : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0); 
	signal M_AXI_ARVALID           : std_logic;
	signal M_AXI_ARREADY           : std_logic; 
		
	--AXI Master Interface Read Data
	signal M_AXI_RDATA             : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0); 
	signal M_AXI_RRESP             : std_logic_vector(1 downto 0); 
	signal M_AXI_RVALID            : std_logic; 
	signal M_AXI_RREADY            : std_logic;
		
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
		
	Counter_Ena <= (M_AXI_WREADY and M_AXI_AWREADY) or (M_AXI_ARREADY and M_AXI_RREADY);
		
	Write_BRAM: process(M_AXI_WREADY, M_AXI_AWREADY)
	begin
		if (M_AXI_WREADY and M_AXI_AWREADY) = '1' then
			M_AXI_AWADDR  <= Counter_Data_Out;
			M_AXI_WDATA   <= Counter_Data_Out;
		end if;
	end process;
	
	Read_BRAM: process(M_AXI_ARREADY,  M_AXI_RREADY)
	begin
		if (M_AXI_ARREADY and  M_AXI_RREADY) = '1' then
			M_AXI_ARADDR  <= Counter_Data_Out;
		end if;
	end process;
	
	--M_AXI_AWADDR  <= Counter_Data_Out;
	--M_AXI_ARADDR  <= Counter_Data_Out;
	--M_AXI_WDATA   <= Counter_Data_Out;
	Reset_Counter <= Reset or Rst_Counter;
		
	
	M_AXI_ARESETN <= not reset;
	
	-- Unit Under Test
	UUT : Simple_BRAM_v1_0 
		generic map(
			-- Parameters of Axi Slave Bus Interface S00_AXI
			C_S00_AXI_DATA_WIDTH => 32,
			C_S00_AXI_ADDR_WIDTH => 32
		)
		port map(
			-- Ports of Axi Slave Bus Interface S00_AXI
			s00_axi_aclk     => Clock,            
			s00_axi_aresetn  => M_AXI_ARESETN,            
			s00_axi_awaddr   => M_AXI_AWADDR,
			s00_axi_awprot   => "000",
			s00_axi_awvalid  => M_AXI_AWVALID,
			s00_axi_awready  => M_AXI_AWREADY,
			s00_axi_wdata    => M_AXI_WDATA,  
			s00_axi_wstrb    => "1111",  
			s00_axi_wvalid   => M_AXI_WVALID,
			s00_axi_wready   => M_AXI_WREADY,                                               
			s00_axi_bresp    => M_AXI_BRESP,                                   
			s00_axi_bvalid   => M_AXI_BVALID, 
			s00_axi_bready   => M_AXI_BREADY, 
			s00_axi_araddr   => M_AXI_ARADDR,
			s00_axi_arprot   => "000",
			s00_axi_arvalid  => M_AXI_ARVALID,
			s00_axi_arready  => M_AXI_ARREADY,
			s00_axi_rdata    => M_AXI_RDATA,  
			s00_axi_rresp    => M_AXI_RRESP,  
			s00_axi_rvalid   => M_AXI_RVALID, 
			s00_axi_rready   => M_AXI_RREADY  
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
		reset <= '1';
		wait for 100 ns;
		reset <= '0';
		wait for 20 ns;
		start <= '1';
		wait for 20 ns;
		start <= '0';
		wait; --for 20 ns;
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
	NEXT_STATE_DECODE: process (state_BRAM, Counter_Data_Out, start)
	begin
		next_state_BRAM <= state_BRAM;  --default is to stay in current state
		case (state_BRAM) is
			when ST00_Idle =>
				if start = '1' then
					next_state_BRAM <= ST01_WriteToDDR;
				end if;
			when ST01_WriteToDDR =>                       
				if Counter_Data_Out = x"0000003F" then
					next_state_BRAM <= ST02_ResetCounter;
				end if;
			when ST02_ResetCounter =>
				next_state_BRAM <= ST03_ReadFromDDR;
			when ST03_ReadFromDDR =>
				if Counter_Data_Out = x"0000003F" then
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
				M_AXI_ARVALID <= '0';   
				M_AXI_RREADY  <= '0';
				M_AXI_AWVALID <= '0';
				M_AXI_WVALID  <= '0';
				--Counter_Ena   <= '0';
				Rst_Counter   <= '0';
			when ST01_WriteToDDR         =>
				M_AXI_ARVALID <= '0';
				M_AXI_RREADY  <= '0';
				M_AXI_AWVALID <= '1';
				M_AXI_WVALID  <= '1';
				--Counter_Ena   <= '1';
				Rst_Counter   <= '0';
			when ST02_ResetCounter       =>
				M_AXI_ARVALID <= '0';
				M_AXI_RREADY  <= '0';
				M_AXI_AWVALID <= '0';
				M_AXI_WVALID  <= '0';
				--Counter_Ena   <= '0';
				Rst_Counter   <= '1';
			when ST03_ReadFromDDR        =>
				M_AXI_ARVALID <= '1';
				M_AXI_RREADY  <= '1';
				M_AXI_AWVALID <= '0';
				M_AXI_WVALID  <= '0';
				--Counter_Ena   <= '1';
				Rst_Counter   <= '0';
			when others => null;               
		end case;       
	end process; 
		
end Imp;