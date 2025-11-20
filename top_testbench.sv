`ifndef APB_TESTBENCH_SV
`define APB_TESTBENCH_SV

`include "test.sv"

import uvm_pkg::*;
`include "uvm_macros.svh"

module top;
  logic pclk;
  logic presetn;

  //clock generation
  initial begin
    pclk = 0;
    forever #5 pclk = ~pclk;
  end

  //Reset generation
  initial begin
    presetn = 0;
    #20 presetn = 1;
    $display("time %0t: Reset released", $time);
  end

  //interface
  apb_if apb_if_inst(.pclk(pclk), .presetn(presetn));

  //DUT
  apb_slave dut(.presetn(presetn), .pclk(pclk), .psel(apb_if_inst.psel), .penable(apb_if_inst.penable), .pwrite(apb_if_inst.pwrite), .paddr(apb_if_inst.paddr), .pwdata(apb_if_inst.pwdata), .prdata(apb_if_inst.prdata), .pready(apb_if_inst.pready), .pslverr(apb_if_inst.pslverr));

  //set interface in UVM
  initial begin
    uvm_config_db#(virtual apb_if.DRIVER)::set(null, "*", "vif", apb_if_inst);
    uvm_config_db#(virtual apb_if.MONITOR)::set(null, "*", "vif", apb_if_inst);
    run_test("apb_test");
  end
  
endmodule
`endif
