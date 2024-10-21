//*****************************************************
// x_reg
// function:寄存器，包含32个寄存器，每个寄存器可以存储32比特信息
// 给id提供两个源寄存器数据接口，给ex提供回写rd寄存器数据接口
//*****************************************************

`include "define.v"

module regu (
    input clk,
    input rst_n,

    // id读取信号
    input[`RegBusPort] rs1_i,
    input[`RegBusPort] rs2_i,
    input   rs1_req_rd_valid_i, rs2_req_rd_valid_i,
    output reg[`RegBusPort] rs1_reg_data_o,
    output reg[`RegBusPort] rs2_reg_data_o,

    // ex写回操作
    input[`RegBusPort] rd_i,
    input[`RegBusPort] rd_data_i,
    input   rd_req_wr_valid_i
 

);
    
    // 寄存器
    reg [`RegBusPort]x_reg[0:31];



    // 读写逻辑
    always @(*) begin
        if(rst_n == `RstEnable) begin
            rs1_reg_data_o = `ZeroWord;
            rs2_reg_data_o = `ZeroWord;
            for (int i = 0; i < 32; i = i + 1) begin
                x_reg[i] <= i;  // 复位时再次初始化
            end
        end else begin
            if(rd_req_wr_valid_i)    begin
                x_reg[rd_i] = rd_data_i;
            end else begin
                rs1_reg_data_o = rs1_req_rd_valid_i ? x_reg[rs1_i] : `ZeroWord;
                rs2_reg_data_o = rs2_req_rd_valid_i ? x_reg[rs2_i] : `ZeroWord;
            end
        end
    end

endmodule