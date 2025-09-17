//`include "axi_seq_lib.sv"
class axi_base_test extends uvm_test;
  
  `uvm_component_utils(axi_base_test)

    sequencee tseq;
    
    axi_env env;
   // top_agent toph;    
    
    function new(string name = "axi_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        
        super.build_phase(phase);
	//    toph = top_agent::type_id::create("toph",this);
        tseq = sequencee::type_id::create("tseq");
		env = axi_env::type_id::create("env", this);
	endfunction: build_phase    

    function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction: end_of_elaboration_phase
    
    task run_phase(uvm_phase phase);

        phase.raise_objection(this);
         tseq.start(env.toph.seqr);
         #200;
		phase.drop_objection(this);
	endtask: run_phase

endclass
/*//////////////////////////////////////////////////////////////////////////
class read_test extends axi_base_test;

    `uvm_component_utils(read_test)
     R_sequence rseqh;

    function new(string name = "read_test", uvm_component parent);
        super.new(name, parent);
    endfunction
// build_phase
 virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
 endfunction

    task run_phase(uvm_phase phase);
       phase.raise_objection(this);
		seq.start(env.toph.rseqh);
		 #200;
       phase.drop_objection(this);
	endtask

endclass
//////////////////////////////////////////////////////////////////////////
class axi_write_test extends axi_base_test;
    `uvm_component_utils(axi_write_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  
    endfunction: build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
    endfunction: end_of_elaboration_phase
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        wr_seq.start(env.slave.seqrh); //w_seqr);
        phase.drop_objection(this);
    endtask: run_phase
endclass //write_test 

class axi_read_test extends axi_base_test;
    `uvm_component_utils(axi_read_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  
    endfunction: build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
    endfunction: end_of_elaboration_phase
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        wr_seq.start(env.slave.seqrh); //w_seqr);
        rd_seq.start(env.slave.seqrh); //r_seqr);
        phase.drop_objection(this);
    endtask: run_phase
endclass //write_test 

class axi_fixed_test extends axi_base_test;
    `uvm_component_utils(axi_fixed_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        //test_cfg.burst_type = 0;
        //uvm_config_db#(test_config)::set(null, "uvm_test_top.seq", "config", test_cfg);
        
        wr_seq = new("wr_seq");
        rd_seq = new("rd_seq");
        env = axi_env::type_id::create("env", this);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase
endclass //axi_fixed_test 

class axi_incr_test extends axi_base_test;
    `uvm_component_utils(axi_incr_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        //test_cfg.burst_type = 1;
        //uvm_config_db#(test_config)::set(null, "uvm_test_top.seq", "config", test_cfg);
        
        wr_seq = new("wr_seq");
        rd_seq = new("rd_seq");
        env = axi_env::type_id::create("env", this);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase
endclass //axi_fixed_test 

class axi_wrap_test extends axi_base_test;
    `uvm_component_utils(axi_wrap_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        //test_cfg.burst_type = 2;
        //uvm_config_db#(test_config)::set(null, "uvm_test_top.seq", "config", test_cfg);
        
        wr_seq = new("wr_seq");
        rd_seq = new("rd_seq");
        env = axi_env::type_id::create("env", this);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase
endclass */
