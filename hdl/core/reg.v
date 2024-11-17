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
    input[`PORT_REG_ADDR_WIDTH]     regu_rs1_addr_i,
    input[`PORT_REG_ADDR_WIDTH]     regu_rs2_addr_i,
    output reg[`RegBusPort]         regu_rs1_reg_data_o,
    output reg[`RegBusPort]         regu_rs2_reg_data_o,

    // ex写回操作
    input[`PORT_REG_ADDR_WIDTH]     regu_rd_addr_i,
    input[`RegBusPort]              regu_rd_data_i,
    input                           regu_rd_wr_en_i
 

);
    
    // 寄存器
    reg [`RegBusPort]x_reg[0:31];

    // 初始化寄存器或循环参量
    integer i;

    // 读取组合逻辑
    always @(*) begin : reg_core_read
        if(rst_n == `RstEnable) begin
            regu_rs1_reg_data_o = `ZeroWord;
            regu_rs2_reg_data_o = `ZeroWord;
            for (i = 0; i < 32; i = i + 1) begin
                x_reg[i] <= i;  // 复位时再次初始化, 实际使用全部初始化为0
            end
        end else begin
            // 这里注意初始化的时候必须直接x[0]=0
            if(regu_rd_wr_en_i)    begin
                regu_rs1_reg_data_o = (regu_rs1_addr_i == regu_rd_addr_i && regu_rs1_addr_i != 0) ? regu_rd_data_i : x_reg[regu_rs1_addr_i];
                regu_rs2_reg_data_o = (regu_rs2_addr_i == regu_rd_addr_i && regu_rs2_addr_i != 0) ? regu_rd_data_i : x_reg[regu_rs2_addr_i];
            end else begin
                regu_rs1_reg_data_o = x_reg[regu_rs1_addr_i];
                regu_rs2_reg_data_o = x_reg[regu_rs2_addr_i];
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == `RstEnable) begin

        end else begin
            x_reg[regu_rd_addr_i] <= (regu_rd_wr_en_i && regu_rd_addr_i != 0) ? regu_rd_data_i : x_reg[regu_rd_addr_i];
        end


    end

endmodule
