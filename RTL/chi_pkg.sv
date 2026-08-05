package chi_pkg;
/*
*  None of the parameterized fields (e.g., PB or M) can take the value zero.
*  It is since being zero, it means that field has no bit and is non existent, while 
*  in the current typedef of all flits, all fields are kept for reference.
*  In order to have M = 0 (no MPAM bus), define a new req_flit_t without the field MPAM.
*/

localparam string VERSION = "1.0";

// The max number of bytes transferred in each packet
`ifdef CHI_128
    localparam int DW = 128; // Data Width
`elsif CHI_256
    localparam int DW = 256;
`else
    localparam int DW = 512;
`endif 

/* 
*  up to 16-byte (DW = 128) can be contained in a single packet.
*  max coherency data unit in CHI is a 64-byte cache line, so if a transaction
*  cannot be fitted in one packet (128 bit), it'll be numbered using DataID.
*  // 128-bit: bits [5:4] of the effective memory address of any byte in the packet
*  // 256-bit: bit [5] of the effective memory address of any byte in the packet, concatenated with 0b0
*  // 512-bit: always 0b00
*  DataID 128-bit       256-bit       512-bit
*  0b00   Data[127:0]   Data[255:0]   Data[511:0]
*  0b01   Data[255:128] Reserved      Reserved
*  0b10   Data[383:256] Data[511:256] Reserved
*  0b11   Data[511:384] Reserved      Reserved 
*/

localparam int NID_W = 16; // 7'b to 16'b
localparam int RAW = 44; // Req_Addr_Width (RAW)= 44 to 52
localparam int M = 12;    // M = 0 (no MPAM bus)  or M = 12, 15
localparam int PB = 4;   // PB = 0 (no PBHA bus) or PB = 4
localparam int E = 16;    // E = 0 (no MECID bus) or E = 16 (for RME-MEC) 
localparam int R = 16;    // R = 0 (no StreamID bus) or R = 16 
localparam int E_R = (E > R) ? E : R;  // Max(E,R)
localparam int S = 1;    // S = 0 (no SecSID1 bit) or 1 (for RME-CDA)
localparam int Y = 32;    // Y = 0 (no RSVDC bus) or Y = 4, 8, 12, 16, 24, 32 (Width determined by Req_RSVDC_Width)
localparam int SAW = RAW - 3; // 41 to 49
localparam int DC = 0; // DC = 0 or DW/8
localparam int POIS = 0; // POIS = 0 or DW/64

localparam int REQ_FLIT_FIXED_W = 4 + NID_W + NID_W + 12 + NID_W + 1 + 12 + 7 + 1 + 6 + 3 + 1 + 1 + 2 + 4 + 4 + 1 + 8 + 1 + 1 + 2 + 1; // 93 to 120
localparam int RESP_FLIT_FIXED_W = 4 + NID_W + NID_W + 12 + 5 + 2 + 3 + 3 + 3 + 12 + 4 + 2 + 1 + 6; // 71 to 89
localparam int DATA_FLIT_FIXED_W = 4 + NID_W + NID_W + 12 + NID_W + 4 + 2 + 3 + 8 + 1 + 3 + 2 + 2 + 6 + 2 + 1 + 1 + 2 + 1;
localparam int SNP_FLIT_FIXED_W = 4 + NID_W + 12 + NID_W + 12 + 5 + 3 + 1 + 1 + 1;

localparam int REQ_FLIT_W = REQ_FLIT_FIXED_W + RAW + Y + M + PB + S + E_R;
localparam int RESP_FLIT_W = RESP_FLIT_FIXED_W;
localparam int SNP_FLIT_W = SNP_FLIT_FIXED_W + SAW + M + E;
localparam int DATA_FLIT_W = DATA_FLIT_FIXED_W + E + DW/32 + DW/128 + Y + DW/8 + DW + DC + POIS;

typedef struct packed {
    bit [3:0]       qos;           // Quality of Service priority)
    bit [NID_W-1:0] tgt_id;        // target node ID
    bit [NID_W-1:0] src_id;        // souce node ID
    bit [11:0]      txn_id;        // Transaction unique ID 
    bit [NID_W-1:0] req_field_0;        // 2 FUNCs: return_nid / stash_nid = {(NodeID_Width - 7)’b0, DataTarget[6:0]} (in Stash)
    bit             req_field_1;       // 4 FUNCs: stash_nid_valid / endian / deep / prefetch_tgt_hint
    bit [11:0]      return_txn_id; // {6’b0, StashLPIDValid, StashLPID[4:0]} -> {MBZ, Stash Logical Processor ID Valid, Stash Logical Processor ID} 
    bit [6:0]       opcode;        
    bit             multi_req;     
    bit [5:0]       num_req;       // {3’b0, Size} -- DEF: Field determined by the MultiReq value
    bit [RAW-1:0]   addr;          // address of the memory location being accessed
    bit [2:0]       pas;           // Physical Address Space
    bit             likely_shared; // allocation hint for downstream caches
    bit             allow_retry;   
    bit [1:0]       order;         // DEF: ordering for a request with respect to other requests from the same agent
    bit [3:0]       pcrd_type;     // DEF: Protocol Credit Type
    bit [3:0]       mem_attr;      // memory attribute
    bit             req_field_2;       // 2 FUNCs: snp_attr / do_dwt
    bit [7:0]       req_field_3;       // 3 FUNCs: p_group_id / stash_group_id / tag_group_id = {3’b0, LPID[4:0]} 
    bit             req_field_4;       // 3 FUNCs: excl / snoopme / cah -- DEF: (exclusive transaction) / (in atomic) / (CopyAtHome in CopyBack Write)
    bit             exp_compack;   
    bit [1:0]       tag_op;        
    bit             trace_tag;     
    bit [M-1:0]     mpam;          // bus Memory System Resource Partitioning and Monitoring
    bit [PB-1:0]    pbha;          // Page-based Hardware Attributes
    bit [E_R-1:0]   req_field_5;       // 2 FUNCs: MECID / StreamID 
    bit [S-1:0]     sec_sid1;      // Security state of the StreamID
    bit [Y-1:0]     rsvdc;         // Reserved, user defined
} req_flit_t;

typedef struct packed {
    bit [3:0]       qos;
    bit [NID_W-1:0] tgt_id;
    bit [NID_W-1:0] src_id;
    bit [11:0]      txn_id;
    bit [4:0]       opcode;
    bit [1:0]       resp_err;
    bit [2:0]       resp;
    bit [2:0]       resp_field_0; //2 FUNCs: fwd_state (in DCT) / {2’b0, DataPull} 
    bit [2:0]       c_busy; //
    bit [11:0]      dbid; // {4’b0, PGroupID[7:0]} {4’b0, StashGroupID[7:0]} {4’b0, TagGroupID[7:0]} 
    bit [3:0]       pcrd_type;
    bit [1:0]       tag_op;
    bit             trace_tag;
    bit [5:0]       cacheline_id; // Used in multi-request transaction
} rsp_flit_t;

typedef struct packed {
    bit [3:0]       qos;
    bit [NID_W-1:0] src_id;
    bit [11:0]      txn_id;
    bit [NID_W-1:0] fwd_nid; // {(NodeID_Width - 4)’0, PBHA[3:0]}
    bit [11:0]      fwd_txn_id; // 2 FUNCs: {6’b0, StashLPIDValid, StashLPID[4:0]} (in Stash) / {4’b0, VMIDExt[7:0]}  (in DVM)
    bit [4:0]       opcode;
    bit [SAW-1:0]   addr;
    bit [2:0]       pas;
    bit             do_not_go_to_sd;
    bit             ret_to_src;
    bit             trace_tag; 
    bit [M-1:0]     mpam;
    bit [E-1:0]     mec_id;
} snp_flit_t;

typedef struct packed {
    bit [3:0]          qos;
    bit [NID_W-1:0]    tgt_id;
    bit [NID_W-1:0]    src_id;
    bit [11:0]         txn_id;
    bit [NID_W-1:0]    home_nid; // {(NodeID_Width - 5)’b0, MismatchedMECID, PBHA[3:0]}
    bit [3:0]          opcode;
    bit [1:0]          resp_err;
    bit [2:0]          resp;
    bit [7:0]          data_source; // {5’b0, FwdState[2:0]} // Indicates Data source in a response
    bit                data_pull;
    bit [2:0]          c_busy;
    bit [E-1:0]        mec_id; // {4’b0, DBID[11:0]} 
    bit [1:0]          ccid;
    bit [1:0]          data_id;
    bit [5:0]          cacheline_id;
    bit [1:0]          tag_op;
    bit [(DW/32)-1:0]  tag;
    bit [(DW/128)-1:0] tu;
    bit                trace_tag;
    bit                cah;
    bit [1:0]          num_dat;
    bit                replicate;
    bit [Y-1:0]        rsvdc;
    bit [(DW/8)-1:0]   be;
    bit [DW-1:0]       data;
    bit [DC-1:0]       data_check;
    bit [POIS-1:0]     poison; 
} dat_flit_t;

typedef enum bit [6:0] { 
op_reqlcrdreturn                = {1'b0, 6'h00},
op_readshared                   = {1'b0, 6'h01},
op_readclean                    = {1'b0, 6'h02},
op_readonce                     = {1'b0, 6'h03},
op_readnosnp                    = {1'b0, 6'h04},
op_pcrdreturn                   = {1'b0, 6'h05},
 
op_readunique                   = {1'b0, 6'h07},
op_cleanshared                  = {1'b0, 6'h08},
op_cleaninvalid                 = {1'b0, 6'h09},
op_makeinvalid                  = {1'b0, 6'h0a},
op_cleanunique                  = {1'b0, 6'h0b},
op_makeunique                   = {1'b0, 6'h0c},
op_evict                        = {1'b0, 6'h0d},
op_cleaninvalidstorage          = {1'b0, 6'h0e},
 
op_makereadunique               = {1'b1, 6'h01},
op_writeevictorevict            = {1'b1, 6'h02},
op_writeuniquezero              = {1'b1, 6'h03},
op_writenosnpzero               = {1'b1, 6'h04},
 
op_stashoncesepshared           = {1'b1, 6'h07},
op_stashoncesepunique           = {1'b1, 6'h08},
 
op_readpreferunique             = {1'b1, 6'h0c},
op_cleaninvalidpopa             = {1'b1, 6'h0d},
op_writenosnpdef                = {1'b1, 6'h0e},
 
op_readnosnpsep                 = {1'b0, 6'h11},
 
op_cleansharedpersistsep        = {1'b0, 6'h13},       
op_dvmop                        = {1'b0, 6'h14},
op_writeevictfull               = {1'b0, 6'h15},
 
op_writecleanfull               = {1'b0, 6'h17},
op_writeuniqueptl               = {1'b0, 6'h18},
op_writeuniquefull              = {1'b0, 6'h19}, 
op_writebackptl                 = {1'b0, 6'h1a},
op_writebackfull                = {1'b0, 6'h1b},
op_writenosnpptl                = {1'b0, 6'h1c},
op_writenosnpfull               = {1'b0, 6'h1d},
 
op_writenosnpfullcleansh        = {1'b1, 6'h10},       
op_writenosnpfullcleaninv       = {1'b1, 6'h11},        
op_writenosnpfullcleanshpersep  = {1'b1, 6'h12},              
             
op_writeuniquefullcleansh       = {1'b1, 6'h14},                 

op_writeuniquefullcleanshpersep = {1'b1, 6'h16},       
op_writeuniquefullcleaninvstrg  = {1'b1, 6'h17},      
op_writebackfullcleansh         = {1'b1, 6'h18},   
op_writebackfullcleaninv        = {1'b1, 6'h19},   
op_writebackfullcleanshpersep   = {1'b1, 6'h1a},      
op_writebackfullcleaninvstrg    = {1'b1, 6'h1b},           
op_writecleanfullcleansh        = {1'b1, 6'h1c},
 
op_writecleanfullcleanshpersep  = {1'b1, 6'h1e},
 
op_writeuniquefullstash         = {1'b0, 6'h20},           
op_writeuniqueptlstash          = {1'b0, 6'h21},          
op_stashonceshared              = {1'b0, 6'h22},      
op_stashonceunique              = {1'b0, 6'h23},      
op_readoncecleaninvalid         = {1'b0, 6'h24},           
op_readoncemakeinvalid          = {1'b0, 6'h25},          
op_readnotshareddirty           = {1'b0, 6'h26},         
op_cleansharedpersist           = {1'b0, 6'h27},
 
op_atomicstore_add              = {1'b0, 3'b101, 3'b000}, 
op_atomicstore_clr              = {1'b0, 3'b101, 3'b001},
op_atomicstore_eor              = {1'b0, 3'b101, 3'b010},
op_atomicstore_set              = {1'b0, 3'b101, 3'b011},
op_atomicstore_smax             = {1'b0, 3'b101, 3'b100},
op_atomicstore_smin             = {1'b0, 3'b101, 3'b101},
op_atomicstore_umax             = {1'b0, 3'b101, 3'b110},
op_atomicstore_umin             = {1'b0, 3'b101, 3'b111},
 
op_writenosnpptlcleansh         = {1'b1, 6'h20},           
op_writenosnpptlcleaninv        = {1'b1, 6'h21},                                 
op_writenosnpptlcleanshpersep   = {1'b1, 6'h22},                 
                 
op_writeuniqueptlcleansh        = {1'b1, 6'h24},                                 
               
op_writeuniqueptlcleanshpersep  = {1'b1, 6'h26}, 
 
op_atomicload_add               = {1'b0, 3'b110, 3'b000},                    
op_atomicload_clr               = {1'b0, 3'b110, 3'b001},                            
op_atomicload_eor               = {1'b0, 3'b110, 3'b010},                             
op_atomicload_set               = {1'b0, 3'b110, 3'b011},   
op_atomicload_smax              = {1'b0, 3'b110, 3'b100}, 
op_atomicload_smin              = {1'b0, 3'b110, 3'b101}, 
op_atomicload_umax              = {1'b0, 3'b110, 3'b110}, 
op_atomicload_umin              = {1'b0, 3'b110, 3'b111}, 
 
op_atomicswap                   = {1'b0, 6'h38},                                        
op_atomiccompare                = {1'b0, 6'h39},                                            
op_prefetchtgt                  = {1'b0, 6'h3a},                     
 
op_writenosnpptlcleaninvpopa    = {1'b1, 6'h30},                                
op_writenosnpfullcleaninvpopa   = {1'b1, 6'h31},                                   
op_writenosnpfullcleaninvstrg   = {1'b1, 6'h32},                                  
 
op_writebackfullcleaninvpopa    = {1'b1, 6'h39}                                  
} req_opcode_t;

// reserved = {1'b0, 6'h06}, {1'b0, 6'h0f}, {1'b1, 6'h00}, {1'b1, 6'h05}, {1'b1, 6'h06}, {1'b1, 6'h09}, {1'b1, 6'h0a}, {1'b1, 6'h0b}, {1'b1, 6'h0f}, {1'b0, 6'h10},
// {1'b0, 6'h12}, {1'b0, 6'h16}, {1'b0, 6'h1e}, {1'b0, 6'h1f}, {1'b1, 6'h13}, {1'b1, 6'h15}, {1'b1, 6'h1d}, {1'b1, 6'h1f}, {1'b1, 6'h23}, {1'b1, 6'h25}, {1'b1, 6'h27}, {1'b1, 6'h28}, 
// {1'b1, 6'h29}, {1'b1, 6'h2a}, {1'b1, 6'h2b}, {1'b1, 6'h2c}, {1'b1, 6'h2d}, {1'b1, 6'h2e}, {1'b1, 6'h2f}, {1'b0, 6'h3b}, {1'b0, 6'h3c}, {1'b0, 6'h3d}, {1'b0, 6'h3e}, 
// {1'b0, 6'h3f}, {1'b1, 6'h33}, {1'b1, 6'h34}, {1'b1, 6'h35}, {1'b1, 6'h36}, {1'b1, 6'h37},  {1'b1, 6'h38}, {1'b1, 6'h3a}, {1'b1, 6'h3b}, {1'b1, 6'h3c}, {1'b1, 6'h3d}, 
// {1'b1, 6'h3e}, {1'b1, 6'h3f},


endpackage: chi_pkg



module chi_pkg_check;
/*
 * Sanity checks for the CHI package.
 * Verify at elaboration (time 0) that the manually calculated flit widths
 * match the widths computed by $bits() for each packed struct.
 * These checks catch accidental inconsistencies when a field is added,
 * removed, or resized without updating the corresponding width constants.
 */
    import chi_pkg::*;
    initial begin

        assert (REQ_FLIT_W == $bits(req_flit_t))
            else $fatal(1,
                "REQ_FLIT_W mismatch: manual=%0d, struct=%0d",
                REQ_FLIT_W, $bits(req_flit_t));

        assert (RESP_FLIT_W == $bits(rsp_flit_t))
            else $fatal(1,
                "RESP_FLIT_W mismatch: manual=%0d, struct=%0d",
                RESP_FLIT_W, $bits(rsp_flit_t));

        assert (SNP_FLIT_W == $bits(snp_flit_t))
            else $fatal(1,
                "SNP_FLIT_W mismatch: manual=%0d, struct=%0d",
                SNP_FLIT_W, $bits(snp_flit_t));

        assert (DATA_FLIT_W == $bits(dat_flit_t))
            else $fatal(1,
                "DATA_FLIT_W mismatch: manual=%0d, struct=%0d",
                DATA_FLIT_W, $bits(dat_flit_t));

        $display("CHI package consistency checks passed.");

    end

endmodule