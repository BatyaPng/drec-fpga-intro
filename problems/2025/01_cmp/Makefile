TB_LIST := cmp_tb.v

RTL_LIST := cmp.v

sim: $(TB_LIST) $(RTL_LIST)
	iverilog -g2012 $^ -o sim.o

waves: dump.vcd
	gtkwave dump.vcd &

clean:
	rm -rf sim dump.vcd

.PHONY: clean sim waves



