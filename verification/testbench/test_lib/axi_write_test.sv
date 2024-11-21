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


