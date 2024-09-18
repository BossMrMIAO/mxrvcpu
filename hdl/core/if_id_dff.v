//****************************************************
// if_id_dff
// function:位于取指单元与译码单元之间，打一拍起到增加流水线级数作用
//****************************************************

module if_id_dff #(
    
) (
    // global clock
    input clk,
    input rst_n,

    // signals to be transfer from ifu
    input[`PORT_DATA_WIDTH] inst_data_dff_i,
    output[`PORT_DATA_WIDTH] inst_data_dff_O
    
);

    s_bits_dff #(
        .bits_width(`WORD_WIDTH)
    ) u_s_bits_dff_0_0  (
        .clk(clk),
        .rst_n(rst_n),
        .d(inst_data_dff_i),
        .q(inst_data_dff_O)
    );
    
endmodule