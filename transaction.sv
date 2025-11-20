`ifndef APB_ITEM_SV
`define APB_ITEM_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_seq_item extends uvm_sequence_item;
  `uvm_object_utils(apb_seq_item)

  rand bit [31:0]paddr;
  rand bit [31:0]pwdata;
  rand bit pwrite;
  bit [31:0]prdata;
  bit pslverr;
  bit pready;

  function new(string name = "apb_seq_item");
    super.new(name);
  endfunction

endclass
`endif
