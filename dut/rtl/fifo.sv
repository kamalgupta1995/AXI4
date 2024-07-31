`timescale 1ns/1ps

module axi_fifo #(
    parameter WIDTH     = 32,
    parameter DEPTH     = 16,
    parameter PTR_WIDTH = 4   // Dependent on DEPTH value
)(
    input  logic             clk,
    input  logic             resetn, 
    input  logic             push,
    input  logic [WIDTH-1:0] fifo_wdata,
    input  logic             pop,
    output wire  [WIDTH-1:0] fifo_rdata,
    output wire              fifo_full,
    output wire              fifo_empty
);

logic [WIDTH-1:0]   mem [DEPTH-1:0];
logic [PTR_WIDTH:0] wptr;
logic [PTR_WIDTH:0] rptr;
wire [PTR_WIDTH:0] fill_level;

// On push, if the FIFO is not already full, write data into FIFO location pointed by the write pointer
always @(posedge clk) begin
    if (push && (!fifo_full)) begin
        mem[wptr[PTR_WIDTH-1:0]] <= fifo_wdata;
    end
end

// Write pointer logic
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        wptr <= {PTR_WIDTH+1{1'b0}};
    end else if (push && (!fifo_full)) begin
        wptr <= wptr + {{(PTR_WIDTH){1'b0}}, 1'b1};
    end
end

// Read pointer logic
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        rptr <= {PTR_WIDTH+1{1'b0}};
    end else if (pop && (!fifo_empty)) begin
        rptr <= rptr + {{(PTR_WIDTH){1'b0}}, 1'b1};
    end
end

// Wrap logic
assign wrap = wptr[PTR_WIDTH] ^ rptr[PTR_WIDTH];

// Fill-level calculation
assign fill_level = {wrap, wptr[PTR_WIDTH-1:0]} - {1'b0, rptr[PTR_WIDTH-1:0]};

// FIFO status signals
assign fifo_full = (fill_level == DEPTH);
assign fifo_empty = (fill_level == {PTR_WIDTH+1{1'b0}});

// FIFO Read data
assign fifo_rdata = mem[rptr[PTR_WIDTH-1:0]];

endmodule

