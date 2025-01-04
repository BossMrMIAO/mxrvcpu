// *****************************
// s_bits_compare
// function: compare if two input data are equal
// ********************************

`include "../define.v"

module s_bits_compare #(
    parameter bits_width = `WORD_WIDTH
)(

    input[bits_width-1:0] a,
    input[bits_width-1:0] b,
    output q
);

    assign q = a == b ? 1 : 0;

endmodule
