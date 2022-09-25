# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0
# Simple tests for an adder module
import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, with_timeout, ReadOnly
import random
from cocotb.binary import BinaryValue

async def  write_ram(dut, address, value):
    await RisingEdge(dut.clk)              # Synchronise to the read clock
    dut.we = 1
    dut.addr_w = address
    dut.data_in = value
    await RisingEdge(dut.clk)              # Wait 1 clock cycle
    dut.we  = 0                        # Disable write

async def read_ram(dut, address):
    await RisingEdge(dut.clk)               # Synchronise to the read clock
    dut.addr_r = address                   # Drive the value onto the signal
    await RisingEdge(dut.clk)               # Wait for 1 clock cycle

async def RST(dut):
    dut.rst  <= 1
    await ClockCycles(dut.clk, 2)
    dut.rst <= 0;
    await ClockCycles(dut.clk, 2)

async def bit_count(i):
    return bin(i).count('1')

@cocotb.test()
async def test_pixels(dut):
    """Test reading data from RAM"""
    clock = Clock(dut.clk, 25, units="us")
    cocotb.fork(clock.start())

    await RST(dut)

    await ClockCycles(dut.clk, 60000)


      
