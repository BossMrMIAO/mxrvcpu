//*****************************************
// 
//*****************************************
`timescale 1ns/1ps

`include "../../hdl/core/define.v"

module rv_core_test_tb ();

    reg clk;
    reg rst_n;

    // 实例化处理器内核
    soc_core_top  soc_core_top_inst (
        .clk(clk),
        .rst_n(rst_n)
      );


// CLK_ENV
    // clk logic
    initial begin
        clk = 0;
        forever begin
            #5;
            clk = ~clk;
        end
    end

    // rst_n logic
    initial begin
        @(negedge clk);
        rst_n = 0;
        @(negedge clk);
        rst_n = 1;
    end

    // initial ROM for load inst. content
    initial begin
        $readmemh ("../script/inst.data", rv_core_test_tb.soc_core_top_inst.inst_rom_inst.INST_ROM);
    end

    // sim timeout
    initial begin
        #10000
        $display("Time Out.");
        $finish;
    end

    // // generate wave file, used by gtkwave(vcd) or vcs(fsdb)
    // initial begin
    //     // $dumpfile("tb.vcd");
    //     $dumpfile("tb.fsdb");
    //     $dumpvars(0, rv_core_test_tb);
    // end

    // 检查仿真的正确性与否
    initial begin
        #150;

        $display("Simulation Start! s10 = %d, s11 = %d", 
        rv_core_test_tb.soc_core_top_inst.regu_inst.x_reg[`s10], rv_core_test_tb.soc_core_top_inst.regu_inst.x_reg[`s11]);

        wait(rv_core_test_tb.soc_core_top_inst.regu_inst.x_reg[`s10] == 32'h1);

        // repeat 为了给至少连续2个周期写入PASS状态，稳定的s10=1和s11=1
        repeat(5) @ (posedge clk);

        $display("Simulation finish! s10 = %d, s11 = %d", 
        rv_core_test_tb.soc_core_top_inst.regu_inst.x_reg[`s10], rv_core_test_tb.soc_core_top_inst.regu_inst.x_reg[`s11]);

        if(rv_core_test_tb.soc_core_top_inst.regu_inst.x_reg[`s11] == 32'h1) begin
            $display("Simulation PASS! s11 = %d", rv_core_test_tb.soc_core_top_inst.regu_inst.x_reg[`s11]);
        end else begin
            $display("Simulation FAIL! s11 = %d", rv_core_test_tb.soc_core_top_inst.regu_inst.x_reg[`s11]);
        end
    end

    

endmodule


