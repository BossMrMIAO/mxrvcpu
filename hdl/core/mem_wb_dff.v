//****************************************************
// ex_mem_dff
// function:位于执行单元与访存单元之间，打一拍起到增加流水线级数作用
//****************************************************

`include "define.v"

module ex_mem_dff (

    // 全局时钟与异步复位
    input clk,
    input rst_n,

    // PC传递
    input[`PORT_ADDR_WIDTH]     ex_mem_dff_pc_i,
    output[`PORT_ADDR_WIDTH]    ex_mem_dff_pc_o,

    // signals to be transfer from ifu
    input[`PORT_DATA_WIDTH]     ifu_id_dff_inst_data_i,
    output[`PORT_DATA_WIDTH]    ifu_id_dff_inst_data_o,

    // 来自ctrl冲刷信号
    input                       ex_mem_dff_pipeline_flush_flag
    
);

    s_bits_dff #(
        .bits_width(`WORD_WIDTH)
    ) u_s_bits_dff_0_0  (
        .clk(clk),
        .rst_n(rst_n),
        .flush_flag(if_id_dff_pipeline_flush_flag),
        .zero_point({`WORD_WIDTH{1'b0}}),
        .d(ifu_id_dff_pc_i),
        .q(ifu_id_dff_pc_o)
    );

    s_bits_dff #(
        .bits_width(`WORD_WIDTH)
    ) u_s_bits_dff_0_1  (
        .clk(clk),
        .rst_n(rst_n),
        .flush_flag(if_id_dff_pipeline_flush_flag),
        .zero_point({`WORD_WIDTH{1'b0}}),
        .d(ifu_id_dff_inst_data_i),
        .q(ifu_id_dff_inst_data_o)
    );
    
endmodule
