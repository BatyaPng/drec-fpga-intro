TB_LIST := alu_tb.v

PKG_LIST := alu_pkg.v

RTL_LIST := alu.v

sim: $(TB_LIST) $(RTL_LIST)
	iverilog -g2012 $^ -o sim.o

waves: dump.vcd
	gtkwave dump.vcd &

clean:
	rm -rf sim dump.vcd

.PHONY: clean sim waves


