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
    input[`CsrRegAddrBusPort] csr_waddr_i,
    input[`CsrRegAddrBusPort] csr_raddr_i,
    input   csr_we_i,
    input[`RegBusPort]  csr_wdata_i,
    output reg[`RegBusPort] csr_rdata_o,
    // 状态寄存器必要信号
    input   csr_inst_succ_flag_i,


    // CSR寄存器读写冲突逻辑
    // 冲突地址1，可以连接到csr寄存器的csr地址，代表与上一条指令的数据冲突,z自当优先相应
    input[`CsrRegAddrBusPort]       csr_addr_conflict1_i,
    input[`RegBusPort]              csr_data_conflict1_i,
    input                           csr_wr_en_conflict1_i,

    // 冲突地址2，可以连接到mem的rd地址, 代表与倒数第二条指令的冲突
    input[`CsrRegAddrBusPort]       csr_addr_conflict2_i,
    input[`RegBusPort]              csr_data_conflict2_i,
    input                           csr_wr_en_conflict2_i
    );

    // 浮点累计异常, RO
    reg[`RegBusPort] fflags;
    // 浮点动态舍入模式, RW
    reg[`RegBusPort] frm;
    // 浮点控制状态寄存器, RO
    reg[`RegBusPort] fcsr;

    // 如下必选寄存器

    // 机器模式下状态寄存器, RW
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

    // 如下只读寄存器，只反映状态

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
            if (csr_inst_succ_flag_i) begin
                //{minstreth, minstret} <= {minstreth, minstret} + 1'b1;
                instret <= instret + 1'b1;
            end else begin
                //{minstreth, minstret} <= {minstreth, minstret};
                instret <= instret;
            end
        end
    end

    // 写寄存器逻辑
    // 初始化所有CSR寄存器，需要同步时钟，复位，写请求有效，CSR寄存器地址，写数据
    // we_i为`Read状态时为读，在下个周期返回数据到总线上
    // 同步时钟，复位，读寄存器地址，输出读数据
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == `RstEnable) begin
            // 读写寄存器初始化
            fflags <= `ZeroWord;
            frm <= `ZeroWord;
            fcsr <= `ZeroWord;
            // 必要寄存器初始化
            mstatus <= `ZeroWord;
            // mstatus[0] = 1; // MIE, 全局中断使能
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
            if (csr_we_i == `Write) begin
                case (csr_waddr_i)
                    // RW Registers
                    `CSR_FFLAGS:    fflags <= csr_wdata_i;
                    `CSR_FRM:       frm <= csr_wdata_i;    
                    `CSR_FCSR:      fcsr <= csr_wdata_i;
                    `CSR_MSTATUS:   mstatus <= csr_wdata_i;
                    `CSR_MIE:       mie <= csr_wdata_i;
                    `CSR_MTVEC:     mtvec <= csr_wdata_i;
                    `CSR_MSCRATCH:  mscratch <= csr_wdata_i;
                    `CSR_MEPC:      mepc <= csr_wdata_i;
                    `CSR_MCAUSE:    mcause <= csr_wdata_i;
                    `CSR_MTVAL:     mtval <= csr_wdata_i;
                    `CSR_MIP:       mip <= csr_wdata_i;
                    default:        csr_rdata_o <= `ErrorWord;
                endcase
            end
        end
    end


    // 读寄存器逻辑
    always @(*) begin
        if(rst_n == `RstEnable) begin
            csr_rdata_o = `ZeroWord;
        end else begin // 寄希望于软件配置指令完全正确，否则想非法地址写指令再去读，那么读取就真的错误了
            if (csr_wr_en_conflict1_i && csr_addr_conflict1_i == csr_raddr_i) begin
                csr_rdata_o = csr_data_conflict1_i;
            end else if (csr_wr_en_conflict2_i && csr_addr_conflict2_i == csr_raddr_i) begin
                csr_rdata_o = csr_data_conflict2_i;
            end else if (csr_we_i && csr_waddr_i == csr_raddr_i) begin
                csr_rdata_o = csr_wdata_i;
            end else begin
                case (csr_raddr_i)
                    // RW Registers
                    `CSR_FFLAGS:    csr_rdata_o = fflags;
                    `CSR_FRM:       csr_rdata_o = frm;   
                    `CSR_FCSR:      csr_rdata_o = fcsr;
                    `CSR_MSTATUS:   csr_rdata_o = mstatus;
                    `CSR_MIE:       csr_rdata_o = mie;
                    `CSR_MTVEC:     csr_rdata_o = mtvec;
                    `CSR_MSCRATCH:  csr_rdata_o = mscratch;
                    `CSR_MEPC:      csr_rdata_o = mepc;
                    `CSR_MCAUSE:    csr_rdata_o = mcause;
                    `CSR_MTVAL:     csr_rdata_o = mtval;
                    `CSR_MIP:       csr_rdata_o = mip;
                    // R Registers
                    `CSR_MCYCLE:    csr_rdata_o = mcycle;
                    `CSR_MCYCLEH:   csr_rdata_o = mcycleh;
                    `CSR_MINSTRET:  csr_rdata_o = minstret;
                    `CSR_MINSTRETH: csr_rdata_o = minstreth;
                    `CSR_MVENDORID: csr_rdata_o = mvendorid;
                    `CSR_MARCHID:   csr_rdata_o = marchid;
                    `CSR_MIMPID:    csr_rdata_o = mimpid;
                    `CSR_MHARTID:   csr_rdata_o = mhartid;
                    default:        csr_rdata_o = `ErrorWord;
                endcase
            end
        end       
    end

    //
    
endmodule
