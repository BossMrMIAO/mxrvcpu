//****************************************************
// ex_mem_dff
// function:位于执行单元与访存单元之间，打一拍起到增加流水线级数作用
//****************************************************

`include "define.v"

module mem_wb_dff (

    // 全局时钟与异步复位
    input clk,
    input rst_n,

    // PC传递
    input[`PORT_ADDR_WIDTH]     mem_wb_dff_pc_i,
    output[`PORT_ADDR_WIDTH]    mem_wb_dff_pc_o,

    // signals to be transfer from ex to mem to wb
    input                          mem_wb_rd_wr_en_i,
    input [`PORT_REG_ADDR_WIDTH]   mem_wb_rd_addr_i,
    input [`RegBusPort]            mem_wb_rd_reg_data_i,
    output                         mem_wb_rd_wr_en_o,
    output [`PORT_REG_ADDR_WIDTH]  mem_wb_rd_addr_o,
    output [`RegBusPort]           mem_wb_rd_reg_data_o,

    // 来自ctrl冲刷信号
    input                       mem_wb_dff_pipeline_flush_flag
    
);

    s_bits_dff #(.bits_width(`WORD_WIDTH)) u_s_bits_dff_mem_wb_dff_pc  (
        .clk(clk),.rst_n(rst_n),.flush_flag(mem_wb_dff_pipeline_flush_flag),
        .zero_point({`WORD_WIDTH{1'b0}}),.d(mem_wb_dff_pc_i),.q(mem_wb_dff_pc_o));

    s_bits_dff #(.bits_width(1)) u_s_bits_dff_mem_wb_rd_wr_en  (
        .clk(clk),.rst_n(rst_n),.flush_flag(mem_wb_dff_pipeline_flush_flag),
        .zero_point({1{1'b0}}),.d(ifu_id_dff_inst_data_i),.q(ifu_id_dff_inst_data_o));

    s_bits_dff #(.bits_width(`REG_ADDR_WIDTH)) u_s_bits_dff_mem_wb_rd_addr  (
        .clk(clk),.rst_n(rst_n),.flush_flag(mem_wb_dff_pipeline_flush_flag),
        .zero_point({`REG_ADDR_WIDTH{1'b0}}),.d(mem_wb_rd_addr_i),.q(mem_wb_rd_addr_o));

    s_bits_dff #(.bits_width(`RegBus)) u_s_bits_dff_mem_wb_rd_reg_data  (
        .clk(clk),.rst_n(rst_n),.flush_flag(mem_wb_dff_pipeline_flush_flag),
        .zero_point({`RegBus{1'b0}}),.d(mem_wb_rd_reg_data_i),.q(mem_wb_rd_reg_data_o));

    
    
endmodule
