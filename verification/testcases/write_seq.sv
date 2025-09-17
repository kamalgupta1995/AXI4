class write_seq extends uvm_sequence#(seq_item);

seq_item si;


`uvm_object_utils(write_seq)

 function new(string name = "write_seq");

 super.new(name);

    endfunction

    task body();
        
        si=seq_item::type_id::create("si");

           `uvm_do_with(si,{si.transfer==1;si.write_en==1;si.read_en==0;});
           // si.print();
    endtask

endclass

