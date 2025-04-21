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

    // 来自特殊指令顺序之 读存储器后读寄存器
    input[`PORT_OPCODE_WIDTH]           ctrl_ex_opcode_i,
    input[`PORT_REG_ADDR_WIDTH]         ctrl_ex_rd_addr_i, 
    input[`PORT_REG_ADDR_WIDTH]         ctrl_id_rs1_addr_i,
    input[`PORT_REG_ADDR_WIDTH]         ctrl_id_rs2_addr_i,

    // 冲刷流水线端口，分支指令直接冲刷就好
    output wire                         ctrl_pipeline_flush_flag_o,
    output wire[`PORT_ADDR_WIDTH]       ctrl_pc_jump_o,

    // Hold流水线信号，用于除法指令这种需要多周期完成的
    output wire                         ctrl_pipeline_hold_flag_o
);

    wire hold_1_cycle_case1;
    reg  hold_1_cycle_case2;

    assign ctrl_pipeline_flush_flag_o = ctrl_pc_jump_flag_i;
    assign ctrl_pc_jump_o = ctrl_pc_jump_i;

    assign hold_1_cycle_case1 = (ctrl_ex_opcode_i == `INST_TYPE_L) && 
                                (ctrl_ex_rd_addr_i == ctrl_id_rs1_addr_i || 
                                ctrl_ex_rd_addr_i == ctrl_id_rs2_addr_i);

    always @(posedge clk or negedge rst_n) begin : HOLD_LOGIC
        if(rst_n == `RstEnable) begin
            hold_1_cycle_case2 <= 1'b0;
        end
        else begin
            hold_1_cycle_case2 <= hold_1_cycle_case1;
        end
    end
    
    assign ctrl_pipeline_hold_flag_o = ctrl_pc_hold_flag_i | (hold_1_cycle_case1 & ~hold_1_cycle_case2);

endmodule
