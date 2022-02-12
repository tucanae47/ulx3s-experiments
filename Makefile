# ==============================================================================
# simulation settings
# ==============================================================================
SIM			    ?= icarus			# simulator (icarus, verilator, ...)
TOPLEVEL_LANG   ?= verilog			# hdl (verilog, vhdl)

# ==============================================================================
# source files
# ==============================================================================
# VERILOG_SOURCES += ./*.v
# VERILOG_SOURCES += ./addsub_bin.v
# VERILOG_SOURCES += ./width_adj.v
# VERILOG_SOURCES += ./register.v
# VERILOG_SOURCES += ./counter_bin.v
# VERILOG_SOURCES += ./carryin_bin.v
# VERILOG_SOURCES += ./register_pipe.v
# VERILOG_SOURCES += ./register_pipe_simple.v

# VERILOG_SOURCES += ./bin_mult.v
# VERILOG_SOURCES += ./TOP.v
# VERILOG_SOURCES += ./xnor7.v
# VERILOG_SOURCES += ./sram.v
# VERILOG_SOURCES += ./dffram.v
# VERILOG_SOURCES += ./addsub_bin.v
VERILOG_SOURCES += ./sdd1331_gen_pattern.v
VERILOG_SOURCES += ./oled_sdd1331.v
VERILOG_SOURCES += ./TopSDD.v



# ==============================================================================
# modules
# ==============================================================================
# module	 = test_serin_parout 			# python cocotb tests
# toplevel = serin_parout	        		# top level rtl module


# MODULE	 = test_m_counter 			# python cocotb tests
# TOPLEVEL = m_counter		# top level rtl module


# MODULE	 = test_addsub			# python cocotb tests
# TOPLEVEL = addsub_bin		# top level rtl module

# MODULE	 = test_registerpipe			# python cocotb tests
# TOPLEVEL = register_pipe_simple		# top level rtl module


# MODULE	 = test_bu		# python cocotb tests
# TOPLEVEL = bin_mult		# top level rtl module

MODULE	 = test_clock_ssd		# python cocotb tests
TOPLEVEL = TopSDD		# top level rtl module
# ==============================================================================
# cocotb magic
# ==============================================================================
include $(shell cocotb-config --makefiles)/Makefile.sim

# ==============================================================================
# supplemental commands
# ==============================================================================
clean::
	rm -f results.xml
	rm -f *.vcd
	rm -rf __pycache__/

wave:
	gtkwave *.vcd -a *.gtkw
