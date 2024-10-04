// Designer: Vinay
// Version : 1.0


`timescale 1ns/1ps
`include "axi_config.sv"
module axi_slave 
   (
    // Global Signals
    input wire ACLK,
    input wire ARESETn,

    // Write Address Channel
    input wire [`ID_WIDTH-1:0] MEM_AWID,
    input wire [`ADDR_WIDTH-1:0] MEM_AWADDR,
    input wire [`LEN_WIDTH-1:0] MEM_AWLEN,
    input wire [`SIZE_WIDTH-1:0] MEM_AWSIZE,
    input wire [`BURST_WIDTH-1:0] MEM_AWBURST,
    input wire [`LOCK_WIDTH-1:0] MEM_AWLOCK,
    input wire [`CACHE_WIDTH-1:0] MEM_AWCACHE,
    input wire [`PROT_WIDTH-1:0] MEM_AWPROT,
    input wire [`QOS_WIDTH-1:0] MEM_AWQOS,
    input wire MEM_AWVALID,
    output reg MEM_AWREADY,

    // Write Data Channel
    input wire [`DATA_WIDTH-1:0] MEM_WDATA,
    input wire [(`DATA_WIDTH/8)-1:0] MEM_WSTRB,
    input wire MEM_WLAST,
    input wire MEM_WVALID,
    output reg MEM_WREADY,

    // Write Response Channel
    output wire [`ID_WIDTH-1:0] MEM_BID,
    output wire [`RESP_WIDTH-1:0] MEM_BRESP,
    output reg MEM_BVALID,
    input wire MEM_BREADY,

    // Read Address Channel
    input wire [`ID_WIDTH-1:0] MEM_ARID,
    input wire [`ADDR_WIDTH-1:0] MEM_ARADDR,
    input wire [`LEN_WIDTH-1:0] MEM_ARLEN,
    input wire [`SIZE_WIDTH-1:0] MEM_ARSIZE,
    input wire [`BURST_WIDTH-1:0] MEM_ARBURST,
    input wire [`LOCK_WIDTH-1:0] MEM_ARLOCK,
    input wire [`CACHE_WIDTH-1:0] MEM_ARCACHE,
    input wire [`PROT_WIDTH-1:0] MEM_ARPROT,
    input wire [`QOS_WIDTH-1:0] MEM_ARQOS,
    input wire MEM_ARVALID,
    output reg MEM_ARREADY,

    // Read Data Channel
    output wire [`ID_WIDTH-1:0] MEM_RID,
    output reg [`DATA_WIDTH-1:0] MEM_RDATA,
    output reg [`RESP_WIDTH-1:0] MEM_RRESP,
    output reg MEM_RLAST,
    output reg MEM_RVALID,
    input wire MEM_RREADY
);

    reg [`DATA_WIDTH-1:0] mem [0:`DEPTH-1]; //final storage memory

    reg [`AW_FIFO_WIDTH-1:0] aw_addr_channel; //issue of single address is supported for now
    reg aw_addr_written;
    reg [`DATA_WIDTH-1:0] w_data_channel [0:255];
    reg data_written ;
    wire [`LEN_WIDTH-1:0] awlen;
    wire [`SIZE_WIDTH-1:0] awsize;
    wire [`BURST_WIDTH-1:0] awburst;
    wire [`ADDR_WIDTH-1:0] awaddr;
    wire [`ID_WIDTH-1:0] awid;
    reg mem_written;
    reg [`RESP_WIDTH-1:0] bresp_int;

    //MEM_AWREADY logic
    always@(posedge ACLK or negedge ARESETn)
    begin
      if(!ARESETn)
        begin
          MEM_AWREADY <= 1'b0;
        end
      else
        begin
          if(MEM_AWVALID && !aw_addr_written )
            begin
              MEM_AWREADY <= 1'b1;
            end
          else
            begin
              MEM_AWREADY <= 1'b0;
            end
        end
    end
    
    //aw_addr_channel
    always@(posedge ACLK or negedge ARESETn)
      begin
        if(!ARESETn)
          begin
            aw_addr_channel <= {`AW_FIFO_WIDTH{1'b0}};
            aw_addr_written <= 1'b0;
          end
        else
          begin
            if(mem_written)
              begin
                aw_addr_channel <= {`AW_FIFO_WIDTH{1'b0}};
                aw_addr_written <= 1'b0;
              end
            else if(MEM_AWVALID && MEM_AWREADY)
              begin
                aw_addr_channel <= {MEM_AWID, MEM_AWADDR, MEM_AWLEN, {{1'b0}, MEM_AWSIZE}, {{2'b00}, MEM_AWBURST}, MEM_AWCACHE, {{1'b0}, MEM_AWPROT}, {{3'b000}, MEM_AWLOCK}, MEM_AWQOS}; 
                aw_addr_written <= 1'b1; 
              end
          end
      end
    
    assign awsize = aw_addr_channel[`AW_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH-`LEN_WIDTH-2 : `AW_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH-`LEN_WIDTH-1-`SIZE_WIDTH] ;
    assign awburst = aw_addr_channel[`AW_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH-`LEN_WIDTH-1-`SIZE_WIDTH-3 : `AW_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH-`LEN_WIDTH-1-`SIZE_WIDTH-2-`BURST_WIDTH] ;
    assign awlen = aw_addr_channel[`AW_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH-1 : `AW_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH-`LEN_WIDTH] ;
    assign awaddr = aw_addr_channel[`AW_FIFO_WIDTH-`ID_WIDTH-1 : `AW_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH];
    assign awid = aw_addr_channel[`AW_FIFO_WIDTH-1: `AW_FIFO_WIDTH-`ID_WIDTH];
   
    reg[7:0] awsize_value; 
    always@(posedge ACLK or negedge ARESETn)
      begin
        if(!ARESETn)
          begin
            awsize_value <= 8'b01;
          end
        else
          begin
            case(awsize)
              3'b000: awsize_value <= 8'd1;
              3'b001: awsize_value <= 8'd2;
              3'b010: awsize_value <= 8'd4;
              3'b011: awsize_value <= 8'd8;
              3'b100: awsize_value <= 8'd16;
              3'b101: awsize_value <= 8'd32;
              3'b110: awsize_value <= 8'd64;
              3'b111: awsize_value <= 8'd128;
            endcase
          end
      end


    //MEM_WREADY logic
    always@(posedge ACLK or negedge ARESETn)
      begin
        if(!ARESETn)
          begin
            MEM_WREADY <= 1'b0;
          end
        else
          begin
            if(MEM_WVALID && aw_addr_written)
              begin
                MEM_WREADY <= 1'b1;
              end
            else
              begin
                MEM_WREADY <= 1'b0;
              end
          end
      end

    //w_data_channel logic
    integer i;
    reg [7:0] w_data_write;

    always@(posedge ACLK or negedge ARESETn)
      begin
        if(!ARESETn)
          begin
            data_written <= 1'b0;
            w_data_write <= 8'b0;
            for(i=0; i<255; i=i+1)
              begin
                w_data_channel[i] <= {`DATA_WIDTH{1'b0}};
              end
          end
        else
          begin
            if(mem_written)
              begin
                w_data_write <= 8'b0;
                data_written <= 1'b0;
                for(i=0; i<255; i=i+1)
                  begin
                    w_data_channel[i] <= {`DATA_WIDTH{1'b0}};
                  end
              end
            else if(MEM_WVALID && MEM_WREADY && !data_written)
              begin
                if(w_data_write <= awlen)
                  begin
                    w_data_channel[w_data_write] <= MEM_WDATA;
                    w_data_write <= w_data_write+1;
                    if(MEM_WLAST)
                      begin
                        data_written <= 1'b1;
                      end
                    else
                      begin
                        data_written <= 1'b0;
                      end
                  end
              end
          end
      end

    integer j;
    reg [`LEN_WIDTH-1:0] awlen_written;
    always@(posedge ACLK or negedge ARESETn)
      begin
        if(!ARESETn)
          begin
            mem_written <= 1'b0;
            awlen_written <= {`LEN_WIDTH{1'b0}};
            for(j=0; j<`DEPTH; j=j+1)
              begin
                mem[j] <= {`DATA_WIDTH{1'b0}};
              end
          end
        else
          begin
            if(data_written)
              begin
                if(awaddr >= 32'h00000000 && awaddr <= 32'h000003ff)
                  begin
                    bresp_int <= 2'b00;
                    if(awlen_written <awlen)
                      begin
                        if(awburst == 2'b01)
                          begin
                            mem[awaddr+awsize_value*awlen_written] <= w_data_channel[awlen_written];
                            awlen_written <= awlen_written + 1'b1;
                            mem_written <= 1'b0;
                          end
                        else if(awburst == 2'b00)
                          begin
                            mem[awaddr] <= w_data_channel[awlen_written];
                            awlen_written <= awlen_written + 1'b1;
                            mem_written <= 1'b0;
                          end
                      end
                    else if(awlen_written == awlen)
                      begin
                        if(awburst == 2'b01) //INCR
                          begin
                            mem[awaddr+awsize_value*awlen_written] <= w_data_channel[awlen_written];
                            awlen_written <= {`LEN_WIDTH{1'b0}};
                            mem_written <= 1'b1;
                          end
                        else if(awburst == 2'b00) //FIXED
                          begin
                            mem[awaddr] <= w_data_channel[awlen_written];
                            awlen_written <= {`LEN_WIDTH{1'b0}};
                            mem_written <= 1'b1;
                          end
                      end
                  end
                else 
                  begin
                    bresp_int <= 2'b11;
                    awlen_written <= {`LEN_WIDTH{1'b0}};
                    mem_written <= 1'b0;
                  end 
              end 
            else
              begin
                bresp_int <= 2'b11;
                awlen_written <= {`LEN_WIDTH{1'b0}};
                mem_written <= 1'b0;
              end
          end
      end    
                      
    //bready logic
    always@(posedge ACLK or negedge ARESETn)
      begin
        if(!ARESETn)
          begin
            MEM_BVALID <= 1'b0;
          end
        else
          begin
            if(data_written)
              begin
                MEM_BVALID <= 1'b1;
              end
          end
      end

    assign MEM_BRESP = (MEM_BVALID && MEM_BREADY) ? bresp_int : {`RESP_WIDTH{1'b0}};
    assign MEM_BID   = (MEM_BVALID && MEM_BREADY) ? awid : {`ID_WIDTH{1'b0}};

    reg [`AR_FIFO_WIDTH-1:0] ar_addr_channel;    //issue of single address is supported for now
    wire [`LEN_WIDTH-1:0] arlen;
    wire [`SIZE_WIDTH-1:0] arsize;
    wire [`ADDR_WIDTH-1:0] araddr;
    wire [`ID_WIDTH-1:0] arid;
    wire [`BURST_WIDTH-1:0] arburst;
    reg read_addr_written;
    reg [`LEN_WIDTH-1:0] data_read_out;

    //MEM_ARREADY logic
    always@(posedge ACLK or negedge ARESETn)
    begin
      if(!ARESETn)
        begin
          MEM_ARREADY <= 1'b0;
        end
      else
        begin
          if(MEM_ARVALID && ar_addr_channel=={`AR_FIFO_WIDTH{1'b0}} )
            begin
              MEM_ARREADY <= 1'b1;
            end
          else
            begin
              MEM_ARREADY <= 1'b0;
            end
        end
    end
  
    //aw_addr_channel
    always@(posedge ACLK or negedge ARESETn)
      begin
        if(!ARESETn)
          begin
            ar_addr_channel <= {`AR_FIFO_WIDTH{1'b0}};
            read_addr_written <= 1'b0;
          end
        else
          begin
            if(MEM_RLAST)
              begin
                ar_addr_channel <= {`AR_FIFO_WIDTH{1'b0}};
                read_addr_written <= 1'b0;
              end
            else if(MEM_ARVALID && MEM_ARREADY)
              begin
                ar_addr_channel <= {MEM_ARID, MEM_ARADDR, MEM_ARLEN, {{1'b0}, MEM_ARSIZE}, {{2'b00}, MEM_ARBURST}, MEM_ARCACHE, {{1'b0}, MEM_ARPROT}, {{3'b000}, MEM_ARLOCK}, MEM_ARQOS};  
                read_addr_written <= 1'b1;   
              end
          end
      end

    assign arlen = ar_addr_channel[`AR_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH-1 : `AR_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH-`LEN_WIDTH] ;
    assign araddr = ar_addr_channel[`AR_FIFO_WIDTH-`ID_WIDTH-1 : `AR_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH];
    assign arid = ar_addr_channel[`AR_FIFO_WIDTH-1: `AR_FIFO_WIDTH-`ID_WIDTH];
    assign arsize = ar_addr_channel[`AR_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH-`LEN_WIDTH-2 : `AR_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH-`LEN_WIDTH-1-`SIZE_WIDTH] ;
    assign arburst = ar_addr_channel[`AR_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH-`LEN_WIDTH-1-`SIZE_WIDTH-3 : `AR_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH-`LEN_WIDTH-1-`SIZE_WIDTH-2-`BURST_WIDTH] ;

    always@(posedge ACLK or negedge ARESETn)
      begin
        if(!ARESETn)
          begin
            MEM_RVALID <= 1'b0;
          end
        else
          begin
             if(MEM_RLAST)
               begin
                 MEM_RVALID <= 1'b0;
               end
             else if(read_addr_written)
               begin
                 MEM_RVALID <= 1'b1;
               end
          end 
      end        
  
  reg [7:0] arsize_value;
  always@(posedge ACLK or negedge ARESETn)
      begin
        if(!ARESETn)
          begin
            arsize_value <= 8'b01;
          end
        else
          begin
            case(arsize)
              3'b000: arsize_value <= 8'd1;
              3'b001: arsize_value <= 8'd2;
              3'b010: arsize_value <= 8'd4;
              3'b011: arsize_value <= 8'd8;
              3'b100: arsize_value <= 8'd16;
              3'b101: arsize_value <= 8'd32;
              3'b110: arsize_value <= 8'd64;
              3'b111: arsize_value <= 8'd128;
            endcase
          end
      end



    always@(posedge ACLK or negedge ARESETn)
       begin
         if(!ARESETn)
           begin
             data_read_out <= {`LEN_WIDTH{1'b0}};
             MEM_RDATA <= {`DATA_WIDTH{1'b0}};
             MEM_RRESP <= {`RESP_WIDTH{1'b0}};
             MEM_RLAST <= 1'b0;
           end
         else
           begin
             if(MEM_RVALID && MEM_RREADY && !MEM_RLAST)
               begin
                 if(araddr >= 32'h00000000 && araddr <= 32'h000003ff)
                   begin
                     MEM_RRESP <= 2'b00;
                     if(data_read_out < arlen)
                       begin
                         if(arburst == 2'b01)
                           begin
                             MEM_RDATA <= mem[araddr+data_read_out*arsize_value];
                             MEM_RLAST <= 1'b0;
                             data_read_out <= data_read_out+1'b1;
                           end
                         else if(arburst == 2'b00)
                           begin
                             MEM_RDATA <= mem[araddr];
                             MEM_RLAST <= 1'b0;
                             data_read_out <= data_read_out+1'b1;
                           end
                       end
                     else if(data_read_out == arlen)
                       begin
                         if(arburst == 2'b01)
                           begin
                             MEM_RDATA <= mem[araddr+data_read_out*arsize_value];
                             MEM_RLAST <= 1'b1;
                             data_read_out <= {`LEN_WIDTH{1'b0}};
                           end
                         else if(arburst == 2'b00)
                           begin
                             MEM_RDATA <= mem[araddr];
                             MEM_RLAST <= 1'b1;
                             data_read_out <= {`LEN_WIDTH{1'b0}};
                           end
                       end
                   end
                 else
                   begin
                     MEM_RRESP <= 2'b11;
                     MEM_RDATA <= {`DATA_WIDTH{1'b0}};
                     MEM_RLAST <= 1'b0;
                     data_read_out <= {`LEN_WIDTH{1'b0}};
                   end
               end
             else
               begin
                 MEM_RRESP <= 2'b00;
                 MEM_RDATA <= {`DATA_WIDTH{1'b0}};
                 MEM_RLAST <= 1'b0;
                 data_read_out <= {`LEN_WIDTH{1'b0}};
               end
           end
       end

       assign MEM_RID   = (MEM_RVALID && MEM_RREADY) ? arid : {`ID_WIDTH{1'b0}};
    
 
endmodule
