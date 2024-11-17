// *****************************
// s_bits_dff
// function: custom data width for tranfer
// ********************************

`include "../define.v"

module s_bits_dff #(
    parameter bits_width = `WORD_WIDTH  // 定义触发器的位宽，默认为8位
)(
    input clk,            // 时钟信号
    input rst_n,          // 异步复位信号，低电平有效
    input flush_flag,      // 流水线冲刷信号来临
    input [bits_width-1:0] zero_point, //冲刷流水线复位信号，故意与实际的复位做了隔离
    input [bits_width-1:0] d,  // 数据输入，WIDTH位宽
    output reg [bits_width-1:0] q  // 数据输出，WIDTH位宽
);

// 多比特D触发器的行为描述
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        q <= {bits_width{1'b0}};  // 如果复位信号有效，将输出清零
    end else if(flush_flag) begin
        q <= zero_point;
    end else begin
        q <= d;             // 否则，将输入数据同步到输出
    end
end

endmodule