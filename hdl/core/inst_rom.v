//***********************************************
// inst_rom
// funtion: 存储指令，一般按顺序寻址，由pc值来寻址，本质是多路选择器
//***********************************************

`include "define.v"

module inst_rom (
    input clk,
    input rst_n,
    // 来自ifu的pc地址(实际上是来自于pc_reg的)
    input[`PORT_ADDR_WIDTH]         inst_rom_pc_i,
    // 送给ifu的指令内容
    output[`PORT_DATA_WIDTH]        inst_rom_inst_data_o,

    // 指令存储器,给memc操作存储器使用
    input[`PORT_ADDR_WIDTH]         inst_rom_addr_i,
    input[`PORT_DATA_WIDTH]         inst_rom_wr_data_i,
    input                           inst_rom_wr_en_i,    
    output[`PORT_DATA_WIDTH]        inst_rom_rd_data_o
);

    reg [`PORT_ADDR_WIDTH]_INST_ROM[0:`INST_ROM_DEPTH-1];

    integer i;

    assign inst_rom_inst_data_o = _INST_ROM[inst_rom_pc_i >> 2];
    assign inst_rom_rd_data_o = _INST_ROM[inst_rom_addr_i >> 2];

    // 复位初始化内存数据与写入数据
    always @(posedge clk or negedge rst_n) begin : WRITE_LOGIC
        if(rst_n == `RstEnable) begin
            // 先不要初始化，直接读入指令预设内容，signature
            // for (i = 0; i < `DATA_RAM_DEPTH ; i=i+1) begin
            //     _DATA_RAM[i] = `ZeroWord;
            // end
        end
        else if(inst_rom_wr_en_i) begin
            _INST_ROM[inst_rom_addr_i >> 2] <= inst_rom_wr_data_i;
        end
    end
    
endmodule

