


class axi_scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(axi_scoreboard)
  
  axi_trans trans;
  axi_trans axi_ds[$];   // master driver
  axi_trans axi_ms[$];   //  slave monitor
  axi_trans axi_sd[$];         // slave driver
  axi_trans axi_mm[$];         // master monitor
  
  `uvm_analysis_imp_decl(_masterD)  // master driver
  `uvm_analysis_imp_decl(_slaveM)  // slave monitor
  `uvm_analysis_imp_decl(_slaveD)  // slave driver
  `uvm_analysis_imp_decl(_masterM)  // master monitor
  
  
  uvm_analysis_imp_masterD#(axi_trans,axi_scoreboard) w_in;
  uvm_analysis_imp_slaveM#(axi_trans,axi_scoreboard) w_out;
  uvm_analysis_imp_slaveD#(axi_trans,axi_scoreboard) R_in;
  uvm_analysis_imp_masterM#(axi_trans,axi_scoreboard) R_out;
  
  
  event WRITE_IN,WRITE_OUT,READ_IN,READ_OUT;
  int w_count=0;
  
  
  function new(string name,uvm_component parent);
 super.new(name,parent);
endfunction
  
  
  virtual function void build_phase (uvm_phase phase);  
    super.build_phase(phase);  
    w_in = new("w_in",this); 
    w_out=new("w_out",this); 
    R_in = new("R_in",this); 
    R_out=new("R_out",this);
  endfunction

  
    function void write_masterD(axi_trans trans_in);    
      `uvm_info(get_name,"received pkt from master --driver ",UVM_LOW)
     // trans_in.print();
      w_count++;
      axi_ds.push_back(trans_in);
      ->WRITE_IN;
    endfunction
              
    function void write_slaveM (axi_trans trans_out);
      `uvm_info(get_name,"received pkt from slave monitor",UVM_LOW)
      //trans_out.print();
      w_count++;
      axi_ms.push_back(trans_out);
      ->WRITE_OUT;
    endfunction
  
  /// READ FUNCTIONS ////////
  
    function void write_masterM(axi_trans trans_in);    
      `uvm_info(get_name,"received pkt from master monitor ",UVM_LOW)
      //trans_in.print();
      axi_mm.push_back(trans_in);
      ->READ_IN;
    endfunction
              
    function void write_slaveD (axi_trans trans_out);
      `uvm_info(get_name,"received pkt from slave driver",UVM_LOW)
      //trans_out.print();
      axi_sd.push_back(trans_out);
      ->READ_OUT;
    endfunction
  
  
  
  
  task run_phase(uvm_phase phase);
    forever
    fork 
      compare();
    join
  endtask
  
  
  /// waiting for event
  task wait_for_Wevent();  
      fork
   // $display("events got triggered");
    @WRITE_IN;
    @WRITE_OUT;
      join
    compare_packet();
  endtask
  
  task wait_for_Revent(); 
    fork
   // $display("events got triggered");
    @READ_IN;
    @READ_OUT;
      join
    compare_R_packet();
  endtask
  
  task compare();
    forever
      fork
        //if(w_count>1)        // if i  remove this w_count it is working properly
         // begin
   wait_for_Wevent();
       //end
       wait_for_Revent();
    
   // $display("---3---");
      join
  endtask
  
  
  task compare_packet();
    
    axi_trans pkt1;
    axi_trans pkt2;   
   // axi_trans pkt_r1;
    //axi_trans pkt_r2;
    
    pkt1=axi_ds.pop_front();
    pkt2=axi_ms.pop_front();
    
   // pkt1=new();
    //pkt2=new();
    //pkt_r1=new();
   // pkt_r2=new();
  
    
     //pkt_r1=axi_sd.pop_front();
   // pkt_r2=axi_mm.pop_front();
    
    //begin
    
   // $display("-------------inside compare packets-----------");
    if(pkt1.tr_cmd == AXI_WRITE)
      begin
        if(pkt1.WDATA != pkt2.WDATA) begin
      `uvm_error(get_name,"data mismatch")
          for (int i=0;i<(pkt1.AWLEN+1);i++) begin
      //`uvm_info(get_name,$sformatf("DATA MATCHED ----pkt1data==%0h--pkt2data-==%0h"pkt1.WDATA,pkt2.WDATA),UVM_LOW)
            `uvm_error("NOC_SCOREBOARD",$sformatf("  WRITE DATA BYTE NOT MATCHED : pkt1= %0p  pkt2= %0p",pkt1.WDATA[i],pkt2.WDATA[i]))
      end
        end
    else begin
     // $display(" size value =%0d",pkt1.AWSIZE);
      for (int i=0;i<(pkt1.AWLEN+1);i++) begin
      //`uvm_info(get_name,$sformatf("DATA MATCHED ----pkt1data==%0h--pkt2data-==%0h"pkt1.WDATA,pkt2.WDATA),UVM_LOW)
      `uvm_info("NOC_SCOREBOARD",$sformatf("  WRITE DATA BYTE MATCHED : pkt1= %0p  pkt2= %0p",pkt1.WDATA[i],pkt2.WDATA[i]),UVM_LOW)
      end

    end
      end
//     else if(pkt_r1.tr_cmd ==AXI_READ) 
//       begin
//         if(pkt_r1.RDATA != pkt_r2.RDATA)
//       `uvm_error(get_name,"data mismatch")
//     else begin
//       for (int i=0;i<(2**pkt_r1.ARSIZE);i++) begin
//           //`uvm_info(get_name,$sformatf("DATA MATCHED ----pkt1data==%0h--pkt2data-==%0h"pkt_r1.RDATA,pkt_r2.RDATA),UVM_LOW)
//         `uvm_info("NOC_SCOREBOARD",$sformatf("  READ DATA BYTE MATCHED : pkt1= %0p  pkt2= %0p",pkt_r1.RDATA[i],pkt_r2.RDATA[i]),UVM_LOW)
//       end

//     end
     // end
  endtask
        
  
  task compare_R_packet();
    axi_trans pkt_r1;
    axi_trans pkt_r2;
    
    pkt_r1=axi_sd.pop_front();
    pkt_r2=axi_mm.pop_front();
          if(pkt_r1.tr_cmd ==AXI_READ) 
      begin
        if(pkt_r1.RDATA != pkt_r2.RDATA) begin
          `uvm_error(get_name," READ ---data mismatch--")
          for (int i=0;i<(pkt_r1.ARLEN+1);i++) begin
             `uvm_error("NOC_SCOREBOARD",$sformatf("  READ DATA BYTE MIS-MATCHED : pkt1= %0p  pkt2= %0p",pkt_r1.RDATA[i],pkt_r2.RDATA[i]))
      end
        end
          
    else begin
      for (int i=0;i<(pkt_r1.ARLEN+1);i++) begin
       // $display("ARLEN----%0d",pkt_r1.ARLEN);
          //`uvm_info(get_name,$sformatf("DATA MATCHED ----pkt1data==%0h--pkt2data-==%0h"pkt_r1.RDATA,pkt_r2.RDATA),UVM_LOW)
        `uvm_info("NOC_SCOREBOARD",$sformatf("  READ DATA BYTE MATCHED : pkt1= %0p  pkt2= %0p",pkt_r1.RDATA[i],pkt_r2.RDATA[i]),UVM_LOW)
      end

    end
     end
  endtask
           
              
 endclass:axi_scoreboard
                
