#########################################################
## Makefile
## function: for complie and simulation script
#########################################################

VVP_FILE:=out.vvp
VVP_OPTION:= -o $(VVP_FILE)
VCD_FILE:=mxrv_top_tb.vcd
FILELIST:=mxrv_top_tb.sv

.PHONY:run clean flow

compile:
	iverilog 					\
		$(VVP_OPTION)				\
		$(FILELIST)					

sim:
	vvp							\
		$(VVP_FILE)

wave:
	gtkwave						\
		$(VCD_FILE)

run: compile sim
flow: run wave

clean:
	rm -f $(VVP_FILE) *.vvp $(VCD_FILE) *.vcd *.out
