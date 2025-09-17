<<<<<<< HEAD
class axi_write_test extends uvm_test;
  `uvm_component_utils(axi_write_test)
  
  axi_env env;
  axi_Wsequence seq;

  function new(string name="axi_write_test", uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
		env = axi_env::type_id::create("env", this);
    	seq = axi_Wsequence::type_id::create("seq");
    endfunction //build_phase()

    task run_phase(uvm_phase phase);
    	super.run_phase(phase); //Reqd ??
        phase.raise_objection(this);
		//fork
			seq.start(env.master.seqrh);
			begin
				#200;
				//rd_seq.start(env.master.r_seqr);
			end
		//join
		phase.drop_objection(this);
	endtask: run_phase  
  
endclass //axi_write_test

=======
//`include "axi_seq_lib.sv"
class axi_write_test extends uvm_test;
  
  `uvm_component_utils(axi_write_test)

    write_seq wseq;
    
    axi_env env;
   // top_agent toph;    
    
    function new(string name = "axi_write_test", uvm_component parent);
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

>>>>>>> a87d514e1f22b202a7d6d7084744332e2e3c5423
