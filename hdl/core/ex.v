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
    output[`PORT_ADDR_WIDTH]            ex_pc_o,

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
    // LOAD/SAVE指令的存储器地址与写使能, data_ram
    output                              ex_data_ram_wr_en_o,
    output reg[`PORT_ADDR_WIDTH]        ex_data_ram_addr_o,
    // LOAD/SAVE指令的存储器地址与写使能, inst_rom
    output                              ex_inst_rom_wr_en_o,
    output reg[`PORT_ADDR_WIDTH]        ex_inst_rom_addr_o,
    // 给出mem需要的参数以判定是否为存储性指令
    output[`PORT_OPCODE_WIDTH]          ex_mem_opcode_o,
    output[`PORT_funct3_WIDTH]          ex_mem_funct3_o,
    // 写入存储器指令需要的rs2寄存器数据
    output[`RegBusPort]                 ex_mem_rs2_reg_data_o,
 

    // 读取CSR寄存器，因为CSR寄存器相关指令在ex阶段获取CSR寄存器的值
    output reg[`CsrRegAddrBusPort]      ex_csr_raddr_o,
    input[`RegBusPort]                  ex_csr_rdata_i, 
    output reg[`RegBusPort]             ex_csr_wdata_o,
    
    // 接控制单元   
    output reg                          ex_hold_flag_o,
    
    // 接除法器 
    input                               ex_div_busy_i

);  

    wire[`PORT_WORD_WIDTH] rs1_plus_imm;
    // 用于csrrw指令和csrrs等指令的暂存
    reg[`RegBusPort]        t;


    integer a;

    // hold住或除法器计算中，就不要再一直不停会写寄存器了
    // assign ex_rd_wr_en_o = (ex_hold_flag_i | ex_div_busy_i) ? `Disable : `Enable;

    assign ex_pc_o = ex_pc_i;
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

    assign ex_mem_opcode_o = ex_opcode_i;   
    assign ex_mem_funct3_o = ex_funct3_i;
    assign ex_mem_rs2_reg_data_o = ex_rs2_reg_data_i;
                  
                                          

    // 组合逻辑执行指令操作
    always @(*) begin : ex_core
        if (!rst_n) begin : rst
            ex_pc_jump_o = `ZeroWord;
            ex_rd_reg_data_o = `ZeroWord;
            ex_data_ram_addr_o = `ZeroWord;
            ex_inst_rom_addr_o = `ZeroWord;
            ex_csr_raddr_o = `Disable;
            ex_csr_wdata_o = `ZeroWord;
            ex_hold_flag_o = `Disable;
        end : rst
        else begin : ex_opcode_process
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
                // 所有LOAD/SAVE指令读取存储器数据全部交由mem模块处理，ex模块只负责计算存储器地址
                `INST_TYPE_L, `INST_TYPE_S: begin
                    ex_data_ram_addr_o = rs1_plus_imm;
                    // 为满足冯诺依曼结构的指令测试序列，增加一个相当于单存储器的操作需求，否则后续save后读取不能实现
                    ex_inst_rom_addr_o = rs1_plus_imm;
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
                    ex_csr_raddr_o = ex_csr_addr_i;
                    case (ex_funct3_i)
                        `INST_CSRRW:    begin
                            t = ex_csr_rdata_i;
                            ex_csr_wdata_o = ex_rs1_reg_data_i;
                            ex_rd_reg_data_o = t;
                        end 
                        `INST_CSRRS:    begin
                            t = ex_csr_rdata_i;
                            ex_csr_wdata_o = t | ex_rs1_reg_data_i;
                            ex_rd_reg_data_o = t;
                        end
                        `INST_CSRRC:    begin
                            t = ex_csr_rdata_i;
                            ex_csr_wdata_o = t & ~ex_rs1_reg_data_i;
                            ex_rd_reg_data_o = t;
                        end
                        `INST_CSRRWI:   begin
                            ex_rd_reg_data_o = ex_csr_rdata_i;
                            ex_csr_wdata_o = {27'h0, ex_zimm_i};
                        end
                        `INST_CSRRSI:   begin
                            t = ex_csr_rdata_i;
                            ex_csr_wdata_o = t | {27'h0, ex_zimm_i};
                            ex_rd_reg_data_o = t;
                        end
                        `INST_CSRRCI:   begin
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
                        default: begin
                    
                        end
                    endcase
                end

                default : begin
                
                end
                
            endcase

        end : ex_opcode_process

    end : ex_core

    

  
endmodule
