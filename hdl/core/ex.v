//****************************************
// ex：执行模块
// 接收来自译码后的操作数，执行指令运行内容
// 除了立即数的相关操作，总是要读写内置寄存器的值
// 执行模块也应该用组合逻辑
//****************************************

module mxrv_ex (
    input clk,
    input rst_n,
    // 从指令译码中获得输入数据
    input[`OPCODE_WIDTH]  opcode_i,
    input[`REG_ADDR_WIDTH] rd_i,
    input[`funct3_WIDTH]   funct3_i,
    input[`REG_ADDR_WIDTH] rs1_i,
    input[`REG_ADDR_WIDTH] rs2_i,
    input[`funct7_WIDTH]   funct7_i,
    input[`REG_ADDR_WIDTH] shamt_i,
    input  L_or_A_flag_i,
    input[`REG_ADDR_WIDTH] zimm_i,
    input[`PORT_WORD_WIDTH]    imm_i,

    // 结果寄存器数值
    input[`RegBus]  rs1_reg_data_i,
    input[`RegBus]  rs2_reg_data_i,
    // 回写寄存器
    output[`RegBus] rd_wr_en_o,
    output reg[`RegBus] rd_reg_data_o,
    // 回写存储器

    // 接控制单元
    input Hold_flag_i,

    // 接除法器
    input div_busy_i
);

    // hold住或除法器计算中，就不要再一直不停会写寄存器了
    assign rd_wr_en = (Hold_flag_i | div_busy_i) ? 1'b0 : 1'b1;

    // 组合逻辑执行指令操作
    always @(*) begin
        case (opcode_i)
            `INST_TYPE_I: begin
                case (funct3_i)
                    //加立即数
                    `INST_ADDI: begin
                        rd_reg_data_o = imm_i + rs1_reg_data_i;
                    end
                    `INST_SLTI: begin
                        
                    end
                    // `INST_ADDI, `INST_SLTI, `INST_SLTIU, `INST_XORI, `INST_ORI, `INST_ANDI: begin
                    //     rd = inst_data_i[11:7];
                    //     rs1 = inst_data_i[19:15];
                    //     imm = {20'h0, inst_data_i[31:20]};
                    // end 
                    // `INST_SLLI, `INST_SRI: begin
                    //     rd = inst_data_i[11:7];
                    //     rs1 = inst_data_i[19:15];
                    //     shamt = inst_data_i[24:20];
                    //     L_or_A_flag = inst_data_i[30];
                    // end
                    default: begin
                        
                    end
                endcase
            end
            // `INST_TYPE_L: begin
            //     rd = inst_data_i[11:7];
            //     rs1 = inst_data_i[19:15];
            //     imm = {20'h0, inst_data_i[31:20]};
            // end
            // `INST_TYPE_S: begin
            //     rs1 = inst_data_i[19:15];
            //     rs2 = inst_data_i[24:20];
            //     imm = {20'h0, inst_data_i[31:25], inst_data_i[11:7]};
            // end
            // `INST_TYPE_R_M: begin
            //     rd = inst_data_i[11:7];
            //     rs1 = inst_data_i[19:15];
            //     rs2 = inst_data_i[24:20];
            //     funct7 = inst_data_i[31:25];
            // end
            // `INST_JAL: begin
            //     rd = inst_data_i[11:7];
            //     imm = {11'h0, inst_data_i[31], inst_data_i[19:12], inst_data_i[20], inst_data_i[30:21]};
            // end
            // `INST_JALR: begin
            //     rd = inst_data_i[11:7];
            //     rs1 = inst_data_i[19:15];
            //     imm = {20'h0, inst_data_i[31:20]};
            // end
            default: begin
                
            end
        endcase
    end

    


    
endmodule