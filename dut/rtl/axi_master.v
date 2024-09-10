// Project: AMBA AXI4 Protocol
// Company: ACL Digital
// Domain : RTL Design
// Author : Vinay Chowdary
// File   : axi_master module

`timescale 1ns/1ps
`include "/home/vinay.c/Design/axi_slave/RTL/axi_constants.vh"
module axi_master 
     (
     //Global signals
     input                          aclk                , //system clock 
     input                          aresetn             , //active low reset signal
     //Write request channel signals
     input                          awready             ,
     output reg                     awvalid             ,
     output reg  [`ID_WIDTH-1:0]    awid                , 
     output reg [`ADDR_WIDTH-1:0]   awaddr              , 
     output reg [`LEN_WIDTH-1:0]    awlen               , 
     output reg [`SIZE_WIDTH-1:0]   awsize              , 
     output reg [`BURST_WIDTH-1:0]  awburst             , 
     output wire                    awlock              , 
     output wire [`CACHE_WIDTH-1:0] awcache             ,
     output wire [`PROT_WIDTH-1:0]  awprot              ,
     output wire [`QOS_WIDTH-1:0]   awqos               ,
     //Write data channel
     input                          wready              ,
     output reg                     wvalid              ,
     output reg [`DATA_WIDTH-1:0]   wdata               ,
     output reg[(`DATA_WIDTH/8)-1:0]wstrb               ,
     output reg                     wlast               ,
     //Write response channel
     input [`ID_WIDTH-1:0]          bid                 , 
     input [`RESP_WIDTH-1:0]        bresp               , 
     input                          bvalid              ,
     output reg                     bready              ,
     //Read resquest channel
     input                          arready             ,
     output reg                     arvalid             ,
     output reg [`ID_WIDTH-1:0]     arid                , 
     output reg [`ADDR_WIDTH-1:0]   araddr              ,
     output reg [`LEN_WIDTH-1:0]    arlen               ,
     output reg [`SIZE_WIDTH-1:0]   arsize              ,
     output reg [`BURST_WIDTH-1:0]  arburst             ,
     output wire                    arlock              ,
     output wire [`CACHE_WIDTH-1:0] arcache             ,
     output wire [`PROT_WIDTH-1:0]  arprot              ,
     output wire [`QOS_WIDTH-1:0]   arqos               ,
     //Read data channel
     input [`ID_WIDTH-1:0]          rid                 , 
     input [`DATA_WIDTH-1:0]        rdata               ,
     input [`RESP_WIDTH-1:0]        rresp               , 
     input                          rlast               ,
     input                          rvalid              ,
     output reg                     rready              ,
     //AXI Top driven Signals
     input                          transfer            , //initiates the transaction
     input                          write_en            , //indicates the write transaction
     input                          read_en             , //indicates the read transaction
     input [`ADDR_WIDTH-1:0]        write_addr          , //write address
     input [`ADDR_WIDTH-1:0]        read_addr           , //read address
     input [`ID_WIDTH-1:0]          write_id            ,
     input [`LEN_WIDTH-1:0]         write_len           , //length of the data transfer
     input [`SIZE_WIDTH-1:0]        write_size          , //size of the data transfer
     input [`BURST_WIDTH-1:0]       write_burst         ,
     input [`DATA_WIDTH-1:0]        write_data          ,
     input [(`DATA_WIDTH/8)-1:0]    write_strb          ,
     output reg [`ID_WIDTH-1:0]     write_resp_id       ,
     output reg [`ID_WIDTH-1:0]     read_resp_id        ,
     output reg [`DATA_WIDTH-1:0]   read_data_out       ,
     output reg                     read_data_out_valid ,
     output reg [`RESP_WIDTH-1:0]   wr_error            ,
     output reg [`RESP_WIDTH-1:0]   rd_error            ,
     input [`ID_WIDTH-1:0]          read_id             ,
     input [`LEN_WIDTH-1:0]         read_len            ,
     input [`SIZE_WIDTH-1:0]        read_size           ,
     input [`BURST_WIDTH-1:0]       read_burst         );

     //declaration of local parameters
     localparam WR_IDLE = 2'b00; //Write IDLE state
     localparam WR_ADDR = 2'b01; //Write Address Channel
     localparam WR_DATA = 2'b10; //Write Data Channel
     localparam WR_RESP = 2'b11; //Write Response Channel

     localparam RD_IDLE = 2'b00;  //Read IDLE state
     localparam RD_ADDR = 2'b01; //Read Address Channel
     localparam RD_DATA = 2'b10; //Read Data Channel

     //declaration of registers
     reg [1:0] wr_present_state;
     reg [1:0] wr_next_state;
     reg [1:0] rd_present_state;
     reg [1:0] rd_next_state;
     reg [`LEN_WIDTH-1:0] wdata_sent;


     //unimplemented for now -- taken into consideration to match AXI slave
     assign awlock  = 1'b0;                       //Exclusive access were not supported
     assign awcache = {`CACHE_WIDTH{1'b0}};       //Cache not supported
     assign awprot  = {`PROT_WIDTH{1'b0}};        //Protection not implemented
     assign awqos   = {`QOS_WIDTH{1'b0}};         //Quality of service is not supported 
     assign arlock  = 1'b0;                       //Exclusive access were not supported
     assign arcache = {`CACHE_WIDTH{1'b0}};       //Cache not supported
     assign arprot  = {`PROT_WIDTH{1'b0}};        //Protection not implemented
     assign arqos   = {`QOS_WIDTH{1'b0}};         //Quality of service is not supported

     //present state logic for write 
     always@(posedge aclk or negedge aresetn)
        begin
           if(!aresetn)
              begin
                 wr_present_state <= WR_IDLE;
              end
           else
              begin
                 wr_present_state <= wr_next_state;
              end
        end

     //present state logic for read 
     always@(posedge aclk or negedge aresetn)
        begin
           if(!aresetn)
              begin
                 rd_present_state <= RD_IDLE;
              end
           else
              begin
                 rd_present_state <= rd_next_state;
              end
        end

     //next state and output logic for write
     always@(*)
        begin
           case(wr_present_state)
           WR_IDLE:  begin
                           awaddr     = {`ADDR_WIDTH{1'b0}};
                           awid       = {`ID_WIDTH{1'b0}};
                           awlen      = {`LEN_WIDTH{1'b0}};
                           awsize     = {`SIZE_WIDTH{1'b0}};
                           awburst    = {`BURST_WIDTH{1'b0}};
                           write_resp_id = {`ID_WIDTH{1'b0}};
                           wr_error   = {`RESP_WIDTH{1'b0}};
                           wdata_sent = {`LEN_WIDTH{1'b0}};
                           if(transfer && write_en)
                              begin
                                 wr_next_state = WR_ADDR ;
                                 awvalid    = 1'b1;
                              end
                           else
                              begin
                                 wr_next_state = WR_IDLE ;
                                 awvalid    = 1'b0;
                              end
                     end
           WR_ADDR:  begin
                           awaddr  = write_addr  ;
                           awid    = write_id    ;
                           awlen   = write_len   ;
                           awsize  = write_size  ;
                           awburst = write_burst ;
                           wdata_sent = {`LEN_WIDTH{1'b0}};
                           write_resp_id = {`ID_WIDTH{1'b0}};
                           if(awvalid && awready)
                              begin
                                 wr_next_state = WR_DATA ;
                                 awvalid    = 1'b0;
                                 wvalid     = 1'b1; 
                              end
                           else
                              begin
                                 wr_next_state = WR_ADDR ;
                                 awvalid    = awvalid ;
                                 wvalid     = 1'b0;
                              end
                     end
           WR_DATA:  begin
                           write_resp_id = {`ID_WIDTH{1'b0}}; 
                           if(wdata_sent < awlen)
                              begin
                                 wdata = write_data;
                                 wstrb = write_strb;
                                 wlast = 1'b0;
                                 if(wvalid && wready)
                                    begin
                                       wr_next_state = WR_DATA;
                                       wdata_sent = wdata_sent + 1'b1;
                                    end
                                 else
                                    begin
                                       wr_next_state = WR_DATA;
                                       wdata_sent = wdata_sent;
                                    end
                              end
                           else if(wdata_sent == awlen)
                              begin
                                 wdata = write_data;
                                 wstrb = write_strb;
                                 wlast = 1'b1;
                                 if(wvalid && wready)
                                    begin
                                       wr_next_state = WR_RESP;
                                       wdata_sent = {`LEN_WIDTH{1'b0}};
                                       wvalid = 1'b0;
                                       bready = 1'b1;
                                    end
                                 else
                                    begin
                                       wr_next_state = WR_DATA;
                                       wdata_sent = wdata_sent;
                                       wvalid = wvalid;
                                       bready = 1'b0;
                                    end
                              end
                     end
           WR_RESP:  begin
                           if(bvalid && bready)
                              begin
                                 wr_next_state = WR_IDLE;
                                 bready = 1'b0;
                                 write_resp_id = bid;
                                 wr_error  = bresp;
                              end
                           else
                              begin
                                 wr_next_state = WR_RESP ;
                                 bready = bready;
                                 write_resp_id = {`ID_WIDTH{1'b0}};
                                 wr_error  = {`RESP_WIDTH{1'b0}};
                              end
                        end 
           default:     begin
                           wr_next_state = WR_IDLE;
                        end
           endcase
        end

     //next state and output logic for read
     always@(*)
        begin
           case(rd_present_state)
           RD_IDLE:  begin
                           araddr     = {`ADDR_WIDTH{1'b0}};
                           arid       = {`ID_WIDTH{1'b0}};
                           arlen      = {`LEN_WIDTH{1'b0}};
                           arsize     = {`SIZE_WIDTH{1'b0}};
                           arburst    = {`BURST_WIDTH{1'b0}};
                           read_resp_id = {`ID_WIDTH{1'b0}};
                           rd_error   = {`RESP_WIDTH{1'b0}};
                           if(transfer && read_en)
                              begin
                                 rd_next_state = RD_ADDR ;
                                 arvalid    = 1'b1;
                              end
                           else
                              begin
                                 rd_next_state = RD_IDLE ;
                                 arvalid    = 1'b0;
                              end
                     end
          RD_ADDR:   begin
                           araddr  = read_addr  ;
                           arid    = read_id    ;
                           arlen   = read_len   ;
                           arsize  = read_size  ;
                           arburst = read_burst ;
                           read_resp_id = {`ID_WIDTH{1'b0}};
                           read_data_out ={`DATA_WIDTH{1'b0}};
                           read_data_out_valid = 1'b0;
                           if(arvalid && arready)
                              begin
                                 rd_next_state = RD_DATA ;
                                 arvalid = 1'b0;
                                 rready  = 1'b1;
                              end
                           else
                              begin
                                 rd_next_state = RD_ADDR ;
                                 arvalid = arvalid;
                                 rready  = 1'b0;
                              end
                        end
           RD_DATA:   begin
                           if(rvalid && rready)
                              begin
                                 if(rresp == 2'b00)
                                    begin
                                       rd_error = {`RESP_WIDTH{1'b0}};
                                       if(rlast == 1'b1)
                                          begin
                                             rd_next_state = RD_IDLE;
                                             read_data_out = rdata;
                                             read_data_out_valid = 1'b1;
                                             read_resp_id = rid;
                                             rready = 1'b0;
                                          end
                                       else
                                          begin
                                             rd_next_state = RD_DATA;
                                             read_data_out = rdata;
                                             read_data_out_valid = 1'b1;
                                             read_resp_id = rid;
                                             rready = rready;
                                          end
                                    end
                                 else
                                    begin
                                       rd_next_state = RD_IDLE;
                                       read_data_out = {`DATA_WIDTH{1'b0}};
                                       read_data_out_valid = 1'b0;
                                       read_resp_id = {`ID_WIDTH{1'b0}};
                                       rready = 1'b0;
                                       rd_error = rresp;
                                    end
                              end
                           else
                              begin
                                 rd_next_state = RD_DATA ;
                                 rready = rready;
                                 read_data_out = {`DATA_WIDTH{1'b0}};
                                 read_data_out_valid = 1'b0;
                                 read_resp_id = {`ID_WIDTH{1'b0}};
                                 rd_error = {`RESP_WIDTH{1'b0}};
                              end 
                        end
           default:     begin
                           rd_next_state = RD_IDLE;
                        end
           endcase
        end




endmodule
