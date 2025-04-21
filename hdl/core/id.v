//************************************
// id: 译码模块
// 根据获取到的指令，拆解指令数据
// 整个是一个纯组合逻辑器件，用于拆分传入的指令，并分装到输出接口上
//************************************

`include "define.v"

module id (
    // 全局时钟与异步复位
    input                               clk,
    input                               rst_n,
    // PC传递
    input [`PORT_ADDR_WIDTH]            id_pc_i,
    output [`PORT_ADDR_WIDTH]           id_pc_o,
    // 来自if_id_dff的指令
    input[`PORT_DATA_WIDTH]             id_inst_data_i,
    // 译码拆解信号
    output wire[`PORT_OPCODE_WIDTH]     id_opcode_o,
    output reg[`PORT_REG_ADDR_WIDTH]    id_rd_addr_o,
    output wire[`PORT_funct3_WIDTH]     id_funct3_o,
    output reg[`PORT_REG_ADDR_WIDTH]    id_rs1_addr_o,
    output reg[`PORT_REG_ADDR_WIDTH]    id_rs2_addr_o,
    output reg[`PORT_funct7_WIDTH]      id_funct7_o,
    output reg[`PORT_REG_ADDR_WIDTH]    id_shamt_o,
    output reg[`PORT_WORD_WIDTH]        id_zimm_o,
    output reg[`PORT_WORD_WIDTH]        id_imm_o,
    output reg[`PORT_CSR_WIDTH]         id_csr_addr_o,

    // 译码错误信号，执行单元收到此信号应抛出异常
    output reg                          id_err_o
);

    // 固定连接, all inst use
    assign id_pc_o = id_pc_i;
    assign id_opcode_o = rst_n == `RstEnable ? `Disable : id_inst_data_i[6:0];
    assign id_funct3_o = id_opcode_o == `Disable ? `Disable : 
                                                    (id_opcode_o != `INST_LUI | 
                                                    id_opcode_o != `INST_AUIPC | 
                                                    id_opcode_o != `INST_JAL) ? id_inst_data_i[14:12] : 3'h0;
    // assign {rs1_req_rd_valid_o, rs2_req_rd_valid_o} = {`Enable, `Enable};

    // 组合逻辑拆解指令
    always @(*) begin : id_core
        if(rst_n == `RstEnable) begin
            id_rs1_addr_o = `Disable;
            id_rs2_addr_o = `Disable;
            id_rd_addr_o = `Disable;
            id_funct7_o = `Disable;
            id_shamt_o = `Disable;
            id_zimm_o = `Disable;
            id_imm_o = `Disable;
            id_csr_addr_o = `Disable;
            id_err_o = `Enable;
        end
        else begin
            case (id_opcode_o)
                `INST_TYPE_I: begin
                    case (id_funct3_o)
                        `INST_ADDI, `INST_SLTI, `INST_SLTIU, `INST_XORI, `INST_ORI, `INST_ANDI: begin
                            id_rd_addr_o = id_inst_data_i[11:7];
                            id_rs1_addr_o = id_inst_data_i[19:15];
                            id_imm_o = id_inst_data_i[31] ? {20'hf_ffff, id_inst_data_i[31:20]} : {20'h0, id_inst_data_i[31:20]};
                            id_err_o = `Disable;
                        end 
                        `INST_SLLI, `INST_SRLI_SRAI: begin
                            id_rd_addr_o = id_inst_data_i[11:7];
                            id_rs1_addr_o = id_inst_data_i[19:15];
                            id_shamt_o = id_inst_data_i[24:20];
                            id_funct7_o = id_inst_data_i[31:25];
                            id_err_o = `Disable;
                        end
                        default: begin
                            id_err_o <= `Enable;
                        end
                    endcase
                end
                `INST_TYPE_L: begin
                    id_rd_addr_o = id_inst_data_i[11:7];
                    id_rs1_addr_o = id_inst_data_i[19:15];
                    id_imm_o = id_inst_data_i[31] ? {20'hf_ffff, id_inst_data_i[31:20]} : {20'h0, id_inst_data_i[31:20]};
                    id_err_o = `Disable;
                end
                `INST_TYPE_S: begin
                    id_rs1_addr_o = id_inst_data_i[19:15];
                    id_rs2_addr_o = id_inst_data_i[24:20];
                    id_imm_o = id_inst_data_i[31] ? {20'hf_ffff, id_inst_data_i[31:25], id_inst_data_i[11:7]} :
                                                     {20'h0, id_inst_data_i[31:25], id_inst_data_i[11:7]};
                    id_err_o = `Disable;
                end
                `INST_TYPE_R_M: begin
                    id_rd_addr_o = id_inst_data_i[11:7];
                    id_rs1_addr_o = id_inst_data_i[19:15];
                    id_rs2_addr_o = id_inst_data_i[24:20];
                    id_funct7_o = id_inst_data_i[31:25];
                    id_err_o = `Disable;
                end
                // J type inst
                `INST_JAL: begin
                    id_rd_addr_o = id_inst_data_i[11:7];
                    id_imm_o = {{11{id_inst_data_i[31]}}, id_inst_data_i[31], id_inst_data_i[19:12], id_inst_data_i[20], id_inst_data_i[30:21], 1'h0};
                    id_err_o = `Disable;
                end
                `INST_JALR: begin
                    id_rd_addr_o = id_inst_data_i[11:7];
                    id_rs1_addr_o = id_inst_data_i[19:15];
                    id_imm_o = {{20{id_inst_data_i[31]}}, id_inst_data_i[31:20]};
                    id_err_o = `Disable;
                end
                `INST_LUI, `INST_AUIPC: begin
                    id_rd_addr_o = id_inst_data_i[11:7];
                    id_imm_o = {id_inst_data_i[31:12], 12'h0};
                    id_err_o = `Disable;
                end
                // B type inst
                `INST_TYPE_B: begin
                    id_rs1_addr_o = id_inst_data_i[19:15];
                    id_rs2_addr_o = id_inst_data_i[24:20];
                    id_imm_o = {{19{id_inst_data_i[31]}}, id_inst_data_i[31], id_inst_data_i[7], id_inst_data_i[30:25], id_inst_data_i[11:8], 1'h0};
                    id_err_o = `Disable;
                end
                // CSR inst
                `INST_CSR:  begin
                    case (id_funct3_o)
                        `INST_CSRRW, `INST_CSRRS, `INST_CSRRC:    begin
                            id_rs1_addr_o = id_inst_data_i[19:15];
                            id_rd_addr_o = id_inst_data_i[11:7];
                            id_csr_addr_o = id_inst_data_i[31:20];
                            id_err_o = `Disable;
                        end 
                        `INST_CSRRWI, `INST_CSRRSI, `INST_CSRRC:    begin
                            id_rd_addr_o = id_inst_data_i[11:7];
                            id_zimm_o = id_inst_data_i[19:15];
                            id_csr_addr_o = id_inst_data_i[31:20];
                            id_err_o = `Disable;
                        end
                        default:    begin
                            id_err_o = `Enable;
                        end
                    endcase
                end

                // fence type inst
                `INST_TYPE_FENCE: begin
                    case (id_funct3_o)
                        `INST_FENCE:    begin
                            
                        end
                        `INST_FENCE_I:  begin
                            // 暂时只是一个无条件跳转下一条指令的指令
                        end
                    endcase
                end 
                default: begin
                    // err or start state
                    id_err_o = `Enable;
                    id_rd_addr_o = 'h0;
                end
            endcase
        end
    end
    
    
endmodule

