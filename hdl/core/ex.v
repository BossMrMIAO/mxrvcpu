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

    // PC值传递
    input[`PORT_ADDR_WIDTH]             ex_pc_i,
    output reg[`PORT_ADDR_WIDTH]        ex_pc_o,

    // 控制单元跳转标志，跳转地址PC_jump
    output                              ex_pc_jump_flag,
    output reg[`PORT_ADDR_WIDTH]        ex_pc_jump_o,

    // 从指令译码中获得输入数据
    input[`PORT_OPCODE_WIDTH]           ex_opcode_i,
    input[`PORT_REG_ADDR_WIDTH]         ex_rd_addr_i,
    input[`PORT_funct3_WIDTH]           ex_funct3_i,
    input[`PORT_REG_ADDR_WIDTH]         ex_rs1_addr_i,
    input[`PORT_REG_ADDR_WIDTH]         ex_rs2_addr_i,
    input[`PORT_funct7_WIDTH]           ex_funct7_i,
    input[`PORT_REG_ADDR_WIDTH]         ex_shamt_i,
    input[`PORT_WORD_WIDTH]             ex_zimm_i,
    input[`PORT_WORD_WIDTH]             ex_imm_i,
    input[`PORT_CSR_WIDTH]              ex_csr_addr_i,

    // 结果寄存器数值   
    input[`RegBusPort]                  ex_rs1_reg_data_i,
    input[`RegBusPort]                  ex_rs2_reg_data_i,

    // 回写寄存器   
    output                              ex_rd_wr_en_o,
    output wire[`PORT_REG_ADDR_WIDTH]   ex_rd_addr_o,
    output reg[`RegBusPort]             ex_rd_reg_data_o,
    // 读写data_ram
    output                              ex_data_ram_wr_en_o,
    output reg[`PORT_ADDR_WIDTH]        ex_data_ram_addr_o,
    output reg[`PORT_DATA_WIDTH]        ex_data_ram_wr_data_o,
    input[`PORT_DATA_WIDTH]             ex_data_ram_rd_data_i,
    // 读写inst_rom
    output                              ex_inst_rom_wr_en_o,
    output reg[`PORT_ADDR_WIDTH]        ex_inst_rom_addr_o,
    output reg[`PORT_DATA_WIDTH]        ex_inst_rom_wr_data_o,
    input[`PORT_DATA_WIDTH]             ex_inst_rom_rd_data_i,

    // 读写CSR寄存器
    output                              ex_csr_wr_en_o,
    output reg[`CsrRegAddrBusPort]      ex_csr_addr_o,
    output reg[`RegBusPort]             ex_csr_wdata_o,
    input[`RegBusPort]                  ex_csr_rdata_i, 
    output                              ex_csr_inst_succ_flag_o,
    
    // 接控制单元   
    output reg                          ex_hold_flag_o,
    
    // 接除法器 
    input                               ex_div_busy_i

);  

    wire[`PORT_WORD_WIDTH] rs1_plus_imm;
    // 用于csrrw指令和csrrs等指令
    reg[`RegBusPort]        t;

    integer a;

    // hold住或除法器计算中，就不要再一直不停会写寄存器了
    // assign ex_rd_wr_en_o = (ex_hold_flag_i | ex_div_busy_i) ? `Disable : `Enable;

    assign ex_rd_addr_o = ex_rd_addr_i;
    assign rs1_plus_imm = ex_rs1_reg_data_i + ex_imm_i;
    assign ex_rd_wr_en_o = (ex_opcode_i == `INST_TYPE_I  && (
                            ex_funct3_i == `INST_ADDI   |
                            ex_funct3_i == `INST_SLTI   |
                            ex_funct3_i == `INST_SLTIU  |
                            ex_funct3_i == `INST_XORI   |
                            ex_funct3_i == `INST_ORI    |
                            ex_funct3_i == `INST_ANDI   |
                            ex_funct3_i == `INST_SLLI   |
                            ex_funct3_i == `INST_SRLI_SRAI ) ) ||
                        (ex_opcode_i == `INST_TYPE_L  && (
                            ex_funct3_i == `INST_LB     |
                            ex_funct3_i == `INST_LH     |
                            ex_funct3_i == `INST_LW     |
                            ex_funct3_i == `INST_LBU    |
                            ex_funct3_i == `INST_LHU    ) ) ||
                        (ex_opcode_i == `INST_TYPE_R_M  && (
                            ex_funct3_i == `INST_ADD_SUB  |
                            ex_funct3_i == `INST_SLL      |
                            ex_funct3_i == `INST_SLT      |
                            ex_funct3_i == `INST_SLTU     |
                            ex_funct3_i == `INST_XOR      |
                            ex_funct3_i == `INST_SRA_SRL  |
                            ex_funct3_i == `INST_OR       |
                            ex_funct3_i == `INST_AND    ) ) ||
                        (ex_opcode_i == `INST_LUI        ) ||
                        (ex_opcode_i == `INST_AUIPC      ) ||
                        (ex_opcode_i == `INST_JAL        ) ||
                        (ex_opcode_i == `INST_JALR       )     ? `Enable : `Disable;

    assign ex_pc_jump_flag = (ex_opcode_i == `INST_TYPE_B && (
                            (ex_funct3_i == `INST_BEQ    &&  (ex_rs1_reg_data_i == ex_rs2_reg_data_i)                  )     |
                            (ex_funct3_i == `INST_BNE    &&  (ex_rs1_reg_data_i != ex_rs2_reg_data_i)                  )     |
                            (ex_funct3_i == `INST_BLT    &&  ($signed(ex_rs1_reg_data_i) < $signed(ex_rs2_reg_data_i)) )     |
                            (ex_funct3_i == `INST_BGE    &&  ($signed(ex_rs1_reg_data_i) >= $signed(ex_rs2_reg_data_i)) )     |
                            (ex_funct3_i == `INST_BLTU   &&  (ex_rs1_reg_data_i < ex_rs2_reg_data_i)                   )     |
                            (ex_funct3_i == `INST_BGEU   &&  (ex_rs1_reg_data_i >= ex_rs2_reg_data_i)                   )                    
                            )                             )  ||
                        (ex_opcode_i == `INST_JAL        ) ||
                        (ex_opcode_i == `INST_JALR       ) ||
                        (ex_opcode_i == `INST_TYPE_FENCE )     ? `Enable : `Disable;

    assign ex_data_ram_wr_en_o = (ex_opcode_i == `INST_TYPE_S && (
                            (ex_funct3_i == `INST_SB    )                      |
                            (ex_funct3_i == `INST_SH    )                      |
                            (ex_funct3_i == `INST_SW    )  ) ) ? `Enable : `Disable;

    assign ex_inst_rom_wr_en_o = (ex_opcode_i == `INST_TYPE_S && (
                            (ex_funct3_i == `INST_SB    )                      |
                            (ex_funct3_i == `INST_SH    )                      |
                            (ex_funct3_i == `INST_SW    )  ) ) ? `Enable : `Disable;     
                  
                                          

    // 组合逻辑执行指令操作
    always @(*) begin : ex_core
        case (ex_opcode_i)
            `INST_TYPE_I: begin
                case (ex_funct3_i)
                    // add immedite data
                    `INST_ADDI: begin
                        ex_rd_reg_data_o = ex_imm_i + ex_rs1_reg_data_i;
                        
                    end
                    `INST_SLTI: begin
                        ex_rd_reg_data_o = ($signed(ex_rs1_reg_data_i) < $signed(ex_imm_i) ) ? 1 : 0;
                        
                    end
                    `INST_SLTIU:  begin
                        ex_rd_reg_data_o = (ex_rs1_reg_data_i < ex_imm_i ) ? 1 : 0;
                        
                    end
                    `INST_ANDI: begin
                        ex_rd_reg_data_o = ex_rs1_reg_data_i & ex_imm_i;
                        
                    end
                    `INST_XORI: begin
                        ex_rd_reg_data_o = ex_rs1_reg_data_i ^ ex_imm_i;
                        
                    end 
                    `INST_ORI:  begin
                        ex_rd_reg_data_o = ex_rs1_reg_data_i | ex_imm_i;
                        
                    end
                    // slli rd, rs1, shamt; x[rd] = x[rs1] << shamt(shamt[5] != 0 (RV32I))
                    `INST_SLLI: begin
                        ex_rd_reg_data_o = ex_rs1_reg_data_i << ex_shamt_i;
                        
                    end
                    `INST_SRLI_SRAI:  begin
                        if (ex_funct7_i[5] & ~ex_funct7_i[0]) begin
                            ex_rd_reg_data_o = $signed(ex_rs1_reg_data_i) >>> ex_shamt_i[4:0];
                        end else if(~ex_funct7_i[5] & ~ex_funct7_i[0]) begin
                            ex_rd_reg_data_o = ex_rs1_reg_data_i >> ex_shamt_i[4:0];
                        end else begin
                            ex_rd_reg_data_o = `ZeroWord;
                        end
                    end
                    default: begin
                        
                    end
                endcase
            end
            `INST_TYPE_L: begin
                case(ex_funct3_i)
                    `INST_LB:    begin
                        ex_data_ram_addr_o = rs1_plus_imm;
                        case(ex_data_ram_addr_o[1:0]) 
                            2'b11:  begin
                                ex_rd_reg_data_o = {{24{ex_data_ram_rd_data_i[31]}},ex_data_ram_rd_data_i[31:24]};
                            end
                            2'b10:  begin
                                ex_rd_reg_data_o = {{24{ex_data_ram_rd_data_i[23]}},ex_data_ram_rd_data_i[23:16]};
                            end
                            2'b01:  begin
                                ex_rd_reg_data_o = {{24{ex_data_ram_rd_data_i[15]}},ex_data_ram_rd_data_i[15:8]};
                            end
                            default:  begin
                                ex_rd_reg_data_o = {{24{ex_data_ram_rd_data_i[7]}},ex_data_ram_rd_data_i[7:0]};
                            end
                        endcase
                    end
                    `INST_LH:    begin
                        ex_data_ram_addr_o = rs1_plus_imm;
                        case(ex_data_ram_addr_o[1:0]) 
                            2'b11:  begin
                                ex_rd_reg_data_o = {{24{ex_data_ram_rd_data_i[31]}},ex_data_ram_rd_data_i[31:24]};
                            end
                            2'b10:  begin
                                ex_rd_reg_data_o = {{16{ex_data_ram_rd_data_i[31]}},ex_data_ram_rd_data_i[31:16]};
                            end
                            2'b01:  begin
                                ex_rd_reg_data_o = {{16{ex_data_ram_rd_data_i[23]}},ex_data_ram_rd_data_i[23:8]};
                            end
                            default:  begin
                                ex_rd_reg_data_o = {{16{ex_data_ram_rd_data_i[15]}},ex_data_ram_rd_data_i[15:0]};
                            end
                        endcase
                        // 临时为了通过fence指令，读写inst_rom
                        ex_inst_rom_addr_o = rs1_plus_imm;
                        case(ex_inst_rom_addr_o[1:0]) 
                            2'b11:  begin
                                ex_rd_reg_data_o = {{24{ex_inst_rom_rd_data_i[31]}},ex_inst_rom_rd_data_i[31:24]};
                            end
                            2'b10:  begin
                                ex_rd_reg_data_o = {{16{ex_inst_rom_rd_data_i[31]}},ex_inst_rom_rd_data_i[31:16]};
                            end
                            2'b01:  begin
                                ex_rd_reg_data_o = {{16{ex_inst_rom_rd_data_i[23]}},ex_inst_rom_rd_data_i[23:8]};
                            end
                            default:  begin
                                ex_rd_reg_data_o = {{16{ex_inst_rom_rd_data_i[15]}},ex_inst_rom_rd_data_i[15:0]};
                            end
                        endcase
                    end
                    `INST_LW:    begin
                        ex_data_ram_addr_o = rs1_plus_imm;
                        ex_rd_reg_data_o = ex_data_ram_rd_data_i[31:0];
                        
                    end
                    `INST_LBU:   begin
                        ex_data_ram_addr_o = rs1_plus_imm;
                        case(ex_data_ram_addr_o[1:0]) 
                            2'b11:  begin
                                ex_rd_reg_data_o = {24'h0,ex_data_ram_rd_data_i[31:24]};
                            end
                            2'b10:  begin
                                ex_rd_reg_data_o = {24'h0,ex_data_ram_rd_data_i[23:16]};
                            end
                            2'b01:  begin
                                ex_rd_reg_data_o = {24'h0,ex_data_ram_rd_data_i[15:8]};
                            end
                            default:  begin
                                ex_rd_reg_data_o = {24'h0,ex_data_ram_rd_data_i[7:0]};
                            end
                        endcase                    
                    end
                    `INST_LHU:   begin
                        ex_data_ram_addr_o = rs1_plus_imm;
                        case(ex_data_ram_addr_o[1:0]) 
                            2'b11:  begin
                                ex_rd_reg_data_o = {24'h0,ex_data_ram_rd_data_i[31:24]};
                            end
                            2'b10:  begin
                                ex_rd_reg_data_o = {16'h0,ex_data_ram_rd_data_i[31:16]};
                            end
                            2'b01:  begin
                                ex_rd_reg_data_o = {16'h0,ex_data_ram_rd_data_i[23:8]};
                            end
                            default:  begin
                                ex_rd_reg_data_o = {16'h0,ex_data_ram_rd_data_i[15:0]};
                            end
                        endcase                        
                    end
                    default:    begin
                        
                    end
                endcase
            end

            `INST_TYPE_S: begin
                case(ex_funct3_i)
                    `INST_SB:    begin
                        ex_data_ram_addr_o = rs1_plus_imm;
                        case(ex_data_ram_addr_o[1:0]) 
                            2'b11:  begin
                                ex_data_ram_wr_data_o = {ex_rs2_reg_data_i[7:0], ex_data_ram_rd_data_i[23:0]};
                            end
                            2'b10:  begin
                                ex_data_ram_wr_data_o = {ex_data_ram_rd_data_i[31:24], ex_rs2_reg_data_i[7:0], ex_data_ram_rd_data_i[15:0]};
                            end
                            2'b01:  begin
                                ex_data_ram_wr_data_o = {ex_data_ram_rd_data_i[31:16], ex_rs2_reg_data_i[7:0], ex_data_ram_rd_data_i[7:0]};
                            end
                            default:  begin
                                ex_data_ram_wr_data_o = {ex_data_ram_rd_data_i[31:8], ex_rs2_reg_data_i[7:0]};
                            end
                        endcase
                    end
                    `INST_SH:    begin
                        ex_data_ram_addr_o = rs1_plus_imm;
                        case(ex_data_ram_addr_o[1:0]) 
                            2'b11:  begin
                                ex_data_ram_wr_data_o = {ex_rs2_reg_data_i[7:0], ex_data_ram_rd_data_i[23:0]};
                            end
                            2'b10:  begin
                                ex_data_ram_wr_data_o = {ex_rs2_reg_data_i[15:0], ex_data_ram_rd_data_i[15:0]};
                            end
                            2'b01:  begin
                                ex_data_ram_wr_data_o = {ex_data_ram_rd_data_i[31:24], ex_rs2_reg_data_i[15:0], ex_data_ram_rd_data_i[7:0]};
                            end
                            default:  begin
                                ex_data_ram_wr_data_o = {ex_data_ram_rd_data_i[31:16], ex_rs2_reg_data_i[15:0]};
                            end
                        endcase
                        // 临时为了fence指令启动inst_rom的读写
                        ex_inst_rom_addr_o = rs1_plus_imm;
                        case(ex_inst_rom_addr_o[1:0]) 
                            2'b11:  begin
                                ex_inst_rom_wr_data_o = {ex_rs2_reg_data_i[7:0], ex_inst_rom_rd_data_i[23:0]};
                            end
                            2'b10:  begin
                                ex_inst_rom_wr_data_o = {ex_rs2_reg_data_i[15:0], ex_inst_rom_rd_data_i[15:0]};
                            end
                            2'b01:  begin
                                ex_inst_rom_wr_data_o = {ex_inst_rom_rd_data_i[31:24], ex_rs2_reg_data_i[15:0], ex_inst_rom_rd_data_i[7:0]};
                            end
                            default:  begin
                                ex_inst_rom_wr_data_o = {ex_inst_rom_rd_data_i[31:16], ex_rs2_reg_data_i[15:0]};
                            end
                        endcase
                    end
                    `INST_SW:    begin
                        ex_data_ram_addr_o = rs1_plus_imm;
                        ex_data_ram_wr_data_o = ex_rs2_reg_data_i;
                    end
                    default:    begin
                        
                    end
                endcase
            end
            `INST_TYPE_R_M: begin
                case(ex_funct3_i)
                    `INST_ADD_SUB:    begin
                        ex_rd_reg_data_o = ex_funct7_i[5] ? (ex_rs1_reg_data_i - ex_rs2_reg_data_i) : (ex_rs1_reg_data_i + ex_rs2_reg_data_i);
                        
                    end
                    // sll rd, rs1, rs2; x[rd] = x[rs1] << x[rs2]([4:0](RV32I),[5:0](RV64I))
                    `INST_SLL:    begin
                        ex_rd_reg_data_o = ex_rs1_reg_data_i << ex_rs2_reg_data_i[4:0];
                        
                    end
                    `INST_SLT:    begin
                        ex_rd_reg_data_o = ($signed(ex_rs1_reg_data_i) < $signed(ex_rs2_reg_data_i)) ? 1 : 0;
                        
                    end
                    `INST_SLTU:    begin
                        ex_rd_reg_data_o = (ex_rs1_reg_data_i < ex_rs2_reg_data_i) ? 1 : 0;
                        
                    end
                    `INST_XOR:    begin
                        ex_rd_reg_data_o = ex_rs1_reg_data_i ^ ex_rs2_reg_data_i;
                        
                    end
                    `INST_SRA_SRL:    begin
                        // ex_rd_reg_data_o = ex_funct7_i[5] ? 
                        //                     $signed(($signed(ex_rs1_reg_data_i)) >>> ex_rs2_reg_data_i[4:0]): 
                        //                     (ex_rs1_reg_data_i >> ex_rs2_reg_data_i[4:0]);
                        if (ex_funct7_i[5]) begin
                            ex_rd_reg_data_o = $signed(ex_rs1_reg_data_i) >>> ex_rs2_reg_data_i[4:0];
                        end else begin
                            ex_rd_reg_data_o = ex_rs1_reg_data_i >> ex_rs2_reg_data_i[4:0];
                        end
                        
                    end
                    `INST_OR:    begin
                        ex_rd_reg_data_o = ex_rs1_reg_data_i | ex_rs2_reg_data_i;
                        
                    end
                    `INST_AND:    begin
                        ex_rd_reg_data_o = ex_rs1_reg_data_i & ex_rs2_reg_data_i;
                        
                    end
                    default:    begin
                        
                    end
                endcase
            end
            // special J type inst --- begin
            `INST_JAL: begin
                ex_rd_reg_data_o = ex_pc_i + 4;
                ex_pc_jump_o = ex_pc_i + $signed(ex_imm_i);
            end
            `INST_JALR: begin
                ex_rd_reg_data_o = ex_pc_i + 4;
                ex_pc_jump_o = ex_rs1_reg_data_i +$signed(ex_imm_i);
            end
            // special J type inst --- end
            // special U type inst --- begin
            `INST_LUI:  begin
                ex_rd_reg_data_o = ex_imm_i & 32'hffff_f000;
                
            end
            `INST_AUIPC:    begin
                ex_rd_reg_data_o = ex_pc_i + (ex_imm_i & 32'hffff_f000);
                
            end
            // special U type inst --- end
            `INST_TYPE_B:   begin
                case(ex_funct3_i)
                    `INST_BEQ:  begin
                        ex_pc_jump_o = (ex_rs1_reg_data_i == ex_rs2_reg_data_i) ? (ex_pc_i + $signed(ex_imm_i)) : ex_pc_i;
                    end
                    `INST_BNE:  begin
                        ex_pc_jump_o = (ex_rs1_reg_data_i != ex_rs2_reg_data_i) ? (ex_pc_i + $signed(ex_imm_i)) : ex_pc_i;
                    end
                    `INST_BLT:  begin
                        ex_pc_jump_o = ($signed(ex_rs1_reg_data_i) < $signed(ex_rs2_reg_data_i)) ? (ex_pc_i + $signed(ex_imm_i)) : ex_pc_i;
                    end
                    `INST_BGE:  begin
                        ex_pc_jump_o = ($signed(ex_rs1_reg_data_i) >= $signed(ex_rs2_reg_data_i)) ? (ex_pc_i + $signed(ex_imm_i)) : ex_pc_i;
                    end
                    `INST_BLTU: begin
                        ex_pc_jump_o = (ex_rs1_reg_data_i < ex_rs2_reg_data_i) ? (ex_pc_i + $signed(ex_imm_i)) : ex_pc_i;
                    end
                    `INST_BGEU: begin
                        ex_pc_jump_o = (ex_rs1_reg_data_i >= ex_rs2_reg_data_i) ? (ex_pc_i + $signed(ex_imm_i)) : ex_pc_i;
                    end
                    default:    begin
                        
                    end
                endcase
            end
            // CSR INST
            `INST_CSR:  begin
                case (ex_funct3_i)
                    `INST_CSRRW:    begin
                        ex_csr_addr_o = ex_csr_addr_i;
                        t = ex_csr_rdata_i;
                        ex_csr_wdata_o = ex_rs1_reg_data_i;
                        ex_rd_reg_data_o = t;
                    end 
                    `INST_CSRRS:    begin
                        ex_csr_addr_o = ex_csr_addr_i;
                        t = ex_csr_rdata_i;
                        ex_csr_wdata_o = t | ex_rs1_reg_data_i;
                        ex_rd_reg_data_o = t;
                    end
                    `INST_CSRRC:    begin
                        ex_csr_addr_o = ex_csr_addr_i;
                        t = ex_csr_rdata_i;
                        ex_csr_wdata_o = t & ~ex_rs1_reg_data_i;
                        ex_rd_reg_data_o = t;
                    end
                    `INST_CSRRWI:   begin
                        ex_csr_addr_o = ex_csr_addr_i;
                        ex_rd_reg_data_o = ex_csr_rdata_i;
                        ex_csr_wdata_o = {27'h0, ex_zimm_i};
                    end
                    `INST_CSRRSI:   begin
                        ex_csr_addr_o = ex_csr_addr_i;
                        t = ex_csr_rdata_i;
                        ex_csr_wdata_o = t | {27'h0, ex_zimm_i};
                        ex_rd_reg_data_o = t;
                    end
                    `INST_CSRRCI:   begin
                        ex_csr_addr_o = ex_csr_addr_i;
                        t = ex_csr_rdata_i;
                        ex_csr_wdata_o = t & ~{27'h0, ex_zimm_i};
                        ex_rd_reg_data_o = t;
                    end
                    default:    begin
                        
                    end
                endcase
            end
            // fence type inst
            `INST_TYPE_FENCE: begin
                case (ex_funct3_i)
                    `INST_FENCE:    begin
                        
                    end
                    `INST_FENCE_I:  begin
                        ex_pc_jump_o = ex_pc_i + 32'h4;
                    end
                endcase
            end
            default: begin
                
            end
        endcase
    end

    


    
endmodule
