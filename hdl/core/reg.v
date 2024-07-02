//*****************************************************
// x_reg
// function:寄存器，包含32个寄存器，每个寄存器可以存储32比特信息
// 给id提供两个源寄存器数据接口，给ex提供回写rd寄存器数据接口
//*****************************************************

module regu (
    input clk,
    input rst_n,

    // id读取信号
    input[`RegBus] rs1_addr_i,
    input[`RegBus] rs2_addr_i,
    input   rs1_req_rd_valid_i, rs2_req_rd_valid_i,
    output reg[`RegBus] rs1_reg_data_o,
    output reg[`RegBus] rs2_reg_data_o,

    // ex写回操作
    input[`RegBus] rd_addr_i,
    input[`RegBus] rd_data_i,
    input   rd_req_wr_valid_i
 

);
    
    // 寄存器
    reg [`RegBus]x_reg[0:31];



    // 读写逻辑
    always @(*) begin
        if(rst_n == `RstEnable) begin
            rs1_reg_data_o = `ZeroWord;
            rs2_reg_data_o = `ZeroWord;
            x_reg[0] = 32'h10;
            x_reg[1] = 32'h11;
        end else begin
            if(rd_req_wr_valid_i)    begin
                x_reg[rd_addr_i] = rd_data_i;
            end else begin
                rs1_reg_data_o = rs1_req_rd_valid_i ? x_reg[rs1_addr_i] : `ZeroWord;
                rs2_reg_data_o = rs2_req_rd_valid_i ? x_reg[rs2_addr_i] : `ZeroWord;
            end
        end
    end

endmodule