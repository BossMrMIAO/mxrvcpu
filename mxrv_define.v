//**********************************************
// define and macros
//**********************************************

// sequential logic
`define RstEnable  1'b0
`define RstDisable  1'b1

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
