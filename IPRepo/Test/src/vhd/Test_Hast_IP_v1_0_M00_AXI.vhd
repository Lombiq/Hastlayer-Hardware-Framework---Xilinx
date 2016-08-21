library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
		
entity Test_Hast_IP_v1_0_M00_AXI is
end Test_Hast_IP_v1_0_M00_AXI;
		
architecture Imp of Test_Hast_IP_v1_0_M00_AXI is
		
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
		
	component Hast_IP_v1_0_M00_AXI is
	generic (
		-- Users to add parameters here
		
		-- User parameters ends
		-- Do not modify the parameters beyond this line
		
		-- The master will start generating data from the C_M_START_DATA_VALUE value
		C_M_START_DATA_VALUE : std_logic_vector := x"AA000000";
		-- The master requires a target slave base address.
		-- The master will initiate read and write transactions on the slave with base address specified here as a parameter.
		C_M_TARGET_SLAVE_BASE_ADDR : std_logic_vector := x"00000000";
		
		-- Width of M_AXI address bus. 
		-- The master generates the read and write addresses of width specified as C_M_AXI_ADDR_WIDTH.
		C_M_AXI_ADDR_WIDTH : integer := 32;
		-- Width of M_AXI data bus. 
		-- The master issues write data and accept read data where the width of the data bus is C_M_AXI_DATA_WIDTH
		C_M_AXI_DATA_WIDTH : integer := 32;
		-- Transaction number is the number of write 
		-- and read transactions the master will perform as a part of this example memory test.
		C_M_TRANSACTIONS_NUM : integer := 4
	);
	port (
		-- Users to add ports here
		Hast_IP_MemberId_in     : in  std_logic_vector(C_M_AXI_DATA_WIDTH -1 downto 0);
		Hast_IP_Started_in      : in  std_logic;
		Hast_IP_FinishedAck_in  : in  std_logic;
		Hast_IP_Finished_out    : out std_logic;
		Hast_IP_Performance_out : out std_logic_vector(C_M_AXI_DATA_WIDTH -1 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line
		
		-- System Signals
		M_AXI_ACLK    : in std_logic; -- AXI clock signal
		M_AXI_ARESETN : in std_logic; -- AXI active low reset signal
		
		-- Master Interface Write Address
		M_AXI_AWADDR  : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0); -- Master Interface Write Address Channel ports. Write address (issued by master)
		M_AXI_AWPROT  : out std_logic_vector(2 downto 0); -- Write channel Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access. 
		M_AXI_AWVALID : out std_logic; -- Write address valid. This signal indicates that the master signaling valid write address and control information. 
		M_AXI_AWREADY : in  std_logic; -- Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
		
		-- Master Interface Write Data
		M_AXI_WDATA   : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0); -- Master Interface Write Data Channel ports. Write data (issued by master)
		M_AXI_WSTRB   : out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0); -- Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
		M_AXI_WVALID  : out std_logic; -- Write valid. This signal indicates that valid write data and strobes are available.
		M_AXI_WREADY  : in  std_logic; -- Write ready. This signal indicates that the slave can accept the write data.
		
		-- Master Interface Write Response
		M_AXI_BRESP   : in  std_logic_vector(1 downto 0); -- Master Interface Write Response Channel ports. This signal indicates the status of the write transaction.
		M_AXI_BVALID  : in  std_logic; -- Write response valid. This signal indicates that the channel is signaling a valid write response
		M_AXI_BREADY  : out std_logic; -- Response ready. This signal indicates that the master can accept a write response.
		
		-- Master Interface Read Address
		M_AXI_ARADDR  : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0); -- Master Interface Read Address Channel ports. Read address (issued by master)
		M_AXI_ARPROT  : out std_logic_vector(2 downto 0); -- Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access. 
		M_AXI_ARVALID : out std_logic; -- Read address valid. This signal indicates that the channel is signaling valid read address and control information.
		M_AXI_ARREADY : in  std_logic; -- Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
		
		-- Master Interface Read Data
		M_AXI_RDATA   : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0); -- Master Interface Read Data Channel ports. Read data (issued by slave)
		M_AXI_RRESP   : in  std_logic_vector(1 downto 0); -- Read response. This signal indicates the status of the read transfer.
		M_AXI_RVALID  : in  std_logic; -- Read valid. This signal indicates that the channel is signaling the required read data.
		M_AXI_RREADY  : out std_logic; -- Read ready. This signal indicates that the master can accept the read data and response information.
		
		--Others
		INIT_AXI_TXN  : in  std_logic; -- Initiate AXI transactions
		ERROR         : out std_logic; -- Asserts when ERROR is detected
		TXN_DONE      : out std_logic -- Asserts when AXI transactions is complete
	);
	end component;
		
	-- Clock period definitions
	constant Clock_period     : time := 10 ns;
	constant Clock_periodDiv2 : time := 5  ns;
		
	--General purpose signals
	signal Reset            : std_logic:= '1';
	signal Clock            : std_logic:= '0';
	signal Start_Fill_BRAM  : std_logic:= '0';
		
	--Address and Data Counter signals    
	constant Counter_width  : natural := 32;
		
	--Counter signals
	--signal Counter_Ena      : std_logic;-- := '0';
	--signal Counter_Load     : std_logic := '0';
	--signal Counter_Data_in  : std_logic_vector(31 downto 0) :=(others => '0');
	--signal Counter_Data_Out : std_logic_vector(31 downto 0);-- := (others => '0');
	signal Rst_Counter      : std_logic := '0';
	signal Reset_Counter    : std_logic := '0';
	
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
		
	--Hast_IP_v1_0_M00_AXI constants                                                                                                           
	constant C_M_START_DATA_VALUE       : std_logic_vector := x"AA000000";                                     
	constant C_M_TARGET_SLAVE_BASE_ADDR : std_logic_vector := x"00000000";
	constant C_M_TRANSACTIONS_NUM       : integer := 4; 
	
	--AXI MM Interface signals
	constant C_M_AXI_ADDR_WIDTH    : integer := 32;   
	constant C_M_AXI_DATA_WIDTH    : integer := 32;     
		
	--AXI MM Interface signals
	signal M_AXI_ARESETN           : std_logic;
		
	--AXI Master Interface Write Address
	signal M_AXI_AWADDR            : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0); 
	--signal M_AXI_AWPROT            : std_logic_vector(2 downto 0); 
	signal M_AXI_AWVALID           : std_logic; 
	signal M_AXI_AWREADY           : std_logic; 
		                      
	--AXI Master Interface Write Data
	signal M_AXI_WDATA             :  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0); 
	signal M_AXI_WSTRB             :  std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0); 
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
		
	--AXI Slave Interface slave register signals                           
	signal MemberId                : std_logic_vector(31 downto 0) := x"00000002";
	signal Started                 : std_logic:= '0';
		
	--BRAM Fill Phase Signals
	signal BRAM_FILL_PHASE         : std_logic;
	signal BRAM_FILL_AWVALID       : std_logic;
	signal BRAM_FILL_WVALID        : std_logic;
	signal BRAM_FILL_AWADDR        : std_logic_vector(31 downto 0);
	signal BRAM_FILL_WDATA         : std_logic_vector(31 downto 0);
		
	signal AWVALID                 : std_logic;
	signal WVALID                  : std_logic;
	signal AWADDR                  : std_logic_vector(31 downto 0);
	signal WDATA                   : std_logic_vector(31 downto 0);
		
		
	--State macine states
	type SM_AXI_MM is (ST00_Idle,
					 ST01_Preload_Data_Counter,
					 ST02_WriteToDDR,
					 ST03_ResetCounter,
					 ST04_End_BRAM_Fill,
					 ST05_Start_Hast_IP,
					 ST06_Calc_State); 
	signal state_AXI_MM, next_state_AXI_MM : SM_AXI_MM; 
		
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
		
		
	Counter_Ena_Proc: process(Clock)
	begin
		if (rising_edge(Clock)) then
			Address_Counter_Ena <= (M_AXI_WREADY and M_AXI_AWREADY and BRAM_FILL_PHASE);-- or (M_AXI_ARREADY and M_AXI_RREADY);
			Data_Counter_Ena    <= (M_AXI_WREADY and M_AXI_AWREADY and BRAM_FILL_PHASE) or Data_Counter_Load;-- or (M_AXI_ARREADY and M_AXI_RREADY);
			Reset_Counter       <= Reset or Rst_Counter;
		end if;
	end process;
	
	--Address_Counter_Ena <= (M_AXI_WREADY and M_AXI_AWREADY and BRAM_FILL_PHASE);-- or (M_AXI_ARREADY and M_AXI_RREADY);
	--Data_Counter_Ena    <= (M_AXI_WREADY and M_AXI_AWREADY and BRAM_FILL_PHASE) or Data_Counter_Load;-- or (M_AXI_ARREADY and M_AXI_RREADY);
	--Reset_Counter       <= Reset or Rst_Counter;
		
	--Write_BRAM: process(M_AXI_WREADY, M_AXI_AWREADY)
	--begin                                                                        
	--	if (M_AXI_WREADY and M_AXI_AWREADY and BRAM_FILL_PHASE) = '1' then       
	--		BRAM_FILL_AWADDR  <= Address_Counter_DataOut;                                   
	--		BRAM_FILL_WDATA   <= Data_Counter_DataOut;                                   
	--	end if;                                                                  
	--end process;
		
	Write_BRAM: process (Clock)
	begin
		if (rising_edge(Clock)) then
			if Reset = '1' then
				BRAM_FILL_AWADDR <= (others => '0');
				BRAM_FILL_WDATA  <= (others => '0');
			else
				if (M_AXI_WREADY and M_AXI_AWREADY and BRAM_FILL_PHASE) = '1' then
					BRAM_FILL_AWADDR  <= Address_Counter_DataOut;
					BRAM_FILL_WDATA   <= Data_Counter_DataOut;    
				end if;
			end if;  
		end if;
	end process;
	
	Reg_proc: process (Clock)
	begin
		if (rising_edge(Clock)) then
			if Reset = '1' then
				AWVALID <= '0';
				WVALID  <= '0';
				AWADDR  <= (others => '0');
				WDATA   <= (others => '0');
			else
				if BRAM_FILL_PHASE = '1' then
					AWVALID <= BRAM_FILL_AWVALID;
					WVALID  <= BRAM_FILL_WVALID; 
					AWADDR  <= BRAM_FILL_AWADDR; 
					WDATA   <= BRAM_FILL_WDATA;  
				else   
					AWVALID <= M_AXI_AWVALID; 
					WVALID  <= M_AXI_WVALID;  
					AWADDR  <= M_AXI_AWADDR;  
					WDATA   <= M_AXI_WDATA;   
				end if;
			end if;  
		end if;
	end process;
		
	M_AXI_ARESETN <= not reset;
		
	-- AXI Interfaced Block Memory
	BRAM : Simple_BRAM_v1_0 
		generic map(
			-- Parameters of Axi Slave Bus Interface S00_AXI
			C_S00_AXI_DATA_WIDTH => 32,
			C_S00_AXI_ADDR_WIDTH => 32
		)
		port map(
			-- Ports of Axi Slave Bus Interface S00_AXI
			s00_axi_aclk     => Clock,            
			s00_axi_aresetn  => M_AXI_ARESETN,            
			s00_axi_awaddr   => AWADDR, --M_AXI_AWADDR,
			s00_axi_awprot   => "000",
			s00_axi_awvalid  => AWVALID, --M_AXI_AWVALID,
			s00_axi_awready  => M_AXI_AWREADY,
			s00_axi_wdata    => WDATA, --M_AXI_WDATA,  
			s00_axi_wstrb    => M_AXI_WSTRB,  
			s00_axi_wvalid   => WVALID, --M_AXI_WVALID,
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
		
	UUT: Hast_IP_v1_0_M00_AXI
	generic map (
		-- Users to add parameters here
		
		-- User parameters ends
		-- Do not modify the parameters beyond this line
		
		-- The master will start generating data from the C_M_START_DATA_VALUE value
		C_M_START_DATA_VALUE => x"AA000000",
		-- The master requires a target slave base address.
		-- The master will initiate read and write transactions on the slave with base address specified here as a parameter.
		C_M_TARGET_SLAVE_BASE_ADDR => x"00000000", --x"48000000",
		
		-- Width of M_AXI address bus. 
		-- The master generates the read and write addresses of width specified as C_M_AXI_ADDR_WIDTH.
		C_M_AXI_ADDR_WIDTH => 32,
		-- Width of M_AXI data bus. 
		-- The master issues write data and accept read data where the width of the data bus is C_M_AXI_DATA_WIDTH
		C_M_AXI_DATA_WIDTH => 32,
		-- Transaction number is the number of write 
		-- and read transactions the master will perform as a part of this example memory test.
		C_M_TRANSACTIONS_NUM => 4
	)
	port map (
		-- Users to add ports here
		Hast_IP_MemberId_in     => MemberId,
		Hast_IP_Started_in      => Started,--'1',
		Hast_IP_FinishedAck_in  => '0',
		Hast_IP_Finished_out    => open,
		Hast_IP_Performance_out => open,
		-- User ports ends
		-- Do not modify the ports beyond this line
		
		-- System Signals
		M_AXI_ACLK    => Clock, -- AXI clock signal
		M_AXI_ARESETN => M_AXI_ARESETN, -- AXI active low reset signal
		
		-- Master Interface Write Address
		M_AXI_AWADDR  => M_AXI_AWADDR, -- Master Interface Write Address Channel ports. Write address (issued by master)
		M_AXI_AWPROT  => open, -- Write channel Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access. 
		M_AXI_AWVALID => M_AXI_AWVALID, -- Write address valid. This signal indicates that the master signaling valid write address and control information. 
		M_AXI_AWREADY => M_AXI_AWREADY, -- Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
		
		-- Master Interface Write Data
		M_AXI_WDATA   => M_AXI_WDATA, -- Master Interface Write Data Channel ports. Write data (issued by master)
		M_AXI_WSTRB   => M_AXI_WSTRB, -- Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
		M_AXI_WVALID  => M_AXI_WVALID, -- Write valid. This signal indicates that valid write data and strobes are available.
		M_AXI_WREADY  => M_AXI_WREADY, -- Write ready. This signal indicates that the slave can accept the write data.
		
		-- Master Interface Write Response
		M_AXI_BRESP   => M_AXI_BRESP, -- Master Interface Write Response Channel ports. This signal indicates the status of the write transaction.
		M_AXI_BVALID  => M_AXI_BVALID, -- Write response valid. This signal indicates that the channel is signaling a valid write response
		M_AXI_BREADY  => M_AXI_BREADY, -- Response ready. This signal indicates that the master can accept a write response.
		
		-- Master Interface Read Address
		M_AXI_ARADDR  => M_AXI_ARADDR, -- Master Interface Read Address Channel ports. Read address (issued by master)
		M_AXI_ARPROT  => open, -- Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access. 
		M_AXI_ARVALID => M_AXI_ARVALID, -- Read address valid. This signal indicates that the channel is signaling valid read address and control information.
		M_AXI_ARREADY => M_AXI_ARREADY, -- Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
		
		-- Master Interface Read Data
		M_AXI_RDATA   => M_AXI_RDATA, -- Master Interface Read Data Channel ports. Read data (issued by slave)
		M_AXI_RRESP   => M_AXI_RRESP, -- Read response. This signal indicates the status of the read transfer.
		M_AXI_RVALID  => M_AXI_RVALID, -- Read valid. This signal indicates that the channel is signaling the required read data.
		M_AXI_RREADY  => M_AXI_RREADY, -- Read ready. This signal indicates that the master can accept the read data and response information.
		
		--Others
		INIT_AXI_TXN  => Started, --init_txn_pulse, Initiate AXI transactions
		ERROR         => open, -- Asserts when ERROR is detected
		TXN_DONE      => open  -- Asserts when AXI transactions is complete
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
		Start_Fill_BRAM <= '1';
		wait for 20 ns;
		Start_Fill_BRAM <= '0';
		wait;
		reset <= '0';
	end process;
		
	--SM_AXI_MM STATE MACHINE---  
	--SYNC Process of SM_AXI_MM
	SYNC_PROC: process (Clock)
	begin
		if (rising_edge(Clock)) then
			if Reset = '1' then
				state_AXI_MM <= ST00_Idle;
			else
				state_AXI_MM <= next_state_AXI_MM;   
			end if;  
		end if;
	end process;
	
	--NEXT_STATE_DECODE of SM_AXI_MM
	NEXT_STATE_DECODE: process (state_AXI_MM, Data_Counter_DataOut, Start_Fill_BRAM)
	begin
		next_state_AXI_MM <= state_AXI_MM;  --default is to stay in current state
		case (state_AXI_MM) is
			when ST00_Idle =>
				next_state_AXI_MM <= ST01_Preload_Data_Counter;
			when ST01_Preload_Data_Counter =>
				if Start_Fill_BRAM = '1' then
					next_state_AXI_MM <= ST02_WriteToDDR;
				end if;
			when ST02_WriteToDDR =>                       
				if Data_Counter_DataOut = x"0000003F" then
					next_state_AXI_MM <= ST03_ResetCounter;
				end if;
			when ST03_ResetCounter =>
				next_state_AXI_MM <= ST04_End_BRAM_Fill; 
			when ST04_End_BRAM_Fill =>
				next_state_AXI_MM <= ST05_Start_Hast_IP;
			when ST05_Start_Hast_IP =>
				--if Counter_Data_Out = x"0000003F" then
				next_state_AXI_MM <= ST06_Calc_State;
				--end if;
			when ST06_Calc_State =>
			
			when others => null;        
		end case;      
	end process; 
		
		
	--OUTPUT_DECODE of SM_AXI_MM
	OUTPUT_DECODE: process (state_AXI_MM)
	begin
		case (state_AXI_MM) is
			when ST00_Idle               =>
				BRAM_FILL_PHASE   <= '0';
				BRAM_FILL_AWVALID <= '0';
				BRAM_FILL_WVALID  <= '0';
			--	Rst_Counter       <= '0';
				--Address_Counter_Ena <= '0';
				--Data_Counter_Ena    <= '0';
				Data_Counter_Load   <= '0';
				Data_Counter_DataIn <= (others => '0');

			when ST01_Preload_Data_Counter =>                    
				BRAM_FILL_PHASE   <= '0';
				BRAM_FILL_AWVALID <= '0';
				BRAM_FILL_WVALID  <= '0';        
			--	Rst_Counter       <= '0';
				--Address_Counter_Ena <= '0';
				--Data_Counter_Ena    <= '1';   
				Data_Counter_Load   <= '1';
				Data_Counter_DataIn <= x"00000001";  
				
			when ST02_WriteToDDR         =>
				BRAM_FILL_PHASE   <= '1';
				BRAM_FILL_AWVALID <= '1';
				BRAM_FILL_WVALID  <= '1';
			--	Rst_Counter       <= '0';
				--Address_Counter_Ena <= '1';
				--Data_Counter_Ena    <= '1';   
				Data_Counter_Load   <= '0';
				--Data_Counter_DataIn <= (others => '0');
				
			when ST03_ResetCounter       =>
				BRAM_FILL_PHASE   <= '1';
				BRAM_FILL_AWVALID <= '0';
				BRAM_FILL_WVALID  <= '0';
			--	Rst_Counter       <= '1';
				--Address_Counter_Ena <= '0';
				--Data_Counter_Ena    <= '0';   
				Data_Counter_Load   <= '0';
				Data_Counter_DataIn <= (others => '0');
				
			when ST04_End_BRAM_Fill     =>
				BRAM_FILL_PHASE   <= '0';
				BRAM_FILL_AWVALID <= '0';
				BRAM_FILL_WVALID  <= '0';
				
			when ST05_Start_Hast_IP     =>
				BRAM_FILL_PHASE   <= '0';
				BRAM_FILL_AWVALID <= '0';
				BRAM_FILL_WVALID  <= '0';
				Started           <= '1';
			--	Rst_Counter       <= '1';
			
			when ST06_Calc_State     =>
				BRAM_FILL_PHASE   <= '0';
				BRAM_FILL_AWVALID <= '0';
				BRAM_FILL_WVALID  <= '0';
				Started           <= '0';
				
			when others => null;               
		end case;       
	end process; 
		
end Imp;