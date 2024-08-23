class axi_env extends uvm_env;
  `uvm_component_utils(axi_env)
  
  axi_master_agent master;
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
/*
        master_monitor = axi_master_monitor::type_id::create("master_monitor", this);
        if (!uvm_config_db#(uvm_object_wrapper)::get(this, "*", "scoreboard_port", scoreboard_port))
            `uvm_fatal("NO_SB_PORT", "scoreboard port not defined for axi_env")
        
        scoreboard = axi_scoreboard::type_id::create("scoreboard", this);
*/
	endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //master_monitor.analysis_port.connect(scoreboard_port);
    endfunction

endclass
