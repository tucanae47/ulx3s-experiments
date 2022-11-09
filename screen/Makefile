PROJ=bram_oled

all: $(PROJ).bit

$(PROJ).json: top.v oled_video.v bram_buffer.v gen_pos.v
	yosys -p "synth_ecp5 -top top -json $@" $^

$(PROJ)_out.config: $(PROJ).json
	nextpnr-ecp5 --json $< --textcfg $@ --85k --package CABGA381 --lpf ulx3s_v20.lpf

$(PROJ).bit: $(PROJ)_out.config
	ecppack $< $@	

prog: $(PROJ).bit
	fujprog $<

flash: $(PROJ).bit
	fujprog -j flash $<

clean:
	rm -f *.bit *.config *.json out.txt

.PHONY: prog clean

# To save output: make > out.txt 2>&1   