//********************************************************
// ctrl
// function: decide when to send hold and flush command
//********************************************************

`include "define.v"

module ctrl (
    input  wire                         clk,
    input  wire                         rst_n,

    // 来自执行单元的跳转请求与hold请求             
    input  wire                         ctrl_pc_jump_flag_i,
    input  wire[`PORT_ADDR_WIDTH]       ctrl_pc_jump_i,

    input  wire                         ctrl_pc_hold_flag_i,

    

    // 冲刷流水线端口，分支指令直接冲刷就好
    output wire                         ctrl_pipeline_flush_flag_o,
    output wire[`PORT_ADDR_WIDTH]       ctrl_pc_jump_o,

    // Hold流水线信号，用于除法指令这种需要多周期完成的
    output wire                         ctrl_pipeline_hold_flag_o
);


    assign ctrl_pipeline_flush_flag_o = ctrl_pc_jump_flag_i;
    assign ctrl_pc_jump_o = ctrl_pc_jump_i;
    assign ctrl_pipeline_hold_flag_o = ctrl_pc_hold_flag_i;

endmodule
