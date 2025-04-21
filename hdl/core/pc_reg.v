//**************************************************
// pc_reg.v
// function: PC指针变化逻辑
// case1: 默认状态，一拍，PC指针地址偏移+4
// case2: 增加hold状态，此状态下PC指针保持，流水线暂停
// case3: 地址跳转，此状态下PC直接装在送过来的地址
// 2024.8.1 check OK. Done
//**************************************************

`include "define.v"

module pc_reg (
    input                               clk,
    input                               rst_n,
    // hold信号有效时，PC指针保持
    input                               pc_reg_hold_flag_i,
    // jump跳转信号有效，该状态会装载由jump_addr_i
    input                               pc_reg_jump_flag_i,
    input [`PORT_ADDR_WIDTH]            pc_reg_jump_addr_i,
    // 输出wire类型PC值
    output[`PORT_ADDR_WIDTH]            pc_reg_pc_o
);

    reg [`PORT_ADDR_WIDTH]              pc_reg_r;

    assign pc_reg_pc_o = pc_reg_r;

    always @(posedge clk or negedge rst_n) begin
        // 复位
        if(!rst_n) begin
            pc_reg_r <= 0;
        end
        // hold状态
        else if(pc_reg_hold_flag_i) begin
            pc_reg_r <= pc_reg_r;
        end
        // 跳转状态
        else if(pc_reg_jump_flag_i) begin
            pc_reg_r <= pc_reg_jump_addr_i;
        end
        // 常规地址自加
        else begin
            pc_reg_r <= pc_reg_r + `BYTES_IN_A_WORD;
        end
    end
    
endmodule



