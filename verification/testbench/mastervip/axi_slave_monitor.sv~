class axi_slave_monitor extends uvm_monitor;//#(axi_trans);

  `uvm_component_utils(axi_slave_monitor)

  uvm_analysis_port#(axi_trans)axi_slave_mon_ap;
  uvm_analysis_port#(axi_trans)axi_slave_mon_R;
   virtual axi_if axi_vif;
  axi_trans w_tr,r_tr;
  
  // variables
    bit w_done, r_done;
  bit [255:0] data;
  
  //methods
 // extern task run_mon(uvm_phase phase);
  extern task write_monitor();
  extern task read_monitor();    
    
    function new(string name = "axi_slave_monitor",uvm_component parent);
      super.new(name,parent);
      
    endfunction
    
// BUILD_PHASE
    function void build_phase(uvm_phase phase);
 
      axi_slave_mon_ap = new("axi_slave_mon_ap",this);
      axi_slave_mon_R = new("axi_slave_mon_R",this);
          super.build_phase(phase);
      
    endfunction
    
// CONNECT PHASE
    
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
//       if(!uvm_config #(virtual axi_if#(ID_WIDTH,ADDR_WIDTH,LEN_WIDTH,DATA_WIDTH,STRB_WIDTH))::get(this,"","axi_if",axi_vif))
//         uvm_report_fatal("MASTER_MONITOR","NO INTERFACE",UVM_NONE);
       if(! uvm_config_db#(virtual axi_if)::get(this, "", "axi_vif", axi_vif)) 
         `uvm_fatal("AXI_SLAVE_MONITOR", "Cannot get VIF from configuration database!")
    
    endfunction:connect_phase
    
 //RUN_PHA
    extern task run_phase(uvm_phase phase);
endclass  //axi_master_monitor
      
task axi_slave_monitor::run_phase(uvm_phase phase);
  forever begin
    //run_mon(phase);
    w_tr = axi_trans::type_id::create("w_tr");
    @(axi_vif.AXI_ACLK);
    write_monitor();
    read_monitor();
  end
endtask: run_phase
    
/*task axi_master_monitor::run_mon(uvm_phase phase);
  fork
    if(w_done) begin
      phase.raise_objection(this);
      w_done = 0;
      write_monitor();
      w_done = 1;
      phase.drop_objection(this);
    end
    if(r_done) begin
      phase.raise_objection(this);
      r_done = 0;
      read_monitor();
      r_done = 1;
      phase.drop_objection(this);
    end
join_none
endtask: run_mon 
*/
    
task axi_slave_monitor::write_monitor();
  if(axi_vif.AXI_AWVALID && axi_vif.AXI_AWREADY) begin
   // $display("------inside slave moniotr----------");
    w_tr = axi_trans::type_id::create("w_tr");
    w_tr.AWADDR  = axi_vif.AXI_AWADDR;
    w_tr.AWID    = axi_vif.AXI_AWID;
    w_tr.AWSIZE  = axi_vif.AXI_AWSIZE;
    w_tr.AWLEN   = axi_vif.AXI_AWLEN;
    w_tr.awburst = axi_vif.AXI_AWBURST;
   // w_tr.WDATA	 = new [(2 **axi_vif.AXI_AWSIZE) ];
    w_tr.WDATA	 = new [w_tr.AWLEN+1 ];
//     for(int i =0;i<w_tr.AWLEN+1;i++) begin
//      // @(axi_vif.AXI_ACLK);
     
        // Monitor write data
        for (int i = 0; i <=  w_tr.AWLEN ; i++) begin
          wait(axi_vif.AXI_WVALID && axi_vif.AXI_WREADY);
            w_tr.WDATA[i] = new [2**axi_vif.AXI_AWSIZE];
          for(int j=0; j < (2**axi_vif.AXI_AWSIZE) ; j++) begin 
            w_tr.WDATA[i][j] = axi_vif.AXI_WDATA >> (8*j);

          //wait (axi_vif.AXI_WREADY);
        end
        end
    //$display("------slave monitor DATA==%0p", w_tr.WDATA);
   // $display("inside slave monitor");
   // w_tr.print();
    axi_slave_mon_ap.write(w_tr);
//     wait(axi_vif.AXI_BVALID);
//       w_tr.BRESP = axi_vif.AXI_BRESP;

   // `uvm_info("IN_MONITOR",$sformatf("AWADDR=%0d,AWID=%0d,AWSIZE=%0d,AWLEN=%0d,AWBURST=%0d,WDATA =%0h",w_tr.AWADDR,w_tr.AWID,w_tr.AWSIZE,w_tr.AWLEN,axi_vif.AXI_AWBURST,axi_vif.WDATA),UVM_NONE)
  end
    
endtask: write_monitor
    
    

    
task axi_slave_monitor::read_monitor();

  if(axi_vif.AXI_ARVALID && axi_vif.AXI_ARREADY) begin
     // if(axi_vif.AXI_AWVALID && axi_vif.AXI_AWREADY) begin
    //$display($time,"inside SLAVE monitor --READ--");
    r_tr = axi_trans::type_id::create("r_tr");
    r_tr.tr_cmd=AXI_READ;
    r_tr.ARADDR  = axi_vif.AXI_ARADDR;
    r_tr.ARID    = axi_vif.AXI_ARID;
    r_tr.ARSIZE  = axi_vif.AXI_ARSIZE;
    r_tr.ARLEN   = axi_vif.AXI_ARLEN;
    r_tr.arburst = axi_vif.AXI_ARBURST;
    r_tr.RDATA	 =  new [(axi_vif.AXI_ARLEN+1) ];
    //r_tr.RRESP   = new [r_tr.ARLEN+1];
        for(int i =0;i<r_tr.ARLEN+1;i++) begin
      @(axi_vif.AXI_ACLK);
          wait(axi_vif.AXI_RVALID && axi_vif.AXI_RREADY);
          @(posedge axi_vif.AXI_ACLK);
                    @(posedge axi_vif.AXI_ACLK);
          r_tr.RDATA[i] = new [2**axi_vif.AXI_ARSIZE];
          for(int j = 0;j<2**axi_vif.AXI_ARSIZE;j++) begin
            r_tr.RDATA[i][j] = axi_vif.AXI_RDATA[8*j+:8];
      end
          //r_tr.RRESP[i] = axi_vif.AXI_RRESP;
     // end
          //$display($time,"------SLAVE MONITOR RDATA==%0h--- pkt data=%0p",axi_vif.AXI_RDATA, r_tr.RDATA);
      
        axi_slave_mon_R.write(r_tr);
       // `uvm_info("IN_MONITOR",$sformatf("ARADDR=%0d,ARID=%0d,ARSIZE=%0d,ARLEN=%0d,arburst=%0d,RDATA =%0h",r_tr.ARADDR,r_tr.AWID,w_tr.AWSIZE,w_tr.AWLEN,axi_vif.AWBURST,axi_vif.RDATA),UVM_NONE)
      end
  end
endtask: read_monitor
//endclass:axi_master_monitor
