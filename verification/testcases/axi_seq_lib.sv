
class axi_Rsequence extends uvm_sequence#(axi_trans);
 
  `uvm_object_utils(axi_Rsequence)
  axi_trans trans; 
  // int no_of_transactions;

  //bit[6:0] count;
  
  function new(string name = "axi_Rsequence");
    super.new(name);
  endfunction 
  
  task body(); 
   // repeat(5)
      begin
       
        req=axi_trans::type_id::create("req");
       start_item(req);
        assert(req.randomize () with {req.tr_cmd == AXI_READ;});
        // `uvm_do_with(req,{req.addr == 48'h0000_0000_0000;req.tr_cmd == AXI_READ; req.id == 0;})
       finish_item(req);
      end    
  endtask  
endclass

//////////////////////////////////////////////////////////////
//////////////  multiple ---unaligned single transfer//////////////////////
//////////////////////////////////////////////////////////////

/*
class axi_mul_unalignedsequence extends uvm_sequence#(axi_trans);
 
  `uvm_object_utils(axi_mul_unalignedsequence)
  axi_trans trans; 
  // int no_of_transactions;

  //bit[6:0] count;
  
  function new(string name = "axi_mul_unalignedsequence");
    super.new(name);
  endfunction 
  
  task body(); 
    repeat(5)
      begin
       
       req=axi_trans::type_id::create("req");
       start_item(req);
        assert(req.randomize() with { req.AWADDR == 48'h000000000012;});
       finish_item(req);
      end    
  endtask  
endclass

*/
/////////////////////////////////////////////////////////////
//////////////single--- unaligned transfer///////////////////
////////////////////////////////////////////////////////////
/*
class axi_unalignedsequence extends uvm_sequence#(axi_trans);
 
  `uvm_object_utils(axi_unalignedsequence)
  axi_trans trans; 
  // int no_of_transactions;

  //bit[6:0] count;
  
  function new(string name = "axi_unalignedsequence");
    super.new(name);
  endfunction 
  
  task body(); 
  
      begin
      
       req=axi_trans::type_id::create("req");
       start_item(req);
        assert(req.randomize () with { req.AWADDR == 48'h000000000012});
       finish_item(req);
      end    
  endtask  
endclass

*/
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
   // repeat(5)
      begin
       
       req=axi_trans::type_id::create("req");
       start_item(req);
        assert(req.randomize () with {req.tr_cmd == AXI_WRITE;});
       finish_item(req);
      end    
  endtask  
endclass

//////////////////////////////////////////////////////////
////////////////////FIXED sequence //////////////////////
/////////////////////////////////////////////////////////

/*
class axi_FIXEDB_sequence extends uvm_sequence#(axi_trans);
 
  `uvm_object_utils(axi_FIXEDB_sequence)
  axi_trans trans; 
  // int no_of_transactions;
  
  function new(string name = "axi_FIXEDB_sequence");
    super.new(name);
  endfunction 
  
  task body(); 
      begin
        `uvm_do_with(req,{req.addr == 48'h0000_0000_0000;req.tr_cmd == AXI_WRITE; req.awburst == AXI_BURST_FIXED ;})
      end    
  endtask  
endclass

///////////////////////////////////////////////////////////
//////////////////////Increment burst//////////////////////
///////////////////////////////////////////////////////////

class axi_INCRB_sequence extends uvm_sequence#(axi_trans);
 
  `uvm_object_utils(axi_INCRB_sequence)
  axi_trans trans; 
  // int no_of_transactions;
  
  function new(string name = "axi_INCRB_sequence");
    super.new(name);
  endfunction 
  
  task body(); 
      begin
        `uvm_do_with(req,{req.addr == 48'h0000_0000_0000;req.tr_cmd == AXI_WRITE; req.awburst == AXI_BURST_INCR ;})
      end    
  endtask  
endclass

////////////////////////////////////////////////////////////////////
///////////////////////////WRAP BURST///////////////////////////////
////////////////////////////////////////////////////////////////////



class axi_WRAPB_sequence extends uvm_sequence#(axi_trans);
 
  `uvm_object_utils(axi_WRAPB_sequence)
  axi_trans trans; 
  // int no_of_transactions;
  
  function new(string name = "axi_WRAPB_sequence");
    super.new(name);
  endfunction 
  
  task body(); 
      begin
        `uvm_do_with(req,{req.addr == 48'h0000_0000_0000;req.tr_cmd == AXI_WRITE; req.awburst == AXI_BURST_WRAP ;})
      end    
  endtask  
endclass

////////////////////////////////////////////////
*/
