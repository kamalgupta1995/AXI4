class axi_read_test extends uvm_test;
  `uvm_component_utils(axi_read_test)
  
  axi_env env;
  axi_Rsequence seq;

  function new(string name="axi_read_test", uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
		env = axi_env::type_id::create("env", this);
    	seq = axi_Rsequence::type_id::create("seq");
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
  
endclass //axi_Read_test


