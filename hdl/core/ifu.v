//**************************************************
// if
// function:取指令模块，有几个主要功能
// 1.根据pc寄存器地址输出，从存储区域中访问相应位置，并获得返回的数据，也就是指令内容
// 2.pc寄存器获得的地址可以直接作为指令存储的地址
// 3.指令内容由总线返回，该模块仅处理指令相关时序
// 4.暂时可不考虑特殊的逻辑，因为hold或jump状态直接操作了pc地址，这里会被动改变状态
//**************************************************

`include "define.v"

module ifu (
    // 全局时钟与异步复位
    input                                   clk,
    input                                   rst_n,
    // 传递来自pc_reg的pc地址
    input[`PORT_ADDR_WIDTH]                 ifu_pc_i,
    output[`PORT_ADDR_WIDTH]                ifu_pc_o,
    // 传递来自指令存储器的执行指令
    input[`PORT_DATA_WIDTH]                 ifu_inst_data_i,
    output[`PORT_DATA_WIDTH]                ifu_inst_data_o
);
    
    assign ifu_pc_o = ifu_pc_i; 
    assign ifu_inst_data_o = ifu_inst_data_i;


endmodule

