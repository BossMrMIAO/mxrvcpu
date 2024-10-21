//************************************
// id: 译码模块
// 根据获取到的指令，拆解指令数据
// 整个是一个纯组合逻辑器件，用于拆分传入的指令，并分装到输出接口上
//************************************

`include "define.v"

module id (
    // Global clock and reset for initial all logic output
    input clk,
    input rst_n,
    // pass pc
    input pc_id_i,
    // inst
    input[`PORT_DATA_WIDTH] inst_data_i,
    // 输出拆解信号
    output wire[`PORT_OPCODE_WIDTH]  opcode,
    output reg[`PORT_REG_ADDR_WIDTH] rd,
    output wire[`PORT_funct3_WIDTH]   funct3,
    output reg[`PORT_REG_ADDR_WIDTH] rs1,
    output reg[`PORT_REG_ADDR_WIDTH] rs2,
    output reg[`PORT_funct7_WIDTH]   funct7,
    output reg[`PORT_REG_ADDR_WIDTH] shamt,
    output reg[`PORT_R_TOGGLE_FLAG]  r_toggle_flag,
    output reg[`PORT_WORD_WIDTH] zimm,
    output reg[`PORT_WORD_WIDTH]    imm,
    output reg[`PORT_CSR_WIDTH]     csr,

    // rom valid signal
    output rs1_req_rd_valid_o, rs2_req_rd_valid_o,

    // decode err signal
    output reg id_err_o
);

    // 固定连接, all inst use
    assign opcode = rst_n == `RstEnable ? `Disable : inst_data_i[6:0];
    assign funct3 = opcode == `Disable ? `Disable : (opcode != `INST_LUI | opcode != `INST_AUIPC | opcode != `INST_JAL) ? inst_data_i[14:12] : 3'h0;
    assign {rs1_req_rd_valid_o, rs2_req_rd_valid_o} = {`Enable, `Enable};

    // 组合逻辑拆解指令
    always @(*) begin
        if(rst_n == `RstEnable) begin
            rs1 = `Disable;
            rs2 = `Disable;
            rd = `Disable;
            funct7 = `Disable;
            shamt = `Disable;
            r_toggle_flag = `Disable;
            zimm = `Disable;
            imm = `Disable;
            id_err_o = `Enable;
        end
        else begin
            case (opcode)
                `INST_TYPE_I: begin
                    case (funct3)
                        `INST_ADDI, `INST_SLTI, `INST_SLTIU, `INST_XORI, `INST_ORI, `INST_ANDI: begin
                            rd = inst_data_i[11:7];
                            rs1 = inst_data_i[19:15];
                            imm = inst_data_i[31] ? {20'hf_ffff, inst_data_i[31:20]} : {20'h0, inst_data_i[31:20]};
                            id_err_o = `Disable;
                        end 
                        `INST_SLLI, `INST_SRLI: begin
                            rd = inst_data_i[11:7];
                            rs1 = inst_data_i[19:15];
                            shamt = inst_data_i[24:20];
                            id_err_o = `Disable;
                        end
                        default: begin
                            id_err_o <= `Enable;
                        end
                    endcase
                end
                `INST_TYPE_L: begin
                    rd = inst_data_i[11:7];
                    rs1 = inst_data_i[19:15];
                    imm = inst_data_i[31] ? {20'hf_ffff, inst_data_i[31:20]} : {20'h0, inst_data_i[31:20]};
                    id_err_o = `Disable;
                end
                `INST_TYPE_S: begin
                    rs1 = inst_data_i[19:15];
                    rs2 = inst_data_i[24:20];
                    imm = inst_data_i[31] ? {20'hf_ffff, inst_data_i[31:20]} : {20'h0, inst_data_i[31:20]};
                    id_err_o = `Disable;
                end
                `INST_TYPE_R_M: begin
                    rd = inst_data_i[11:7];
                    rs1 = inst_data_i[19:15];
                    rs2 = inst_data_i[24:20];
                    funct7 = inst_data_i[31:25];
                    id_err_o = `Disable;
                end
                // J type inst
                `INST_JAL: begin
                    rd = inst_data_i[11:7];
                    imm = {11'h0, inst_data_i[31], inst_data_i[19:12], inst_data_i[20], inst_data_i[30:21]};
                    id_err_o = `Disable;
                end
                `INST_JALR: begin
                    rd = inst_data_i[11:7];
                    rs1 = inst_data_i[19:15];
                    imm = {20'h0, inst_data_i[31:20]};
                    id_err_o = `Disable;
                end
                `INST_LUI, `INST_AUIPC: begin
                    rd = inst_data_i[11:7];
                    imm = {inst_data_i[31:12], 12'h0};
                    id_err_o = `Disable;
                end
                // B type inst
                `INST_TYPE_B: begin
                    rs1 = inst_data_i[19:15];
                    rs2 = inst_data_i[24:20];
                    imm = {19'h0, inst_data_i[31], inst_data_i[7], inst_data_i[30:25], inst_data_i[11:8], 1'h0};
                    id_err_o = `Disable;
                end
                // CSR inst
                `INST_CSR:  begin
                    case (funct3)
                        `INST_CSRRW, `INST_CSRRS, `INST_CSRRC:    begin
                            rs1 = inst_data_i[19:15];
                            rd = inst_data_i[11:7];
                            csr = inst_data_i[31:20];
                            id_err_o = `Disable;
                        end 
                        `INST_CSRRWI, `INST_CSRRSI, `INST_CSRRC:    begin
                            rd = inst_data_i[11:7];
                            zimm = inst_data_i[19:15];
                            csr = inst_data_i[31:20];
                            id_err_o = `Disable;
                        end
                        default:    begin
                            id_err_o = `Enable;
                        end
                    endcase
                end
                default: begin
                    // err or start state
                    id_err_o = `Enable;
                    rd = 'h0;
                end
            endcase
        end
    end
    
    
endmodule