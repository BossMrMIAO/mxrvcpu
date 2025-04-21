module cache #(
    parameter CACHE_LINES = 16, // Number of cache lines
    parameter LINE_SIZE = 64    // Size of each cache line in bytes
)(
    input wire clk,
    input wire rst_n,
    input wire [31:0] addr,     // Address from CPU
    input wire [31:0] wdata,    // Data to write
    input wire write,           // Write enable
    input wire read,            // Read enable
    output reg [31:0] rdata,    // Data to CPU
    output reg hit,             // Cache hit flag

    // AXI interface
    output reg [31:0] axi_araddr,
    output reg axi_arvalid,
    input wire axi_arready,
    input wire [31:0] axi_rdata,
    input wire axi_rvalid,
    output reg axi_rready,
    output reg [31:0] axi_awaddr,
    output reg axi_awvalid,
    input wire axi_awready,
    output reg [31:0] axi_wdata,
    output reg axi_wvalid,
    input wire axi_wready,
    output reg axi_bready,
    input wire axi_bvalid
);

    // Cache line structure
    reg valid[CACHE_LINES-1:0];
    reg dirty[CACHE_LINES-1:0];
    reg [5:0] tag[CACHE_LINES-1:0];
    reg [LINE_SIZE*8-1:0] data[CACHE_LINES-1:0];

    // LRU tracking
    reg [CACHE_LINES-1:0] lru;

    // Internal variables
    integer i;
    reg [31:0] index;
    reg [31:0] tag_reg;
    reg [31:0] offset;
    reg [31:0] mem_addr;
    reg [31:0] mem_data;
    reg mem_read;
    reg mem_write;

    // Cache access
    always @(posedge clk or posedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < CACHE_LINES; i = i + 1) begin
                valid[i] <= 0;
                dirty[i] <= 0;
                tag[i] <= 0;
                data[i] <= 0;
                lru[i] <= 0;
            end
            hit <= 0;
            rdata <= 0;
            axi_arvalid <= 0;
            axi_rready <= 0;
            axi_awvalid <= 0;
            axi_wvalid <= 0;
            axi_bready <= 0;
        end else begin
            index = addr[7:4]; // Assuming 64 cache lines
            tag_reg = addr[31:8];
            offset = addr[3:0];

            // Check for cache hit
            if (valid[index] && tag[index] == tag_reg) begin
                hit <= 1;
                if (read) begin
                    rdata <= data[index][offset*8 +: 32];
                end
                if (write) begin
                    data[index][offset*8 +: 32] <= wdata;
                    dirty[index] <= 1;
                end
                // Update LRU
                lru[index] <= 1;
            end else begin 
                hit <= 0;
                // Cache miss handling
                if (read) begin
                    // Read from main memory
                    axi_araddr <= {tag_reg, index, 2'b00}; // 4-byte aligned address
                    axi_arvalid <= 1;
                    if (axi_arready) begin
                        axi_arvalid <= 0;
                        axi_rready <= 1;
                    end
                    if (axi_rvalid) begin
                        data[index] <= axi_rdata;
                        valid[index] <= 1;
                        tag[index] <= tag_reg;
                        axi_rready <= 0;
                        rdata <= axi_rdata[offset*8 +: 32];
                    end
                end
                if (write) begin
                    // Write back to main memory if dirty
                    if (dirty[index]) begin
                        axi_awaddr <= {tag[index], index, 2'b00}; // 4-byte aligned address
                        axi_awvalid <= 1;
                        if (axi_awready) begin
                            axi_awvalid <= 0;
                            axi_wdata <= data[index];
                            axi_wvalid <= 1;
                        end
                        if (axi_wready) begin
                            axi_wvalid <= 0;
                            axi_bready <= 1;
                        end
                        if (axi_bvalid) begin
                            axi_bready <= 0;
                            dirty[index] <= 0;
                        end
                    end
                    // Write new data to cache
                    data[index][offset*8 +: 32] <= wdata;
                    valid[index] <= 1;
                    tag[index] <= tag_reg;
                    dirty[index] <= 1;
                end
            end
        end
    end

endmodule
