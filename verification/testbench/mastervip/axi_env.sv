class axi_env extends uvm_env;
  `uvm_component_utils(axi_env)
  
  axi_master_agent master;
  axi_slave_agent slave;
 axi_scoreboard scoreboard;
/*
    axi_master_monitor master_monitor;
    axi_scoreboard scoreboard;
    uvm_analysis_port#(axi_transaction) scoreboard_port;
*/
    function new(string name = "axi_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        master= axi_master_agent::type_id::create("master",this);
      slave= axi_slave_agent::type_id::create("slave",this);
      scoreboard =axi_scoreboard::type_id::create("scoreboard",this);
/*
        master_monitor = axi_master_monitor::type_id::create("master_monitor", this);
        if (!uvm_config_db#(uvm_object_wrapper)::get(this, "*", "scoreboard_port", scoreboard_port))
            `uvm_fatal("NO_SB_PORT", "scoreboard port not defined for axi_env")
        
        scoreboard = axi_scoreboard::type_id::create("scoreboard", this);
*/
	endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
       slave.monh.axi_slave_mon_ap.connect(scoreboard.w_out);
        master.drvh. master_agent_ap.connect(scoreboard.w_in);
      // slave.drvh. slave_agent_ap.connect(scoreboard.R_in);
      slave.monh.axi_slave_mon_R.connect(scoreboard.R_in);
       master.monh.axi_master_mon_ap.connect(scoreboard.R_out);
        
    endfunction

endclass
