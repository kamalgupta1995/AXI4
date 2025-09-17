//----------------------------------------------------
// AXI Interface
// File Name: axi_if.sv
//----------------------------------------------------
`timescale 1ns/1ns

interface axi_if #(
  parameter int ID_WIDTH     = 4,
  parameter int ADDR_WIDTH   = 32,
  parameter int LEN_WIDTH    = 8,
  parameter int DATA_WIDTH   = 256,
  parameter int STRB_WIDTH   = `DATA_WIDTH/8 
  )
  (input AXI_ACLK, input AXI_ARESETn);

  parameter int ID_MAX     = ID_WIDTH     - 1;
  parameter int ADDR_MAX   = ADDR_WIDTH   - 1;
  parameter int DATA_MAX   = DATA_WIDTH   - 1;
  parameter int STRB_MAX   = STRB_WIDTH   - 1;

  // Write Address Channel
  logic      [ID_MAX:0] AXI_AWID;
  logic    [ADDR_MAX:0] AXI_AWADDR;
  logic [LEN_WIDTH-1:0] AXI_AWLEN;
  logic           [2:0] AXI_AWSIZE;
  logic           [1:0] AXI_AWBURST;
  logic                 AXI_AWLOCK;
  logic           [3:0] AXI_AWCACHE;
  logic           [2:0] AXI_AWPROT;
  logic                 AXI_AWVALID;
  logic                 AXI_AWREADY;


  // Write Data Channel
  logic     [ID_MAX:0] AXI_WID;
  logic   [255:0] AXI_WDATA;
  logic   [STRB_MAX:0] AXI_WSTRB;
  logic                AXI_WLAST;
  logic                AXI_WVALID;
  logic                AXI_WREADY;


  // Write Response Channel
  logic     [ID_MAX:0] AXI_BID;
  logic          [1:0] AXI_BRESP;
  logic                AXI_BVALID;
  logic                AXI_BREADY;

  // Read Address Channel
  logic     [ID_MAX:0] AXI_ARID;
  logic   [ADDR_MAX:0] AXI_ARADDR;
  logic[LEN_WIDTH-1:0] AXI_ARLEN;
  logic          [2:0] AXI_ARSIZE;
  logic          [1:0] AXI_ARBURST;
  logic          [3:0] AXI_ARCACHE;
  logic          [2:0] AXI_ARPROT;
  logic                AXI_ARLOCK;
  logic                AXI_ARVALID;
  logic                AXI_ARREADY;


  // Read Data Channel
  logic     [ID_MAX:0] AXI_RID;
  logic   [255:0] AXI_RDATA;
  logic          [1:0] AXI_RRESP;
  logic                AXI_RLAST;
  logic                AXI_RVALID;
  logic                AXI_RREADY;
 
  logic         [3:0] AXI_AWQOS;
  logic         [3:0] AXI_ARQOS;


  //logic AXI_ACLK;
  //logic AXI_ARESETn;

/*
  // AXI4 Addition
  logic         [3:0] AXI_AWREGION;
  logic         [3:0] AXI_AWQOS;
  logic         [3:0] AXI_ARREGION;
  logic         [3:0] AXI_ARQOS;


  // User defined signaling
  logic [AWUSER_MAX:0] AXI_AWUSER;
  logic  [WUSER_MAX:0] AXI_WUSER;
  logic  [BUSER_MAX:0] AXI_BUSER;
  logic [ARUSER_MAX:0] AXI_ARUSER;
  logic  [RUSER_MAX:0] AXI_RUSER;
*/
endinterface

