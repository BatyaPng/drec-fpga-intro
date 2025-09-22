.PHONY: all build run lint clean

FILELIST = filelist.f
WAIVES = waives.vlt
TOP = sa_tb

lint:
	verilator -Wall -sv --timing --lint-only -f $(FILELIST) $(WAIVES) --top-module $(TOP)