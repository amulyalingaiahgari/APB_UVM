`ifndef APB_ENVIRONMENT_SV
`define APB_ENVIRONMENT_SV

`include "agent.sv"
`include "scoreboard.sv"

class apb_env extends uvm_env;
  `uvm_component_utils(apb_env)

  apb_agent agent;
  apb_scoreboard scoreboard;

  function new(string name="apb_env", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = apb_agent::type_id::create("agent", this);
    scoreboard = apb_scoreboard::type_id::create("scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.monitor.mon_ap.connect(scoreboard.sb_ap);
  endfunction

endclass
`endif
