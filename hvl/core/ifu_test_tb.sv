//*****************************************
// 
//*****************************************
`timescale 1ns/1ps

module ifu_test_tb ();

    reg clk;
    reg rst_n;

// ifu test
    reg[`RegBus] pc;

    wire inst_valid;
    wire[`RegBus] inst_data;
    wire pc_send_valid;
    wire pc_receive_ready;

    wire[`PORT_WORD_WIDTH] pc_ifu;
    wire inst_ifu_valid;
    wire[`PORT_WORD_WIDTH] inst_data_ifu;

    ifu u_ifu (
        .clk(clk),
        .rst_n(rst_n),
        .pc_i(pc),
        .inst_valid_i(inst_valid),
        .inst_data_i(inst_data),
        .pc_send_valid_o(pc_send_valid),
        .pc_receive_ready_i(pc_receive_ready),
        .pc_ifu_o(pc_ifu),
        .inst_ifu_valid_o(inst_ifu_valid),
        .inst_data_ifu_o(inst_data_ifu)
    );

    rom u_rom (
        .clk(clk),
        .rst_n(rst_n),
        .pc_i(pc),
        .pc_send_valid_i(pc_send_valid),
        .pc_receive_ready_o(pc_receive_ready),
        .inst_data_o(inst_data),
        .inst_valid_o(inst_valid)
    );

    // instance pc_reg
    pc_reg u_pc_reg (
        .clk(clk),
        .rst_n(rst_n),
        .pc_o(pc)
    );

    // instance id
    id u_id (
        .inst_data_i(inst_data_ifu)
    );

    // initial ROM for load inst. content
    initial begin
        $readmemh ("inst.data", ifu_test_tb.u_rom.INST_ROM);
    end
    



// CLK_ENV
    // clk logic
    initial begin
        clk = 0;
        forever begin
            #10;
            clk = ~clk;
        end
    end

    // rst_n logic
    initial begin
        #10;
        rst_n = 0;
        #90;
        rst_n = 1;
    end

    // sim timeout
    initial begin
        #10000
        $display("Time Out.");
        $finish;
    end

    // generate wave file, used by gtkwave(vcd) or vcs(fsdb)
    initial begin
        // $dumpfile("tb.vcd");
        $dumpfile("tb.fsdb");
        $dumpvars(0, ifu_test_tb);
    end


endmodule
