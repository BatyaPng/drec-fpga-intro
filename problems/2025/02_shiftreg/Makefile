VLIB  = vlib
VLOG  = vlog
VSIM  = vsim

WORK  = work
TOP   = shift_register_tb

SRC   = shift_register.sv \
        shift_register_tb.sv

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
