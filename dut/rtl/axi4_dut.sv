////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Comapny:                  ACL Digital
// Engineer:                 Ishan Sharma
// Create Date:              19-06-2024
// Design Name:              AXI4 DUT
// Module Name:              axi4_dut
// Description:              Implements an AXI4 interface to write/read into/from a register bank
// Dependencies:             fifo.sv
// Revision:                 1.0
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//Current Specifications/Features of the Design:

//This DUT is designed to act as an AXI4 slave, processing read and write requests from an AXI4 master and providing appropriate responses. The master initiates transactions, while the slave (this DUT) responds to those transactions.

//1. Parameterized Design:

//The design is highly parameterized with configurable parameters like DATA_WIDTH, ADDR_WIDTH, ID_WIDTH, DEPTH, and various FIFO widths, enabling flexibility for different configurations.

//2. FIFO Implementation:

//Separate FIFOs are implemented for each AXI4 channel (AW, W, B, AR, R), which handle address, write data, write response, read address, and read data respectively.

//3. Write Channel (AW and W):

//The AW channel FIFO stores the write address and related control signals.
//The W channel FIFO stores the write data and related control signals.
//Handshaking signals (AWREADY, WREADY) are implemented to control the flow of data.
//Write responses are generated and stored in the B channel FIFO.

//4. Read Channel (AR and R):

//The AR channel FIFO stores the read address and related control signals.
//The R channel FIFO stores the read data and related control signals.
//Handshaking signals (ARREADY, RVALID) are implemented to control the flow of data.

//5. Address Decoding:

//Address decoding logic is implemented to ensure that write/read operations are performed only within a valid address range (between START_ADDR and END_ADDR).

//6. Error Handling:

//If a write or read address is out of the valid range, an error response (DECERR) is generated.

//Limitations of the Design:

//1. Single Beat Transactions:

//The current implementation assumes single beat transactions. Burst transactions (multiple beats) might not be fully supported or tested.

//2. Read Data Validity:

//The RLAST signal is hardcoded to 1'b1, assuming all read transactions are single beat. This may not be suitable for burst read transactions.

//3. Simultaneous Transactions:

//While the design can handle multiple outstanding transactions, the handling of simultaneous read and write operations and their synchronization is not explicitly detailed.

//4. The current design supports a single AXI4 master

//Current Capabilities:

//Write Operations: Can accept and process write transactions, including generating appropriate write responses.
//Read Operations: Can accept and process read transactions, including providing appropriate read data and responses.
//Error Detection: Can detect and respond to address out-of-range errors.
//FIFO Management: Uses FIFOs to manage data flow between different AXI4 channels, ensuring proper handshaking and data integrity.

//Areas for Improvement:

//1. Burst Transaction Support: Extend support and testing for burst transactions.
//2. Synchronization: Ensure proper synchronization between read and write operations, especially for simultaneous transactions3. Generalization for Larger Designs: Consider the scalability of the design for more complex systems, potentially reintroducing NoC for address decoding and routing.
//4. To support multiple AXI4 masters, you would need to add arbiter logic to manage access to the shared resources and possibly duplicate the FIFOs or manage them in such a way to handle input from multiple sources.


`timescale 1ns/1ps

module axi4_dut #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter ID_WIDTH = 4,
    parameter DEPTH = 1024,
    parameter LEN_WIDTH = 8,
    parameter SIZE_WIDTH = 3,
    parameter BURST_WIDTH = 2,
    parameter LOCK_WIDTH = 1,
    parameter CACHE_WIDTH = 4,
    parameter PROT_WIDTH = 3,
    parameter QOS_WIDTH = 4,
    parameter RESP_WIDTH = 2,
    parameter AW_FIFO_WIDTH = ADDR_WIDTH + // 32
                              LEN_WIDTH +  // 8
                              SIZE_WIDTH + // 3
                              BURST_WIDTH +// 2
                              CACHE_WIDTH +// 4
                              PROT_WIDTH + // 3
                              LOCK_WIDTH + // 1
                              QOS_WIDTH +  // 4
                              ID_WIDTH +   // 4
                              7,           // Additional bits for Leading zeroes to align with hex concatenation = 68
    parameter W_FIFO_WIDTH = 1 +            // 1
                             (DATA_WIDTH/8) + // 4
                             DATA_WIDTH,      // 32 = 37
    parameter AR_FIFO_WIDTH = ADDR_WIDTH +
                              LEN_WIDTH +
                              SIZE_WIDTH +
                              BURST_WIDTH +
                              CACHE_WIDTH +
                              PROT_WIDTH +
                              LOCK_WIDTH +
                              QOS_WIDTH +
                              ID_WIDTH +
                              7,             // Additional bits for Leading zeroes to align with hex concatenation = 68
    parameter R_FIFO_WIDTH = DATA_WIDTH +    // 32
                             RESP_WIDTH +    // 2
                             ID_WIDTH +      // 4
                             2,              // Additional bits for Leading zeroes to align with hex concatenation = 40
    parameter B_FIFO_WIDTH = RESP_WIDTH +    // 2
                             ID_WIDTH,       // 4 = 6
    parameter START_ADDR = 32'h00000000,
    parameter END_ADDR = 32'h000003FF
)(

    // Global Signals
    input wire ACLK,
    input wire ARESETn,

    // Write Address Channel
    input wire [ID_WIDTH-1:0] MEM_AWID,
    input wire [ADDR_WIDTH-1:0] MEM_AWADDR,
    input wire [LEN_WIDTH-1:0] MEM_AWLEN,
    input wire [SIZE_WIDTH-1:0] MEM_AWSIZE,
    input wire [BURST_WIDTH-1:0] MEM_AWBURST,
    input wire [LOCK_WIDTH-1:0] MEM_AWLOCK,
    input wire [CACHE_WIDTH-1:0] MEM_AWCACHE,
    input wire [PROT_WIDTH-1:0] MEM_AWPROT,
    input wire [QOS_WIDTH-1:0] MEM_AWQOS,
    input wire MEM_AWVALID,
    output reg MEM_AWREADY,

    // Write Data Channel
    input wire [DATA_WIDTH-1:0] MEM_WDATA,
    input wire [(DATA_WIDTH/8)-1:0] MEM_WSTRB,
    input wire MEM_WLAST,
    input wire MEM_WVALID,
    output reg MEM_WREADY,

    // Write Response Channel
    output wire [ID_WIDTH-1:0] MEM_BID,
    output wire [RESP_WIDTH-1:0] MEM_BRESP,
    output reg MEM_BVALID,
    input wire MEM_BREADY,

    // Read Address Channel
    input wire [ID_WIDTH-1:0] MEM_ARID,
    input wire [ADDR_WIDTH-1:0] MEM_ARADDR,
    input wire [LEN_WIDTH-1:0] MEM_ARLEN,
    input wire [SIZE_WIDTH-1:0] MEM_ARSIZE,
    input wire [BURST_WIDTH-1:0] MEM_ARBURST,
    input wire [LOCK_WIDTH-1:0] MEM_ARLOCK,
    input wire [CACHE_WIDTH-1:0] MEM_ARCACHE,
    input wire [PROT_WIDTH-1:0] MEM_ARPROT,
    input wire [QOS_WIDTH-1:0] MEM_ARQOS,
    input wire MEM_ARVALID,
    output reg MEM_ARREADY,

    // Read Data Channel
    output wire [ID_WIDTH-1:0] MEM_RID,
    output wire [DATA_WIDTH-1:0] MEM_RDATA,
    output wire [RESP_WIDTH-1:0] MEM_RRESP,
    output wire MEM_RLAST,
    output reg MEM_RVALID,
    input wire MEM_RREADY
);

// Register bank
reg [DATA_WIDTH-1:0] reg_bank [0:DEPTH-1];
  
// FIFO signals
wire	aw_push;
wire	aw_pop;
wire	w_push;
wire	w_pop;
wire	ar_push;
wire	ar_pop;
wire	r_push;
wire	r_pop;
wire	b_push;
wire	b_pop;
wire	aw_fifo_full;
wire	aw_fifo_empty;
wire	w_fifo_full;
wire	w_fifo_empty;
wire	ar_fifo_full;
wire	ar_fifo_empty;
wire	r_fifo_full;
wire	r_fifo_empty;
wire	b_fifo_full;
wire	b_fifo_empty;

wire [AW_FIFO_WIDTH-1:0] aw_fifo_wdata;
wire [AW_FIFO_WIDTH-1:0] aw_fifo_rdata;
wire [AR_FIFO_WIDTH-1:0] ar_fifo_wdata;
wire [AR_FIFO_WIDTH-1:0] ar_fifo_rdata;
wire [W_FIFO_WIDTH-1:0]  w_fifo_wdata;
wire [W_FIFO_WIDTH-1:0]  w_fifo_rdata;
wire [R_FIFO_WIDTH-1:0]  r_fifo_rdata;
wire [B_FIFO_WIDTH-1:0]  b_fifo_wdata;
wire [B_FIFO_WIDTH-1:0]  b_fifo_rdata;

reg [R_FIFO_WIDTH-1:0] r_fifo_wdata;

// Intermediate register for BRESP
reg [RESP_WIDTH-1:0] bresp_int;  

// AW FIFO
axi_fifo #(
    .WIDTH(AW_FIFO_WIDTH),
    .DEPTH(16),
    .PTR_WIDTH(4)
) aw_fifo (
    .clk(ACLK),
    .resetn(ARESETn),
    .push(aw_push),
    .fifo_wdata(aw_fifo_wdata),
    .pop(aw_pop),
    .fifo_rdata(aw_fifo_rdata),
    .fifo_full(aw_fifo_full),
    .fifo_empty(aw_fifo_empty)
);

// Handshaking signals for AW channel
assign aw_push = MEM_AWVALID && MEM_AWREADY && !aw_fifo_full;
assign MEM_AWREADY = !aw_fifo_full;
assign aw_pop = !aw_fifo_empty && !w_fifo_empty && !b_fifo_full;
assign aw_fifo_wdata = {MEM_AWID, MEM_AWADDR, MEM_AWLEN, {{1'b0}, MEM_AWSIZE}, {{2'b00}, MEM_AWBURST}, MEM_AWCACHE, {{1'b0}, MEM_AWPROT}, {{3'b000}, MEM_AWLOCK}, MEM_AWQOS};  

// W FIFO
axi_fifo #(
    .WIDTH(W_FIFO_WIDTH),
    .DEPTH(16),
    .PTR_WIDTH(4)
) w_fifo (
    .clk(ACLK),
    .resetn(ARESETn),
    .push(w_push),
    .fifo_wdata(w_fifo_wdata),
    .pop(w_pop),
    .fifo_rdata(w_fifo_rdata),
    .fifo_full(w_fifo_full),
    .fifo_empty(w_fifo_empty)
);

// Handshaking signals for W channel
assign w_push = MEM_WVALID && MEM_WREADY && !w_fifo_full;
assign MEM_WREADY = !w_fifo_full;
assign w_pop = !w_fifo_empty && aw_pop;
assign w_fifo_wdata = {MEM_WLAST, MEM_WSTRB, MEM_WDATA};
  
// B FIFO
axi_fifo #(
    .WIDTH(B_FIFO_WIDTH),
    .DEPTH(16),
    .PTR_WIDTH(4)
) b_fifo (
    .clk(ACLK),
    .resetn(ARESETn),
    .push(b_push),
    .fifo_wdata(b_fifo_wdata),
    .pop(b_pop),
    .fifo_rdata(b_fifo_rdata),
    .fifo_full(b_fifo_full),
    .fifo_empty(b_fifo_empty)
);

// Handshaking signals for B channel
assign b_push = w_pop && !b_fifo_full && aw_pop;
assign b_pop = MEM_BREADY && MEM_BVALID;
assign MEM_BVALID = !b_fifo_empty;
assign MEM_BID = b_fifo_rdata[B_FIFO_WIDTH-1:B_FIFO_WIDTH-ID_WIDTH];
assign MEM_BRESP = b_fifo_rdata[B_FIFO_WIDTH-ID_WIDTH-1:0];
assign b_fifo_wdata = {aw_fifo_rdata[AW_FIFO_WIDTH-1:AW_FIFO_WIDTH-ID_WIDTH], bresp_int};
  
// AR FIFO
axi_fifo #(
    .WIDTH(AR_FIFO_WIDTH),
    .DEPTH(16),
    .PTR_WIDTH(4)
) ar_fifo (
    .clk(ACLK),
    .resetn(ARESETn),
    .push(ar_push),
    .fifo_wdata(ar_fifo_wdata),
    .pop(ar_pop),
    .fifo_rdata(ar_fifo_rdata),
    .fifo_full(ar_fifo_full),
    .fifo_empty(ar_fifo_empty)
);

// Handshaking signals for AR channel
assign ar_push = MEM_ARVALID && MEM_ARREADY && !ar_fifo_full;  
assign MEM_ARREADY = !ar_fifo_full;
assign ar_pop = !ar_fifo_empty && !r_fifo_full;
assign ar_fifo_wdata = {MEM_ARID, MEM_ARADDR, MEM_ARLEN, {{1'b0}, MEM_ARSIZE}, {{2'b00}, MEM_ARBURST}, MEM_ARCACHE, {{1'b0}, MEM_ARPROT}, {{3'b000}, MEM_ARLOCK}, MEM_ARQOS};
  
// R FIFO
axi_fifo #(
    .WIDTH(R_FIFO_WIDTH),
    .DEPTH(16),
    .PTR_WIDTH(4)
) r_fifo (
    .clk(ACLK),
    .resetn(ARESETn),
    .push(r_push),
    .fifo_wdata(r_fifo_wdata),
    .pop(r_pop),
    .fifo_rdata(r_fifo_rdata),
    .fifo_full(r_fifo_full),
    .fifo_empty(r_fifo_empty)
);

// Handshaking signals for R channel
assign r_push = ar_pop && !r_fifo_full;
assign r_pop = MEM_RREADY && MEM_RVALID;
assign MEM_RVALID = !r_fifo_empty;
assign MEM_RID = r_fifo_rdata[R_FIFO_WIDTH-1:2+RESP_WIDTH+DATA_WIDTH];
assign MEM_RDATA = r_fifo_rdata[DATA_WIDTH-1:0];
assign MEM_RRESP = r_fifo_rdata[2+RESP_WIDTH+DATA_WIDTH-1:DATA_WIDTH];
assign MEM_RLAST = 1'b1;

// Address decoding and data writing
always @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
        integer i;
        for (i = 0; i < DEPTH; i = i + 1) begin
            reg_bank[i] <= {DATA_WIDTH{1'b0}};
        end
        bresp_int <= 2'b00;
    end else begin
        if (aw_pop && w_pop) begin
            // Check if the address is within the valid range
            if (aw_fifo_rdata[AW_FIFO_WIDTH-5:32] >= START_ADDR && aw_fifo_rdata[AW_FIFO_WIDTH-5:32] <= END_ADDR) begin
                // Calculate the index in the register bank
                reg_bank[aw_fifo_rdata[AW_FIFO_WIDTH-5:32]] <= w_fifo_rdata[DATA_WIDTH-1:0];
            end
        end
    end
end

always @(*) begin
    if (aw_pop && w_pop) begin
        // Check if the address is within the valid range
        if (aw_fifo_rdata[AW_FIFO_WIDTH-5:32] >= START_ADDR && aw_fifo_rdata[AW_FIFO_WIDTH-5:32] <= END_ADDR) begin
            // Calculate the index in the register bank
            bresp_int <= 2'b00; // OKAY response
        end else begin
            bresp_int <= 2'b11; // DECERR response
        end
    end
end

// Logic to read from register bank and push into R FIFO
always @(*) begin
    if (!ARESETn) begin
        r_fifo_wdata <= {R_FIFO_WIDTH{1'b0}};
    end else begin
        if (ar_pop) begin
            // Check if the address is within the valid range
            if (ar_fifo_rdata[AR_FIFO_WIDTH-5:32] >= START_ADDR && ar_fifo_rdata[AR_FIFO_WIDTH-5:32] <= END_ADDR) begin
                // Calculate the index in the register bank and read data
                r_fifo_wdata <= {ar_fifo_rdata[AR_FIFO_WIDTH-1:AR_FIFO_WIDTH-ID_WIDTH], {{2'b00}, 2'b00}, reg_bank[ar_fifo_rdata[AR_FIFO_WIDTH-5:32]]};
            end else begin
                r_fifo_wdata <= {ar_fifo_rdata[AR_FIFO_WIDTH-1:AR_FIFO_WIDTH-ID_WIDTH], {{2'b00}, 2'b11}, reg_bank[ar_fifo_rdata[AR_FIFO_WIDTH-5:32]]}; // DECERR response
            end
        end
    end
end

endmodule
