
  
    `define DATA_WIDTH  32 
    `define ADDR_WIDTH  32 
    `define ID_WIDTH  4 
    `define DEPTH  1024 
    `define LEN_WIDTH  8 
    `define SIZE_WIDTH  3 
    `define BURST_WIDTH  2 
    `define LOCK_WIDTH  1 
    `define CACHE_WIDTH 4 
    `define PROT_WIDTH  3 
    `define QOS_WIDTH  4 
    `define RESP_WIDTH  2 
    `define AW_FIFO_WIDTH   (`ADDR_WIDTH + `LEN_WIDTH + `SIZE_WIDTH + `BURST_WIDTH + `CACHE_WIDTH + `PROT_WIDTH + `LOCK_WIDTH + `QOS_WIDTH +  `ID_WIDTH + 7  )         
    `define W_FIFO_WIDTH  (1 + (`DATA_WIDTH/8) + `DATA_WIDTH )      
    `define AR_FIFO_WIDTH   ( `ADDR_WIDTH + `LEN_WIDTH + `SIZE_WIDTH + `BURST_WIDTH + `CACHE_WIDTH + `PROT_WIDTH +`LOCK_WIDTH +`QOS_WIDTH +`ID_WIDTH + 7 )       
    `define R_FIFO_WIDTH  ( `DATA_WIDTH + `RESP_WIDTH + `ID_WIDTH + 2 )
    `define B_FIFO_WIDTH  (`RESP_WIDTH + `ID_WIDTH )
    `define START_ADDR  32'h00000000 
    `define END_ADDR  32'h000003FF 
	
