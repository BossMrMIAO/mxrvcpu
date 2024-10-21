//****************************************
// ex：执行模块
// 接收来自译码后的操作数，执行指令运行内容
// 除了立即数的相关操作，总是要读写内置寄存器的值
// 执行模块也应该用组合逻辑
//****************************************

`include "define.v"

module ex (
    input clk,
    input rst_n,

 
    // 从指令译码中获得输入数据
    input[`PORT_OPCODE_WIDTH]  opcode_i,
    input[`PORT_REG_ADDR_WIDTH] rd_i,
    input[`PORT_funct3_WIDTH]   funct3_i,
    input[`PORT_REG_ADDR_WIDTH] rs1_i,
    input[`PORT_REG_ADDR_WIDTH] rs2_i,
    input[`PORT_funct7_WIDTH]   funct7_i,
    input[`PORT_REG_ADDR_WIDTH] shamt_i,
    input[`PORT_R_TOGGLE_FLAG]  r_toggle_flag,
    input[`PORT_WORD_WIDTH] zimm_i,
    input[`PORT_WORD_WIDTH]    imm_i,

    // 结果寄存器数值
    input[`RegBusPort]  rs1_reg_data_i,
    input[`RegBusPort]  rs2_reg_data_i,
    // 回写寄存器
    output reg rd_wr_en_o,
    output wire rd_o,
    output reg[`RegBusPort] rd_reg_data_o,
    // 回写存储器

    // 接控制单元
    input Hold_flag_i,

    // 接除法器
    input div_busy_i
);

    wire[`PORT_WORD_WIDTH] rs1_plus_imm;

    // hold住或除法器计算中，就不要再一直不停会写寄存器了
    // assign rd_wr_en_o = (Hold_flag_i | div_busy_i) ? `Disable : `Enable;

    assign rd_o = rd_i;
    assign rs1_plus_imm = rs1_reg_data_i + imm_i;

    // 组合逻辑执行指令操作
    always @(*) begin
        case (opcode_i)
            `INST_TYPE_I: begin
                case (funct3_i)
                    // add immedite data
                    `INST_ADDI: begin
                        rd_reg_data_o = imm_i + rs1_reg_data_i;
                        rd_wr_en_o = `Enable;
                    end
                    `INST_SLTI: begin
                        rd_reg_data_o = ($signed(rs1_reg_data_i) < $signed(imm_i) ) ? 1 : 0;
                        rd_wr_en_o = `Enable;
                    end
                    `INST_SLTIU:  begin
                        rd_reg_data_o = (rs1_reg_data_i < imm_i ) ? 1 : 0;
                        rd_wr_en_o = `Enable;
                    end
                    `INST_ANDI: begin
                        rd_reg_data_o = rs1_reg_data_i & imm_i;
                        rd_wr_en_o = `Enable;
                    end
                    `INST_XORI: begin
                        rd_reg_data_o = rs1_reg_data_i ^ imm_i;
                        rd_wr_en_o = `Enable;
                    end 
                    `INST_ORI:  begin
                        rd_reg_data_o = rs1_reg_data_i | imm_i;
                        rd_wr_en_o = `Enable;
                    end
                    `INST_SLLI: begin
                        rd_reg_data_o = rs1_reg_data_i << shamt_i;
                        rd_wr_en_o = `Enable;
                    end
                    `INST_SRLI:  begin
                        rd_reg_data_o = rs1_reg_data_i >> shamt_i;
                        rd_wr_en_o = `Enable;
                    end
                    default: begin
                        rd_wr_en_o =`Disable;
                    end
                endcase
            end
            `INST_TYPE_L: begin
                case(funct3_i)
                    // `INST_LB:    begin
                    //     rd_reg_data_o = {24{rs1_plus_imm[7]}, rs1_plus_imm[7:0]};
                    //     rd_wr_en_o = `Enable;
                    // end
                    // `INST_LH:    begin
                    //     rd_reg_data_o = {16{(rs1_reg_data_i + imm_i)[15]}, (rs1_reg_data_i + imm_i)[15:0]};
                    //     rd_wr_en_o = `Enable;
                    // end
                    // `INST_LW:    begin
                    //     rd_reg_data_o = (rs1_reg_data_i + imm_i)[31:0];
                    //     rd_wr_en_o = `Enable;
                    // end
                    // `INST_LBU:   begin
                    //     rd_reg_data_o = {24'h0, (rs1_reg_data_i + imm_i)[7:0]};
                    //     rd_wr_en_o = `Enable;
                    // end
                    // `INST_LHU:   begin
                    //     rd_reg_data_o = {16'h0, (rs1_reg_data_i + imm_i)[15:0]};
                    //     rd_wr_en_o = `Enable;
                    // end
                    default:    begin
                        rd_wr_en_o = `Disable;
                    end
                endcase
            end

            `INST_TYPE_S: begin
                case(funct3_i)
                    `INST_SB:    begin
                        
                    end
                    `INST_SH:    begin
                        
                    end
                    `INST_SW:    begin
                        
                    end
                    default:    begin
                        rd_wr_en_o = `Disable;
                    end
                endcase
            end
            `INST_TYPE_R_M: begin
                case(funct3_i)
                    `INST_ADD_SUB:    begin
                        rd_reg_data_o = r_toggle_flag[5] ? (rs1_reg_data_i + rs2_reg_data_i) : (rs1_reg_data_i - rs2_reg_data_i);
                        rd_wr_en_o = `Enable;
                    end
                    `INST_SLL:    begin
                        rd_reg_data_o = rs1_reg_data_i << rs2_reg_data_i;
                        rd_wr_en_o = `Enable;
                    end
                    `INST_SLT:    begin
                        rd_reg_data_o = ($signed(rs1_reg_data_i) < $signed(rs2_reg_data_i)) ? 1 : 0;
                        rd_wr_en_o = `Enable;
                    end
                    `INST_SLTU:    begin
                        rd_reg_data_o = (rs1_reg_data_i < rs2_reg_data_i) ? 1 : 0;
                        rd_wr_en_o = `Enable;
                    end
                    `INST_XOR:    begin
                        rd_reg_data_o = rs1_reg_data_i ^ rs2_reg_data_i;
                        rd_wr_en_o = `Enable;
                    end
                    `INST_SR:    begin
                        rd_reg_data_o = r_toggle_flag[5] ? (rs1_reg_data_i >> rs2_reg_data_i[4:0]) : (rs1_reg_data_i >> rs2_reg_data_i[4:0]);
                        rd_wr_en_o = `Enable;
                    end
                    `INST_OR:    begin
                        rd_reg_data_o = rs1_reg_data_i | rs2_reg_data_i;
                        rd_wr_en_o = `Enable;
                    end
                    `INST_AND:    begin
                        rd_reg_data_o = rs1_reg_data_i & rs2_reg_data_i;
                        rd_wr_en_o = `Enable;
                    end
                    default:    begin
                        rd_wr_en_o = `Disable;
                    end
                endcase
            end
            // special J type inst --- begin
            `INST_JAL: begin
                // rd_reg_data_o = 
            end
            `INST_JALR: begin
                // rd_reg_data_o = 
            end
            // special J type inst --- end
            // special U type inst --- begin
            `INST_LUI:  begin
                rd_reg_data_o = imm_i & 32'hffff_f000;
                rd_wr_en_o = `Enable;
            end
            `INST_AUIPC:    begin
                // rd_reg_data_o = pc + imm_i & 32'hffff_f000;
                // rd_wr_en_o = `Enable;
            end
            // special U type inst --- end
            `INST_TYPE_B:   begin
                case(funct3_i)
                    `INST_BEQ:  begin
                        
                    end
                    `INST_BNE:  begin
                        
                    end
                    `INST_BLT:  begin
                        
                    end
                    `INST_BGE:  begin
                        
                    end
                    `INST_BLTU: begin
                        
                    end
                    `INST_BGEU: begin
                        
                    end
                    default:    begin
                        rd_wr_en_o = `Disable;
                    end
                endcase
            end
            // CSR INST
            `INST_CSR:  begin
                case (funct3_i)
                    `INST_CSRRW:    begin
                        
                    end 
                    `INST_CSRRS:    begin
                        
                    end
                    `INST_CSRRC:    begin
                        
                    end
                    `INST_CSRRWI:   begin
                        
                    end
                    `INST_CSRRSI:   begin
                        
                    end
                    `INST_CSRRCI:   begin
                        
                    end
                    default:    begin
                        rd_wr_en_o = `Disable;
                    end
                endcase
            end
            default: begin
                rd_wr_en_o = `Disable;
            end
        endcase
    end

    


    
endmodule