
class axi_trans#(int  ID_WIDTH=10,ADDR_WIDTH=48,LEN_WIDTH=8,DATA_WIDTH=8,STRB_WIDTH=32) extends uvm_sequence_item;
  
  `uvm_object_param_utils(axi_trans#(WIDTH,SIZE))
  
  function new(string name = "axi_trans"); 
    super.new(name);  
  endfunction
 
 // rand bit AXI_WRITE;   //write operation
  //rand bit AXI_READ;    //read operation
  
  //Write Channel Signals
  rand axi_transaction_cmd tr_cmd;
  rand bit [ADDR_WIDTH-1:0] AWADDR;
  rand bit [ID_WIDTH-1:0] AWID;   // 10bit
  rand bit [ID_WIDTH-1:0] WID;
  rand bit [LEN_WIDTH-1:0] AWLEN;   //7bit 
  rand bit [(LEN_WIDTH/4):0] AWSIZE;   
  rand axi_burst_type awburst;
  rand axi_cache_type awcache;
  rand axi_lock_type awlock;
  rand axi_prot_type awprot;
  rand bit  [STRB_WIDTH-1:0] wstrb; 
  rand bit [DATA_WIDTH-1:0] WDATA[];
  
 //read Channel Signals
  rand bit [ID_WIDTH+1:0] ARID;   
  rand bit [ID_WIDTH+1:0] RID;
  rand bit [LEN_WIDTH-1:0] ARLEN;
  rand bit [ADDR_WIDTH-1:0] ARADDR;
  rand bit [(LEN_WIDTH/4):0] ARSIZE;
  rand axi_burst_type arburst;
  rand axi_cache_type arcache;
  rand axi_lock_type arlock;
  rand axi_prot_type arprot;
  rand bit [DATA_WIDTH-1:0] RDATA [];      
  
  
  
  // Constarints 
  // constraint c_wstrb{wstrb == 32'h0000_000F;}    
    constraint ID_W { AWID==WID;}
    constraint ID_R { ARID=RID;} 
  
  //burst -length constraint  
    constraint arburst_val {if (ARBURST==2'b10) {ARLEN inside {1,3,7,15};}} 
    constraint awburst_val {if (AWBURST==2'b10) {AWLEN inside {1,3,7,15};}} 
        
      constraint data_size { WDATA.size() == (2**AWSIZE); }   // 256 size
    constraint data_size { RDATA.size() == (2**ARSIZE); } 
    constraint c_size{soft AWSIZE == 5;}   
      //write
      constraint  W_lock_type { soft awlock == 2'h00;}
      constraint  W_prot_type { soft awprot == 3'h2;}
      constraint  W_cache_type { soft awcache == 4'h0;}
      //read
      constraint  R_lock_type { soft awlock == 2'h00;}
      constraint  R_prot_type { soft awprot == 3'h2;}
      constraint  R_cache_type { soft awcache == 4'h0;}
    
    
    virtual function void do_print(uvm_printer printer);  
        super.do_print(printer); 
        printer.print_string("tr_cmd", tr_cmd.name);
        printer.print_field_int("AWADDR", AWADDR, $bits(AWADDR), UVM_HEX);
        printer.print_field_int("AWLEN", AWLEN, $bits(AWLEN), UVM_HEX);
        printer.print_field_int("AWSIZE",AWLEN,$bits(AWSIZE),UVM_HEX);
        printer.print_string("awburst", awburst.name);
        printer.print_string("awcache", awcache.name);
        printer.print_string("awlock", awlock.name);
        printer.print_string("awprot", awprot.name);
        printer.print_field_int("ARADDR", ARADDR, $bits(ARADDR), UVM_HEX);
        printer.print_field_int("ARLEN", ARLEN, $bits(ARLEN), UVM_HEX);
        printer.print_field_int("ARSIZE",ARLEN,$bits(ARSIZE),UVM_HEX);
        printer.print_string("arburst", arburst.name);
        printer.print_string("arcache", arcache.name);
        printer.print_string("arlock", arlock.name);
        printer.print_string("arprot", arprot.name);  
     end function
  
  
endclass:axi_tans
  
  
       
       
  
  
  
  
   
  









