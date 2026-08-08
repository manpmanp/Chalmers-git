module chi_link
import chi_pkg::*;
(
    input logic clk,
    input logic rst_n,

    //---------------
    // upstream
    //---------------
    chi_iface_req.tx up_req,
    chi_iface_rsp.tx up_rsp,
    chi_iface_snp.tx up_snp,
    chi_iface_dat.tx up_dat,

    //---------------
    // downstream
    //---------------
    chi_iface_req.rx down_req,
    chi_iface_rsp.rx down_rsp,
    chi_iface_snp.rx down_snp,
    chi_iface_dat.rx down_dat
);

endmodule