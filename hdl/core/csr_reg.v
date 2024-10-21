//**********************************
// csr_reg
// funtion:
// RV32标准控制寄存器实现————实现读写寄存器操作
// 只能读而不能写的寄存器无需在写指令中实现功能
// 需要定义大量宏以提高可读性
// 参考文档应当包含书籍或官方文档

`include "define.v"

module csr_reg (
    // global clock
    input clk,
    input rst_n,
    
    // 读写寄存器一套接口
    input[`CsrRegAddrBusPort] csr_addr_i,
    input   we_i,
    input[`RegBusPort]  csr_wdata_i,
    output reg[`RegBusPort] csr_rdata_o,
    // 状态寄存器必要信号
    input   inst_succ_flag
    );

    // 浮点累计异常
    reg[`RegBusPort] fflags;
    // 浮点动态舍入模式
    reg[`RegBusPort] frm;
    // 浮点控制状态寄存器
    reg[`RegBusPort] fcsr;
    // 机器模式下状态寄存器
    reg[`RegBusPort] mstatus;
    // 指示当前处理器支持架构特性
    reg[`RegBusPort] misa;
    // 控制不同类型中断局部屏蔽
    reg[`RegBusPort] mie;
    // 配置异常的入口地址
    reg[`RegBusPort] mtvec;
    // 机器模式下程序临时保存某些数据
    reg[`RegBusPort] mscratch;
    // 保存进入异常之前的PC值
    reg[`RegBusPort] mepc;
    // 保存进入异常前的出错原因，最高一位为中断域，低31位为异常编号
    reg[`RegBusPort] mcause;
    // 保存进入异常前的出错指令编码值
    reg[`RegBusPort] mtval;
    // 查询终端等待状态
    reg[`RegBusPort] mip;
    // 反应处理器执行了多少个时钟，共64位
    wire[`RegBusPort] mcycle;
    wire[`RegBusPort] mcycleh;
    // 反应处理器成功执行的指令数目，可用于衡量处理器性能
    wire[`RegBusPort] minstret;
    wire[`RegBusPort] minstreth;
    // 只读，供应商编号，为0，为非商业处理器
    reg[`RegBusPort] mvendorid;
    // 只读，微架构编号，为0，未实现
    reg[`RegBusPort] marchid;
    // 只读，硬件实现编号，为0，未实现
    reg[`RegBusPort] mimpid;
    // 只读，hartID
    reg[`RegBusPort] mhartid;
    // 计时器，配合mtimecmp的值以产生中断，按理来说需要放在其他位置
    // 标准RISC-V没有给他们的规定地址
    reg[`RegBusPort] mtime;
    reg[`RegBusPort] mtimecmp;
    reg[`RegBusPort] msip;

    // cycle and instret
    reg[`DoubleRegBusPort]  cycle,instret;
    assign mcycle = cycle[31:0];
    assign mcycleh = cycle[63:32];
    assign minstret = instret[31:0];
    assign minstreth = instret[63:32];
    

    // 周期计数: 时钟，复位，cycle寄存器
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == `RstEnable) begin
            //{mcycleh, mcycle} <= `ZeroDouble;
            cycle <= `ZeroDouble;
        end else begin
            //{mcycleh, mcycle} <= {mcycleh, mcycleh} + 1'b1;
            cycle <= cycle + 1'b1;
        end
    end

    // 指令成功计数：时钟，复位，指令执行成功信号，instret寄存器
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == `RstEnable) begin
            //{minstreth, minstret} <= `ZeroDouble;
            instret <= `ZeroDouble;
        end else begin
            if (inst_succ_flag) begin
                //{minstreth, minstret} <= {minstreth, minstret} + 1'b1;
                instret <= instret + 1'b1;
            end else begin
                //{minstreth, minstret} <= {minstreth, minstret};
                instret <= instret;
            end
        end
    end

    // 读写寄存器逻辑
    // 初始化所有CSR寄存器，需要同步时钟，复位，写请求有效，CSR寄存器地址，写数据
    // we_i为`Read状态时为读，在下个周期返回数据到总线上
    // 同步时钟，复位，读寄存器地址，输出读数据
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == `RstEnable) begin
            // 读写寄存器初始化
            fflags <= `ZeroWord;
            frm <= `ZeroWord;
            fcsr <= `ZeroWord;
            mstatus <= `ZeroWord;
            mie <= `ZeroWord;
            mtvec <= `ZeroWord;
            mscratch <= `ZeroWord;
            mepc <= `ZeroWord;
            mcause <= `ZeroWord;
            mtval <=`ZeroWord;
            mip <= `ZeroWord;
            // 只读寄存器初始化
            // 32位指令集支持
            misa <= `RV32I;
            mvendorid <= `ZeroWord;
            marchid <= `ZeroWord;
            mimpid <= `ZeroWord;
            // 暂不支持超线程技术，仅单核处理器实现
            mhartid <= `SingleHart;
            // 读输出初始化
            csr_rdata_o <= `ZeroWord;
        end else begin
            if (we_i == `Write) begin
                case (csr_addr_i)
                    `CSR_FFLAGS: begin
                        fflags <= csr_wdata_i;
                    end
                    `CSR_FRM: begin
                        frm <= csr_wdata_i;
                    end
                    `CSR_FCSR: begin
                        fcsr <= csr_wdata_i;
                    end
                    `CSR_MSTATUS: begin
                        mstatus <= csr_wdata_i;
                    end
                    `CSR_MIE: begin
                        mie <= csr_wdata_i;
                    end
                    `CSR_MTVEC: begin
                        mtvec <= csr_wdata_i;
                    end
                    `CSR_MSCRATCH: begin
                        mscratch <= csr_wdata_i;
                    end
                    `CSR_MEPC: begin
                        mepc <= csr_wdata_i;
                    end
                    `CSR_MCAUSE: begin
                        mcause <= csr_wdata_i;
                    end
                    `CSR_MTVAL: begin
                        mtval <= csr_wdata_i;
                    end
                    `CSR_MIP: begin
                        mip <= csr_wdata_i;
                    end
                    default: begin
                        csr_rdata_o <= `ErrorWord;
                    end
                endcase
            end else begin
                case (csr_addr_i)
                    `CSR_FFLAGS: begin
                        csr_rdata_o <= fflags;
                    end
                    `CSR_FRM: begin
                        csr_rdata_o <= frm;
                    end
                    `CSR_FCSR: begin
                        csr_rdata_o <= fcsr;
                    end
                    `CSR_MSTATUS: begin
                        csr_rdata_o <= mstatus;
                    end
                    `CSR_MISA: begin
                        csr_rdata_o <= misa;
                    end
                    `CSR_MIE: begin
                        csr_rdata_o <= mie;
                    end
                    `CSR_MTVEC: begin
                        csr_rdata_o <= mtvec;
                    end
                    `CSR_MSCRATCH: begin
                        csr_rdata_o <= mscratch;
                    end
                    `CSR_MEPC: begin
                        csr_rdata_o <= mepc;
                    end
                    `CSR_MCAUSE: begin
                        csr_rdata_o <= mcause;
                    end
                    `CSR_MTVAL: begin
                        csr_rdata_o <= mtval;
                    end
                    `CSR_MIP: begin
                        csr_rdata_o <= mip;
                    end
                    `CSR_MCYCLE: begin
                        csr_rdata_o <= mcycle;
                    end
                    `CSR_MCYCLEH: begin
                        csr_rdata_o <= mcycleh;
                    end
                    `CSR_MINSTRET: begin
                        csr_rdata_o <= minstret;
                    end
                    `CSR_MINSTRETH: begin
                        csr_rdata_o <= minstreth;
                    end
                    `CSR_MVENDORID: begin
                        csr_rdata_o <= mvendorid;
                    end
                    `CSR_MARCHID: begin
                        csr_rdata_o <= marchid;
                    end
                    `CSR_MIMPID: begin
                        csr_rdata_o <= mimpid;
                    end
                    `CSR_MHARTID: begin
                        csr_rdata_o <= mhartid;
                    end


                    
                    default: begin
                        csr_rdata_o <= `ErrorWord;
                    end
                endcase
            end
        end
    end

    
endmodule
