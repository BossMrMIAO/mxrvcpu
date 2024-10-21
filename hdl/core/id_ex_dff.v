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

    // data after inst decode
    input[`PORT_OPCODE_WIDTH]    opcode_dff_i,
    input[`PORT_REG_ADDR_WIDTH]  rd_dff_i, rs1_dff_i, rs2_dff_i,
    input[`PORT_funct3_WIDTH]    funct3_dff_i,
    input[`PORT_funct7_WIDTH]    funct7_dff_i,
    // input[`WORD_WIDTH] shammt_dff_i,
    input[`PORT_WORD_WIDTH]  zimm_dff_i,
    input[`PORT_WORD_WIDTH] imm_dff_i,
    
    // data after inst decode
    output[`PORT_OPCODE_WIDTH]   opcode_dff_o,
    output[`PORT_REG_ADDR_WIDTH] rd_dff_o, rs1_dff_o, rs2_dff_o,
    output[`PORT_funct3_WIDTH]   funct3_dff_o,
    output[`PORT_funct7_WIDTH]  funct7_dff_o,
    // output[`WORD_WIDTH] shammt_dff_o,
    output[`PORT_WORD_WIDTH] zimm_dff_o,
    output[`PORT_WORD_WIDTH] imm_dff_o,

    // reg data source storage
    input[`RegBusPort]  rs1_reg_data_dff_i, rs2_reg_data_dff_i,
    output[`RegBusPort]  rs1_reg_data_dff_o, rs2_reg_data_dff_o


);

    s_bits_dff #(.bits_width(`OPCODE_WIDTH)) u_s_bits_dff_1_0 
    (.clk(clk),.rst_n(rst_n),.d(opcode_dff_i),.q(opcode_dff_o));

    s_bits_dff #(.bits_width(`REG_ADDR_WIDTH)) u_s_bits_dff_1_1 
    (.clk(clk),.rst_n(rst_n),.d(rd_dff_i),.q(rd_dff_o));

    s_bits_dff #(.bits_width(`REG_ADDR_WIDTH)) u_s_bits_dff_1_2
    (.clk(clk),.rst_n(rst_n),.d(rs1_dff_i),.q(rs1_dff_o));

    s_bits_dff #(.bits_width(`REG_ADDR_WIDTH))u_s_bits_dff_1_3
    (.clk(clk),.rst_n(rst_n),.d(rs2_dff_i),.q(rs2_dff_o));
    
    s_bits_dff #(.bits_width(`funct3_WIDTH)) u_s_bits_dff_1_4
    (.clk(clk),.rst_n(rst_n),.d(funct3_dff_i),.q(funct3_dff_o));

    s_bits_dff #(.bits_width(`funct7_WIDTH)) u_s_bits_dff_1_5
    (.clk(clk),.rst_n(rst_n),.d(funct7_dff_i),.q(funct7_dff_o));

    s_bits_dff #(.bits_width(`REG_ADDR_WIDTH)) u_s_bits_dff_1_6
    (.clk(clk),.rst_n(rst_n),.d(zimm_dff_i),.q(zimm_dff_o));

    s_bits_dff #(.bits_width(`WORD_WIDTH)) u_s_bits_dff_1_7
    (.clk(clk),.rst_n(rst_n),.d(imm_dff_i),.q(imm_dff_o));


    s_bits_dff #(.bits_width(`RegBus)) u_s_bits_dff_1_8 
    (.clk(clk),.rst_n(rst_n),.d(rs1_reg_data_dff_i),.q(rs1_reg_data_dff_o));

    s_bits_dff #(.bits_width(`RegBus)) u_s_bits_dff_1_9 
    (.clk(clk),.rst_n(rst_n),.d(rs2_reg_data_dff_i),.q(rs2_reg_data_dff_o));


endmodule

