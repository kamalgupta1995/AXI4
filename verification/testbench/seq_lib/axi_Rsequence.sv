class axi_Rsequence extends uvm_sequence#(axi_trans);
 
  `uvm_object_utils(axi_Rsequence)
  axi_trans trans; 
  // int no_of_transactions;

  //bit[6:0] count;
  
  function new(string name = "axi_Rsequence");
    super.new(name);
  endfunction 
   
    task body(); 
      //repeat(2)
      begin
        
        `uvm_do_with(req,{req.AWADDR == 48'h0000_0000_0000;req.tr_cmd == AXI_WRITE; req.AWLEN == 0; req. awburst == 1'b0;})
        
        `uvm_do_with(req,{req.ARADDR == 48'h0000_0000_0000;req.tr_cmd == AXI_READ; req.ARLEN == 0;req. arburst == 1'b0;})
      end
        
  endtask 
endclass
