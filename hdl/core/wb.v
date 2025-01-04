`include "define.v"

module wb (

    // global clock and async reset
    input wire clk,
    input wire rst_n,

    // pc pass through
    input wire [`PORT_ADDR_WIDTH] wb_pc_i,
    output wire [`PORT_ADDR_WIDTH] wb_pc_o,

    // signals to be transfer from ex to mem to wb
    input wire wb_rd_wr_en_i,
    input wire [`PORT_REG_ADDR_WIDTH] wb_rd_addr_i,
    input wire [`RegBusPort] wb_rd_reg_data_i,
    
    output wire wb_rd_wr_en_o,
    output wire [`PORT_REG_ADDR_WIDTH] wb_rd_addr_o,
    output wire [`RegBusPort] wb_rd_reg_data_o

);

    // Write-back data selection
    assign wb_pc_o = wb_pc_i;
    assign wb_rd_wr_en_o = wb_rd_wr_en_i;
    assign wb_rd_addr_o = wb_rd_addr_i;
    assign wb_rd_reg_data_o = wb_rd_reg_data_i;


endmodule