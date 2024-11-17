//****************************************************
// id_ex_dff
// function:位于译码单元与执行单元之间，打一拍起到增加流水线级数作用
//****************************************************

`include "define.v"

module id_ex_dff #(
    
) (
    // global clock
    input clk,
    input rst_n,

    // pc_pass
    input[`PORT_ADDR_WIDTH]         id_ex_dff_pc_i,
    output[`PORT_ADDR_WIDTH]        id_ex_dff_pc_o,


    // data after inst decode
    input[`PORT_OPCODE_WIDTH]       id_ex_dff_opcode_i,
    input[`PORT_REG_ADDR_WIDTH]     id_ex_dff_rd_i, id_ex_dff_rs1_i, id_ex_dff_rs2_i,
    input[`PORT_funct3_WIDTH]       id_ex_dff_funct3_i,
    input[`PORT_funct7_WIDTH]       id_ex_dff_funct7_i,
    input[`PORT_REG_ADDR_WIDTH]     id_ex_dff_shamt_i,
    input[`PORT_WORD_WIDTH]         id_ex_dff_zimm_i,
    input[`PORT_WORD_WIDTH]         id_ex_dff_imm_i,
    
    // data after inst decode
    output[`PORT_OPCODE_WIDTH]      id_ex_dff_opcode_o,
    output[`PORT_REG_ADDR_WIDTH]    id_ex_dff_rd_o, id_ex_dff_rs1_o, id_ex_dff_rs2_o,
    output[`PORT_funct3_WIDTH]      id_ex_dff_funct3_o,
    output[`PORT_funct7_WIDTH]      id_ex_dff_funct7_o,
    output[`PORT_REG_ADDR_WIDTH]    id_ex_dff_shamt_o,
    output[`PORT_WORD_WIDTH]        id_ex_dff_zimm_o,
    output[`PORT_WORD_WIDTH]        id_ex_dff_imm_o,

    // reg data source storage
    input[`RegBusPort]              id_ex_dff_rs1_reg_data_i, id_ex_dff_rs2_reg_data_i,
    output[`RegBusPort]             id_ex_dff_rs1_reg_data_o, id_ex_dff_rs2_reg_data_o,

    // 来自ctrl冲刷信号
    input                           id_ex_dff_pipeline_flush_flag


);

    s_bits_dff #(.bits_width(`OPCODE_WIDTH)) u_s_bits_dff_1_0 
    (.clk(clk),.rst_n(rst_n),.flush_flag(id_ex_dff_pipeline_flush_flag),
    .zero_point({`OPCODE_WIDTH{1'b0}}),.d(id_ex_dff_opcode_i),.q(id_ex_dff_opcode_o));

    s_bits_dff #(.bits_width(`REG_ADDR_WIDTH)) u_s_bits_dff_1_1 
    (.clk(clk),.rst_n(rst_n),.flush_flag(id_ex_dff_pipeline_flush_flag),
    .zero_point({`REG_ADDR_WIDTH{1'b0}}),.d(id_ex_dff_rd_i),.q(id_ex_dff_rd_o));

    s_bits_dff #(.bits_width(`REG_ADDR_WIDTH)) u_s_bits_dff_1_2
    (.clk(clk),.rst_n(rst_n),.flush_flag(id_ex_dff_pipeline_flush_flag),
    .zero_point({`REG_ADDR_WIDTH{1'b0}}),.d(id_ex_dff_rs1_i),.q(id_ex_dff_rs1_o));

    s_bits_dff #(.bits_width(`REG_ADDR_WIDTH))u_s_bits_dff_1_3
    (.clk(clk),.rst_n(rst_n),.flush_flag(id_ex_dff_pipeline_flush_flag),
    .zero_point({`REG_ADDR_WIDTH{1'b0}}),.d(id_ex_dff_rs2_i),.q(id_ex_dff_rs2_o));
    
    s_bits_dff #(.bits_width(`funct3_WIDTH)) u_s_bits_dff_1_4
    (.clk(clk),.rst_n(rst_n),.flush_flag(id_ex_dff_pipeline_flush_flag),
    .zero_point({`funct3_WIDTH{1'b0}}),.d(id_ex_dff_funct3_i),.q(id_ex_dff_funct3_o));

    s_bits_dff #(.bits_width(`funct7_WIDTH)) u_s_bits_dff_1_5
    (.clk(clk),.rst_n(rst_n),.flush_flag(id_ex_dff_pipeline_flush_flag),
    .zero_point({`funct7_WIDTH{1'b0}}),.d(id_ex_dff_funct7_i),.q(id_ex_dff_funct7_o));

    s_bits_dff #(.bits_width(`REG_ADDR_WIDTH)) u_s_bits_dff_1_6 
    (.clk(clk),.rst_n(rst_n),.flush_flag(id_ex_dff_pipeline_flush_flag),
    .zero_point({`REG_ADDR_WIDTH{1'b0}}),.d(id_ex_dff_shamt_i),.q(id_ex_dff_shamt_o));

    s_bits_dff #(.bits_width(`REG_ADDR_WIDTH)) u_s_bits_dff_1_7
    (.clk(clk),.rst_n(rst_n),.flush_flag(id_ex_dff_pipeline_flush_flag),
    .zero_point({`REG_ADDR_WIDTH{1'b0}}),.d(id_ex_dff_zimm_i),.q(id_ex_dff_zimm_o));

    s_bits_dff #(.bits_width(`WORD_WIDTH)) u_s_bits_dff_1_8
    (.clk(clk),.rst_n(rst_n),.flush_flag(id_ex_dff_pipeline_flush_flag),
    .zero_point({`WORD_WIDTH{1'b0}}),.d(id_ex_dff_imm_i),.q(id_ex_dff_imm_o));

    s_bits_dff #(.bits_width(`RegBus)) u_s_bits_dff_1_9
    (.clk(clk),.rst_n(rst_n),.flush_flag(id_ex_dff_pipeline_flush_flag),
    .zero_point({`RegBus{1'b0}}),.d(id_ex_dff_rs1_reg_data_i),.q(id_ex_dff_rs1_reg_data_o));

    s_bits_dff #(.bits_width(`RegBus)) u_s_bits_dff_1_10
    (.clk(clk),.rst_n(rst_n),.flush_flag(id_ex_dff_pipeline_flush_flag),
    .zero_point({`RegBus{1'b0}}),.d(id_ex_dff_rs2_reg_data_i),.q(id_ex_dff_rs2_reg_data_o));

    s_bits_dff #(.bits_width(`RegBus)) u_s_bits_dff_1_11
    (.clk(clk),.rst_n(rst_n),.flush_flag(id_ex_dff_pipeline_flush_flag),
    .zero_point({`RegBus{1'b0}}),.d(id_ex_dff_pc_i),.q(id_ex_dff_pc_o));


endmodule

