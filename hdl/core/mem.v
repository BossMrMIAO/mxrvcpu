`include "define.v"

module mem (
    // 全局时钟与异步复位
    input clk,
    input rst_n,

    // PC传递
    input[`PORT_ADDR_WIDTH]     mem_pc_i,
    output[`PORT_ADDR_WIDTH]    mem_pc_o,

    // signals to be transfer from ex to mem to wb
    input                          mem_rd_wr_en_i,
    input [`PORT_REG_ADDR_WIDTH]   mem_rd_addr_i,
    input [`RegBusPort]            mem_rd_reg_data_i,
    output reg                     mem_rd_wr_en_o,
    output [`PORT_REG_ADDR_WIDTH]  mem_rd_addr_o,
    output reg[`RegBusPort]        mem_rd_reg_data_o,
    // 指令类型指示器
    input[`PORT_OPCODE_WIDTH]      mem_opcode_i,
    input[`PORT_funct3_WIDTH]      mem_funct3_i,

    // signals to be tranfer from ex to mem, mem write them into memory
    // input                          mem_arch_flag_i,
    // 读写data_ram
    input                          mem_data_ram_wr_en_i,
    input[`PORT_ADDR_WIDTH]        mem_data_ram_addr_i,

    input[`PORT_DATA_WIDTH]        mem_data_ram_rd_data_i,
    output                         mem_data_ram_wr_en_o,
    output[`PORT_ADDR_WIDTH]       mem_data_ram_addr_o,
    output reg[`PORT_DATA_WIDTH]   mem_data_ram_wr_data_o,
    // 读写inst_rom
    input                          mem_inst_rom_wr_en_i,
    input[`PORT_ADDR_WIDTH]        mem_inst_rom_addr_i,

    input[`PORT_DATA_WIDTH]        mem_inst_rom_rd_data_i,
    output                         mem_inst_rom_wr_en_o,
    output[`PORT_ADDR_WIDTH]       mem_inst_rom_addr_o,
    output reg[`PORT_DATA_WIDTH]   mem_inst_rom_wr_data_o,

    // 写指令需要的rs2_reg_data信号
    input[`RegBusPort]             mem_rs2_reg_data_i
);

    wire[`PORT_ADDR_WIDTH] mem_addr_r;
    wire[`PORT_DATA_WIDTH] mem_data_r;
    wire mem_arch_flag_i = `VN_ARCH;
    assign mem_addr_r = mem_arch_flag_i == `HF_ARCH ? mem_data_ram_addr_i : mem_inst_rom_addr_i;
    assign mem_data_r = mem_arch_flag_i == `HF_ARCH ? mem_data_ram_rd_data_i : mem_inst_rom_rd_data_i;
    
    assign mem_pc_o = mem_pc_i;

    assign mem_rd_addr_o = mem_rd_addr_i; //保持ex译码后的地址

    assign mem_data_ram_wr_en_o = mem_data_ram_wr_en_i;
    assign mem_data_ram_addr_o = mem_data_ram_addr_i;

    assign mem_inst_rom_wr_en_o = mem_inst_rom_wr_en_i;
    assign mem_inst_rom_addr_o = mem_inst_rom_addr_i;

    always @(*) begin
        case(mem_opcode_i)
            `INST_TYPE_L: begin
                mem_rd_wr_en_o = `Enable;
                case(mem_funct3_i)
                    `INST_LB:    begin
                        case(mem_addr_r[1:0]) 
                            2'b11:  begin
                                mem_rd_reg_data_o = {{24{mem_data_r[31]}},mem_data_r[31:24]};
                            end
                            2'b10:  begin
                                mem_rd_reg_data_o = {{24{mem_data_r[23]}},mem_data_r[23:16]};
                            end
                            2'b01:  begin
                                mem_rd_reg_data_o = {{24{mem_data_r[15]}},mem_data_r[15:8]};
                            end
                            default:  begin
                                mem_rd_reg_data_o = {{24{mem_data_r[7]}},mem_data_r[7:0]};
                            end
                        endcase
                    end
                    `INST_LH:    begin
                        case(mem_addr_r[1:0]) 
                            2'b11:  begin
                                mem_rd_reg_data_o = {{24{mem_data_r[31]}},mem_data_r[31:24]};
                            end
                            2'b10:  begin
                                mem_rd_reg_data_o = {{16{mem_data_r[31]}},mem_data_r[31:16]};
                            end
                            2'b01:  begin
                                mem_rd_reg_data_o = {{16{mem_data_r[23]}},mem_data_r[23:8]};
                            end
                            default:  begin
                                mem_rd_reg_data_o = {{16{mem_data_r[15]}},mem_data_r[15:0]};
                            end
                        endcase
                    end
                    `INST_LW:    begin
                        mem_rd_reg_data_o = mem_data_r[31:0];
                    end
                    `INST_LBU:   begin
                        case(mem_addr_r[1:0]) 
                            2'b11:  begin
                                mem_rd_reg_data_o = {24'h0,mem_data_r[31:24]};
                            end
                            2'b10:  begin
                                mem_rd_reg_data_o = {24'h0,mem_data_r[23:16]};
                            end
                            2'b01:  begin
                                mem_rd_reg_data_o = {24'h0,mem_data_r[15:8]};
                            end
                            default:  begin
                                mem_rd_reg_data_o = {24'h0,mem_data_r[7:0]};
                            end
                        endcase                    
                    end
                    `INST_LHU:   begin
                        case(mem_addr_r[1:0]) 
                            2'b11:  begin
                                mem_rd_reg_data_o = {24'h0,mem_data_r[31:24]};
                            end
                            2'b10:  begin
                                mem_rd_reg_data_o = {16'h0,mem_data_r[31:16]};
                            end
                            2'b01:  begin
                                mem_rd_reg_data_o = {16'h0,mem_data_r[23:8]};
                            end
                            default:  begin
                                mem_rd_reg_data_o = {16'h0,mem_data_r[15:0]};
                            end
                        endcase                        
                    end
                    default:    begin
                        mem_rd_reg_data_o = mem_rd_reg_data_i;
                    end
                endcase
            end
            `INST_TYPE_S: begin
                case(mem_funct3_i)
                    `INST_SB:    begin
                        case(mem_addr_r[1:0]) 
                            2'b11:  begin
                                mem_inst_rom_wr_data_o = {mem_rs2_reg_data_i[7:0], mem_data_r[23:0]};
                            end
                            2'b10:  begin
                                mem_inst_rom_wr_data_o = {mem_data_r[31:24], mem_rs2_reg_data_i[7:0], mem_data_r[15:0]};
                            end
                            2'b01:  begin
                                mem_inst_rom_wr_data_o = {mem_data_r[31:16], mem_rs2_reg_data_i[7:0], mem_data_r[7:0]};
                            end
                            default:  begin
                                mem_inst_rom_wr_data_o = {mem_data_r[31:8], mem_rs2_reg_data_i[7:0]};
                            end
                        endcase
                    end
                    `INST_SH:    begin
                        case(mem_addr_r[1:0]) 
                            2'b11:  begin
                                mem_inst_rom_wr_data_o = {mem_rs2_reg_data_i[7:0], mem_data_r[23:0]};
                            end
                            2'b10:  begin
                                mem_inst_rom_wr_data_o = {mem_rs2_reg_data_i[15:0], mem_data_r[15:0]};
                            end
                            2'b01:  begin
                                mem_inst_rom_wr_data_o = {mem_data_r[31:24], mem_rs2_reg_data_i[15:0], mem_data_r[7:0]};
                            end
                            default:  begin
                                mem_inst_rom_wr_data_o = {mem_data_r[31:16], mem_rs2_reg_data_i[15:0]};
                            end
                        endcase
                    end
                    `INST_SW:    begin
                        mem_inst_rom_wr_data_o = mem_rs2_reg_data_i;
                    end
                    default:    begin
                        mem_rd_reg_data_o = mem_rd_reg_data_i;
                    end
                endcase
            end
            default : begin
                // 其他指令不需要特殊处理,其写入寄存器的值由ex阶段传递过来
                mem_rd_reg_data_o = mem_rd_reg_data_i;
                // ex阶段不使能写reg信号，因为正确的来自mem的data尚未产生，对T+1指令源寄存器数据冲突
                mem_rd_wr_en_o = mem_rd_wr_en_i;
            end
        endcase
               
    end


endmodule