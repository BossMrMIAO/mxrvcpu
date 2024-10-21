//***********************************************
// rom
// funtion: 存储指令，一般按顺序寻址，由pc值来寻址
//***********************************************

`include "define.v"

module rom (
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

    reg [`PORT_ADDR_WIDTH]INST_ROM[0:127];


    always @(posedge clk or negedge rst_n) begin
        if(rst_n == `RstEnable) begin
            pc_receive_ready_o <= `Enable;
            inst_data_o <= `ZeroWord;
            inst_valid_o <= `Enable;
        end else begin
            inst_data_o <= INST_ROM[pc_i >> 2];
            inst_valid_o <= `Enable;
        end
    end

    
endmodule