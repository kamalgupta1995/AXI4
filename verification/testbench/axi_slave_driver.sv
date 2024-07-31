class axi_slave_driver extends uvm_driver#(axi_trans);

    `uvm_component_utils(axi_slave_driver)

    virtual axi_if axi_vif;
    
    axi_trans   axi_xfer;
  
    // Address range for the slave
    int unsigned min_addr;
    int unsigned max_addr;

    // Memory and address variables
    reg [(AXI_DATA_WIDTH/8)-1:0] slv_mem [int]; 
    bit [47:0] wr_address;  // 48-bit address for write     
    bit [47:0] rd_address;  // 48-bit address for read
    reg [AXI_DATA_WIDTH-1:0] mem_data_out;

    int addr;
    int brstcnt;
    bit [255:0] wr_data[]; 
    bit [255:0] rd_data[];
    bit resp_okay;
    
    //--------------------------------------------------------
    // Methods
    //--------------------------------------------------------

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new

    function void build_phase(uvm_phase phase);
        axi_xfer = axi_trans::type_id::create("axi_xfer");  

       if(! uvm_config_db#(virtual axi_if)::get(this, "", "axi_vif", axi_vif)) begin
            `uvm_fatal("AXI_SLV_DRV", "Cannot get VIF from configuration database!")
       end
       super.build_phase(phase);

    endfunction //build_phase
    
    //-------------------------------------
    task run_phase(uvm_phase phase);
       axi_vif.AXI_AWREADY    = 1;// All time ready slave
       axi_vif.AXI_ARREADY    = 1;
       axi_vif.AXI_WREADY     = 1;
       //axi_vif.AXI_BVALID     = 0;
       //axi_vif.AXI_RLAST      = 0;
       //axi_vif.AXI_RVALID     = 0;
       //axi_vif.AXI_RDATA      = 0;
       forever begin
        @(posedge axi_vif.AXI_ACLK)
        drive();
       end
 
    endtask //run_phase

    //------------------------------------------------
    task drive();
      if(!axi_vif.AXI_ARESETn) begin
        axi_vif.AXI_RVALID = 0;
        axi_vif.AXI_BVALID = 0;
        axi_vif.AXI_BVALID     = 0;
        axi_vif.AXI_RLAST      = 0;
        axi_vif.AXI_RVALID     = 0;
        axi_vif.AXI_RDATA      = 0;
      end
      
      fork
      	
       if(axi_vif.AXI_AWVALID) begin 
          sample_write_address(axi_xfer);
          sample_write_data(axi_xfer);
          send_write_response(axi_xfer);
        end

        if(axi_vif.AXI_ARVALID) begin 
          sample_read_address(axi_xfer);
          sample_read_data(axi_xfer);
        end
      join_none

    endtask
    
    //-----------------------------------------------------------
    task sample_write_address(axi_trans axi_xfer);
     // if(axi_vif.AXI_AWVALID) begin 
	axi_xfer.tr_cmd = AXI_WRITE;
        axi_xfer.id     = axi_vif.AXI_AWID;
        axi_xfer.addr   = axi_vif.AXI_AWADDR;
        axi_xfer.size   = axi_vif.AXI_AWSIZE;
        axi_xfer.len    = axi_vif.AXI_AWLEN;
        wr_address      = axi_xfer.addr;
        brstcnt         = axi_xfer.len + 1;
       `uvm_info("SLV_DRV", $sformatf("AXI WRITE TRANSACTION PRINT: addr = %0h,num_trans=%0d",addr,brstcnt),UVM_LOW)
        axi_xfer.print();
      end	
      
      //repeat (1) @(posedge axi_vif.AXI_ACLK);
      //axi_vif.AXI_AWREADY = 1;
        
    endtask: sample_write_address
    
    //-----------------------------------------------------------------
    task sample_write_data(axi_trans axi_xfer);
      bit [(AXI_DATA_WIDTH/8)-1:0] data_in;
      int write_addr;

      /*// Update AXI_WREADY
      if (axi_vif.AXI_WVALID && !axi_vif.AXI_WREADY) begin
        axi_vif.AXI_WREADY = 1'b1;
      end else begin
        axi_vif.AXI_WREADY = 1'b0;
      end  */
   
      if(AXI_AWBURST==2'b00) begin    //Fixed burst
         

          for (int wr_byte_index = 0; wr_byte_index < (AXI_DATA_WIDTH/8); wr_byte_index = wr_byte_index + 1) begin
            if (axi_vif.AXI_WSTRB[wr_byte_index]) begin
              data_in = axi_vif.AXI_WDATA[(wr_byte_index*8 + 7) -: 8];

              // Calculate the write address
              write_addr = wr_address + wr_byte_index;

             // Check if the address is within the range
             if (write_addr >= min_addr && write_addr <= max_addr) begin
	      slv_mem[write_addr] = data_in;
             `uvm_info("WR_DATA", $sformatf("AXI_SLV_DRV: AXI_WSTRB[%0h] = %0h, slv_mem[%0h] = %0h", wr_byte_index, axi_vif.AXI_WSTRB[wr_byte_index], write_addr, slv_mem[write_addr]), UVM_LOW)
               resp_okay=1;
             end 
             else
               resp_okay=0;
             end 
	
   end
          end

      end


      else if(AXI_AWBURST==2'b01) begin //INCR Burst

        for (int i = 0; i < brstcnt; i++) begin
          @(posedge axi_vif.AXI_ACLK);
          axi_vif.AXI_WID   = axi_xfer.id;
          axi_vif.AXI_WLAST = (i == brstcnt-1) ? 1 : 0;
          for (int wr_byte_index = 0; wr_byte_index < (AXI_DATA_WIDTH/8); wr_byte_index = wr_byte_index + 1) begin
            if (axi_vif.AXI_WSTRB[wr_byte_index]) begin
              data_in = axi_vif.AXI_WDATA[(wr_byte_index*8 + 7) -: 8];

              // Calculate the write address
              write_addr = wr_address + wr_byte_index;

             // Check if the address is within the range
             if (write_addr >= min_addr && write_addr <= max_addr) begin
	      slv_mem[write_addr] = data_in;
             `uvm_info("WR_DATA", $sformatf("AXI_SLV_DRV: AXI_WSTRB[%0h] = %0h, slv_mem[%0h] = %0h", wr_byte_index, axi_vif.AXI_WSTRB[wr_byte_index], write_addr, slv_mem[write_addr]), UVM_LOW)
               resp_okay=1;
             end 
             else
               resp_okay=0;
	
   end
          end

	   // Increment the base address after each burst
           wr_address = wr_address + (AXI_DATA_WIDTH/8);
        end
      end


   else if(AXI_AWBURST==2'b10) begin //WRAP Burst

        for (int i = 0; i < brstcnt; i++) begin
          @(posedge axi_vif.AXI_ACLK);
          axi_vif.AXI_WID   = axi_xfer.id;
          axi_vif.AXI_WLAST = (i == brstcnt-1) ? 1 : 0;
          for (int wr_byte_index = 0; wr_byte_index < (AXI_DATA_WIDTH/8); wr_byte_index = wr_byte_index + 1) begin
            if (axi_vif.AXI_WSTRB[wr_byte_index]) begin
              data_in = axi_vif.AXI_WDATA[(wr_byte_index*8 + 7) -: 8];

              // Calculate the write address
              write_addr = wr_address + wr_byte_index;

             // Check if the address is within the range
             if (write_addr >= min_addr && write_addr <= max_addr) begin
	      slv_mem[write_addr] = data_in;
             `uvm_info("WR_DATA", $sformatf("AXI_SLV_DRV: AXI_WSTRB[%0h] = %0h, slv_mem[%0h] = %0h", wr_byte_index, axi_vif.AXI_WSTRB[wr_byte_index], write_addr, slv_mem[write_addr]), UVM_LOW)
               resp_okay=1;
             end 
             else
               resp_okay=0;
	
   end
          end

	   // Increment the base address after each burst
           //wr_address = wr_address + (AXI_DATA_WIDTH/8);


        // Increment the base address after each burst and wrap back when wrap address is reached
           wrap_boundary= int(wr_address/axi_vif.AXI_LENGTH*(2**AXI_SIZE))*axi_vif.AXI_LENGTH*(2**axi_vif.AXI_SIZE);
           address_N= wrap_boundary + axi_vif.AXI_LENGTH*(2**axi_vif.AXI_SIZE);
           wr_address = wr_address + (AXI_DATA_WIDTH/8);
           if(wr_address==wrap_boundary)
              wr_address= address_N;
           else 
                wr_address = wr_address + (AXI_DATA_WIDTH/8);


        end
      end
 
 
     
    endtask
  

    //----------------------------------------------------------------
    task send_write_response(axi_trans axi_xfer);
     if(!axi_vif.AXI_ARESETn) begin
       axi_vif.AXI_BID = 4'b0000;
       axi_vif.AXI_BRESP = 2'b00;
       axi_vif.AXI_BVALID = 1'b0;
     end
      
     if(resp_okay) begin
          axi_vif.AXI_BID = axi_xfer.id;
          axi_vif.AXI_BRESP = 2'b00;
          axi_vif.AXI_BVALID = 1'b1;
          wait(axi_vif.AXI_BREADY);
          @(posedge axi_vif.AXI_ACLK)
          axi_vif.AXI_BVALID = 1'b0;
     end

     else if(!resp_okay)begin
          axi_vif.AXI_BID = axi_xfer.id;
          axi_vif.AXI_BRESP = 2'b10;
          axi_vif.AXI_BVALID = 1'b1;
          @(posedge axi_vif.AXI_ACLK)
          axi_vif.AXI_BVALID = 1'b0;
     end
     
    else if(axi_vif.AXI_AWLOCK)begin
          axi_vif.AXI_BID = axi_xfer.id;
          axi_vif.AXI_BRESP = 2'b01;     //Give Ex access response for AWLOCK transactions
          axi_vif.AXI_BVALID = 1'b1;
          @(posedge axi_vif.AXI_ACLK)
          axi_vif.AXI_BVALID = 1'b0;
     end
          




    endtask

    //-----------------------------------------------------------
    task sample_read_address(axi_trans axi_xfer);
   
     if(axi_vif.AXI_ARVALID) begin
       axi_xfer.tr_cmd = AXI_READ;
       axi_xfer.id     = axi_vif.AXI_ARID;
       axi_xfer.addr   = axi_vif.AXI_ARADDR;
       axi_xfer.size   = axi_vif.AXI_ARSIZE;
       axi_xfer.len    = axi_vif.AXI_ARLEN;
       rd_address      = axi_xfer.addr;
       brstcnt         = axi_xfer.len + 1;
      `uvm_info("SLV_DRV", $sformatf("AXI READ TRANSACTION PRINT: rd_address = %0h,num_trans=%0d",rd_address,brstcnt),UVM_LOW)
       axi_xfer.print();
      end

      //repeat (1) @(posedge axi_vif.AXI_ACLK);
      //axi_vif.AXI_ARREADY = 1'b1;
         
      
     endtask: sample_read_address
  
    //-------------------------------------------------------------
 task sample_read_data(axi_trans axi_xfer);
  reg [(AXI_DATA_WIDTH/8)-1:0] data_out;
  int read_addr;

  // Wait for AXI_RREADY to be asserted
  //wait(axi_vif.AXI_RREADY);
  axi_vif.AXI_RVALID = 1'b1;

  if (axi_vif.AXI_RREADY == 1'b1) begin
    for (int i = 0; i < brstcnt; i++) begin
      @(posedge axi_vif.AXI_ACLK);
      axi_vif.AXI_RID   = axi_xfer.id;
      axi_vif.AXI_RLAST = (i == brstcnt-1) ? 1 : 0;
      axi_vif.AXI_RRESP = 1'b0;

      // Read Data
      for (int rd_byte_index = 0; rd_byte_index < (AXI_DATA_WIDTH/8); rd_byte_index = rd_byte_index + 1) begin
       
        read_addr = rd_address + rd_byte_index;
        // Check if the address is within the range
        if (read_addr >= min_addr && read_addr <= max_addr) begin
          data_out = slv_mem[read_addr];
          `uvm_info("RD_DATA", $sformatf("AXI_SLV_DRV: slv_mem[%0h] = %0h, data_out = %0h", read_addr, slv_mem[read_addr], data_out), UVM_LOW)
          axi_vif.AXI_RDATA[(rd_byte_index*8 + 7) -: 8] = data_out;
          resp_okay=1;
        end 
        else
          resp_okay=0;
      end
           // Increment the base address after each burst
     rd_address = rd_address + (AXI_DATA_WIDTH/8);

    end

  end

  // Set AXI_RVALID to 0 to end the read operation
  axi_vif.AXI_RVALID = 0;
endtask

 endclass //axi_slave_driver