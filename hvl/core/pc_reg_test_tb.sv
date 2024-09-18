//*****************************************
// pc_reg_test_tb.sv
// function: provide module instance and basic test
//*****************************************
`timescale 1ns/1ps

module pc_reg_test_tb ();

    reg clk;
    reg rst_n;

//PC_REG_TEST
    // jump signals
    reg jump_flag;
    reg [`PORT_ADDR_WIDTH]  jump_addr;

    // hold signals
    reg hold_flag;


    // csr_reg_signal
    reg we;
    reg[`RegBusPort] csr_addr;
    reg[`RegBusPort] csr_wdata;
    reg[`RegBusPort] csr_rdata;
    
    // instance pc_reg
    pc_reg u_pc_reg (
        .clk(clk),
        .rst_n(rst_n),
        // case2 use 
        .hold_flag_i(hold_flag),
        // case3 use
        .jump_flag_i(jump_flag),
        .jump_addr_i(jump_addr),
        .pc_o(pc_from_pc_to_if)
    );

    // instance csr_reg
    csr_reg u_csr_reg (
        .clk(clk),
        .rst_n(rst_n),
        .csr_addr_i(csr_addr),
        .csr_wdata_i(csr_wdata),
        .we_i(we),
        .csr_rdata_o(csr_rdata)
    );

    // case1 normal pc = pc + 4

    // case2 hold
    initial begin
        hold_flag = 0;
        #1000;
        hold_flag = 1;
        #2000;
        hold_flag = 0;
        #3000;
        hold_flag = 1;
        #4000;
        hold_flag = 0;
    end

    // case3 jump
    initial begin
        jump_flag = 0;
        jump_addr = 0;
        #4500;
        jump_flag = 1;
        jump_addr = $urandom;
        repeat(2) begin
            @(negedge clk);
        end
        jump_flag = 0;
        jump_addr = 0;
    end


    // CSR_REG READ OR WRITE TEST
    initial begin
        we = `Read;
        csr_wdata = `ZeroWord;
        csr_addr = `ZeroWord;
        #5000;
        fork
            begin: READ
                #100;
                we = `Read;
                csr_addr = `CSR_MISA;
            end
            begin: WRITE
                #300;
                we = `Write;
                csr_addr = `CSR_MSTATUS;
                csr_wdata = $urandom;
            end
            begin: CHECK
                #400;
                we = `Read;
                csr_addr = `CSR_MSTATUS;
            end
        join
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
        $dumpvars(0, pc_reg_test_tb);
    end


endmodule
