class axi_read_test extends axi_write_test;

    `uvm_component_utils(axi_read_test)
     read_seq rseq;

    function new(string name = "axi_read_test", uvm_component parent);
        super.new(name, parent);
    endfunction
    
// build_phase
 virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
 endfunction

    task run_phase(uvm_phase phase);
       phase.raise_objection(this);
		rseq.start(env.toph.seqr);
		 #200;
       phase.drop_objection(this);
	endtask

endclass

