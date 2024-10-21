#RUN_DIR=
SIM_DIR = $(RUN_DIR)/../sim
#----------------------------------------
#	BASIC PARAMETER
#----------------------------------------
SEED ?= $(shell date +%Y%m%d%H%M%S)
TEST_CASE ?= mcdf_data_consistence_basic_test

#----------------------------------------
#	OPT
#----------------------------------------
FILELIST_OPT ?= -f ../filelist/hdl.f
FILELIST_OPT += -f ../filelist/hvl.f
INC_OPT ?= -f ../filelist/inc.f
TIMESCALE_OPT ?= -timescale=1ns/1ps
RUN_AFTER_COMP ?= 1
# UVM_OPT ?= -ntb_opts uvm-1.2 +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=$(TEST_CASE)
LOG_OPT ?= -l $(SIM_DIR)/$(TEST_CASE).log
DEFINE_OPT ?= +define+UVM_REG_GET_BASE_RESPONSE_WITHOUT_REQ_ID
# DEFINE_OPT += +define+BASIC_SIM_ENV+PC_REG_TEST
IES_OPT := -full64  $(RUN_OPT)  +vc  +v2k  -sverilog +seed=$(SEED) -debug_access+all -fsdb -top rv_core_test_tb

#----------------------------------------
#	logic control
#----------------------------------------
#if ($(RUN_AFTER_COMP) eq 1):
	IES_OPT += -R


#----------------------------------------
#	TEST_COMMAND
#----------------------------------------
test :
	echo $(SEED)




#----------------------------------------
#	comp and run by vcs
#----------------------------------------
run	:
	vcs \
		$(INC_OPT) \
		$(FILELIST_OPT) \
        $(TIMESCALE_OPT) \
		$(UVM_OPT) \
		$(DEFINE_OPT) \
        $(IES_OPT)	\
		$(LOG_OPT)
        
#----------------------------------------
#	simv by vcs
#----------------------------------------
simv	:
	./simv

#----------------------------------------
#	verdi
#----------------------------------------
verdi  :
	verdi -sv \
		$(FILELIST_OPT) \
		-ssf tb.fsdb \
		-sswr signal.rc &	


#----------------------------------------
#	clean for vcs
#----------------------------------------
clean  :
	 rm  -rf  *~  core  csrc  simv*  vc_hdrs.h  ucli.key  urg* *.log  novas.* *.fsdb* verdiLog  64* DVEfiles *.vpd
	 rm -rf INCA_libs irun*
	 rm -rf modelsim.ini transcript work
