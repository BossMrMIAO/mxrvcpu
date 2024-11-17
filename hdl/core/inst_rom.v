//***********************************************
// inst_rom
// funtion: 存储指令，一般按顺序寻址，由pc值来寻址，本质是多路选择器
//***********************************************

`include "define.v"

module inst_rom (
    input clk,
    input rst_n,
    // 来自ifu的pc地址(实际上是来自于pc_reg的)
    input[`PORT_ADDR_WIDTH]         inst_rom_pc_i,
    // 送给ifu的指令内容
    output[`PORT_DATA_WIDTH]    inst_rom_inst_data_o
);

    reg [`PORT_ADDR_WIDTH]INST_ROM[0:511];



    assign inst_rom_inst_data_o = INST_ROM[inst_rom_pc_i >> 2];


    
endmodule

