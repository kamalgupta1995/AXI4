class axi_slave_monitor extends uvm_monitor;
  `uvm_component_utils(axi_slave_monitor)

    // Components
  uvm_analysis_port#(axi_trans#(WIDTH,SIZE)) ap;
    virtual axi_intf axi_vif;
    // variables
  axi_trans#(WIDTH,SIZE) w_tr, r_tr;
    bit w_done, r_done;
   // int b_size;
    
    // Methods
    extern task run_mon(uvm_phase phase);
    extern task write_monitor();
    extern task read_monitor();

    function new(string name, uvm_component parent);
        super.new(name, parent);
        w_done = 1;
        r_done = 1;
    endfunction //new()

    //  build_phase
    function void build_phase(uvm_phase phase);
    ap = new("ap", this);
    endfunction: build_phase
      
    //CONNECT PHASE
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
            
      if(! uvm_config_db #(virtual axi_intf)::get(this,"*","axi_vif",axi_vif))

            uvm_report_fatal("IN_MONITOR ","NO INTERFACE",UVM_NONE);
    endfunction:connect_phase        

    
    // run_phase
    extern task run_phase(uvm_phase phase);
    
endclass //axi_s_monitor extends uvm_monitor

task axi_slave_monitor::run_phase(uvm_phase phase);
    forever begin
        run_mon(phase);
      @(axi_vif.clk);
    end
endtask: run_phase

task axi_slave_monitor::run_mon(uvm_phase phase);
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

task axi_slave_monitor::write_monitor();
  if(axi_vif.AWVALID && axi_vif.AWREADY) begin
        w_tr         = axi_trans#(WIDTH,SIZE)::type_id::create("w_tr");
        w_tr.AWADDR  = axi_vif.AWADDR;
        w_tr.AWID    = axi_vif.AWID;
        w_tr.AWSIZE  = axi_vif.AWSIZE;
        w_tr.AWLEN   = axi_vif.AWLEN;
    w_tr.AWBURST     = axi_wburst_type'(axi_vif.AWBURST);
    w_tr.WDATA       = new [w_tr.AWLEN+1];
    for (int i=0; i<w_tr.AWLEN+1; i++) begin
          @(axi_vif.clk);
          wait(axi_vif.WVALID && axi_vif.WREADY);
            w_tr.WDATA[i] = new [WIDTH/8];
            for (int j=0; j<WIDTH/8; j++) begin
              w_tr.WDATA[i][j] = axi_vif.WDATA[8*j+:8];
            end
        end
      wait(axi_vif.clk.BVALID);
        w_tr.BRESP = axi_vif.clk.BRESP;
    `uvm_info("IN_MONITOR",$sformatf("AWADDR=%0d,AWID=%0d,AWSIZE=%0d,AWLEN=%0d,AWBURST=%0d,WDATA =%0d",w_tr.AWADDR,w_tr.AWID,w_tr.AWSIZE,w_tr.AWLEN,AWBURST,WDATA),UVM_NONE)
 
endtask: write_monitor

task axi_slave_monitor::read_monitor();
  if(axi_vif.ARVALID && axi_vif.ARREADY) begin
        r_tr         = axi_trans#(WIDTH,SIZE)::type_id::create("r_tr");
        r_tr.ADADDR  = axi_vif.ARADDR;
        r_tr.ARID    = axi_vif.ARID;
        r_tr.ARSIZE  = axi_vif.ARSIZE;
        r_tr.ARLEN   = axi_vif.ARLEN;
        r_tr.ARBURST = axi_wburst_type'(axi_vif.ARBURST);
        r_tr.ARDATA  = new [r_tr.ARLEN+1];
        r_tr.RRESP   = new [r_tr.ARLEN+1];
     for (int i=0; i<r_tr.ARLEN+1; i++) begin
          @(axi_vif.clk);
          wait(axi_vif.RVALID && axi_vif.RREADY);
            r_tr.RDATA[i] = new [WIDTH/8];
            for (int j=0; j<WIDTH/8; j++) begin
              r_tr.RDATA[i][j] = axi_vif.RDATA[8*j+:8];
            end
          r_tr.RRESP[i] = axi_vif.RRESP;
       `uvm_info("IN_MONITOR",$sformatf("ARADDR=%0d,ARID=%0d,ARSIZE=%0d,ARLEN=%0d,ARBURST=%0d,RDATA =%0d",r_tr.ARADDR,r_tr.ARID,r_tr.ARSIZE,r_tr.ARLEN,ARBURST,RDATA),UVM_NONE)
        end
        ap.write(r_tr);
    
    end
endtask: read_monitor