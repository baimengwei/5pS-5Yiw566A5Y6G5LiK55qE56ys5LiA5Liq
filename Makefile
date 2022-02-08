VERSION=uvm-1.1
UVM_TOP=test.sv
VERBOSITY=UVM_MEDIUM
CASE=test_collection
OPTION=+UVM_LOG_RECORD +UVM_TR_RECORD

RTL_PATH=./rtl
# DUT=$(RTL_PATH)/router.sv $(RTL_PATH)/router_io.sv $(RTL_PATH)/ral/host_io.sv
DUT=$(RTL_PATH)/ral/router.sv $(RTL_PATH)/router_io.sv $(RTL_PATH)/ral/host_io.sv
HARNESS=$(RTL_PATH)/router_test_top.sv
PACKAGE=packet_seq_lib_pkg.sv

RALFILE=host.ralf
RALPOSTFIX=host_regmodel

all: compile run

compile: 
	vcs -sverilog -debug_all -ntb_opts $(VERSION)  -l compile.log -timescale="1ns/100ps" +vcs+vcdpluson\
		 $(DUT) $(HARNESS)  $(PACKAGE) $(UVM_TOP)

run:
	./simv -l sim.log +UVM_VERBOSITY=$(VERBOSITY) +UVM_TESTNAME=$(CASE) $(OPTION)

dve_i:
	./simv -l sim.lg -gui +UVM_VERBOSITY=$(VERBOSITY) +UVM_TESTNAME=$(CASE) &

dve:
	dve -vpd vcdplus.vpd &

gen_ral:
	ralgen -uvm -t $(RALPOSTFIX) $(RALFILE)

clean:
	rm -rf *.log csrc simv.daidir simv ucli.key vc_hdrs.h DVEfiles simv.cst *.vpd *.lg tags
