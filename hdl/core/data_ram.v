//***********************************************
// data_rom
// funtion: 数据存储器，用于SB，SW等指令
//***********************************************

`include "define.v"

module data_ram (
    input clk,
    input rst_n,

    input[`PORT_ADDR_WIDTH]         data_ram_addr_i,
    input[`PORT_DATA_WIDTH]         data_ram_wr_data_i,
    input                           data_ram_wr_en_i,    
    
    output[`PORT_DATA_WIDTH]        data_ram_rd_data_o
);

    reg [`PORT_ADDR_WIDTH]_DATA_RAM[0:`DATA_RAM_DEPTH-1];


    integer i;

    assign data_ram_rd_data_o = _DATA_RAM[data_ram_addr_i >> 2];

    // 复位初始化内存数据与写入数据
    always @(posedge clk or negedge rst_n) begin : WRITE_LOGIC
        if(rst_n == `RstEnable) begin
            // 先不要初始化，直接读入指令预设内容，signature，(这是之前的策略，为了使data_ram也存入指令)
            // 现在需要他初始化，如果不初始化，导致原寄存器读取指令获得x态，分支不跳转，造成伪PASS
            for (i = 0; i < `DATA_RAM_DEPTH ; i=i+1) begin
                _DATA_RAM[i] = `ZeroWord;
            end
        end
        else if(data_ram_wr_en_i) begin
            _DATA_RAM[data_ram_addr_i >> 2] <= data_ram_wr_data_i;
        end
    end


    
endmodule
