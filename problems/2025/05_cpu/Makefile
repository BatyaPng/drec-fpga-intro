TB_LIST := src/cpu_top_tb.v

RTL_LIST := \
	src/core/core_pkg.sv \
	src/core/core_alu.sv \
	src/core/core_and.sv \
	src/core/core_bru.sv \
	src/core/core_control.sv \
	src/core/core_get_reg.sv \
	src/core/core_lsu.sv \
	src/core/core_mux4.sv \
	src/core/core_or.sv \
	src/core/core_pc.sv \
	src/core/core_reg.sv \
	src/core/core_sign_ext.sv \
	src/core/core.sv \
	src/imem.v \
	src/dmem.v \
	src/mem_xbar.v \
	src/cpu_top.v

.PHONY: syn fpga clean samples gui sim waves cpu_top run_cpu_top gui_cpu_top work

sim: $(TB_LIST) $(RTL_LIST)
	iverilog -I./src/ $^ -o sim
	./sim

waves: dump.vcd
	gtkwave dump.vcd &

samples:
	$(MAKE) -C samples/

syn:
	quartus_sh --flow compile fpga

gui:
	quartus fpga &

fpga:
	quartus_pgm -c "USB-Blaster" -m JTAG -o "p;output/fpga.sof"

work:
	if [ ! -d "work" ]; then vlib work; fi

cpu_top: work samples $(TB_LIST) $(RTL_LIST)
	vlog -sv +incdir+./src $(TB_LIST) $(RTL_LIST)

run_cpu_top: cpu_top
	vsim -c work.cpu_top_tb -do "run -all; quit"

gui_cpu_top: cpu_top
	vsim work.cpu_top_tb -do "add wave -r /*; run -all"

clean:
	rm -rf sim dump.vcd
	rm -rf db incremental_db output fpga.qws greybox_tmp *.bak
	rm -rf work transcript vsim.wlf
	$(MAKE) -C samples/ clean
