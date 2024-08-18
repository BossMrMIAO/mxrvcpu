/*
soc_top

Integrate all component of pipeline SOC, from left to right

PC_REG, 

*/


module soc_core_top (
    input   clk,
    input   rst_n
);

// connection wires between different component
    reg[`RegBus] pc;

    wire inst_valid;
    wire[`RegBus] inst_data;
    wire pc_send_valid;
    wire pc_receive_ready;

    wire[`PORT_WORD_WIDTH] pc_ifu;
    wire inst_ifu_valid;
    wire[`PORT_WORD_WIDTH] inst_data_ifu_dff_bef, inst_data_ifu_dff_aft;
    


    wire[`OPCODE_WIDTH] opcode;
    wire[`REG_ADDR_WIDTH] rd;
    wire[`funct3_WIDTH] funct3;
    wire[`REG_ADDR_WIDTH]   rs1,rs2;
    wire[`funct7_WIDTH] fucnt7;
    wire[`REG_ADDR_WIDTH] shamt;
    wire    L_or_A_flag;
    wire[`REG_ADDR_WIDTH] zimm;
    wire[`PORT_WORD_WIDTH]  imm;

    wire[`RegBus] rs1_reg_data,rs2_reg_data;
    wire[`RegBus] rd_wr_en,rd_reg_data;
    wire Hold_flag,div_busy;

   
    wire[`RegBus] rs1_addr, rs2_addr;   
    wire rs1_req_rd_valid, rs2_req_rd_valid;
    wire[`RegBus] rs1_reg_data, rs2_reg_data;
    wire[`RegBus] rd_addr, rd_data;
    wire rd_req_wr_valid;

// initialize all component

    // instance pc_reg
    pc_reg u_pc_reg (
        .clk(clk),
        .rst_n(rst_n),
        .pc_o(pc)
    );

    rom u_rom (
        .clk(clk),
        .rst_n(rst_n),
        .pc_i(pc),
        .pc_send_valid_i(pc_send_valid),
        .pc_receive_ready_o(pc_receive_ready),
        .inst_data_o(inst_data),
        .inst_valid_o(inst_valid)
    );


    ifu u_ifu (
        .clk(clk),
        .rst_n(rst_n),
        .pc_i(pc),
        .inst_valid_i(inst_valid),
        .inst_data_i(inst_data),
        .pc_send_valid_o(pc_send_valid),
        .pc_receive_ready_i(pc_receive_ready),
        .pc_ifu_o(pc_ifu),
        .inst_ifu_valid_o(inst_ifu_valid),
        .inst_data_ifu_o(inst_data_ifu_dff_bef)
    );

    if_id_dff u_if_id_dff (
        .clk(clk),
        .rst_n(rst_n),
        .inst_data_dff_i(inst_data_ifu_dff_bef),
        .inst_data_dff_O(inst_data_ifu_dff_aft)
    );


    // instance id
    id u_id (
        .inst_data_i(inst_data_ifu_dff_aft),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7),
        .shamt(shamt),
        .L_or_A_flag(L_or_A_flag),
        .zimm(zimm),
        .imm(imm),
        .rs1_req_rd_valid_o(rs1_req_rd_valid),
        .rs2_req_rd_valid_o(rs2_req_rd_valid)
    );


    id_ex_dff u_id_ex_dff (
        .clk(clk),
        .rst_n(rst_n),

        // data after inst decode
        .opcode_dff_i(opcode_dff_bef),
        .rd_dff_i(rd_dff_bef), 
        .rs1_dff_i(rs1_dff_bef), 
        .rs2_dff_i(rs2_dff_bef),
        .funct3_dff_i(funct3_dff_bef),
        .funct7_dff_i(funct7_dff_bef),
        // input[`REG_ADDR_WIDTH] shammt_dff_i,
        .zimm_dff_i(zimm_dff_bef),
        .imm_dff_i(imm_dff_bef),
        
        // data after inst decode
        .opcode_dff_o(opcode_dff_aft),
        .rd_dff_o(rd_dff_aft), 
        .rs1_dff_o(rs1_dff_aft), 
        .rs2_dff_o(rs2_dff_aft),
        .funct3_dff_o(funct3_dff_aft),
        .funct7_dff_o(funct7_dff_aft),
        // output[`REG_ADDR_WIDTH] shammt_dff_o,
        .zimm_dff_o(zimm_dff_aft),
        .imm_dff_o(imm_dff_aft)
    )

    // instance ex
    ex u_ex (
        .clk(clk),
        .rst_n(rst_n),
        .opcode_i(opcode_dff_aft),
        .rd_i(rd_dff_aft),
        .funct3_i(funct3_dff_aft),
        .rs1_i(rs1_dff_aft),
        .rs2_i(rs2_dff_aft),
        .funct7_i(funct7_dff_aft),
        .shamt_i(shamt),
        .L_or_A_flag_i(L_or_A_flag),
        .zimm_i(zimm_dff_aft),
        .imm_i(imm_dff_aft),
        .rs1_reg_data_i(rs1_reg_data),
        .rs2_reg_data_i(rs2_reg_data),
        .rd_wr_en_o(rd_wr_en),
        .rd_reg_data_o(rd_reg_data),
        .Hold_flag_i(Hold_flag),
        .div_busy_i(div_busy)
    );

    regu u_regu (
        .clk(clk),
        .rst_n(rst_n),
        .rs1_addr_i(rs1),
        .rs2_addr_i(rs2),
        .rs1_req_rd_valid_i(rs1_req_rd_valid),
        .rs2_req_rd_valid_i(rs2_req_rd_valid),
        .rs1_reg_data_o(rs1_reg_data),
        .rs2_reg_data_o(rs2_reg_data),
        .rd_addr_i(rd_addr),
        .rd_data_i(rd_data),
        .rd_req_wr_valid_i(rd_req_wr_valid)
    );


endmodule