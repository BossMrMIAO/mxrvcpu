//**************************************************
// if
// function:取指令模块，有几个主要功能
// 1.根据pc寄存器地址输出，从存储区域中访问相应位置，并获得返回的数据，也就是指令内容
// 2.pc寄存器获得的地址可以直接作为指令存储的地址
// 3.指令内容由总线返回，该模块仅处理指令相关时序
// 4.暂时可不考虑特殊的逻辑，因为hold或jump状态直接操作了pc地址，这里会被动改变状态
//**************************************************

module ifu (
    // global clock
    input clk,
    input rst_n,
    // pc value = inst_addr，链接来自pc_reg
    input[`PORT_WORD_WIDTH] pc_i,
    // inst data and send out pc，与指令存储器ROM的交互接口
    input   inst_valid_i,
    input[`PORT_WORD_WIDTH] inst_data_i,
    output reg pc_send_valid_o,
    output reg[`PORT_WORD_WIDTH] pc_ifu_o,
    input pc_receive_ready_i,


    // 将pc值与指令一并送出，时序需要注意, 连接DFF1
    output reg  inst_ifu_valid_o,
    output reg[`PORT_WORD_WIDTH]    inst_data_ifu_o
    
);
    
    // 同步控制pc值与指令值
    // 待考虑后续ex真的需要pc值吗？
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == `RstEnable) begin
            inst_ifu_valid_o <= `Disable;
            pc_ifu_o <= `Disable;
            inst_data_ifu_o <= `Disable;
            // transfer pc to INST rom
            pc_ifu_o <= `ZeroWord;
            pc_send_valid_o <= `Disable;
        end else begin
            // 来自ROM的指令内容有效
            if(inst_valid_i) begin
                inst_data_ifu_o <= inst_data_i;
                inst_ifu_valid_o <= `Enable;
            end
            // ROM给出的可以接收指令ready信号
            if(pc_receive_ready_i) begin
                pc_ifu_o <= pc_i;
                pc_send_valid_o <= `Enable;
            end
        end
    end


    

endmodule

