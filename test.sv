`ifndef APB_TEST_SV
`define APB_TEST_SV

`include "environment.sv"

class apb_test extends uvm_test;
  `uvm_component_utils(apb_test)

  apb_env env;
  apb_sequence seq;

  function new(string name="apb_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_env::type_id::create("env", this);
    `uvm_info("TEST", "Build phase complete", UVM_LOW)
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    seq = apb_sequence::type_id::create("seq");
    seq.start(env.agent.sequencer);

    #1000ns;
    phase.drop_objection(this);
  endtask

endclass
`endif
