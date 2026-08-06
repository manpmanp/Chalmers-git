module chi_rn_simple
import chi_pkg::*;
(
    input logic clk,
    input logic rst_n,
    
    input logic req_ready_i,
    output logic req_valid,
    output req_flit_t req_o,

    input logic rsp_valid_i,
    input rsp_flit_t rsp_i,

    input logic dat_valid_i,
    input dat_flit_t dat_i
);

