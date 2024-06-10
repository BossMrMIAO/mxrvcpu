//**************************************************
// mxrv_if
// function:取指令模块，有几个主要功能
// 1.根据pc寄存器地址输出，从存储区域中访问相应位置，并获得返回的数据，也就是指令内容
// 2.pc寄存器获得的地址可以直接作为指令存储的地址
// 3.指令内容有总线返回，该模块仅处理指令相关时序
// 4.暂时可不考虑特殊的逻辑，因为hold或jump状态直接操作了pc地址，这里会被动改变状态
//**************************************************

module mxrv_if(
    input clk,
    input rst_n,
    // pc value = inst_addr
    input[`PORT_WORD_WIDTH] pc_i,
    // inst data
    input[`PORT_WORD_WIDTH] inst_data_i,
    
);
    
    

endmodule

