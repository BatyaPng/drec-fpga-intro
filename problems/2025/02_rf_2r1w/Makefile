VLIB  = vlib
VLOG  = vlog
VSIM  = vsim

WORK  = work
TOP   = rf_2r1w_tb

SRC   = rf_2r1w.sv \
        rf_2r1w_tb.sv

.PHONY: all lib compile sim gui clean

all: clean lib compile sim

lib:
	$(VLIB) $(WORK)

compile: lib
	$(VLOG) -work $(WORK) -sv +acc $(SRC)

sim:
	$(VSIM) -c $(WORK).$(TOP) -do "run -all; quit;"

gui: compile
	$(VSIM) $(WORK).$(TOP) -do "add wave -r /*; run -all;"

clean:
	rm -rf $(WORK) transcript *.wlf vsim.dbg
