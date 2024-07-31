`timescale 1ns/1ps

module axi4_dut_tb;
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

    // DUT Signals
    reg ACLK;
    reg ARESETn;

    // Write Address Channel
    reg [ID_WIDTH-1:0] MEM_AWID;
    reg [ADDR_WIDTH-1:0] MEM_AWADDR;
    reg [LEN_WIDTH-1:0] MEM_AWLEN;
    reg [SIZE_WIDTH-1:0] MEM_AWSIZE;
    reg [BURST_WIDTH-1:0] MEM_AWBURST;
    reg [LOCK_WIDTH-1:0] MEM_AWLOCK;
    reg [CACHE_WIDTH-1:0] MEM_AWCACHE;
    reg [PROT_WIDTH-1:0] MEM_AWPROT;
    reg [QOS_WIDTH-1:0] MEM_AWQOS;
    reg MEM_AWVALID;
    wire MEM_AWREADY;

    // Write Data Channel
    reg [DATA_WIDTH-1:0] MEM_WDATA;
    reg [(DATA_WIDTH/8)-1:0] MEM_WSTRB;
    reg MEM_WLAST;
    reg MEM_WVALID;
    wire MEM_WREADY;

    // Write Response Channel
    wire [ID_WIDTH-1:0] MEM_BID;
    wire [RESP_WIDTH-1:0] MEM_BRESP;
    wire MEM_BVALID;
    reg MEM_BREADY;

    // Read Address Channel
    reg [ID_WIDTH-1:0] MEM_ARID;
    reg [ADDR_WIDTH-1:0] MEM_ARADDR;
    reg [LEN_WIDTH-1:0] MEM_ARLEN;
    reg [SIZE_WIDTH-1:0] MEM_ARSIZE;
    reg [BURST_WIDTH-1:0] MEM_ARBURST;
    reg [LOCK_WIDTH-1:0] MEM_ARLOCK;
    reg [CACHE_WIDTH-1:0] MEM_ARCACHE;
    reg [PROT_WIDTH-1:0] MEM_ARPROT;
    reg [QOS_WIDTH-1:0] MEM_ARQOS;
    reg MEM_ARVALID;
    wire MEM_ARREADY;

    // Read Data Channel
    wire [ID_WIDTH-1:0] MEM_RID;
    wire [DATA_WIDTH-1:0] MEM_RDATA;
    wire [RESP_WIDTH-1:0] MEM_RRESP;
    wire MEM_RLAST;
    wire MEM_RVALID;
    reg MEM_RREADY;

    // Instantiate the DUT
    axi4_dut #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .DEPTH(DEPTH),
        .LEN_WIDTH(LEN_WIDTH),
        .SIZE_WIDTH(SIZE_WIDTH),
        .BURST_WIDTH(BURST_WIDTH),
        .LOCK_WIDTH(LOCK_WIDTH),
        .CACHE_WIDTH(CACHE_WIDTH),
        .PROT_WIDTH(PROT_WIDTH),
        .QOS_WIDTH(QOS_WIDTH),
        .RESP_WIDTH(RESP_WIDTH),
        .START_ADDR(START_ADDR)
    ) dut (
        .ACLK(ACLK),
        .ARESETn(ARESETn),
        .MEM_AWID(MEM_AWID),
        .MEM_AWADDR(MEM_AWADDR),
        .MEM_AWLEN(MEM_AWLEN),
        .MEM_AWSIZE(MEM_AWSIZE),
        .MEM_AWBURST(MEM_AWBURST),
        .MEM_AWLOCK(MEM_AWLOCK),
        .MEM_AWCACHE(MEM_AWCACHE),
        .MEM_AWPROT(MEM_AWPROT),
        .MEM_AWQOS(MEM_AWQOS),
        .MEM_AWVALID(MEM_AWVALID),
        .MEM_AWREADY(MEM_AWREADY),
        .MEM_WDATA(MEM_WDATA),
        .MEM_WSTRB(MEM_WSTRB),
        .MEM_WLAST(MEM_WLAST),
        .MEM_WVALID(MEM_WVALID),
        .MEM_WREADY(MEM_WREADY),
        .MEM_BID(MEM_BID),
        .MEM_BRESP(MEM_BRESP),
        .MEM_BVALID(MEM_BVALID),
        .MEM_BREADY(MEM_BREADY),
        .MEM_ARID(MEM_ARID),
        .MEM_ARADDR(MEM_ARADDR),
        .MEM_ARLEN(MEM_ARLEN),
        .MEM_ARSIZE(MEM_ARSIZE),
        .MEM_ARBURST(MEM_ARBURST),
        .MEM_ARLOCK(MEM_ARLOCK),
        .MEM_ARCACHE(MEM_ARCACHE),
        .MEM_ARPROT(MEM_ARPROT),
        .MEM_ARQOS(MEM_ARQOS),
        .MEM_ARVALID(MEM_ARVALID),
        .MEM_ARREADY(MEM_ARREADY),
        .MEM_RID(MEM_RID),
        .MEM_RDATA(MEM_RDATA),
        .MEM_RRESP(MEM_RRESP),
        .MEM_RLAST(MEM_RLAST),
        .MEM_RVALID(MEM_RVALID),
        .MEM_RREADY(MEM_RREADY)
    );

    // Clock Generation
    always #5 ACLK = ~ACLK;

    initial begin
        // Initialize Inputs
        ACLK = 0;
        ARESETn = 0;
        MEM_AWID = 0;
        MEM_AWADDR = 0;
        MEM_AWLEN = 0;
        MEM_AWSIZE = 3'b010; // 4 bytes
        MEM_AWBURST = 2'b01; // INCR
        MEM_AWLOCK = 0;
        MEM_AWCACHE = 0;
        MEM_AWPROT = 0;
        MEM_AWQOS = 0;
        MEM_AWVALID = 0;
        MEM_WDATA = 0;
        MEM_WSTRB = 4'b1111;
        MEM_WLAST = 0;
        MEM_WVALID = 0;
        MEM_BREADY = 0;
        MEM_ARID = 0; // Set a different ID for read transactions
        MEM_ARADDR = 0;
        MEM_ARLEN = 0;
        MEM_ARSIZE = 3'b010; // 4 bytes
        MEM_ARBURST = 2'b01; // INCR
        MEM_ARLOCK = 0;
        MEM_ARCACHE = 0;
        MEM_ARPROT = 0;
        MEM_ARQOS = 0;
        MEM_ARVALID = 0;
        MEM_RREADY = 0;

        // Reset the DUT
        #10;
        ARESETn = 1;

        // First Write Transaction
        #10;
        MEM_AWID = 4'b0010; // Example AWID
        MEM_AWADDR = 32'h00000004;
        MEM_AWVALID = 1;  // Assert AWVALID
        wait (MEM_AWREADY);
        @(posedge ACLK); // Wait one more cycle after AWREADY is asserted
        #5;
        MEM_AWVALID = 0;  // Deassert AWVALID
        #10;
        MEM_WDATA = 32'hABCD0123;
        MEM_WVALID = 1;  // Assert WVALID
        MEM_WLAST = 1;
        wait (MEM_WREADY);
        @(posedge ACLK); // Wait one more cycle after WREADY is asserted
        #5;
        MEM_WVALID = 0;  // Deassert WVALID
        MEM_WLAST = 0;
        #5;

        // B channel response for first transaction
        MEM_BREADY = 1;  // Assert BREADY
        wait (MEM_BVALID);
        #11;
        MEM_BREADY = 0;  // Deassert BREADY

        // Second Write Transaction
        #10;
        MEM_AWID = 4'b0011; // Example AWID
        MEM_AWADDR = 32'h00000008;
        MEM_AWVALID = 1;  // Assert AWVALID
        wait (MEM_AWREADY);
        @(posedge ACLK); // Wait one more cycle after AWREADY is asserted
        #5;
        MEM_AWVALID = 0;  // Deassert AWVALID
        #10;
        MEM_WDATA = 32'h1234ABCD;
        MEM_WVALID = 1;  // Assert WVALID
        MEM_WLAST = 1;
        wait (MEM_WREADY);
        @(posedge ACLK); // Wait one more cycle after WREADY is asserted
        #5;
        MEM_WVALID = 0;  // Deassert WVALID
        MEM_WLAST = 0;
        #5;

        // B channel response for second transaction
        MEM_BREADY = 1;  // Assert BREADY
        wait (MEM_BVALID);
        #11;
        MEM_BREADY = 0;  // Deassert BREADY

        // Third Write Transaction
        #10;
        MEM_AWID = 4'b0110; // Example AWID
        MEM_AWADDR = 32'h0000000B;
        MEM_AWVALID = 1;  // Assert AWVALID
        wait (MEM_AWREADY);
        @(posedge ACLK); // Wait one more cycle after AWREADY is asserted
        #5;
        MEM_AWVALID = 0;  // Deassert AWVALID
        #10;
        MEM_WDATA = 32'h44442222;
        MEM_WVALID = 1;  // Assert WVALID
        MEM_WLAST = 1;
        wait (MEM_WREADY);
        @(posedge ACLK); // Wait one more cycle after WREADY is asserted
        #5;
        MEM_WVALID = 0;  // Deassert WVALID
        MEM_WLAST = 0;
        #5;

        // B channel response for Third transaction
        MEM_BREADY = 1;  // Assert BREADY
        wait (MEM_BVALID);
        #11;
        MEM_BREADY = 0;  // Deassert BREADY

        // First Read Transaction
        #10;
        #1;
        MEM_ARID = 4'b0100;
        MEM_ARADDR = 32'h00000004;
        MEM_ARVALID = 1;  // Assert ARVALID
        wait (MEM_ARREADY);
        @(posedge ACLK); // Wait one more cycle after ARREADY is asserted
        #1;
        MEM_ARVALID = 0;  // Deassert ARVALID
        #5;
        MEM_RREADY = 1;  // Assert RREADY
        wait (MEM_RVALID);
        #11;
        @(posedge ACLK); // Wait one more cycle after RVALID is asserted
        MEM_RREADY = 0;  // Deassert RREADY

        // Second Read Transaction
        #10;
        #1;
        MEM_ARID = 4'b0101;
        MEM_ARADDR = 32'h00000008;
        MEM_ARVALID = 1;  // Assert ARVALID
        wait (MEM_ARREADY);
        #11;
        MEM_ARVALID = 0;  // Deassert ARVALID
        #5;
        MEM_RREADY = 1;  // Assert RREADY
        wait (MEM_RVALID);
        #11;
        @(posedge ACLK); // Wait one more cycle after RVALID is asserted
        MEM_RREADY = 0;  // Deassert RREADY

        // Third Read Transaction
        #10;
        #1;
        MEM_ARID = 4'b0111;
        MEM_ARADDR = 32'h0000000B;
        MEM_ARVALID = 1;  // Assert ARVALID
        wait (MEM_ARREADY);
        #11;
        MEM_ARVALID = 0;  // Deassert ARVALID
        #5;
        MEM_RREADY = 1;  // Assert RREADY
        wait (MEM_RVALID);
        #11;
        @(posedge ACLK); // Wait one more cycle after RVALID is asserted
        MEM_RREADY = 0;  // Deassert RREADY

        // Finish simulation
        #100;
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("axi4_dut_tb.vcd");
        $dumpvars(0, axi4_dut_tb);
    end

    // Timeout logic
    initial begin
        #1000;
        $display("Simulation Timeout");
        $finish;
    end
endmodule

