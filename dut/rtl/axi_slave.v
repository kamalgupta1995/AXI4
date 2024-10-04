// Designer: Vinay
// Version : 1.0


`timescale 1ns/1ps
`include "axi_config.sv"
module axi4_dut 
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

    reg [`REG_BANK_WIDTH-1:0] mem [0:`DEPTH-1]; //final storage memory

    reg [`AW_FIFO_WIDTH-1:0] aw_addr_channel; //issue of single address is supported for now
    reg aw_addr_written;
    reg [`DATA_WIDTH-1:0] w_data_channel [0:15];
    wire [`LEN_WIDTH-1:0] awlen;
    wire [`ADDR_WIDTH-1:0] awaddr;
    wire [`ID_WIDTH-1:0] awid;
    reg data_written ;
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
    
    assign awlen = aw_addr_channel[`AW_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH-1 : `AW_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH-`LEN_WIDTH] ;
    assign awaddr = aw_addr_channel[`AW_FIFO_WIDTH-`ID_WIDTH-1 : `AW_FIFO_WIDTH-`ID_WIDTH-`ADDR_WIDTH];
    assign awid = aw_addr_channel[`AW_FIFO_WIDTH-1: `AW_FIFO_WIDTH-`ID_WIDTH];

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
    reg [3:0] w_data_write;

    always@(posedge ACLK or negedge ARESETn)
      begin
        if(!ARESETn)
          begin
            data_written <= 1'b0;
            w_data_write <= 4'b0;
            for(i=0; i<15; i=i+1)
              begin
                w_data_channel[i] <= {`DATA_WIDTH{1'b0}};
              end
          end
        else
          begin
            if(mem_written)
              begin
                w_data_write <= 4'b0;
                data_written <= 1'b0;
                for(i=0; i<15; i=i+1)
                  begin
                    w_data_channel[i] <= {`DATA_WIDTH{1'b0}};
                  end
              end
            else if(MEM_WVALID && MEM_WREADY && !data_written)
              begin
                if(w_data_write <= awlen && awlen<=8'h10) //length of maximum 16 is only supported
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

    integer k;
    reg [`LEN_WIDTH-1:0] awlen_written;
    //decoding the address range and write into memory
    always@(posedge ACLK or negedge ARESETn)
      begin
        if(!ARESETn)
          begin
            mem_written <= 1'b0;
            bresp_int <= 2'b00;
            awlen_written <= {`LEN_WIDTH{1'b0}};
            for(k=0; k<`DEPTH; k=k+1)
              begin
                mem[k] <= {`REG_BANK_WIDTH{1'b0}};
              end
          end
        else
          begin
            if(data_written)
              begin
                if(awaddr >= 32'h00000000 && awaddr <= 32'h000003ff && awlen < 8'h10)
                  begin
                    bresp_int <= 2'b00;
                      begin
                        if(awlen_written<=awlen )
                          begin
                            case(awlen_written)
                            0:  begin
                                  mem[awaddr][(`DATA_WIDTH-1)+`DATA_WIDTH*0 :`DATA_WIDTH*0]     <= w_data_channel[0];
                                  if(awlen == 8'h00)
                                    begin
                                      mem_written <= 1'b1;
                                      awlen_written = {`LEN_WIDTH{1'b0}};
                                    end
                                  else
                                    begin
                                     mem_written <= 1'b0;
                                     awlen_written = awlen_written+1'b1;
                                    end
                                end
                            1:  begin 
                                  mem[awaddr][(`DATA_WIDTH-1)+`DATA_WIDTH*1 :`DATA_WIDTH*1]     <= w_data_channel[1];
                                  if(awlen == 8'h01)
                                    begin
                                      mem_written <= 1'b1;
                                      awlen_written = {`LEN_WIDTH{1'b0}};
                                    end
                                  else
                                    begin
                                      mem_written <= 1'b0;
                                      awlen_written = awlen_written+1'b1;
                                    end
                                end
                            2:  begin 
                                  mem[awaddr][(`DATA_WIDTH-1)+`DATA_WIDTH*2 :`DATA_WIDTH*2]     <= w_data_channel[2];
                                  if(awlen == 8'h02)
                                    begin
                                      mem_written <= 1'b1;
                                      awlen_written = {`LEN_WIDTH{1'b0}};
                                    end
                                  else
                                    begin
                                      mem_written <= 1'b0;
                                      awlen_written = awlen_written+1'b1;
                                    end
                                end
                            3:  begin 
                                  mem[awaddr][(`DATA_WIDTH-1)+`DATA_WIDTH*3 :`DATA_WIDTH*3]     <= w_data_channel[3];
                                  if(awlen == 8'h03)
                                    begin
                                      mem_written <= 1'b1;
                                      awlen_written = {`LEN_WIDTH{1'b0}};
                                    end
                                  else
                                    begin
                                      mem_written <= 1'b0;
                                      awlen_written = awlen_written+1'b1;
                                    end
                                end
                            4:  begin 
                                  mem[awaddr][(`DATA_WIDTH-1)+`DATA_WIDTH*4 :`DATA_WIDTH*4]     <= w_data_channel[4];
                                  if(awlen == 8'h04)
                                    begin
                                      mem_written <= 1'b1;
                                      awlen_written = {`LEN_WIDTH{1'b0}};
                                    end
                                  else
                                    begin
                                      mem_written <= 1'b0;
                                      awlen_written = awlen_written+1'b1;
                                    end
                                end
                            5:  begin 
                                  mem[awaddr][(`DATA_WIDTH-1)+`DATA_WIDTH*5 :`DATA_WIDTH*5]     <= w_data_channel[5];
                                  if(awlen == 8'h05)
                                    begin
                                      mem_written <= 1'b1;
                                      awlen_written = {`LEN_WIDTH{1'b0}};
                                    end
                                  else
                                    begin
                                      mem_written <= 1'b0;
                                      awlen_written = awlen_written+1'b1;
                                    end
                                end
                            6:  begin 
                                  mem[awaddr][(`DATA_WIDTH-1)+`DATA_WIDTH*6 :`DATA_WIDTH*6]     <= w_data_channel[6];
                                  if(awlen == 8'h06)
                                    begin
                                      mem_written <= 1'b1;
                                      awlen_written = {`LEN_WIDTH{1'b0}};
                                    end
                                  else
                                    begin
                                      mem_written <= 1'b0;
                                      awlen_written = awlen_written+1'b1;
                                    end
                                end
                            7:  begin 
                                  mem[awaddr][(`DATA_WIDTH-1)+`DATA_WIDTH*7 :`DATA_WIDTH*7]     <= w_data_channel[7];
                                  if(awlen == 8'h07)
                                    begin
                                      mem_written <= 1'b1;
                                      awlen_written = {`LEN_WIDTH{1'b0}};
                                    end
                                  else
                                    begin
                                      mem_written <= 1'b0;
                                      awlen_written = awlen_written+1'b1;
                                    end
                                end
                            8:  begin 
                                  mem[awaddr][(`DATA_WIDTH-1)+`DATA_WIDTH*8 :`DATA_WIDTH*8]     <= w_data_channel[8];
                                  if(awlen == 8'h08)
                                    begin
                                      mem_written <= 1'b1;
                                      awlen_written = {`LEN_WIDTH{1'b0}};
                                    end
                                  else
                                    begin
                                      mem_written <= 1'b0;
                                      awlen_written = awlen_written+1'b1;
                                    end
                                end
                            9:  begin 
                                  mem[awaddr][(`DATA_WIDTH-1)+`DATA_WIDTH*9 :`DATA_WIDTH*9]     <= w_data_channel[9];
                                  if(awlen == 8'h09)
                                    begin
                                      mem_written <= 1'b1;
                                      awlen_written = {`LEN_WIDTH{1'b0}};
                                    end
                                  else
                                    begin
                                      mem_written <= 1'b0;
                                      awlen_written = awlen_written+1'b1;
                                    end
                                end
                            10:  begin 
                                  mem[awaddr][(`DATA_WIDTH-1)+`DATA_WIDTH*10 :`DATA_WIDTH*10]     <= w_data_channel[10];
                                  if(awlen == 8'h0a)
                                    begin
                                      mem_written <= 1'b1;
                                      awlen_written = {`LEN_WIDTH{1'b0}};
                                    end
                                  else
                                    begin
                                      mem_written <= 1'b0;
                                      awlen_written = awlen_written+1'b1;
                                    end
                                end
                            11:  begin 
                                  mem[awaddr][(`DATA_WIDTH-1)+`DATA_WIDTH*11 :`DATA_WIDTH*11]     <= w_data_channel[11];
                                  if(awlen == 8'h0b)
                                    begin
                                      mem_written <= 1'b1;
                                      awlen_written = {`LEN_WIDTH{1'b0}};
                                    end
                                  else
                                    begin
                                      mem_written <= 1'b0;
                                      awlen_written = awlen_written+1'b1;
                                    end
                                end
                            12:  begin 
                                  mem[awaddr][(`DATA_WIDTH-1)+`DATA_WIDTH*12 :`DATA_WIDTH*12]     <= w_data_channel[12];
                                  if(awlen == 8'h0c)
                                    begin
                                      mem_written <= 1'b1;
                                      awlen_written = {`LEN_WIDTH{1'b0}};
                                    end
                                  else
                                    begin
                                      mem_written <= 1'b0;
                                      awlen_written = awlen_written+1'b1;
                                    end
                                end
                            13:  begin 
                                  mem[awaddr][(`DATA_WIDTH-1)+`DATA_WIDTH*13 :`DATA_WIDTH*13]     <= w_data_channel[13];
                                  if(awlen == 8'h0d)
                                    begin
                                      mem_written <= 1'b1;
                                      awlen_written = {`LEN_WIDTH{1'b0}};
                                    end
                                  else
                                    begin
                                      mem_written <= 1'b0;
                                      awlen_written = awlen_written+1'b1;
                                    end
                                end
                            14:  begin 
                                  mem[awaddr][(`DATA_WIDTH-1)+`DATA_WIDTH*14 :`DATA_WIDTH*14]     <= w_data_channel[14];
                                  if(awlen == 8'h0e)
                                    begin
                                      mem_written <= 1'b1;
                                      awlen_written = {`LEN_WIDTH{1'b0}};
                                    end
                                  else
                                    begin
                                      mem_written <= 1'b0;
                                      awlen_written = awlen_written+1'b1;
                                    end
                                end
                            15:  begin 
                                  mem[awaddr][(`DATA_WIDTH-1)+`DATA_WIDTH*15 :`DATA_WIDTH*15]     <= w_data_channel[15];
                                  if(awlen == 8'h0f)
                                    begin
                                      mem_written <= 1'b1;
                                      awlen_written = {`LEN_WIDTH{1'b0}};
                                    end
                                  else
                                    begin
                                      mem_written <= 1'b0;
                                      awlen_written = awlen_written+1'b1;
                                    end
                                end
                            endcase
                          end
                        else
                          begin
                            mem_written <= 1'b0;
                            awlen_written <= {`LEN_WIDTH{1'b0}};
                          end
                      end
                  end
                else
                  begin
                    bresp_int <= 2'b11;
                    mem_written <= 1'b0;
                    awlen_written <= {`LEN_WIDTH{1'b0}};
                  end
              end
            else
              begin
                mem_written <= 1'b0;
                bresp_int <= 2'b00;
                awlen_written <= {`LEN_WIDTH{1'b0}};
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
    wire [`ADDR_WIDTH-1:0] araddr;
    wire [`ID_WIDTH-1:0] arid;
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


    always@(posedge ACLK or negedge ARESETn)
       begin
         if(!ARESETn)
           begin
             data_read_out <= {`LEN_WIDTH{1'b0}};
           end
         else
           begin
             if(MEM_RVALID && MEM_RREADY && !MEM_RLAST)
               begin
                 if((araddr >= 32'h00000000 && araddr <= 32'h000003ff) && arlen < 8'h10)
                   begin
                     MEM_RRESP <= 2'b00;
                     if(data_read_out <= arlen)
                       begin
                         case(data_read_out)
                         0: begin
                              MEM_RDATA <= mem[araddr][(`DATA_WIDTH-1)+`DATA_WIDTH*0:`DATA_WIDTH*0];
                              if(arlen==8'h00)
                                begin
                                  MEM_RLAST <= 1'b1;
                                  data_read_out <= {`LEN_WIDTH{1'b0}};
                                end
                              else
                                begin
                                  MEM_RLAST <= 1'b0;
                                  data_read_out <= data_read_out + 1'b1;
                                end
                            end
                         1: begin
                              MEM_RDATA <= mem[araddr][(`DATA_WIDTH-1)+`DATA_WIDTH*1:`DATA_WIDTH*1];
                              if(arlen==8'h01)
                                begin
                                  MEM_RLAST <= 1'b1;
                                  data_read_out <= {`LEN_WIDTH{1'b0}};
                                end
                              else
                                begin
                                  MEM_RLAST <= 1'b0;
                                  data_read_out <= data_read_out + 1'b1;
                                end
                            end
                         2: begin
                              MEM_RDATA <= mem[araddr][(`DATA_WIDTH-1)+`DATA_WIDTH*2:`DATA_WIDTH*2];
                              if(arlen==8'h02)
                                begin
                                  MEM_RLAST <= 1'b1;
                                  data_read_out <= {`LEN_WIDTH{1'b0}};
                                end
                              else
                                begin
                                  MEM_RLAST <= 1'b0;
                                  data_read_out <= data_read_out + 1'b1;
                                end
                            end
                         3: begin
                              MEM_RDATA <= mem[araddr][(`DATA_WIDTH-1)+`DATA_WIDTH*3:`DATA_WIDTH*3];
                              if(arlen==8'h03)
                                begin
                                  MEM_RLAST <= 1'b1;
                                  data_read_out <= {`LEN_WIDTH{1'b0}};
                                end
                              else
                                begin
                                  MEM_RLAST <= 1'b0;
                                  data_read_out <= data_read_out + 1'b1;
                                end
                            end
                         4: begin
                              MEM_RDATA <= mem[araddr][(`DATA_WIDTH-1)+`DATA_WIDTH*4:`DATA_WIDTH*4];
                              if(arlen==8'h04)
                                begin
                                  MEM_RLAST <= 1'b1;
                                  data_read_out <= {`LEN_WIDTH{1'b0}};
                                end
                              else
                                begin
                                  MEM_RLAST <= 1'b0;
                                  data_read_out <= data_read_out + 1'b1;
                                end
                            end
                         5: begin
                              MEM_RDATA <= mem[araddr][(`DATA_WIDTH-1)+`DATA_WIDTH*5:`DATA_WIDTH*5];
                              if(arlen==8'h05)
                                begin
                                  MEM_RLAST <= 1'b1;
                                  data_read_out <= {`LEN_WIDTH{1'b0}};
                                end
                              else
                                begin
                                  MEM_RLAST <= 1'b0;
                                  data_read_out <= data_read_out + 1'b1;
                                end
                            end
                         6: begin
                              MEM_RDATA <= mem[araddr][(`DATA_WIDTH-1)+`DATA_WIDTH*6:`DATA_WIDTH*6];
                              if(arlen==8'h06)
                                begin
                                  MEM_RLAST <= 1'b1;
                                  data_read_out <= {`LEN_WIDTH{1'b0}};
                                end
                              else
                                begin
                                  MEM_RLAST <= 1'b0;
                                  data_read_out <= data_read_out + 1'b1;
                                end
                            end
                         7: begin
                              MEM_RDATA <= mem[araddr][(`DATA_WIDTH-1)+`DATA_WIDTH*7:`DATA_WIDTH*7];
                              if(arlen==8'h07)
                                begin
                                  MEM_RLAST <= 1'b1;
                                  data_read_out <= {`LEN_WIDTH{1'b0}};
                                end
                              else
                                begin
                                  MEM_RLAST <= 1'b0;
                                  data_read_out <= data_read_out + 1'b1;
                                end
                            end
                         8: begin
                              MEM_RDATA <= mem[araddr][(`DATA_WIDTH-1)+`DATA_WIDTH*8:`DATA_WIDTH*8];
                              if(arlen==8'h08)
                                begin
                                  MEM_RLAST <= 1'b1;
                                  data_read_out <= {`LEN_WIDTH{1'b0}};
                                end
                              else
                                begin
                                  MEM_RLAST <= 1'b0;
                                  data_read_out <= data_read_out + 1'b1;
                                end
                            end
                         9: begin
                              MEM_RDATA <= mem[araddr][(`DATA_WIDTH-1)+`DATA_WIDTH*9:`DATA_WIDTH*9];
                              if(arlen==8'h09)
                                begin
                                  MEM_RLAST <= 1'b1;
                                  data_read_out <= {`LEN_WIDTH{1'b0}};
                                end
                              else
                                begin
                                  MEM_RLAST <= 1'b0;
                                  data_read_out <= data_read_out + 1'b1;
                                end
                            end
                         10: begin
                              MEM_RDATA <= mem[araddr][(`DATA_WIDTH-1)+`DATA_WIDTH*10:`DATA_WIDTH*10];
                              if(arlen==8'h0a)
                                begin
                                  MEM_RLAST <= 1'b1;
                                  data_read_out <= {`LEN_WIDTH{1'b0}};
                                end
                              else
                                begin
                                  MEM_RLAST <= 1'b0;
                                  data_read_out <= data_read_out + 1'b1;
                                end
                            end
                         11: begin
                              MEM_RDATA <= mem[araddr][(`DATA_WIDTH-1)+`DATA_WIDTH*11:`DATA_WIDTH*11];
                              if(arlen==8'h0b)
                                begin
                                  MEM_RLAST <= 1'b1;
                                  data_read_out <= {`LEN_WIDTH{1'b0}};
                                end
                              else
                                begin
                                  MEM_RLAST <= 1'b0;
                                  data_read_out <= data_read_out + 1'b1;
                                end
                            end
                         12: begin
                              MEM_RDATA <= mem[araddr][(`DATA_WIDTH-1)+`DATA_WIDTH*12:`DATA_WIDTH*12];
                              if(arlen==8'h0c)
                                begin
                                  MEM_RLAST <= 1'b1;
                                  data_read_out <= {`LEN_WIDTH{1'b0}};
                                end
                              else
                                begin
                                  MEM_RLAST <= 1'b0;
                                  data_read_out <= data_read_out + 1'b1;
                                end
                            end
                         13: begin
                              MEM_RDATA <= mem[araddr][(`DATA_WIDTH-1)+`DATA_WIDTH*13:`DATA_WIDTH*13];
                              if(arlen==8'h0d)
                                begin
                                  MEM_RLAST <= 1'b1;
                                  data_read_out <= {`LEN_WIDTH{1'b0}};
                                end
                              else
                                begin
                                  MEM_RLAST <= 1'b0;
                                  data_read_out <= data_read_out + 1'b1;
                                end
                            end
                         14: begin
                              MEM_RDATA <= mem[araddr][(`DATA_WIDTH-1)+`DATA_WIDTH*14:`DATA_WIDTH*14];
                              if(arlen==8'h0d)
                                begin
                                  MEM_RLAST <= 1'b1;
                                  data_read_out <= {`LEN_WIDTH{1'b0}};
                                end
                              else
                                begin
                                  MEM_RLAST <= 1'b0;
                                  data_read_out <= data_read_out + 1'b1;
                                end
                            end
                         15: begin
                              MEM_RDATA <= mem[araddr][(`DATA_WIDTH-1)+`DATA_WIDTH*15:`DATA_WIDTH*15];
                              if(arlen==8'h0f)
                                begin
                                  MEM_RLAST <= 1'b1;
                                  data_read_out <= {`LEN_WIDTH{1'b0}};
                                end
                              else
                                begin
                                  MEM_RLAST <= 1'b0;
                                  data_read_out <= data_read_out + 1'b1;
                                end
                            end
                         endcase
                       end
                     else
                       begin
                         MEM_RDATA <= {`DATA_WIDTH{1'b0}};
                         MEM_RLAST <= 1'b0;
                         data_read_out <= {`LEN_WIDTH{1'b0}};
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
                 MEM_RRESP <= {`RESP_WIDTH{1'b0}};
                 MEM_RDATA <= {`DATA_WIDTH{1'b0}};
                 MEM_RLAST <= 1'b0;
                 data_read_out <= {`LEN_WIDTH{1'b0}};
               end
           end 
       end            

       assign MEM_RID   = (MEM_RVALID && MEM_RREADY) ? arid : {`ID_WIDTH{1'b0}};
     
    endmodule
