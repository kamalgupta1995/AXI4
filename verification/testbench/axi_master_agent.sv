

class AXI_master_agent extends uvm_agent;
  `uvm_component_utils( AXI_master_agent) 
  
 // AXI_config m_cfg;        //config DB in case we are using
  
	AXI_master_monitor monh;
  AXI_sequencer seqrh;
  AXI_master_driver drvh;
  
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(AXI_config)::get(this,"","AXI_config",m_cfg))
      `uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db.Have you set() it?") 
      monh=AXI_master_monitor::type_id::create("monh",this); 
   // if(m_cfg.input_agent_is_active==UVM_ACTIVE)  	// this can be used if we are using the config DB
	if(get_is_active()==UVM_ACTIVE) 
      begin
        drvh=AXI_master_driver::type_id::create("drvh",this);
        seqrh= AXI_sequencer ::type_id::create("seqrh",this);
      end
  endfunction
  
  function void connect_phase(uvm_phase phase);
   // if(m_cfg.input_agent_is_active==UVM_ACTIVE)            //this can be used if we are using the config DB
	if(get_is_active()==UVM_ACTIVE) 
      begin
        drvh.seq_item_port.connect(seqrh.seq_item_export); 
      end
  endfunction
endclass :AXI_master_agent
  


