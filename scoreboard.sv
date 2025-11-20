`ifndef APB_SCOREBOARD_SV
`define APB_SCOREBOARD_SV

class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)

  uvm_analysis_imp #(apb_seq_item, apb_scoreboard) sb_ap ;

  //Expected memory model
  bit [31:0] expected_mem [0:31];

  function new(string name="apb_scoreboard", uvm_component parent=null);
    super.new(name, parent);
    sb_ap = new("sb_ap", this);
  endfunction

  function void write(apb_seq_item tr);
    apb_seq_item trans = tr;

    if(trans.paddr >= 32) begin
      if(!trans.pslverr) begin
        `uvm_error("SB_ADDR", $sformatf("Expected pslverr=1 for invalid addr %0d, got %0d", trans.paddr, trans.pslverr) )
      end
      else begin
        `uvm_info("SB", $sformatf("invalid access correctly returned pslverr for addr %0d", trans.paddr), UVM_LOW)
      end
      return;
    end

    if(trans.pwrite) begin
      expected_mem[trans.paddr] = trans.pwdata;
      `uvm_info("SB", $sformatf("write:mem[%0d] <= 0x%0h", trans.paddr, trans.pwdata), UVM_LOW)
    end
    else begin
      if(expected_mem[trans.paddr] !== trans.prdata) begin
        `uvm_error("SB_DATA", $sformatf("data mismatch at addr %0d: expected 0x%0h got 0x%0h", trans.paddr, expected_mem[trans.paddr], trans.prdata) )
      end
      else begin
        `uvm_info("SB", $sformatf("read matched for addr %0d: 0x%0h", trans.paddr, trans.prdata), UVM_LOW)
      end
    end
  endfunction

endclass
`endif
