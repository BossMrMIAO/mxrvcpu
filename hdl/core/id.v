//************************************
// id: 译码模块
// 根据获取到的指令，拆解指令数据
// 整个是一个纯组合逻辑器件，用于拆分传入的指令，并分装到输出接口上
//************************************

module id (
    // inst
    input[`PORT_WORD_WIDTH] inst_data_i,
    // 输出拆解信号
    output wire[`OPCODE_WIDTH]  opcode,
    output reg[`REG_ADDR_WIDTH] rd,
    output wire[`funct3_WIDTH]   funct3,
    output reg[`REG_ADDR_WIDTH] rs1,
    output reg[`REG_ADDR_WIDTH] rs2,
    output reg[`funct7_WIDTH]   funct7,
    output reg[`REG_ADDR_WIDTH] shamt,
    output reg  L_or_A_flag,
    output reg[`REG_ADDR_WIDTH] zimm,
    output reg[`PORT_WORD_WIDTH]    imm,

    // decode err signal
    output reg id_err_o
);

    // 固定连接
    assign opcode = inst_data_i[6:0];
    assign funct3 = (opcode != `INST_LUI | opcode != `INST_AUIPC | opcode != `INST_JAL) ? inst_data_i[14:12] : 3'h0;

    // 组合逻辑拆解指令
    always @(*) begin
        case (opcode)
            `INST_TYPE_I: begin
                case (funct3)
                    `INST_ADDI, `INST_SLTI, `INST_SLTIU, `INST_XORI, `INST_ORI, `INST_ANDI: begin
                        rd = inst_data_i[11:7];
                        rs1 = inst_data_i[19:15];
                        imm = {20'h0, inst_data_i[31:20]};
                        id_err_o = `Disable;
                    end 
                    `INST_SLLI, `INST_SRI: begin
                        rd = inst_data_i[11:7];
                        rs1 = inst_data_i[19:15];
                        shamt = inst_data_i[24:20];
                        L_or_A_flag = inst_data_i[30];
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
                imm = {20'h0, inst_data_i[31:20]};
                id_err_o = `Disable;
            end
            `INST_TYPE_S: begin
                rs1 = inst_data_i[19:15];
                rs2 = inst_data_i[24:20];
                imm = {20'h0, inst_data_i[31:25], inst_data_i[11:7]};
                id_err_o = `Disable;
            end
            `INST_TYPE_R_M: begin
                rd = inst_data_i[11:7];
                rs1 = inst_data_i[19:15];
                rs2 = inst_data_i[24:20];
                funct7 = inst_data_i[31:25];
                id_err_o = `Disable;
            end
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
            default: begin
                id_err_o = `Enable;
            end
        endcase
    end
    
endmodule