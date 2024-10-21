//*****************************************
// 
//*****************************************
`timescale 1ns/1ps

`include "../../hdl/core/define.v"

module ifu_test_tb ();

    reg clk;
    reg rst_n;

// ifu test
    reg[`PORT_ADDR_WIDTH] pc;

    wire inst_valid;
    wire[`PORT_DATA_WIDTH] inst_data;
    wire pc_send_valid;
    wire pc_receive_ready;

    wire[`ADDR_WIDTH] pc_ifu;
    wire inst_ifu_valid;
    wire[`DATA_WIDTH] inst_data_ifu;


    wire[`PORT_OPCODE_WIDTH] opcode;
    wire[`PORT_REG_ADDR_WIDTH] rd;
    wire[`PORT_funct3_WIDTH] funct3;
    wire[`PORT_REG_ADDR_WIDTH]   rs1,rs2;
    wire[`PORT_funct7_WIDTH] fucnt7;
    wire[`PORT_REG_ADDR_WIDTH] shamt;
    wire    L_or_A_flag;
    wire[`PORT_WORD_WIDTH] zimm;
    wire[`PORT_WORD_WIDTH]  imm;

    wire[`RegBus] rs1_reg_data,rs2_reg_data;
    wire[`RegBus] rd_wr_en,rd_reg_data;
    wire Hold_flag,div_busy;

   
    wire[`RegBus] rs1_addr, rs2_addr;   
    wire rs1_req_rd_valid, rs2_req_rd_valid;
    wire[`RegBus] rs1_reg_data, rs2_reg_data;
    wire[`RegBus] rd_addr, rd_data;
    wire rd_req_wr_valid;

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
        .inst_data_ifu_o(inst_data_ifu)
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

    // instance pc_reg
    pc_reg u_pc_reg (
        .clk(clk),
        .rst_n(rst_n),
        .pc_o(pc)
    );

    // instance id
    id u_id (
        .inst_data_i(inst_data_ifu),
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

    // instance ex
    ex u_ex (
        .clk(clk),
        .rst_n(rst_n),
        .opcode_i(opcode),
        .rd_i(rd),
        .funct3_i(funct3),
        .rs1_i(rs1),
        .rs2_i(rs2),
        .funct7_i(funct7),
        .shamt_i(shamt),
        .L_or_A_flag_i(L_or_A_flag),
        .zimm_i(zimm),
        .imm_i(imm),
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

    // initial ROM for load inst. content
    initial begin
        $readmemh ("inst.data", ifu_test_tb.u_rom.INST_ROM);
    end
    



// CLK_ENV
    // clk logic
    initial begin
        clk = 0;
        forever begin
            #10;
            clk = ~clk;
        end
    end

    // rst_n logic
    initial begin
        #10;
        rst_n = 0;
        #90;
        rst_n = 1;
    end

    // sim timeout
    initial begin
        #10000
        $display("Time Out.");
        $finish;
    end

    // generate wave file, used by gtkwave(vcd) or vcs(fsdb)
    initial begin
        // $dumpfile("tb.vcd");
        $dumpfile("tb.fsdb");
        $dumpvars(0, ifu_test_tb);
    end


endmodule
