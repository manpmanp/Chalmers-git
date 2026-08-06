//====================================================
// CHI Interface REQ
//====================================================
interface chi_iface_req;
import chi_pkg::*;

    req_flit_t req_flit;
    logic req_valid;
    logic req_lcrd_valid; //lcrd = link credit

    modport rx (
        // REQ
        input  req_flit,
        input  req_valid,
        output req_lcrd_valid
    );

    modport tx (
        // REQ
        output req_flit,
        output req_valid,
        input  req_lcrd_valid
    );

endinterface //chi_iface_req

//====================================================
// CHI Interface RSP
//====================================================
interface chi_iface_rsp;
import chi_pkg::*;

    rsp_flit_t rsp_flit;
    logic rsp_valid;
    logic rsp_lcrd_valid;

    modport rx (
        input  rsp_flit,
        input  rsp_valid,
        output rsp_lcrd_valid
    );

   modport tx (
        output rsp_flit,
        output rsp_valid,
        input  rsp_lcrd_valid
    );

endinterface //chi_iface_rsp

//====================================================
// CHI Interface SNP
//====================================================
interface chi_iface_snp;
import chi_pkg::*;
    
    snp_flit_t snp_flit;
    logic snp_valid;
    logic snp_lcrd_valid;

    modport rx (
        input  snp_flit,
        input  snp_valid,
        output snp_lcrd_valid
    );

    modport tx (
        output  snp_flit,
        output  snp_valid,
        input   snp_lcrd_valid
    );

endinterface //chi_iface_snp

//====================================================
// CHI Interface DAT
//====================================================
interface chi_iface_dat;
import chi_pkg::*;
    
    dat_flit_t dat_flit;
    logic dat_valid;
    logic dat_lcrd_valid;

    modport rx (
        input  dat_flit,
        input  dat_valid,
        output dat_lcrd_valid
    );

    modport tx (
        output dat_flit,
        output dat_valid,
        input  dat_lcrd_valid
    );

endinterface //chi_iface_dat