`ifndef APB_SEQUENCE_SV
`define APB_SEQUENCE_SV

import uvm_pkg ::*;
`include "uvm_macros.svh"
`include "transaction.sv"

class apb_sequence extends uvm_sequence #(apb_seq_item);
  `uvm_object_utils(apb_sequence)

  function new(string name = "apb_sequence");
    super.new(name);
  endfunction

  task body();
    apb_seq_item req;
    int saved_addr;

    //write transaction
    repeat(3) begin
      //random write to valid address
      req = apb_seq_item::type_id::create("req_write");
      assert(req.randomize() with {pwrite == 1; paddr inside {[0:31]}; })
      else
        `uvm_info("SEQ", "Randomize failed for write", UVM_LOW);

      req.prdata=$urandom();
      saved_addr = req.paddr;
      start_item(req);
      finish_item(req);
      `uvm_info("SEQ", $sformatf("started write addr=%0d data=0x%0h", req.paddr, req.pwdata), UVM_LOW)

      //read transaction
      req = apb_seq_item::type_id::create("req_read");
      req.pwrite = 0;
      req.paddr = saved_addr;
      start_item(req);
      finish_item(req);
      `uvm_info("SEQ", $sformatf("Started read addr=%0d", req.paddr), UVM LOW)
    end

    //invalid write/read
    req = apb_seq_item::type_id::create("invalid_read"):
    req.pwrite = 0;
    req.paddr = 32;
    start_item(req);
    finish_item(req);
    `uvm_info("SEQ", "started invalid read (addr=32)", UVM_LOW)
  endtask

endclass
`endif
