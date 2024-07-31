// *****************************
// s_bits_dff
// function: custom data width for tranfer
// ********************************

module s_bits_dff #(
    bits_width = WORD_WIDTH
) (
    // clock signals
    input clk,
    input rst_n,

    // D port data
    input [bits_width - 1 : 0] d,
    // Q port data
    output reg[bits_width - 1 : 0] q
);
    
    // basic dff logic
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            q <= `ZeroWord;
        end
        else begin
            q <= d;
        end
    end


endmodule