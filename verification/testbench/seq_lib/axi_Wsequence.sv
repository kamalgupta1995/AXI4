//////////////////////////////////////////////////////////
////////////////////write sequence///////////////////////
/////////////////////////////////////////////////////////
class axi_Wsequence extends uvm_sequence#(axi_trans);
 
  `uvm_object_utils(axi_Wsequence)
  axi_trans req; 
  // int no_of_transactions;
  
  function new(string name = "axi_Wsequence");
    super.new(name);
  endfunction 
  
  task body(); 
   // repeat(4)
      begin 
       req=axi_trans::type_id::create("req");
       start_item(req);
        assert(req.randomize () with {req.tr_cmd == AXI_WRITE;req.awburst ==  AXI_BURST_INCR ;req.AWLEN == 0 ; req.AWADDR == 32'h0 ;});
       finish_item(req);
      end    
  endtask  
endclass

