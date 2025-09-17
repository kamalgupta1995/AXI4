class read_seq extends uvm_sequence#(seq_item);

seq_item si;


`uvm_object_utils(read_seq)

 function new(string name = "read_seq");

 super.new(name);

    endfunction

    task body();
        
        si=seq_item::type_id::create("si");

           `uvm_do_with(si,{si.transfer==1;si.write_en==0;si.read_en==1;});
           // si.print();
    endtask

endclass

