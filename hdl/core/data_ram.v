//***********************************************
// data_rom
// funtion: 数据存储器，用于SB，SW等指令
//***********************************************

`include "define.v"

module data_ram (
    input clk,
    input rst_n,
    // from if
    input[`PORT_ADDR_WIDTH] pc_i,
    input pc_send_valid_i,
    output reg pc_receive_ready_o,
    // to if
    output reg[`PORT_DATA_WIDTH] inst_data_o,
    output reg inst_valid_o
);

    reg [`PORT_ADDR_WIDTH]DATA_RAM[0:127];


    always @(posedge clk or negedge rst_n) begin
        if(rst_n == `RstEnable) begin
            pc_receive_ready_o <= `Enable;
            inst_data_o <= `ZeroWord;
            inst_valid_o <= `Enable;
        end else begin
            inst_data_o <= DATA_RAM[pc_i >> 2];
            inst_valid_o <= `Enable;
        end
    end

    
endmodule