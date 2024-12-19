module mem (
    input wire clk,
    input wire rst,
    input wire mem_read,
    input wire mem_write,
    input wire [31:0] address,
    input wire [31:0] write_data,
    output reg [31:0] read_data,
    output reg mem_ready
);

    reg [31:0] memory [0:255]; // Simple memory array

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_ready <= 0;
            read_data <= 32'b0;
        end else begin
            if (mem_read) begin
                read_data <= memory[address[7:0]]; // Read from memory
                mem_ready <= 1;
            end else if (mem_write) begin
                memory[address[7:0]] <= write_data; // Write to memory
                mem_ready <= 1;
            end else begin
                mem_ready <= 0;
            end
        end
    end

endmodule
module mem_stage (
    input wire clk,
    input wire rst,
    input wire mem_read,
    input wire mem_write,
    input wire [31:0] address,
    input wire [31:0] write_data,
    input wire [31:0] alu_result,
    input wire [31:0] mem_wb_data,
    input wire mem_wb_enable,
    output reg [31:0] mem_data,
    output reg mem_ready
);

    reg [31:0] memory [0:255]; // Simple memory array

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_ready <= 0;
            mem_data <= 32'b0;
        end else begin
            if (mem_read) begin
                mem_data <= memory[address[7:0]]; // Read from memory
                mem_ready <= 1;
            end else if (mem_write) begin
                memory[address[7:0]] <= write_data; // Write to memory
                mem_ready <= 1;
            end else begin
                mem_ready <= 0;
            end
        end
    end

    always @(posedge clk) begin
        if (mem_wb_enable) begin
            memory[address[7:0]] <= mem_wb_data; // Write back data to memory
        end
    end

endmodule