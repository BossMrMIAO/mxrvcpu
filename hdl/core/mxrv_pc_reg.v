//**************************************************
// mxrv_pc_reg.v
// function: PC指针变化逻辑
// case1: 默认状态，一拍，PC指针地址偏移+4
// case2: 增加hold状态，此状态下PC指针保持，流水线暂停
// case3: 地址跳转，此状态下PC直接装在送过来的地址
//**************************************************

module mxrv_pc_reg (
    input   clk,
    input   rst_n,
    // case2 use
    input   hold_flag_i,
    // case3 use
    input   jump_flag_i,
    input [`PORT_WORD_WIDTH]  jump_addr_i,

    // output
    output [`PORT_WORD_WIDTH]    pc_o
);

    reg [`PORT_WORD_WIDTH]   pc_reg;

    assign pc_o = pc_reg;

    always @(posedge clk or negedge rst_n) begin
        // reset logic
        if(!rst_n) begin
            pc_reg <= 0;
        end
        // hold logic
        else if(hold_flag_i) begin
            pc_reg <= pc_reg;
        end
        // jump logic
        else if(jump_flag_i) begin
            pc_reg <= jump_addr_i;
        end
        // case1 logic
        else begin
            pc_reg <= pc_reg + `BYTES_IN_A_WORD;
        end
    end
    
endmodule

