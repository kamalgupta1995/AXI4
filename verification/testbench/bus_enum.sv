//----------------------------------------------
// AXI ENUM USER DEFINED TYPES
// File Name: bus_enum.sv
//----------------------------------------------

`include "uvm_macros.svh" 
import uvm_pkg::*;

typedef enum
{
    AXI_WRITE,		// WRITE
    AXI_READ		// READ
} axi_transaction_cmd;

typedef enum bit[1:0]
{
    AXI_BURST_FIXED = 2'h0,  // FIXED
    AXI_BURST_INCR  = 2'h1,  // INCR
    AXI_BURST_WRAP  = 2'h2   // WRAP
} axi_burst_type; 

typedef enum bit[1:0]
{
    AXI_ALOCK_NOLOCK  = 2'h0,  // NO LOCK
    AXI_ALOCK_EXCL    = 2'h1,  // EXCL
    AXI_ALOCK_LOCKED  = 2'h2   // LOCKED
} axi_lock_type;


typedef enum bit[2:0]
{
    AXI_APROT_DATA_SECURE_NORMAL    = 3'h0, 
    AXI_APROT_DATA_SECURE_PRIV      = 3'h1, 
    AXI_APROT_DATA_NONSECURE_NORMAL = 3'h2, 
    AXI_APROT_DATA_NONSECURE_PRIV   = 3'h3, 
    AXI_APROT_INST_SECURE_NORMAL    = 3'h4, 
    AXI_APROT_INST_SECURE_PRIV      = 3'h5, 
    AXI_APROT_INST_NONSECURE_NORMAL = 3'h6, 
    AXI_APROT_INST_NONSECURE_PRIV   = 3'h7 
} axi_prot_type;

typedef enum bit[1:0]
{
    AXI_RESP_OKAY   = 2'h0,  // OKAY
    AXI_RESP_EXOKAY = 2'h1,  // EXOKAY
    AXI_RESP_SLVERR = 2'h2,  // SLVERR
    AXI_RESP_DECERR = 2'h3   // DECERR
} axi_resp_type; 


typedef enum bit[3:0]
{
    AXI_CACHE_NO_CACHE_NO_BUFFER    = 4'h0, //Noncacheable and nonbufferable
    AXI_CACHE_BUFFER_ONLY           = 4'h1, //Bufferable only
    AXI_CACHE_CACHE_NO_ALLOC        = 4'h2, //Cacheable, but do not allocate
    AXI_CACHE_CACHE_BUFFER_NO_ALLOC = 4'h3, //Cacheable and bufferable, but do not allocate
    AXI_CACHE_CACHE_WT_ALLOC_READ   = 4'h6, //Cacheable write-through, allocate on reads only
    AXI_CACHE_CACHE_WB_ALLOC_READ   = 4'h7, //Cacheable write-back, allocate on reads only
    AXI_CACHE_CACHE_WT_ALLOC_WRITE  = 4'ha, //Cacheable write-through, allocate on writes only
    AXI_CACHE_CACHE_WB_ALLOC_WRITE  = 4'hb, //Cacheable write-back, allocate on writes only
    AXI_CACHE_CACHE_WT_ALLOC_ALL    = 4'he, //Cacheable write-through, allocate on both reads and writes
    AXI_CACHE_CACHE_WB_ALLOC_ALL    = 4'hf  //Cacheable write-back, allocate on both reads and writes
} axi_cache_type;

typedef enum
{
    AXI_AWREADY,   // Three ready type used for AXI INTERCONNECT MASTER PORTS
    AXI_WREADY,
    AXI_ARREADY,
    AXI_BREADY,    // Two ready type used for AXI INTERCONNECT SLAVE PORTS
    AXI_RREADY,
    AXI_ALL_READY
} axi_ready_type;

typedef enum
{
    AXI_BUS_TYPE_WRITE_ADDR,
    AXI_BUS_TYPE_WRITE_DATA,
    AXI_BUS_TYPE_WRITE_RESP,
    AXI_BUS_TYPE_READ_ADDR,
    AXI_BUS_TYPE_READ_DATA
    
} axi_bus_type;




