/*
 *********************************************************************************** 
 * Class     : act_tb
 *
 * Details   : Basic top module which can run test case
 *
 **********************************************************************************
 */  

import uvm_pkg:: *;
`include "uvm_macros.svh"

`include "act_transaction.sv"
`include "act_monitor.sv"
`include "act_scoreboard.sv"
`include "act_env.sv"
`include "act_test.sv"

module act_tb;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  initial begin
    run_test("act_test");
  end

endmodule //act_tb
