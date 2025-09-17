class axi_trans extends uvm_sequence_item;
  
 // `uvm_object_param_utils(axi_trans#(ID_WIDTH,ADDR_WIDTH,LEN_WIDTH,DATA_WIDTH,STRB_WIDTH))
  `uvm_object_utils(axi_trans)
  
  
  function new(string name = "axi_trans"); 
    super.new(name);  
  endfunction
 
 // rand bit AXI_WRITE;   //write operation
  //rand bit AXI_READ;    //read operation
  
  //Write Channel Signals
  rand axi_transaction_cmd tr_cmd;
  rand bit [`ADDR_WIDTH-1:0] AWADDR;
  rand bit [`ID_WIDTH-1:0] AWID;   // 10bit
  rand bit [`ID_WIDTH-1:0] WID;
  rand bit [`LEN_WIDTH-1:0] AWLEN;   //7bit 
  rand bit [(`LEN_WIDTH/4):0] AWSIZE;   
  rand axi_burst_type awburst;
  rand axi_cache_type awcache;
  rand axi_lock_type awlock;
  rand axi_prot_type awprot;
  rand bit  [31:0] wstrb; 
  rand bit [7:0] WDATA[][];
  
 //read Channel Signals
  rand bit [`ID_WIDTH-1:0] ARID;   
  rand bit [`ID_WIDTH-1:0] RID;
  rand bit [`LEN_WIDTH-1:0] ARLEN;
  rand bit [`ADDR_WIDTH-1:0] ARADDR;
  rand bit [(`LEN_WIDTH/4):0] ARSIZE;
  rand axi_burst_type arburst;
  rand axi_cache_type arcache;
  rand axi_lock_type arlock;
  rand axi_prot_type arprot;
  rand bit [7:0] RDATA [][];  
  
  
  logic     [3:0] BID;
  logic          [1:0] BRESP;
  logic          [1:0] RRESP; // need clarity on this
  logic                BVALID;
  logic                BREADY;
  
  
  
  // Constarints 
   constraint c_wstrb{wstrb == 32'hFFFF_FFFF;}    
    constraint ID_W { AWID==WID;}
  constraint ID_R { ARID==RID;} 
  
  //burst -length constraint  
  constraint arburst_val {if (/*ARBURST*/arburst==2'b10) {ARLEN inside {1,3,7,15};}} 
    constraint awburst_val {if (/*AWBURST*/awburst==2'b10) {AWLEN inside {1,3,7,15};}} 
        
    //  constraint wdata_size { WDATA.size() == (2**AWSIZE); }   // 256 size
//       constraint wdata_size { WDATA.size() == AWLEN +1; 
//                              foreach (WDATA.SIZE)
                               
//                                 } 
    
      constraint size_value { 8*(2** AWSIZE) == `DATA_WIDTH ;}  
        constraint size_value { 8*(2** ARSIZE) == `DATA_WIDTH ;}     
        constraint wdata_size {
        /*  solve order constraints  */
        solve AWLEN before WDATA;
        solve AWSIZE before WDATA;

        /*  rand variable constraints  */
           WDATA.size() == AWLEN+1;
           foreach (WDATA[i])
               WDATA[i].size() == 2**AWSIZE;
        } 
      
   // constraint rdata_size { RDATA.size() == (2**ARSIZE); } 
        constraint Rdata_size {
        /*  solve order constraints  */
        solve ARLEN before RDATA;
        solve ARSIZE before RDATA;

        /*  rand variable constraints  */
          RDATA.size() == ARLEN+1;
          foreach (RDATA[i])
            RDATA[i].size() == 2**ARSIZE;
        } 
      
      
      
   // constraint c_size{soft AWSIZE == 5;} 
      //constraint R_size{soft ARSIZE == AWSIZE;} 
      //write
      constraint  W_lock_type { soft awlock == 2'h0;}
      constraint  W_prot_type { soft awprot == 3'h2;}
      constraint  W_cache_type { soft awcache == 4'h0;}
      //read
      constraint  R_lock_type { soft awlock == 2'h0;}
      constraint  R_prot_type { soft awprot == 3'h2;}
      constraint  R_cache_type { soft awcache == 4'h0;}
    
    
    virtual function void do_print(uvm_printer printer);  
        super.do_print(printer); 
        printer.print_string("tr_cmd", tr_cmd.name);
        printer.print_field("AWADDR", AWADDR, $bits(AWADDR));
        printer.print_field("AWLEN", AWLEN, $bits(AWLEN));
        printer.print_field("AWSIZE",AWLEN,$bits(AWSIZE));                    
        printer.print_string("awburst", awburst.name);
        printer.print_string("awcache", awcache.name);
        printer.print_string("awlock", awlock.name);
        printer.print_string("awprot", awprot.name);
        printer.print_field("ARADDR", ARADDR, $bits(ARADDR));
        printer.print_field("ARLEN", ARLEN, $bits(ARLEN));
        printer.print_field("ARSIZE",ARLEN,$bits(ARSIZE));
        printer.print_string("arburst", arburst.name);
        printer.print_string("arcache", arcache.name);
        printer.print_string("arlock", arlock.name);
        printer.print_string("arprot", arprot.name);  
     endfunction
  
  
endclass:axi_trans
  
