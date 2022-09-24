PROJ=oled

export COCOTB_REDUCED_LOG_FMT=1
export PYTHONPATH := test:$(PYTHONPATH)
export LIBPYTHON_LOC=$(shell cocotb-config --libpython)
all: $(PROJ).bit

# $(PROJ).json: top.v hvsync_generator.v pll_25to100mhz.v	
# $(PROJ).json: SSD1351.v oled.v	
$(PROJ).json: top_checkered.v oled_video.v pll_25to50mhz.v
	yosys -p "synth_ecp5 -top top_checkered -json $@" $^

$(PROJ)_out.config: $(PROJ).json
	nextpnr-ecp5 --json $< --textcfg $@ --85k --package CABGA381 --lpf ulx3s_v20.lpf

$(PROJ).bit: $(PROJ)_out.config
	ecppack $< $@	

prog: $(PROJ).bit
	fujprog $<

flash: $(PROJ).bit
	fujprog -j flash $<



test_coco:
	rm -rf sim_build/ results.xml
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s oled -s dump SSD1351.v oled.v dump_ospi.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test_spi vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml

show_%: %.vcd %.gtkw
	gtkwave $^

lint:
	verible-verilog-lint src/*v --rules_config verible.rules

clean:
	rm -f *.bit *.config *.json out.txt *vcd sim_build test/__pycache__ results.xml


.PHONY: prog clean

# To save output: make > out.txt 2>&1   