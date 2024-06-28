//*****************************************************
// mxrv_reg
// function:寄存器，包含32个寄存器，每个寄存器可以存储32比特信息
// 给id提供两个源寄存器数据接口，给ex提供回写rd寄存器数据接口
//*****************************************************

module mxrv_reg (
    input clk,
    input rst_n,

    // 寄存器的读写信号
    input[`RegBus] rs1_addr_i,
    input[`RegBus] rs2_addr_i,
    input[`RegBus] rd_addr_i,

    input we_i,

    output reg[`RegBus] rs1_reg_data_o,
    output reg[`RegBus] rs2_reg_data_o,
    input[`RegBus] rd_data_i

);
    
    // 寄存器
    reg [`RegBus]x_reg[0:4];



    // 读写逻辑
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == `RstEnable) begin
            rs1_reg_data_o <= `ZeroWord;
            rs2_reg_data_o <= `ZeroWord;
        end else begin
            if(we_i)    begin
                x_reg[rd_addr_i] <= rd_data_i;
            end else    begin
                rs1_reg_data_o <= x_reg[rs1_addr_i];
                rs2_reg_data_o <= x_reg[rs2_addr_i];
            end
        end
    end

endmodule