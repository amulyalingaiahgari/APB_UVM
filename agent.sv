`ifndef APB_AGENT_SV
`define APB_AGENT_SV

`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"

class apb_agent extends uvm_agent;
  `uvm_component_utils(apb_agent)

  apb_driver driver;
  apb_monitor monitor;
  apb_sequencer sequencer;

  function new(string name="apb_agent", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = apb_monitor::type_id::create("monitor", this);
    driver = apb_driver::type_id::reate("driver", this);
    sequencer = apb_sequencer::type_id::create("sequencer", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass
`endif
