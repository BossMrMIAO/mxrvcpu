//****************************************************
// ex_mem_dff
// function:位于执行单元与访存单元之间，打一拍起到增加流水线级数作用
//****************************************************

`include "define.v"

module ex_mem_dff (

    // 全局时钟与异步复位
    input clk,
    input rst_n,

    // PC传递
    input[`PORT_ADDR_WIDTH]     ex_mem_dff_pc_i,
    output[`PORT_ADDR_WIDTH]    ex_mem_dff_pc_o,

    // signals to be transfer from ex to mem to wb
    input                          ex_mem_rd_wr_en_i,
    input [`PORT_REG_ADDR_WIDTH]   ex_mem_rd_addr_i,
    input [`RegBusPort]            ex_mem_rd_reg_data_i,
    output                         ex_mem_rd_wr_en_o,
    output [`PORT_REG_ADDR_WIDTH]  ex_mem_rd_addr_o,
    output [`RegBusPort]           ex_mem_rd_reg_data_o,

    // signals to be tranfer from ex to mem, mem write them into memory
    // 读写data_ram
    input                          ex_mem_data_ram_wr_en_i,
    input[`PORT_ADDR_WIDTH]        ex_mem_data_ram_addr_i,
    input[`PORT_DATA_WIDTH]        ex_mem_data_ram_wr_data_i,
    output                         ex_mem_data_ram_wr_en_o,
    output[`PORT_ADDR_WIDTH]       ex_mem_data_ram_addr_o,
    output[`PORT_DATA_WIDTH]       ex_mem_data_ram_wr_data_o,
    
    // 读写inst_rom
    input                          ex_mem_inst_rom_wr_en_i,
    input[`PORT_ADDR_WIDTH]        ex_mem_inst_rom_addr_i,
    input[`PORT_DATA_WIDTH]        ex_mem_inst_rom_wr_data_i,
    output                         ex_mem_inst_rom_wr_en_o,
    output[`PORT_ADDR_WIDTH]       ex_mem_inst_rom_addr_o,
    output[`PORT_DATA_WIDTH]       ex_mem_inst_rom_wr_data_o,

    // 来自ctrl冲刷信号
    input                       ex_mem_dff_pipeline_flush_flag
    
);

    s_bits_dff #(.bits_width(`WORD_WIDTH)) u_s_bits_dff_ex_mem_dff_pc  (
        .clk(clk),.rst_n(rst_n),.flush_flag(ex_mem_dff_pipeline_flush_flag),
        .zero_point({`WORD_WIDTH{1'b0}}),.d(ex_mem_dff_pc_i),.q(ex_mem_dff_pc_o));

    s_bits_dff #(.bits_width(1)) u_s_bits_dff_ex_mem_rd_wr_en  (
        .clk(clk),.rst_n(rst_n),.flush_flag(ex_mem_dff_pipeline_flush_flag),
        .zero_point({1'b0}),.d(ex_mem_rd_wr_en_i),.q(ex_mem_rd_wr_en_o));

    s_bits_dff #(.bits_width(`REG_ADDR_WIDTH)) u_s_bits_dff_ex_mem_rd_addr  (
        .clk(clk),.rst_n(rst_n),.flush_flag(ex_mem_dff_pipeline_flush_flag),
        .zero_point({`REG_ADDR_WIDTH{1'b0}}),.d(ex_mem_rd_addr_i),.q(ex_mem_rd_addr_o));

    s_bits_dff #(.bits_width(`RegBus)) u_s_bits_dff_ex_mem_rd_reg_data  (
        .clk(clk),.rst_n(rst_n),.flush_flag(ex_mem_dff_pipeline_flush_flag),
        .zero_point({`RegBus{1'b0}}),.d(ex_mem_rd_reg_data_i),.q(ex_mem_rd_reg_data_o));

    s_bits_dff #(.bits_width(1)) u_s_bits_dff_ex_mem_data_ram_wr_en  (
        .clk(clk),.rst_n(rst_n),.flush_flag(ex_mem_dff_pipeline_flush_flag),
        .zero_point({1'b0}),.d(ex_mem_data_ram_wr_en_i),.q(ex_mem_data_ram_wr_en_o));

    s_bits_dff #(.bits_width(`WORD_WIDTH)) u_s_bits_dff_ex_mem_data_ram_addr  (
        .clk(clk),.rst_n(rst_n),.flush_flag(ex_mem_dff_pipeline_flush_flag),
        .zero_point({`WORD_WIDTH{1'b0}}),.d(ex_mem_data_ram_addr_i),.q(ex_mem_data_ram_addr_o));

    s_bits_dff #(.bits_width(`WORD_WIDTH)) u_s_bits_dff_ex_mem_data_ram_wr_data  (
        .clk(clk),.rst_n(rst_n),.flush_flag(ex_mem_dff_pipeline_flush_flag),
        .zero_point({`WORD_WIDTH{1'b0}}),.d(ex_mem_data_ram_wr_data_i),.q(ex_mem_data_ram_wr_data_o));

    s_bits_dff #(.bits_width(1)) u_s_bits_dff_ex_mem_inst_rom_wr_en  (
        .clk(clk),.rst_n(rst_n),.flush_flag(ex_mem_dff_pipeline_flush_flag),
        .zero_point({1'b0}),.d(ex_mem_inst_rom_wr_en_i),.q(ex_mem_inst_rom_wr_en_o));

    s_bits_dff #(.bits_width(`WORD_WIDTH)) u_s_bits_dff_ex_mem_inst_rom_addr  (
        .clk(clk),.rst_n(rst_n),.flush_flag(ex_mem_dff_pipeline_flush_flag),
        .zero_point({`WORD_WIDTH{1'b0}}),.d(ex_mem_inst_rom_addr_i),.q(ex_mem_inst_rom_addr_o));

    s_bits_dff #(.bits_width(`WORD_WIDTH)) u_s_bits_dff_ex_mem_inst_rom_wr_data  (
        .clk(clk),.rst_n(rst_n),.flush_flag(ex_mem_dff_pipeline_flush_flag),
        .zero_point({`WORD_WIDTH{1'b0}}),.d(ex_mem_inst_rom_wr_data_i),.q(ex_mem_inst_rom_wr_data_o));

        


    
endmodule
