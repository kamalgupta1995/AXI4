class R_sequence extends uvm_sequence#(seq_item);

seq_item seh;


`uvm_object_utils(R_sequence)

 function new(string name = "R_sequence");

 super.new(name);

    endfunction

    task body();
        
        seh=seq_item::type_id::create("seh");
        repeat(2)

           `uvm_do_with(seh,{seh.transfer==1;seh.write_en==0;seh.read_en==1;});
           
           // si.print();
    endtask

endclass

/*
class axi_Rsequence extends uvm_sequence#(axi_trans);
 
  `uvm_object_utils(axi_Rsequence)
  axi_trans req; 
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
endclass*/
