//Since we are developing separate Master & Slave VIPs, we have separate sequencers
class axi_master_sequencer extends uvm_sequencer#(axi_trans);  
  `uvm_component_utils(axi_master_sequencer)
  
  function new(string name = "axi_master_sequencer",uvm_component parent);
    super.new(name,parent);
  endfunction
      
/* Do not call super.build_phase() from any class that is extended from an UVM base class. For more information see UVM Cookbook v1800.2 p.503 */
 
endclass:axi_master_sequencer
