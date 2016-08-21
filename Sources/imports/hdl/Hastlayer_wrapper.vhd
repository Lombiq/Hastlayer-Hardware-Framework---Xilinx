--Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2015.1 (win64) Build 1215546 Mon Apr 27 19:22:08 MDT 2015
--Date        : Mon Jun 08 22:33:45 2015
--Host        : Shodan-PC running 64-bit Service Pack 1  (build 7601)
--Command     : generate_target Hastlayer_wrapper.bd
--Design      : Hastlayer_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity Hastlayer_wrapper is
  port (
    --Generic purpose Ports
    reset : in STD_LOGIC;
    sys_clock : in STD_LOGIC;
    
    --DDR2 Memory Ports
    DDR2_addr : out STD_LOGIC_VECTOR ( 12 downto 0 );
    DDR2_ba : out STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR2_cas_n : out STD_LOGIC;
    DDR2_ck_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR2_ck_p : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR2_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR2_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR2_dm : out STD_LOGIC_VECTOR ( 1 downto 0 );
    DDR2_dq : inout STD_LOGIC_VECTOR ( 15 downto 0 );
    DDR2_dqs_n : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    DDR2_dqs_p : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    DDR2_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR2_ras_n : out STD_LOGIC;
    DDR2_we_n : out STD_LOGIC;
    
    --USB UART Ports
    USB_Uart_rxd : in STD_LOGIC;
    USB_Uart_txd : out STD_LOGIC;

    --Ethernet Ports
    ETH_mdio_mdc_mdc : out STD_LOGIC;
    ETH_rmii_crs_dv : in STD_LOGIC;
    ETH_rmii_rx_er : in STD_LOGIC;
    ETH_rmii_rxd : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ETH_rmii_tx_en : out STD_LOGIC;
    ETH_rmii_txd : out STD_LOGIC_VECTOR ( 1 downto 0 );
    eth_mdio_mdc_mdio_io : inout STD_LOGIC;
    eth_ref_clk : out STD_LOGIC
  );
end Hastlayer_wrapper;

architecture STRUCTURE of Hastlayer_wrapper is
  component Hastlayer is
  port (
    --Generic purpose Ports
    reset : in STD_LOGIC;
    sys_clock : in STD_LOGIC;
    m00_axi_init_axi_txn : in STD_LOGIC; 

    
    --DDR2 Memory Ports
    DDR2_dq : inout STD_LOGIC_VECTOR ( 15 downto 0 );
    DDR2_dqs_p : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    DDR2_dqs_n : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    DDR2_addr : out STD_LOGIC_VECTOR ( 12 downto 0 );
    DDR2_ba : out STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR2_ras_n : out STD_LOGIC;
    DDR2_cas_n : out STD_LOGIC;
    DDR2_we_n : out STD_LOGIC;
    DDR2_ck_p : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR2_ck_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR2_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR2_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR2_dm : out STD_LOGIC_VECTOR ( 1 downto 0 );
    DDR2_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
    
    --USB UART Ports
    USB_Uart_rxd : in STD_LOGIC;
    USB_Uart_txd : out STD_LOGIC;
    
    --Ethernet Ports
    eth_ref_clk : out STD_LOGIC;
    ETH_mdio_mdc_mdc : out STD_LOGIC;
    ETH_mdio_mdc_mdio_i : in STD_LOGIC;
    ETH_mdio_mdc_mdio_o : out STD_LOGIC;
    ETH_mdio_mdc_mdio_t : out STD_LOGIC;
    ETH_rmii_crs_dv : in STD_LOGIC;
    ETH_rmii_rx_er : in STD_LOGIC;
    ETH_rmii_rxd : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ETH_rmii_tx_en : out STD_LOGIC;
    ETH_rmii_txd : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  end component Hastlayer;
  
  component IOBUF is
  port (
    I : in STD_LOGIC;
    O : out STD_LOGIC;
    T : in STD_LOGIC;
    IO : inout STD_LOGIC
  );
  end component IOBUF;
  signal eth_mdio_mdc_mdio_i : STD_LOGIC;
  signal eth_mdio_mdc_mdio_o : STD_LOGIC;
  signal eth_mdio_mdc_mdio_t : STD_LOGIC;
  
begin
Hastlayer_i: component Hastlayer
     port map (
     --Generic purpose Ports
      reset => reset,
      sys_clock => sys_clock,
      m00_axi_init_axi_txn => '0',
      --DDR2 Memory Ports 
      DDR2_addr(12 downto 0) => DDR2_addr(12 downto 0),
      DDR2_ba(2 downto 0) => DDR2_ba(2 downto 0),
      DDR2_cas_n => DDR2_cas_n,
      DDR2_ck_n(0) => DDR2_ck_n(0),
      DDR2_ck_p(0) => DDR2_ck_p(0),
      DDR2_cke(0) => DDR2_cke(0),
      DDR2_cs_n(0) => DDR2_cs_n(0),
      DDR2_dm(1 downto 0) => DDR2_dm(1 downto 0),
      DDR2_dq(15 downto 0) => DDR2_dq(15 downto 0),
      DDR2_dqs_n(1 downto 0) => DDR2_dqs_n(1 downto 0),
      DDR2_dqs_p(1 downto 0) => DDR2_dqs_p(1 downto 0),
      DDR2_odt(0) => DDR2_odt(0),
      DDR2_ras_n => DDR2_ras_n,
      DDR2_we_n => DDR2_we_n,
      
      --USB UART Ports
      USB_Uart_rxd => USB_Uart_rxd,
      USB_Uart_txd => USB_Uart_txd,
      
      --Ethernet Ports
      eth_ref_clk => eth_ref_clk,
      ETH_mdio_mdc_mdc => ETH_mdio_mdc_mdc,
      ETH_mdio_mdc_mdio_i => eth_mdio_mdc_mdio_i,
      ETH_mdio_mdc_mdio_o => eth_mdio_mdc_mdio_o,
      ETH_mdio_mdc_mdio_t => eth_mdio_mdc_mdio_t,
      ETH_rmii_crs_dv => ETH_rmii_crs_dv,
      ETH_rmii_rx_er => ETH_rmii_rx_er,
      ETH_rmii_rxd(1 downto 0) => ETH_rmii_rxd(1 downto 0),
      ETH_rmii_tx_en => ETH_rmii_tx_en,
      ETH_rmii_txd(1 downto 0) => ETH_rmii_txd(1 downto 0)
    );
    
IOBUF_i: IOBUF 
    port map (
      I   => eth_mdio_mdc_mdio_o,
      O   => eth_mdio_mdc_mdio_i,
      T   => eth_mdio_mdc_mdio_t,
      IO  => eth_mdio_mdc_mdio_io
    );

end STRUCTURE;
