// Code your testbench here
// or browse Examples
//------------------------------------------------------------------
// Class : axi_master_driver
//------------------------------------------------------------------

class axi_master_driver extends uvm_driver#(axi_trans);

   `uvm_component_utils(axi_master_driver)

    virtual axi_if#(`ID_WIDTH,`ADDR_WIDTH,`LEN_WIDTH,`DATA_WIDTH,(`DATA_WIDTH/8)) axi_vif;
 
    uvm_analysis_port#(axi_trans) master_agent_ap;

    bit [255:0] wr_data[];
    logic[1:0] bresp;
    logic[3:0] bid;
  int count;

    //-------------------------------------------------
    // Methods
    //-------------------------------------------------

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        master_agent_ap = new("master_agent_ap", this);
    endfunction //new

    function void build_phase(uvm_phase phase);
      if(! uvm_config_db#(virtual axi_if#(`ID_WIDTH,`ADDR_WIDTH,`LEN_WIDTH,`DATA_WIDTH,(`DATA_WIDTH/8)))::get(this, "", "axi_vif", axi_vif)) 
        `uvm_fatal("AXI_MASTR_DRV", "Cannot get VIF from configuration database!")
        super.build_phase(phase);
    endfunction //build_phase
//           axi_xfer = axi_trans::type_id::create("axi_xfer");  

    //-------------------------------------
    task run_phase(uvm_phase phase);
       forever begin
        seq_item_port.get_next_item(req);
      
        req.print();
    	$cast(rsp, req.clone());
        rsp.set_id_info(req);
         
         wait(axi_vif.AXI_ARESETn == 0)
         //  @( axi_vif.AXI_ACLK) ;
           fork  
              reset_axi_write_addr();
              reset_axi_write_data();
              reset_axi_read_addr();
              axi_vif.AXI_BREADY = 1'b0;
           join
            wait (axi_vif.AXI_ARESETn);
           begin
             drive_transaction(req);
           end
        seq_item_port.item_done();
       end
    endtask //run_phase

    //------------------------------------------------
    task drive_transaction(axi_trans axi_xfer);
       
//       if (axi_vif.AXI_ARESETn == 0) 
//         @( posedge axi_vif.AXI_ACLK) ;
//         fork
//           $display("inside reset fork block");

//           reset_axi_write_addr();
//           reset_axi_write_data();
//           reset_axi_read_addr();
//           axi_vif.AXI_BREADY = 1'b0;
//         join
     
 
      // wait for reset
            
        @(posedge axi_vif.AXI_ACLK);
    //  wait (axi_vif.AXI_ARESETn);
      
      
      case(axi_xfer.tr_cmd)
         AXI_WRITE : begin
	                  transfer_write_addr(axi_xfer);
		              transfer_write_data_burst(axi_xfer);
			          sample_write_resp(axi_xfer);
       	             end
         AXI_READ  : begin 
                        transfer_read_addr(axi_xfer);
                        sample_read_data_and_resp(axi_xfer);
       	             end
      endcase 

    endtask

    // Reset AXI Write Address Channel Bus  
    task reset_axi_write_addr();
       axi_vif.AXI_AWID    = 4'h0;
       axi_vif.AXI_AWADDR  = 'h0;
       axi_vif.AXI_AWLEN   = 4'h0;
       axi_vif.AXI_AWSIZE  = 3'h0;
       axi_vif.AXI_AWBURST = 2'h0;
       axi_vif.AXI_AWLOCK  = 2'h0; 
       axi_vif.AXI_AWVALID = 1'b0;
    endtask // reset_axi_write_addr

    //------------------------------------------------
    task transfer_write_addr(axi_trans axi_xfer);
       @(posedge axi_vif.AXI_ACLK);
         axi_vif.AXI_AWID     = axi_xfer.AWID;
         axi_vif.AXI_AWADDR   = axi_xfer.AWADDR;
         axi_vif.AXI_AWLEN    = axi_xfer.AWLEN;
         axi_vif.AXI_AWSIZE   = axi_xfer.AWSIZE;
         axi_vif.AXI_AWBURST  = axi_xfer.awburst; //incrementing address burst
         axi_vif.AXI_AWLOCK   = 2'h0; //normal access
         axi_vif.AXI_AWCACHE  = 4'h0; 
         axi_vif.AXI_AWPROT   = 3'h2; //normal, non-secure data access
         axi_vif.AXI_AWVALID  = 1'b1;
         wait (axi_vif.AXI_AWREADY);
	 if(axi_vif.AXI_AWREADY == 0) begin 
           @(posedge axi_vif.AXI_ACLK);
           axi_vif.AXI_AWVALID = 1'b0;
	 end
   endtask

   // Reset AXI Write Data Channel Bus  
   task reset_axi_write_data();
     axi_vif.AXI_WID    = 4'h0;
     axi_vif.AXI_WDATA  = 'h0;
     axi_vif.AXI_WSTRB  = 4'h0;
     axi_vif.AXI_WLAST  = 1'b0;
     axi_vif.AXI_WVALID = 1'b0;
   endtask // reset_axi_write_data


   //-------------------------------------------------
   task transfer_write_data_burst(axi_trans axi_xfer);
     int brstcnt;
     int total_bytes;

     axi_vif.AXI_WSTRB = axi_xfer.wstrb;
     brstcnt = axi_xfer.AWLEN + 1;
     wr_data = new[brstcnt];

 
     // Data
     /*for(int i=0; i < brstcnt; i++) begin         
        axi_vif.AXI_WID   = axi_xfer.id; 
	for(int j=0; j < (2**axi_xfer.size); j++) begin
          wr_data[i][8*j+:8] = axi_xfer.data[i];
        end
       `uvm_info("WR_DATA",$sformatf(" Data[%0d] = %0h",i,wr_data[i]),UVM_LOW)
        axi_vif.AXI_WDATA = wr_data[i]; 
	axi_vif.AXI_WLAST = (i == brstcnt-1)? 1:0;
	axi_vif.AXI_WVALID= 1'b1;
        wait (axi_vif.AXI_WREADY);
	@(posedge axi_vif.AXI_ACLK);
     end*/
     //$display("daata==%0p",axi_xfer.WDATA);
     //$display(" awlength=%0d",axi_xfer.AWLEN);
     //$display(" AWBURST=%0s ",axi_xfer.awburst.name());   
     
     for(int i=0; i< axi_xfer.AWLEN+1; i++) begin
       `uvm_info("WR_DATA",$sformatf(" Data[%0h] = %0p",i,wr_data[i]),UVM_LOW)
       count=count+1;
       $display("count==%0d",count);
       @(posedge axi_vif.AXI_ACLK) begin
        wait (axi_vif.AXI_WREADY);
         axi_vif.AXI_WDATA = axi_xfer.WDATA[i]; //wdata[size] expecting it to come from sequencce transaction 
         axi_vif.AXI_WLAST = (i == axi_xfer.AWLEN)? 1:0;
       	axi_vif.AXI_WVALID= 1'b1;
        axi_vif.AXI_WID   = axi_xfer.WID; 
       end  
       
     end
     
     
     // Set WVALID to 0
     @(posedge axi_vif.AXI_ACLK)
     axi_vif.AXI_WVALID = 1'b0;
     axi_vif.AXI_WLAST =1'b0;

   endtask 

   //----------------------------------------------------------
   task sample_write_resp(axi_trans axi_xfer);
     axi_vif.AXI_BREADY = 1'b0;
     wait(axi_vif.AXI_BVALID);
     axi_vif.AXI_BREADY = 1'b1;
     bresp = axi_vif.AXI_BRESP;
     bid = axi_vif.AXI_BID;
     //if(axi_vif.AXI_BVALID & ~ axi_vif.AXI_BREADY) begin 
     //  axi_vif.AXI_BREADY = 1'b1;
     //end
     
     repeat(1) @(posedge axi_vif.AXI_ACLK);
     axi_vif.AXI_BREADY = 1'b0;
   endtask

  
   // Reset AXI read Address Channel Bus  
   task reset_axi_read_addr();
     axi_vif.AXI_ARID    = 4'h0;
     axi_vif.AXI_ARADDR  = 'h0;
     axi_vif.AXI_ARLEN   = 4'h0;
     axi_vif.AXI_ARSIZE  = 3'h0;
     axi_vif.AXI_ARBURST = 2'h0;
     axi_vif.AXI_ARLOCK  = 2'h0; 
     axi_vif.AXI_ARVALID = 1'b0;
   endtask // reset_axi_read_addr

   //-------------------------------------------------------
   task transfer_read_addr(axi_trans axi_xfer);
         @(posedge axi_vif.AXI_ACLK);
	 
	 // send AXI_ARVALID to slave
	 axi_vif.AXI_ARVALID  = 1'b1;

         axi_vif.AXI_ARID     = axi_xfer.ARID;
         axi_vif.AXI_ARADDR   = axi_xfer.ARADDR;
         axi_vif.AXI_ARLEN    = axi_xfer.ARLEN;
         axi_vif.AXI_ARSIZE   = axi_xfer.ARSIZE;
         axi_vif.AXI_ARBURST  = 2'h1; //incrementing address burst
         axi_vif.AXI_ARLOCK   = 2'h0; //normal access
         axi_vif.AXI_ARCACHE  = 4'h0; 
         axi_vif.AXI_ARPROT   = 3'h2; //normal, non-secure data access
                  
	 wait (axi_vif.AXI_ARREADY);
	  
         repeat(2) @(posedge axi_vif.AXI_ACLK);
	 axi_vif.AXI_ARVALID = 1'b0;  
         
   endtask
   
   //-----------------------------------------------------------------
   task sample_read_data_and_resp(axi_trans axi_xfer);
     axi_vif.AXI_RREADY = 0;
     repeat(2) @(posedge axi_vif.AXI_ACLK);
     axi_vif.AXI_RREADY = 1;
     repeat(10) @(posedge axi_vif.AXI_ACLK);
     axi_vif.AXI_RREADY = 0;
     repeat(2) @(posedge axi_vif.AXI_ACLK);
     axi_vif.AXI_RREADY = 1;

   endtask
   
   
endclass //axi_master_driver


