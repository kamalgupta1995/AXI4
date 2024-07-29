`timescale 1ns/1ps

module axi_tb_top;

    import uvm_pkg::*;
    `include "uvm_macros.svh" 

    bit ACLK;
    bit ARESETn;

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

    // AXI Interface Instantiation
    axi_if #(.ID_WIDTH      (AXI_ID_WIDTH    ),
             .ADDR_WIDTH    (AXI_ADDR_WIDTH  ),
             .LEN_WIDTH     (AXI_LEN_WIDTH   ),
             .DATA_WIDTH    (AXI_DATA_WIDTH  ),
             .STRB_WIDTH    (AXI_DATA_WIDTH/8),
             .AWUSER_WIDTH  (AXI_AWUSER_WIDTH),
             .WUSER_WIDTH   (AXI_WUSER_WIDTH ),
             .BUSER_WIDTH   (AXI_BUSER_WIDTH ),
             .ARUSER_WIDTH  (AXI_ARUSER_WIDTH),
             .RUSER_WIDTH   (AXI_RUSER_WIDTH )
    ) axi_slave_if0(clk, resetn);    
    

    // Clock Generation
    always #5 ACLK = ~ACLK;

    initial begin
        // Initialize Inputs
        ACLK = 0;
        ARESETn = 0;
        // Reset the DUT
        #10;
        ARESETn = 1;
        #10;
        ARESETn = 0;
    end

    // Set config_db for Interface and run_test method
    initial begin
        uvm_config_db#(virtual axi_if)::set(null, "*", "axi_vif", axi_slave_if0);
        run_test();
    end

    // Waveform dump (edapg)
    initial begin
        $dumpfile("axi_tb_top.vcd");
        $dumpvars(0, axi_tb_top);
    end
 

endmodule
