//======================================================================
//
// tb_xtea_core.v
// --------------
// Testbench for the xtea block cipher core.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2019, Assured AB
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

//------------------------------------------------------------------
// Test module.
//------------------------------------------------------------------
module tb_xtea_core();

  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter DEBUG     = 0;
  parameter DUMP_WAIT = 0;

  parameter CLK_HALF_PERIOD = 1;
  parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;


  //----------------------------------------------------------------
  // Register and Wire declarations.
  //----------------------------------------------------------------
  reg [31 : 0] cycle_ctr;
  reg [31 : 0] error_ctr;
  reg [31 : 0] tc_ctr;
  reg          tb_monitor;

  reg           tb_clk;
  reg           tb_reset_n;
  reg           tb_encdec;
  reg           tb_next;
  wire          tb_ready;
  reg [5 : 0]   tb_rounds;
  reg [127 : 0] tb_key;
  reg [63 : 0]  tb_block;
  wire [63 : 0] tb_result;


  //----------------------------------------------------------------
  // Device Under Test.
  //----------------------------------------------------------------
  xtea_core dut(
                .clk(tb_clk),
                .reset_n(tb_reset_n),

                .encdec(tb_encdec),
                .next(tb_next),

                .rounds(tb_rounds),
                .key(tb_key),

                .block(tb_block),
                .result(tb_result),
                .ready(tb_ready)
               );


  //----------------------------------------------------------------
  // clk_gen
  //
  // Always running clock generator process.
  //----------------------------------------------------------------
  always
    begin : clk_gen
      #CLK_HALF_PERIOD;
      tb_clk = !tb_clk;
    end // clk_gen


  //----------------------------------------------------------------
  // sys_monitor()
  //
  // An always running process that creates a cycle counter and
  // conditionally displays information about the DUT.
  //----------------------------------------------------------------
  always
    begin : sys_monitor
      cycle_ctr = cycle_ctr + 1;
      #(CLK_PERIOD);
      if (tb_monitor)
        begin
          dump_dut_state();
        end
    end


  //----------------------------------------------------------------
  // dump_dut_state()
  //
  // Dump the state of the dump when needed.
  //----------------------------------------------------------------
  task dump_dut_state;
    begin
      $display("State of DUT");
      $display("------------");
      $display("Cycle: %08d", cycle_ctr);
      $display("Inputs and outputs:");
      $display("encdec = 0x%01x, next = 0x%01x", dut.encdec, dut.next);
      $display("key   = 0x%016x ", dut.key);
      $display("block = 0x%08x", dut.block);
      $display("ready  = 0x%01x", dut.ready);
      $display("result = 0x%08x", dut.result);
      $display("");
      $display("Internal states:");
      $display("core_ctrl_reg = 0x%01x, core_ctrl_new = 0x%01x, round_ctr = 0x%02x",
               dut.core_ctrl_reg, dut.core_ctrl_new, dut.round_ctr_reg);
      $display("init_state = 0x%01x, update_v0 = 0x%01x, update_v1 = 0x%01x, update_sum = 0x%01x",
               dut.init_state, dut.update_v0, dut.update_v1, dut.update_sum);
      $display("keyw[0] = 0x%08x, keyw[1] = 0x%08x, keyw[2] = 0x%08x, keyw[3] = 0x%08x",
               dut.xtea_core_dp.keyw[0], dut.xtea_core_dp.keyw[1],
               dut.xtea_core_dp.keyw[2], dut.xtea_core_dp.keyw[3]);
      $display("v0_reg  = 0x%08x, v0_new  = 0x%08x, v0_0_0 = 0x%08x, v0_0_1 = 0x%08x, v0_0 = 0x%08x, v0_1 = 0x%08x, v0_delta = 0x%08x, v0_we = 0x%01x",
               dut.v0_reg, dut.v0_new, dut.xtea_core_dp.v0_0_0, dut.xtea_core_dp.v0_0_1, dut.xtea_core_dp.v0_0, dut.xtea_core_dp.v0_1,
               dut.xtea_core_dp.v0_delta, dut.v0_we);
      $display("v1_reg  = 0x%08x, v1_new  = 0x%08x, v1_0_0 = 0x%08x, v1_0_1 = 0x%08x, v1_0 = 0x%08x, v1_1 = 0x%08x, v1_delta = 0x%08x, v1_we = 0x%01x",
               dut.v1_reg, dut.v1_new, dut.xtea_core_dp.v1_0_0, dut.xtea_core_dp.v1_0_1, dut.xtea_core_dp.v1_0, dut.xtea_core_dp.v1_1,
               dut.xtea_core_dp.v1_delta, dut.v1_we);
      $display("sum_reg = 0x%08x, sum_new = 0x%08x, sum_we = 0x%01x",
               dut.sum_reg, dut.sum_new, dut.sum_we);
      $display("");
    end
  endtask // dump_dut_state


  //----------------------------------------------------------------
  // reset_dut()
  //
  // Toggle reset to put the DUT into a well known state.
  //----------------------------------------------------------------
  task reset_dut;
    begin
      $display("*** Toggle reset.");
      tb_reset_n = 0;
      #(2 * CLK_PERIOD);
      tb_reset_n = 1;
    end
  endtask // reset_dut


  //----------------------------------------------------------------
  // display_test_result()
  //
  // Display the accumulated test results.
  //----------------------------------------------------------------
  task display_test_result;
    begin
      if (error_ctr == 0)
        begin
          $display("*** All %02d test cases completed successfully", tc_ctr);
        end
      else
        begin
          $display("*** %02d tests completed - %02d test cases did not complete successfully.",
                   tc_ctr, error_ctr);
        end
    end
  endtask // display_test_result


  //----------------------------------------------------------------
  // wait_ready()
  //
  // Wait for the ready flag in the dut to be set.
  //
  // Note: It is the callers responsibility to call the function
  // when the dut is actively processing and will in fact at some
  // point set the flag.
  //----------------------------------------------------------------
  task wait_ready;
    begin
      while (!tb_ready)
        begin
          #(CLK_PERIOD);
          if (DUMP_WAIT)
            begin
              dump_dut_state();
            end
        end
    end
  endtask // wait_ready


  //----------------------------------------------------------------
  // init_sim()
  //
  // Initialize all counters and testbed functionality as well
  // as setting the DUT inputs to defined values.
  //----------------------------------------------------------------
  task init_sim;
    begin
      cycle_ctr  = 0;
      error_ctr  = 0;
      tc_ctr     = 0;
      tb_monitor = 0;

      tb_clk     = 0;
      tb_reset_n = 1;
      tb_encdec  = 0;
      tb_next    = 0;
      tb_rounds  = 6'h20;
      tb_key     = 128'h0;
      tb_block   = 64'h0;
    end
  endtask // init_sim


  //----------------------------------------------------------------
  // tc1()
  //----------------------------------------------------------------
  task tc1;
    begin
      $display("*** TC1 - encryption started.");
      tc_ctr = tc_ctr + 1;
      tb_monitor = 0;
      tb_key = 128'h000102030405060708090a0b0c0d0e0f;
      tb_block = 64'h4142434445464748;
      tb_encdec = 1'h1;
      tb_next = 1'h1;
      #(2 * CLK_PERIOD);
      tb_next = 1'h0;
      wait_ready();
      tb_monitor = 0;

      if (tb_result == 64'h497df3d072612cb5)
        $display("Correct result for TC1.");
      else
        begin
          $display("Incorrect result for TC1. Expected 0x497df3d072612cb5, Got 0x%08x", tb_result);
          error_ctr = error_ctr + 1;
        end
      $display("*** TC1 completed.");
      $display("");
    end
  endtask // tc1


  //----------------------------------------------------------------
  // tc2()
  //----------------------------------------------------------------
  task tc2;
    begin
      $display("*** TC2 - decryption started.");
      tc_ctr = tc_ctr + 1;
      tb_monitor = 0;
      tb_key = 128'h000102030405060708090a0b0c0d0e0f;
      tb_block = 64'h497df3d072612cb5;
      tb_encdec = 1'h0;
      tb_next = 1'h1;
      #(2 * CLK_PERIOD);
      tb_next = 1'h0;
      wait_ready();
      tb_monitor = 0;

      if (tb_result == 64'h4142434445464748)
        $display("Correct result for TC2.");
      else
        begin
          $display("Incorrect result for TC2. Expected 0x4142434445464748, Got 0x%08x", tb_result);
          error_ctr = error_ctr + 1;
        end
      $display("*** TC2 completed.");
      $display("");
    end
  endtask // tc2


  //----------------------------------------------------------------
  // xtea_core_test
  //
  // Test vectors from:
  //----------------------------------------------------------------
  initial
    begin : xtea_core_test
      $display("   -= Testbench for xtea core started =-");
      $display("     =================================");
      $display("");

      init_sim();
      reset_dut();

      tc1();
      tc2();

      display_test_result();
      $display("");
      $display("*** xtea core simulation done. ***");
      $finish;
    end // xtea_core_test
endmodule // tb_xtea_core

//======================================================================
// EOF tb_xtea_core.v
//======================================================================
