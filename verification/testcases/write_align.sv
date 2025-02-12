//`include "axi_seq_lib.sv"
class axi_alignwrite_test extends uvm_test;
  
  `uvm_component_utils(axi_alignwrite_test)

    write_seq wseq;
    
    axi_env env;
   // top_agent toph;    
    
    function new(string name = "axi_alignwrite_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        
        super.build_phase(phase);
	//    toph = top_agent::type_id::create("toph",this);
        wseq = write_seq::type_id::create("wseq");
		env = axi_env::type_id::create("env", this);
	endfunction: build_phase    

    function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction: end_of_elaboration_phase
    
    task run_phase(uvm_phase phase);

        phase.raise_objection(this);
         wseq.start(env.toph.seqr);
         #200;
		phase.drop_objection(this);
	endtask: run_phase

endclass

