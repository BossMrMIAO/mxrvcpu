//***********************************************
// data_rom
// funtion: 数据存储器，用于SB，SW等指令
//***********************************************

`include "define.v"

module data_ram (
    input clk,
    input rst_n,

    input[`PORT_ADDR_WIDTH]         data_ram_addr,
    input[`PORT_DATA_WIDTH]         data_ram_wr_data,
    input                           data_ram_wr_en,    
    
    output[`PORT_DATA_WIDTH]        data_ram_rd_data_o
);

    reg [`PORT_ADDR_WIDTH]_DATA_RAM[0:`DATA_RAM_DEPTH-1];


    integer i;

    assign data_ram_rd_data_o = _DATA_RAM[data_ram_addr >> 2];

    // 复位初始化内存数据与写入数据
    always @(posedge clk or negedge rst_n) begin : WRITE_LOGIC
        if(rst_n == `RstEnable) begin
            // 先不要初始化，直接读入指令预设内容，signature
            // for (i = 0; i < `DATA_RAM_DEPTH ; i=i+1) begin
            //     _DATA_RAM[i] = `ZeroWord;
            // end
        end
        else if(data_ram_wr_en) begin
            _DATA_RAM[data_ram_addr >> 2] <= data_ram_wr_data;
        end
    end


    
endmodule
