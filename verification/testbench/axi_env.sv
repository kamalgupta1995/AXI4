class axi_env extends uvm_env;
  `uvm_component_utils(axi_env)

    axi_slave_monitor slave_monitor;
    axi_slave_scoreboard slave_scoreboard;
    uvm_analysis_port#(axi_transaction) scoreboard_port;

    function new(string name = "axi_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        slave_monitor = axi_slave_monitor::type_id::create("slave_monitor", this);
        if (!uvm_config_db#(uvm_object_wrapper)::get(this, "*", "scoreboard_port", scoreboard_port))
            `uvm_fatal("NO_SB_PORT", "slave_scoreboard port not defined for axi_env")
        
        slave_scoreboard = axi_slave_scoreboard::type_id::create("slave_scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        slave_monitor.analysis_port.connect(scoreboard_port);
    endfunction

endclass