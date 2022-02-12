# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0
# Simple tests for an adder module
import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, with_timeout
import random

async def RST(dut):
    dut.rst  <= 1

    #await RisingEdge(dut.clk)
    await ClockCycles(dut.clk, 2)
    dut.rst <= 0;
    #await RisingEdge(dut.clk)
    await ClockCycles(dut.clk, 2)

@cocotb.test()
async def test_clock_ssd(dut):
    """Test for adding 2 random numbers multiple times"""
    clock = Clock(dut.clk, 10, units="ps")
    cocotb.fork(clock.start())

    # dut.height <= 0b101
    # dut.height <= 0b000

    await RST(dut)
    await ClockCycles(dut.clk, 4000)

