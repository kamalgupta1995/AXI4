class AXI4_sequencer uvm_sequencer#(seq_item);
  
  `uvm_component_utils(AXI4_sequencer)
  
  function new(string name = "sequencer",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  // BUILD PHASE
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_report_info("SEQUENCER","MSG FROM SEQUENCER",UVM_NONE);
  endfunction`
  
endclass:AXI4_sequencer