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

    // 写回操作
    input[`PORT_REG_ADDR_WIDTH]     regu_rd_addr_i,
    input[`RegBusPort]              regu_rd_data_i,
    input                           regu_rd_wr_en_i,

    // 冲突地址1，可以连接到ex的rd地址，代表与上一条指令的数据冲突
    input[`PORT_REG_ADDR_WIDTH]     regu_rd_addr_conflict1_i,
    input[`RegBusPort]              regu_rd_data_conflict1_i,
    input                           regu_rd_wr_en_conflict1_i,



    // 冲突地址2，可以连接到mem的rd地址, 代表与倒数第二条指令的冲突
    input[`PORT_REG_ADDR_WIDTH]     regu_rd_addr_conflict2_i,
    input[`RegBusPort]              regu_rd_data_conflict2_i,
    input                           regu_rd_wr_en_conflict2_i

);
    
    // 寄存器
    reg [`RegBusPort]x_reg[0:`REG_DEPTH-1];

    // 初始化寄存器或循环参量
    integer i;

    // 写入组合逻辑
    always @(*) begin : reg_core_read
        if(rst_n == `RstEnable) begin
            regu_rs1_reg_data_o <= `ZeroWord;
            regu_rs2_reg_data_o <= `ZeroWord;
        end else begin
            if (regu_rd_wr_en_conflict1_i && regu_rd_addr_conflict1_i == regu_rs1_addr_i) begin
                regu_rs1_reg_data_o = regu_rd_data_conflict1_i;
            end else if (regu_rd_wr_en_conflict2_i && regu_rd_addr_conflict2_i == regu_rs1_addr_i) begin
                regu_rs1_reg_data_o = regu_rd_data_conflict2_i;
            end else if (regu_rd_wr_en_i && regu_rd_addr_i == regu_rs1_addr_i) begin
                regu_rs1_reg_data_o = regu_rd_data_i;
            end else begin
                regu_rs1_reg_data_o = x_reg[regu_rs1_addr_i];
            end

            if (regu_rd_wr_en_conflict1_i && regu_rd_addr_conflict1_i == regu_rs2_addr_i) begin
                regu_rs2_reg_data_o = regu_rd_data_conflict1_i;
            end else if (regu_rd_wr_en_conflict2_i && regu_rd_addr_conflict2_i == regu_rs2_addr_i) begin
                regu_rs2_reg_data_o = regu_rd_data_conflict2_i;
            end else if (regu_rd_wr_en_i && regu_rd_addr_i == regu_rs2_addr_i) begin
                regu_rs2_reg_data_o = regu_rd_data_i;
            end else begin
                regu_rs2_reg_data_o = x_reg[regu_rs2_addr_i];
            end
        
        end
    end

    // 写入时序逻辑
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == `RstEnable) begin
            for (i = 0; i < `REG_DEPTH; i = i + 1) begin
                x_reg[i] <= i;  // 复位时再次初始化, 实际使用全部初始化为0
            end
        end else begin
            if (regu_rd_wr_en_i && regu_rd_addr_i != 0) begin
                x_reg[regu_rd_addr_i] <= regu_rd_data_i;
            end
        end


    end

endmodule
