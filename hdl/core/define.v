//**********************************************
// define and macros
//**********************************************

// sequential and basic logic
`define RstEnable           1'b0
`define RstDisable          1'b1
`define Enable              1'b1
`define Disable             1'b0

// port width declare   
`define PORT_ADDR_WIDTH     31:0
`define PORT_DATA_WIDTH     31:0
`define PORT_WORD_WIDTH     31:0
`define WORD_WIDTH          32
`define BYTES_IN_A_WORD     4

// CSRRegBus
`define CsrRegAddrBusPort   11:0
`define RegBusPort          31:0
`define RegBus              32
`define DoubleRegBusPort    63:0

// Common Value
`define ZeroByte            8'h0
`define ZeroWord            32'h0
`define ErrorWord           32'hffff_ffff
`define ZeroDouble          64'h0


// CSR parameter support
`define RV32I               32'h4000_0100
`define SingleHart          32'h1
`define Write               1'b1
`define Read                1'b0


// CSR REG addr list
`define CSR_FFLAGS          12'h001
`define CSR_FRM             12'h002
`define CSR_FCSR            12'h003
`define CSR_MSTATUS         12'h300
`define CSR_MISA            12'h301
`define CSR_MIE             12'h304
`define CSR_MTVEC           12'h305
`define CSR_MSCRATCH        12'h340
`define CSR_MEPC            12'h341
`define CSR_MCAUSE          12'h342
`define CSR_MTVAL           12'h343
`define CSR_MIP             12'h344
`define CSR_MCYCLE          12'hB00
`define CSR_MCYCLEH         12'hB80
`define CSR_MINSTRET        12'hB02
`define CSR_MINSTRETH       12'hB82
`define CSR_MVENDORID       12'hF11
`define CSR_MARCHID         12'hF12
`define CSR_MIMPID          12'hF13
`define CSR_MHARTID         12'hF14


// INST disassembly
`define PORT_OPCODE_WIDTH       6:0
`define PORT_REG_ADDR_WIDTH     4:0
`define PORT_SHAMT_WIDTH        5:0
`define PORT_funct3_WIDTH       2:0
`define PORT_funct7_WIDTH       6:0
`define PORT_CSR_WIDTH          11:0

`define OPCODE_WIDTH            7
`define REG_ADDR_WIDTH          5
`define SHAMT_WIDTH             6
`define funct3_WIDTH            3
`define funct7_WIDTH            7
`define CSR_WIDTH               12
`define REG_DEPTH               32
`define INST_ROM_DEPTH          4096
`define DATA_RAM_DEPTH          4096

// MEM ARCH
`define HF_ARCH                 1'b1
`define VN_ARCH                 1'b0

// I type inst
`define INST_TYPE_I             7'b0010011
`define INST_ADDI               3'b000
`define INST_SLTI               3'b010
`define INST_SLTIU              3'b011
`define INST_XORI               3'b100
`define INST_ORI                3'b110
`define INST_ANDI               3'b111
`define INST_SLLI               3'b001
`define INST_SRLI_SRAI          3'b101

// L type inst
`define INST_TYPE_L             7'b0000011
`define INST_LB                 3'b000
`define INST_LH                 3'b001
`define INST_LW                 3'b010
`define INST_LBU                3'b100
`define INST_LHU                3'b101

// S type inst          
`define INST_TYPE_S             7'b0100011
`define INST_SB                 3'b000
`define INST_SH                 3'b001
`define INST_SW                 3'b010

// R and M type inst
`define INST_TYPE_R_M           7'b0110011
// R type inst
`define INST_ADD_SUB            3'b000
`define INST_SLL                3'b001
`define INST_SLT                3'b010
`define INST_SLTU               3'b011
`define INST_XOR                3'b100
`define INST_SRA_SRL            3'b101
`define INST_OR                 3'b110
`define INST_AND                3'b111
// M type inst          
`define INST_MUL                3'b000
`define INST_MULH               3'b001
`define INST_MULHSU             3'b010
`define INST_MULHU              3'b011
`define INST_DIV                3'b100
`define INST_DIVU               3'b101
`define INST_REM                3'b110
`define INST_REMU               3'b111
            
// J type inst          
`define INST_JAL                7'b1101111
`define INST_JALR               7'b1100111
            
// U type inst          
`define INST_LUI                7'b0110111
`define INST_AUIPC              7'b0010111
`define INST_NOP                32'h00000001
`define INST_NOP_OP             7'b0000001
`define INST_MRET               32'h30200073
`define INST_RET                32'h00008067
            
// B type inst          
`define INST_TYPE_B             7'b1100011
`define INST_BEQ                3'b000
`define INST_BNE                3'b001
`define INST_BLT                3'b100
`define INST_BGE                3'b101
`define INST_BLTU               3'b110
`define INST_BGEU               3'b111
            
// CSR inst         
`define INST_CSR                7'b1110011
`define INST_CSRRW              3'b001
`define INST_CSRRS              3'b010
`define INST_CSRRC              3'b011
`define INST_CSRRWI             3'b101
`define INST_CSRRSI             3'b110
`define INST_CSRRCI             3'b111

// fence type inst
`define INST_TYPE_FENCE         7'b0001111
`define INST_FENCE              3'b000
`define INST_FENCE_I            3'b001

`define INST_ECALL              32'h73
`define INST_EBREAK             32'h00100073

// 寄存器
`define x0      5'd0
`define zero    5'd0
`define x1      5'd1
`define ra      5'd1
`define x2      5'd2
`define sp      5'd2
`define x3      5'd3
`define gp      5'd3
`define x4      5'd4
`define tp      5'd4
`define x5      5'd5
`define t0      5'd5
`define x6      5'd6
`define t1      5'd6
`define x7      5'd7
`define t2      5'd7
`define x8      5'd8
`define fp      5'd8
`define x9      5'd9
`define s1      5'd9
`define x10     5'd10
`define a0      5'd10
`define x11     5'd11
`define a1      5'd11
`define x12     5'd12
`define a2      5'd12
`define x13     5'd13
`define a3      5'd13
`define x14     5'd14
`define a4      5'd14
`define x15     5'd15
`define a5      5'd15
`define x16     5'd16
`define a6      5'd16
`define x17     5'd17
`define a7      5'd17
`define x18     5'd18
`define s2      5'd18
`define x19     5'd19
`define s3      5'd19
`define x20     5'd20
`define s4      5'd20
`define x21     5'd21
`define s5      5'd21
`define x22     5'd22
`define s6      5'd22
`define x23     5'd23
`define s7      5'd23
`define x24     5'd24
`define s8      5'd24
`define x25     5'd25
`define s9      5'd25
`define x26     5'd26
`define s10     5'd26
`define x27     5'd27
`define s11     5'd27
`define x28     5'd28
`define t3      5'd28
`define x29     5'd29
`define t4      5'd29
`define x30     5'd30
`define t5      5'd30
`define x31     5'd31
`define t6      5'd31