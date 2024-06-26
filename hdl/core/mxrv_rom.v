//***********************************************
// mxrv_rom
// funtion: 存储指令，一般按顺序寻址，由pc值来寻址
//***********************************************


module mxrv_rom (
    input clk,
    input rst_n,
    // from mxrv_if
    input[`PORT_WORD_WIDTH] pc_i,
    input rd_valid,
    output reg rd_ready,
    // to mxrv_if
    output reg[`PORT_WORD_WIDTH] inst_data_o,
    output reg inst_valid_o
);

    reg [`RegBus]INST_ROM[0:31];


    always @(posedge clk or negedge rst_n) begin
        if(rst_n == `RstEnable) begin
            rd_ready <= `Enable;
            inst_data_o <= `ZeroWord;
            inst_valid_o <= `Enable;
        end else begin
            if(rd_valid) begin
                inst_data_o <= INST_ROM[pc_i];
                inst_valid_o <= `Enable;
            end
        end
    end

    
endmodule