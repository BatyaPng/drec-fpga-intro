TB_LIST := signext_tb.v

RTL_LIST := signext_b.v signext_s.v

sim: $(TB_LIST) $(RTL_LIST)
	iverilog -g2012 $^ -o sim.o

waves: dump.vcd
	gtkwave dump.vcd &

clean:
	rm -rf sim dump.vcd

.PHONY: clean sim waves
