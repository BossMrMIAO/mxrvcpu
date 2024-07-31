//****************************************************
// id_ex_dff
// function:位于译码单元与执行单元之间，打一拍起到增加流水线级数作用
//****************************************************

module if_id_dff #(
    
) (
    // global clock
    input clk,
    input rst_n,

    // data after inst decode
    input[`OPCODE_WIDTH] opcode_dff_i,
    input[`REG_ADDR_WIDTH] rd_dff_i, rs1_dff_i, rs2_dff_i,
    input[`funct3_WIDTH] funct3_dff_i,
    input[`funct7_WIDTH]  funct7_dff_i,
    // input[`REG_ADDR_WIDTH] shammt_dff_i,
    input[`REG_ADDR_WIDTH] zimm_dff_i,
    input[`PORT_WORD_WIDTH] imm_dff_I,
    
    // data after inst decode
    output[`OPCODE_WIDTH] opcode_dff_o,
    output[`REG_ADDR_WIDTH] rd_dff_o, rs1_dff_o, rs2_dff_o,
    output[`funct3_WIDTH] funct3_dff_o,
    output[`funct7_WIDTH]  funct7_dff_o,
    // output[`REG_ADDR_WIDTH] shammt_dff_o,
    output[`REG_ADDR_WIDTH] zimm_dff_o,
    output[`PORT_WORD_WIDTH] imm_dff_o,


);

    s_bits_dff u_s_bits_dff(bits_width = OPCODE_WIDTH) 
    (.clk(clk),.rst_n(rst_n),.d(opcode_dff_i),.q(opcode_dff_o));

    s_bits_dff u_s_bits_dff(bits_width = REG_ADDR_WIDTH) 
    (.clk(clk),.rst_n(rst_n),.d(rd_dff_i),.q(rd_dff_o));

    s_bits_dff u_s_bits_dff(bits_width = REG_ADDR_WIDTH) 
    (.clk(clk),.rst_n(rst_n),.d(rs1_dff_i),.q(rs1_dff_o));

    s_bits_dff u_s_bits_dff(bits_width = REG_ADDR_WIDTH) 
    (.clk(clk),.rst_n(rst_n),.d(rs2_dff_i),.q(rs2_dff_o));
    
    s_bits_dff u_s_bits_dff(bits_width = funct3_WIDTH) 
    (.clk(clk),.rst_n(rst_n),.d(funct3_dff_i),.q(funct3_dff_o));

    s_bits_dff u_s_bits_dff(bits_width = funct7_WIDTH) 
    (.clk(clk),.rst_n(rst_n),.d(funct7_dff_i),.q(funct7_dff_o));

    s_bits_dff u_s_bits_dff(bits_width = REG_ADDR_WIDTH) 
    (.clk(clk),.rst_n(rst_n),.d(zimm_dff_i),.q(zimm_dff_o));

    s_bits_dff u_s_bits_dff(bits_width = PORT_WORD_WIDTH) 
    (.clk(clk),.rst_n(rst_n),.d(imm_dff_i),.q(imm_dff_o));

endmodule

