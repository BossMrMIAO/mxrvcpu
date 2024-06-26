//*****************************************
// mxrv_top_tb.sv
// function: provide module instance and basic test
//*****************************************
`timescale 1ns/1ps

`include "mxrv_define.v"
`include "mxrv_pc_reg.v"
`include "mxrv_csr_reg.v"
`include "mxrv_if.v"
`include "mxrv_rom.v"

module mxrv_top_tb ();

    reg clk;
    reg rst_n;

    // jump signals
    reg jump_flag;
    reg [`PORT_WORD_WIDTH]  jump_addr;

    // hold signals
    reg hold_flag;

    // pc_reg output
    wire [`PORT_WORD_WIDTH] pc_from_pc_to_if;

    // csr_reg ports
    reg[`CsrRegAddrBus] csr_addr;
    reg we;
    reg[`RegBus]    csr_wdata;
    wire[`RegBus]   csr_rdata;

    // wire between if and rom
    wire[`RegBus]   inst_if_rom;
    wire    rd_valid_if_rom;
    wire    rd_ready_if_rom;
    wire    inst_valid_if_rom;
    
    // instance pc_reg
    mxrv_pc_reg u_pc_reg (
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
    mxrv_csr_reg u_csr_reg (
        .clk(clk),
        .rst_n(rst_n),
        .csr_addr_i(csr_addr),
        .csr_wdata_i(csr_wdata),
        .we_i(we),
        .csr_rdata_o(csr_rdata)
    );

    // mxrv_if
    mxrv_if u_mxrv_if (
        .clk(clk),
        .rst_n(rst_n),
        .pc_i(pc_from_pc_to_if),
        .inst_valid_i(inst_valid_if_rom),
        .inst_data_i(inst_if_rom),
        .rd_valid(rd_valid_if_rom),
        .rd_ready(rd_ready_if_rom),
        .pc_o()
        

    );

    //mxrv_rom
    mxrv_rom u_mxrv_rom (
        .clk(clk),
        .rst_n(rst_n),
        .pc_i(pc_from_pc_to_if),
        .rd_valid(rd_valid_if_rom),
        .rd_ready(rd_ready_if_rom),
        .inst_data_o(inst_if_rom),
        .inst_valid_o(inst_valid_if_rom)
    );

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

    // sim timeout
    initial begin
        #10000
        $display("Time Out.");
        $finish;
    end

    // generate wave file, used by gtkwave
    initial begin
        $dumpfile("mxrv_top_tb.vcd");
        $dumpvars(0, mxrv_top_tb);
    end

endmodule
