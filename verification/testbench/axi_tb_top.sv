`timescale 1ns/1ps

module axi_tb_top;

    //import uvm_pkg::*;
    //`include "uvm_macros.svh" 

    bit ACLK=0;
    bit ARESETn=1;
/*
    // Parameters
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
    parameter ID_WIDTH = 4;
    parameter DEPTH = 1024;
    parameter LEN_WIDTH = 8;
    parameter SIZE_WIDTH = 3;
    parameter BURST_WIDTH = 2;
    parameter LOCK_WIDTH = 1;
    parameter CACHE_WIDTH = 4;
    parameter PROT_WIDTH = 3;
    parameter QOS_WIDTH = 4;
    parameter RESP_WIDTH = 2;
    localparam START_ADDR = 32'h00000000;
    localparam END_ADDR = 32'h000003FF;
*/
    // AXI Interface Instantiation
  axi_if #(.ID_WIDTH      (4   ),
           .ADDR_WIDTH    (32  ),
           .LEN_WIDTH     (8   ),
           .DATA_WIDTH    (32  ),
           .STRB_WIDTH    (32/8)
//              .AWUSER_WIDTH  (AXI_AWUSER_WIDTH),
//              .WUSER_WIDTH   (AXI_WUSER_WIDTH ),
//              .BUSER_WIDTH   (AXI_BUSER_WIDTH ),
//              .ARUSER_WIDTH  (AXI_ARUSER_WIDTH),
//              .RUSER_WIDTH   (AXI_RUSER_WIDTH )
            ) axi_if_master0(ACLK, ARESETn);    
    
    // Instantiate the DUT
    axi4_dut #(
      .DATA_WIDTH(32),
      .ADDR_WIDTH(32),
      .ID_WIDTH(4),
      .DEPTH(1024),
      .LEN_WIDTH(8),
      .SIZE_WIDTH(3),
      .BURST_WIDTH(2),
      .LOCK_WIDTH(1),
      .CACHE_WIDTH(4),
      .PROT_WIDTH(3),
      .QOS_WIDTH(4),
      .RESP_WIDTH(2),
      .START_ADDR(0)
    ) dut (
        .ACLK(ACLK),
        .ARESETn(ARESETn),
        .MEM_AWID(axi_if_master0.AXI_AWID),
        .MEM_AWADDR(axi_if_master0.AXI_AWADDR),
        .MEM_AWLEN(axi_if_master0.AXI_AWLEN),
        .MEM_AWSIZE(axi_if_master0.AXI_AWSIZE),
        .MEM_AWBURST(axi_if_master0.AXI_AWBURST),
        .MEM_AWLOCK(axi_if_master0.AXI_AWLOCK),
        .MEM_AWCACHE(axi_if_master0.AXI_AWCACHE),
        .MEM_AWPROT(axi_if_master0.AXI_AWPROT),
//        .MEM_AWQOS(axi_if_master0.AXI_AWQOS),
        .MEM_AWVALID(axi_if_master0.AXI_AWVALID),
        .MEM_AWREADY(axi_if_master0.AXI_AWREADY),
//        .MEM_WID(axi_if_master0.AXI_WID), // no WID in AXI4
        .MEM_WDATA(axi_if_master0.AXI_WDATA),
        .MEM_WSTRB(axi_if_master0.AXI_WSTRB),
        .MEM_WLAST(axi_if_master0.AXI_WLAST),
        .MEM_WVALID(axi_if_master0.AXI_WVALID),
        .MEM_WREADY(axi_if_master0.AXI_WREADY),
        .MEM_BID(axi_if_master0.AXI_BID),
        .MEM_BRESP(axi_if_master0.AXI_BRESP),
        .MEM_BVALID(axi_if_master0.AXI_BVALID),
        .MEM_BREADY(axi_if_master0.AXI_BREADY),
        .MEM_ARID(axi_if_master0.AXI_ARID),
        .MEM_ARADDR(axi_if_master0.AXI_ARADDR),
        .MEM_ARLEN(axi_if_master0.AXI_ARLEN),
        .MEM_ARSIZE(axi_if_master0.AXI_ARSIZE),
        .MEM_ARBURST(axi_if_master0.AXI_ARBURST),
        .MEM_ARLOCK(axi_if_master0.AXI_ARLOCK),
        .MEM_ARCACHE(axi_if_master0.AXI_ARCACHE),
        .MEM_ARPROT(axi_if_master0.AXI_ARPROT),
//        .MEM_ARQOS(axi_if_master0.AXI_ARQOS),
        .MEM_ARVALID(axi_if_master0.AXI_ARVALID),
        .MEM_ARREADY(axi_if_master0.AXI_ARREADY),
        .MEM_RID(axi_if_master0.AXI_RID),
        .MEM_RDATA(axi_if_master0.AXI_RDATA),
        .MEM_RRESP(axi_if_master0.AXI_RRESP),
        .MEM_RLAST(axi_if_master0.AXI_RLAST),
        .MEM_RVALID(axi_if_master0.AXI_RVALID),
        .MEM_RREADY(axi_if_master0.AXI_ARREADY)
    );

    // Clock Generation
    always #5 ACLK = ~ACLK;

    initial begin
        // Initialize Inputs
        ACLK = 0;
        ARESETn = 1;
        // Reset the DUT
        #8;
        ARESETn = 0;
        #17;
      @(posedge axi_if_master0.AXI_ACLK);
        ARESETn = 1;
    end

    // Set config_db for Interface and run_test method
    initial begin
		uvm_config_db#(virtual axi_if)::set(null, "*", "axi_vif", axi_if_master0);
      	run_test("axi_sanity_test");
      //run_test("axi_read_test");
    end

      initial #10000 $finish;

    // Waveform dump (edapg)
  /*  initial begin
      	$printtimescale;
        $dumpfile("axi_tb_top.vcd");
        $dumpvars(0, axi_tb_top);
    end  */

       
 initial
   begin
    // $dumpfile("dump.vcd"); 
    // $dumpvars; 
    $shm_open("waves.shm");
    $shm_probe("AS");
   end
endmodule
