/*
soc_top

Integrate all component of pipeline SOC, from left to right

PC_REG, 

*/

`include "define.v"


module soc_core_top (
    // 全局时钟与异步复位
    input   clk,
    input   rst_n
);

    // 内核各组件之间连接线

    // pc_reg --- ifu
    wire[`PORT_ADDR_WIDTH]      pc_reg_ifu_pc;
    // pc_reg --- inst_rom
    wire[`PORT_ADDR_WIDTH]      pc_reg_inst_rom_pc;
    assign pc_reg_inst_rom_pc = pc_reg_ifu_pc;

    // inst_rom --- ifu
    wire[`PORT_DATA_WIDTH]      inst_rom_ifu_inst_data;

    // ifu --- if_id_dff
    wire[`PORT_ADDR_WIDTH]      ifu_if_id_dff_pc_bef;
    wire[`PORT_DATA_WIDTH]      ifu_if_id_dff_inst_data_bef;

    // if_id_dff --- id
    wire[`PORT_ADDR_WIDTH]      if_id_dff_id_pc_aft;
    wire[`PORT_DATA_WIDTH]      if_id_dff_id_inst_data_aft;

    // id --- id_ex_dff
    wire[`PORT_OPCODE_WIDTH]    id_id_ex_dff_opcode_bef;
    wire[`PORT_REG_ADDR_WIDTH]  id_id_ex_dff_rd_addr_bef;
    wire[`PORT_funct3_WIDTH]    id_id_ex_dff_funct3_bef;
    wire[`PORT_REG_ADDR_WIDTH]  id_id_ex_dff_rs1_addr_bef;
    wire[`PORT_REG_ADDR_WIDTH]  id_id_ex_dff_rs2_addr_bef;
    wire[`PORT_funct7_WIDTH]    id_id_ex_dff_funct7_bef;
    wire[`PORT_REG_ADDR_WIDTH]  id_id_ex_dff_shamt_bef;
    wire[`PORT_WORD_WIDTH]      id_id_ex_dff_zimm_bef;
    wire[`PORT_WORD_WIDTH]      id_id_ex_dff_imm_bef;
    wire[`PORT_WORD_WIDTH]      id_id_ex_dff_csr_addr_bef;
    wire[`PORT_ADDR_WIDTH]      id_id_ex_dff_pc_bef;

    // id --- regu
    wire[`PORT_REG_ADDR_WIDTH]  id_regu_rs1_addr;
    wire[`PORT_REG_ADDR_WIDTH]  id_regu_rs2_addr;
    assign id_regu_rs1_addr = id_id_ex_dff_rs1_addr_bef;
    assign id_regu_rs2_addr = id_id_ex_dff_rs2_addr_bef;

    // regu --- id_ex_dff
    wire[`RegBusPort]           regu_id_ex_dff_rs1_reg_data_bef;
    wire[`RegBusPort]           regu_id_ex_dff_rs2_reg_data_bef;

    // id_ex_dff --- ex
    wire[`PORT_OPCODE_WIDTH]    id_ex_dff_ex_opcode_aft;
    wire[`PORT_REG_ADDR_WIDTH]  id_ex_dff_ex_rd_addr_aft;
    wire[`PORT_funct3_WIDTH]    id_ex_dff_ex_funct3_aft;
    wire[`PORT_REG_ADDR_WIDTH]  id_ex_dff_ex_rs1_addr_aft;
    wire[`PORT_REG_ADDR_WIDTH]  id_ex_dff_ex_rs2_addr_aft;
    wire[`PORT_funct7_WIDTH]    id_ex_dff_ex_funct7_aft;
    wire[`PORT_REG_ADDR_WIDTH]  id_ex_dff_ex_shamt_aft;
    wire[`PORT_WORD_WIDTH]      id_ex_dff_ex_zimm_aft;
    wire[`PORT_WORD_WIDTH]      id_ex_dff_ex_imm_aft;
    wire[`PORT_WORD_WIDTH]      id_ex_dff_ex_csr_addr_aft;
    wire[`PORT_ADDR_WIDTH]      id_ex_dff_ex_pc_aft;
    wire[`RegBusPort]           id_ex_dff_ex_rs1_reg_data_aft;
    wire[`RegBusPort]           id_ex_dff_ex_rs2_reg_data_aft;

    // ex --- regu
    wire                        ex_regu_rd_wr_en;
    wire[`PORT_REG_ADDR_WIDTH]  ex_regu_rd_addr;
    wire[`RegBusPort]           ex_regu_rd_reg_data;

    // ex --- ctrl            
    wire                        ex_ctrl_pc_jump_flag;
    wire[`PORT_ADDR_WIDTH]      ex_ctrl_pc_jump;
    wire                        ex_ctrl_pc_hold_flag;

    // ctrl --- pc_reg
    wire                        ctrl_pc_reg_pipeline_flush_flag;
    wire[`PORT_ADDR_WIDTH]      ctrl_pc_reg_pc_jump;
    wire                        ctrl_pc_reg_pipeline_hold_flag;

    // ctrl --- if_id_dff
    wire                        ctrl_if_id_dff_pipeline_flush_flag;
    assign ctrl_if_id_dff_pipeline_flush_flag = ctrl_pc_reg_pipeline_flush_flag;

    // ctrl --- id_ex_dff
    wire                        ctrl_id_ex_dff_pipeline_flush_flag;
    assign ctrl_id_ex_dff_pipeline_flush_flag = ctrl_pc_reg_pipeline_flush_flag;

    // ex --- data_ram
    wire                        ex_data_ram_wr_en;
    wire[`PORT_ADDR_WIDTH]      ex_data_ram_addr;
    wire[`PORT_DATA_WIDTH]      ex_data_ram_wr_data;

    // data_ram --- ex
    wire[`PORT_DATA_WIDTH]      data_ram_ex_rd_data;




// 实例化SOC内核
    pc_reg  pc_reg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .pc_reg_hold_flag_i(ctrl_pc_reg_pipeline_hold_flag),
        .pc_reg_jump_flag_i(ctrl_pc_reg_pipeline_flush_flag),
        .pc_reg_jump_addr_i(ctrl_pc_reg_pc_jump),
        .pc_reg_pc_o(pc_reg_ifu_pc)
      );

    inst_rom  inst_rom_inst (
        .clk(clk),
        .rst_n(rst_n),
        .inst_rom_pc_i(pc_reg_inst_rom_pc),
        .inst_rom_inst_data_o(inst_rom_ifu_inst_data)
      );

    ifu  ifu_inst (
        .clk(clk),
        .rst_n(rst_n),
        .ifu_pc_i(pc_reg_ifu_pc),
        .ifu_pc_o(ifu_if_id_dff_pc_bef),
        .ifu_inst_data_i(inst_rom_ifu_inst_data),
        .ifu_inst_data_o(ifu_if_id_dff_inst_data_bef)
      );

    if_id_dff  if_id_dff_inst (
        .clk(clk),
        .rst_n(rst_n),
        .ifu_id_dff_pc_i(ifu_if_id_dff_pc_bef),
        .ifu_id_dff_pc_o(if_id_dff_id_pc_aft),
        .ifu_id_dff_inst_data_i(ifu_if_id_dff_inst_data_bef),
        .ifu_id_dff_inst_data_o(if_id_dff_id_inst_data_aft),
        .if_id_dff_pipeline_flush_flag(ctrl_if_id_dff_pipeline_flush_flag)
      );
    
    id  id_inst (
        .clk(clk),
        .rst_n(rst_n),
        .id_pc_i(if_id_dff_id_pc_aft),
        .id_pc_o(id_id_ex_dff_pc_bef),
        .id_inst_data_i(if_id_dff_id_inst_data_aft),
        .id_opcode_o(id_id_ex_dff_opcode_bef),
        .id_rd_addr_o(id_id_ex_dff_rd_addr_bef),
        .id_funct3_o(id_id_ex_dff_funct3_bef),
        .id_rs1_addr_o(id_id_ex_dff_rs1_addr_bef),
        .id_rs2_addr_o(id_id_ex_dff_rs2_addr_bef),
        .id_funct7_o(id_id_ex_dff_funct7_bef),
        .id_shamt_o(id_id_ex_dff_shamt_bef),
        .id_zimm_o(id_id_ex_dff_zimm_bef),
        .id_imm_o(id_id_ex_dff_imm_bef),
        .id_csr_addr_o(id_id_ex_dff_csr_addr_bef),
        .id_err_o()
      );   

    id_ex_dff  id_ex_dff_inst (
        .clk(clk),
        .rst_n(rst_n),
        .id_ex_dff_pc_i(id_id_ex_dff_pc_bef),
        .id_ex_dff_pc_o(id_ex_dff_ex_pc_aft),
        .id_ex_dff_opcode_i(id_id_ex_dff_opcode_bef),
        .id_ex_dff_rd_i(id_id_ex_dff_rd_addr_bef),
        .id_ex_dff_rs1_i(id_id_ex_dff_rs1_addr_bef),
        .id_ex_dff_rs2_i(id_id_ex_dff_rs2_addr_bef),
        .id_ex_dff_funct3_i(id_id_ex_dff_funct3_bef),
        .id_ex_dff_funct7_i(id_id_ex_dff_funct7_bef),
        .id_ex_dff_shamt_i(id_id_ex_dff_shamt_bef),
        .id_ex_dff_zimm_i(id_id_ex_dff_zimm_bef),
        .id_ex_dff_imm_i(id_id_ex_dff_imm_bef),
        .id_ex_dff_opcode_o(id_ex_dff_ex_opcode_aft),
        .id_ex_dff_rd_o(id_ex_dff_ex_rd_addr_aft),
        .id_ex_dff_rs1_o(id_ex_dff_ex_rs1_addr_aft),
        .id_ex_dff_rs2_o(id_ex_dff_ex_rs2_addr_aft),
        .id_ex_dff_funct3_o(id_ex_dff_ex_funct3_aft),
        .id_ex_dff_funct7_o(id_ex_dff_ex_funct7_aft),
        .id_ex_dff_shamt_o(id_ex_dff_ex_shamt_aft),
        .id_ex_dff_zimm_o(id_ex_dff_ex_zimm_aft),
        .id_ex_dff_imm_o(id_ex_dff_ex_imm_aft),
        .id_ex_dff_rs1_reg_data_i(regu_id_ex_dff_rs1_reg_data_bef),
        .id_ex_dff_rs2_reg_data_i(regu_id_ex_dff_rs2_reg_data_bef),
        .id_ex_dff_rs1_reg_data_o(id_ex_dff_ex_rs1_reg_data_aft),
        .id_ex_dff_rs2_reg_data_o(id_ex_dff_ex_rs2_reg_data_aft),
        .id_ex_dff_pipeline_flush_flag(ctrl_id_ex_dff_pipeline_flush_flag)
      );

    regu  regu_inst (
        .clk(clk),
        .rst_n(rst_n),
        .regu_rs1_addr_i(id_regu_rs1_addr),
        .regu_rs2_addr_i(id_regu_rs2_addr),
        .regu_rs1_reg_data_o(regu_id_ex_dff_rs1_reg_data_bef),
        .regu_rs2_reg_data_o(regu_id_ex_dff_rs2_reg_data_bef),
        .regu_rd_addr_i(ex_regu_rd_addr),
        .regu_rd_data_i(ex_regu_rd_reg_data),
        .regu_rd_wr_en_i(ex_regu_rd_wr_en)
      );    

    ex  ex_inst (
        .clk(clk),
        .rst_n(rst_n),
        .ex_pc_i(id_ex_dff_ex_pc_aft),
        .ex_pc_o(),
        .ex_pc_jump_flag(ex_ctrl_pc_jump_flag),
        .ex_pc_jump_o(ex_ctrl_pc_jump),
        .ex_opcode_i(id_ex_dff_ex_opcode_aft),
        .ex_rd_addr_i(id_ex_dff_ex_rd_addr_aft),
        .ex_funct3_i(id_ex_dff_ex_funct3_aft),
        .ex_rs1_addr_i(id_ex_dff_ex_rs1_addr_aft),
        .ex_rs2_addr_i(id_ex_dff_ex_rs2_addr_aft),
        .ex_funct7_i(id_ex_dff_ex_funct7_aft),
        .ex_shamt_i(id_ex_dff_ex_shamt_aft),
        .ex_zimm_i(id_ex_dff_ex_zimm_aft),
        .ex_imm_i(id_ex_dff_ex_imm_aft),
        .ex_rs1_reg_data_i(id_ex_dff_ex_rs1_reg_data_aft),
        .ex_rs2_reg_data_i(id_ex_dff_ex_rs2_reg_data_aft),
        .ex_rd_wr_en_o(ex_regu_rd_wr_en),
        .ex_rd_addr_o(ex_regu_rd_addr),
        .ex_rd_reg_data_o(ex_regu_rd_reg_data),
        .ex_data_ram_wr_en_o(ex_data_ram_wr_en),
        .ex_data_ram_addr_o(ex_data_ram_addr),
        .ex_data_ram_wr_data_o(ex_data_ram_wr_data),
        .ex_data_ram_rd_data_i(data_ram_ex_rd_data),
        .ex_hold_flag_o(),
        .ex_div_busy_i()
      );

    ctrl  ctrl_inst (
        .clk(clk),
        .rst_n(rst_n),
        .ctrl_pc_jump_flag_i(ex_ctrl_pc_jump_flag),
        .ctrl_pc_jump_i(ex_ctrl_pc_jump),
        .ctrl_pc_hold_flag_i(ex_ctrl_pc_hold_flag),
        .ctrl_pipeline_flush_flag_o(ctrl_pc_reg_pipeline_flush_flag),
        .ctrl_pc_jump_o(ctrl_pc_reg_pc_jump),
        .ctrl_pipeline_hold_flag_o(ctrl_pc_reg_pipeline_hold_flag)
      );

    data_ram  data_ram_inst (
        .clk(clk),
        .rst_n(rst_n),
        .data_ram_addr(ex_data_ram_addr),
        .data_ram_wr_data(ex_data_ram_wr_data),
        .data_ram_wr_en(ex_data_ram_wr_en),
        .data_ram_rd_data_o(data_ram_ex_rd_data)
      );




endmodule
