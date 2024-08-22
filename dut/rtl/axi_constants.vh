
`ifndef axi_param
`define axi_param
  
    parameter DATA_WIDTH = 32 ;
    parameter ADDR_WIDTH = 32 ;
    parameter ID_WIDTH = 4 ;
    parameter DEPTH = 1024 ;
    parameter LEN_WIDTH = 8 ;
    parameter SIZE_WIDTH = 3 ;
    parameter BURST_WIDTH = 2 ;
    parameter LOCK_WIDTH = 1 ;
    parameter CACHE_WIDTH = 4 ;
    parameter PROT_WIDTH = 3 ;
    parameter QOS_WIDTH = 4 ;
    parameter RESP_WIDTH = 2 ;
    parameter AW_FIFO_WIDTH = ADDR_WIDTH + // 32
                              LEN_WIDTH +  // 8
                              SIZE_WIDTH + // 3
                              BURST_WIDTH +// 2
                              CACHE_WIDTH +// 4
                              PROT_WIDTH + // 3
                              LOCK_WIDTH + // 1
                              QOS_WIDTH +  // 4
                              ID_WIDTH +   // 4
                              7  ;          // Additional bits for Leading zeroes to align with hex concatenation = 68
    parameter W_FIFO_WIDTH = 1 +            // 1
                             (DATA_WIDTH/8) + // 4
                             DATA_WIDTH  ;     // 32 = 37
    parameter AR_FIFO_WIDTH = ADDR_WIDTH +
                              LEN_WIDTH +
                              SIZE_WIDTH +
                              BURST_WIDTH +
                              CACHE_WIDTH +
                              PROT_WIDTH +
                              LOCK_WIDTH +
                              QOS_WIDTH +
                              ID_WIDTH +
                              7           ;   // Additional bits for Leading zeroes to align with hex concatenation = 68
    parameter R_FIFO_WIDTH = DATA_WIDTH +    // 32
                             RESP_WIDTH +    // 2
                             ID_WIDTH +      // 4
                             2             ;  // Additional bits for Leading zeroes to align with hex concatenation = 40
    parameter B_FIFO_WIDTH = RESP_WIDTH +    // 2
                             ID_WIDTH     ;   // 4 = 6
    parameter START_ADDR = 32'h00000000 ;
    parameter END_ADDR = 32'h000003FF ;
	
	`endif //axi_param
