//**********************************************
// define and macros
//**********************************************

// sequential and basic logic
`define RstEnable  1'b0
`define RstDisable  1'b1
`define Enable  1'b1
`define Disable 1'b0

// port width declare
`define PORT_WORD_WIDTH 31:0
`define WORD_WIDTH      32
`define BYTES_IN_A_WORD 4

// CSRRegBus
`define CsrRegAddrBus   11:0
`define RegBus  31:0
`define DoubleRegBus    63:0

// Common Value
`define ZeroByte    8'h0
`define ZeroWord    32'h0
`define ErrorWord   32'hffff_ffff
`define ZeroDouble  64'h0


// CSR parameter support
`define RV32I   32'h4000_0100
`define SingleHart  32'h1
`define Write   1'b1
`define Read    1'b0


// CSR REG addr list
`define CSR_FFLAGS  12'h001
`define CSR_FRM     12'h002
`define CSR_FCSR    12'h003
`define CSR_MSTATUS 12'h300
`define CSR_MISA    12'h301
`define CSR_MIE     12'h304
`define CSR_MTVEC   12'h305
`define CSR_MSCRATCH    12'h340
`define CSR_MEPC    12'h341
`define CSR_MCAUSE  12'h342
`define CSR_MTVAL   12'h343
`define CSR_MIP     12'h344
`define CSR_MCYCLE  12'hB00
`define CSR_MCYCLEH 12'hB80
`define CSR_MINSTRET    12'hB02
`define CSR_MINSTRETH   12'hB82
`define CSR_MVENDORID   12'hF11
`define CSR_MARCHID 12'hF12
`define CSR_MIMPID  12'hF13
`define CSR_MHARTID 12'hF14


// INST disassembly
`define OPCODE_WIDTH    6:0
`define REG_ADDR_WIDTH  4:0
`define funct3_WIDTH    2:0
`define funct7_WIDTH    6:0

// I type inst
`define INST_TYPE_I 7'b0010011
`define INST_ADDI   3'b000
`define INST_SLTI   3'b010
`define INST_SLTIU  3'b011
`define INST_XORI   3'b100
`define INST_ORI    3'b110
`define INST_ANDI   3'b111
`define INST_SLLI   3'b001
`define INST_SRI    3'b101

// L type inst
`define INST_TYPE_L 7'b0000011
`define INST_LB     3'b000
`define INST_LH     3'b001
`define INST_LW     3'b010
`define INST_LBU    3'b100
`define INST_LHU    3'b101

// S type inst
`define INST_TYPE_S 7'b0100011
`define INST_SB     3'b000
`define INST_SH     3'b001
`define INST_SW     3'b010

// R and M type inst
`define INST_TYPE_R_M 7'b0110011
// R type inst
`define INST_ADD_SUB 3'b000
`define INST_SLL    3'b001
`define INST_SLT    3'b010
`define INST_SLTU   3'b011
`define INST_XOR    3'b100
`define INST_SR     3'b101
`define INST_OR     3'b110
`define INST_AND    3'b111
// M type inst
`define INST_MUL    3'b000
`define INST_MULH   3'b001
`define INST_MULHSU 3'b010
`define INST_MULHU  3'b011
`define INST_DIV    3'b100
`define INST_DIVU   3'b101
`define INST_REM    3'b110
`define INST_REMU   3'b111

// J type inst
`define INST_JAL    7'b1101111
`define INST_JALR   7'b1100111

`define INST_LUI    7'b0110111
`define INST_AUIPC  7'b0010111
`define INST_NOP    32'h00000001
`define INST_NOP_OP 7'b0000001
`define INST_MRET   32'h30200073
`define INST_RET    32'h00008067

`define INST_FENCE  7'b0001111
`define INST_ECALL  32'h73
`define INST_EBREAK 32'h00100073

// J type inst
`define INST_TYPE_B 7'b1100011
`define INST_BEQ    3'b000
`define INST_BNE    3'b001
`define INST_BLT    3'b100
`define INST_BGE    3'b101
`define INST_BLTU   3'b110
`define INST_BGEU   3'b111

// CSR inst
`define INST_CSR    7'b1110011
`define INST_CSRRW  3'b001
`define INST_CSRRS  3'b010
`define INST_CSRRC  3'b011
`define INST_CSRRWI 3'b101
`define INST_CSRRSI 3'b110
`define INST_CSRRCI 3'b111

// 寄存器
`define x0      5'h0
`define zero    5'h0
`define x1      5'h1
`define ra      5'h1
`define x2      5'h2
`define sp      5'h2
`define x3      5'h3
`define gp      5'h3
`define x4      5'h4
`define tp      5'h4
`define x5      5'h5
`define t0      5'h5
`define x6      5'h6
`define t1      5'h6
`define x7      5'h7
`define t2      5'h7
`define x8      5'h8
`define fp      5'h8
`define x9      5'h9
`define s1      5'h9
`define x10     5'h10
`define a0      5'h10
`define x11     5'h11
`define a1      5'h11
`define x12     5'h12
`define a2      5'h12
`define x13     5'h13
`define a3      5'h13
`define x14     5'h14
`define a4      5'h14
`define x15     5'h15
`define a5      5'h15
`define x16     5'h16
`define a6      5'h16
`define x17     5'h17
`define a7      5'h17
`define x18     5'h18
`define s2      5'h18
`define x19     5'h19
`define s3      5'h19
`define x20     5'h20
`define s4      5'h20
`define x21     5'h21
`define s5      5'h21
`define x22     5'h22
`define s6      5'h22
`define x23     5'h23
`define s7      5'h23
`define x24     5'h24
`define s8      5'h24
`define x25     5'h25
`define s9      5'h25
`define x26     5'h26
`define s10     5'h26
`define x27     5'h27
`define s11     5'h27
`define x28     5'h28
`define t3      5'h28
`define x29     5'h29
`define t4      5'h29
`define x30     5'h30
`define t5      5'h30
`define x31     5'h31
`define t6      5'h31