`ifndef APB_DRIVER_SV
`define APB_DRIVER_SV

class apb_driver extends uvm_driver #(apb_seq_item);
  `uvm_component_utils(apb_driver)

  virtual apb_if.DRIVER vif;
  apb_seq_item req;

  function new(string name="apb_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  //get virtual interface
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if.DRIVER)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "Driver: No virtual interface assigned to driver(uvm_config_db get failed)")
    end
    `uvm_info("DRV", $sformatf("Driver build_phase: vif=%p", vif), UVM_LOW)
  endfunction

  // initialize safe values //reset
  task reset_phase(uvm_phase phase);
    @(vif.driver_cb);
    vif.driver_cb.psel    <= 0;
    vif.driver_cb.penable <= 0;
    vif.driver_cb.pwrite  <= 0;
    vif.driver_cb.paddr   <= '0;
    vif.driver_cb.pwdata  <= '0;
    @(vif.driver_cb);
    `uvm_info("DRV", "Driver reset_phase applied safe idle values", UVM_LOW)
  endtask

  //main task
  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);

    // apply safe reset/idle values before accepting any items
    reset_phase(phase);

    forever begin
      // get transaction
      seq_item_port.get_next_item(req);
      `uvm_info("DRV", $sformatf("Got seq item: pwrite=%0b paddr=0x%0h pwdata=0x%0h",
                 req.pwrite, req.paddr, req.pwdata), UVM_LOW)

      // perform APB transfer
      drive_item(req);

      // mark item done (item contains captured response fields)
      seq_item_port.item_done();
      `uvm_info("DRV", "Item done signalled to sequencer", UVM_LOW)
    end

    // never reached in typical forever driver; test will drop objection
    // phase.drop_objection(this);
  endtask

  // drive a single APB read/write transfer using clocking block
  task drive_item(apb_seq_item req);
    time start_time = $time;
    int timeout_cycles = 1000; // change as appropriate (to avoid infinite waits)
    int waited = 0;

    // SETUP phase (drive on clocking block)
    @(vif.driver_cb);
    vif.driver_cb.pwrite  <= req.pwrite;
    vif.driver_cb.paddr   <= req.paddr;
    if (req.pwrite) vif.driver_cb.pwdata <= req.pwdata;
    vif.driver_cb.psel    <= 1;
    vif.driver_cb.penable <= 0;
    `uvm_info("DRV", $sformatf("Setup: psel=1 pwrite=%0b paddr=0x%0h pwdata=0x%0h", req.pwrite, req.paddr, req.pwdata), UVM_LOW)

    // ACCESS phase (next clock)
    @(vif.driver_cb);
    vif.driver_cb.penable <= 1;
    `uvm_info("DRV", "Access: penable=1", UVM_LOW)

    // Wait for pready asserted — sample at clock boundaries
    forever begin
      @(vif.driver_cb);
      
      waited++;
      if (vif.driver_cb.pready === 1) begin
        `uvm_info("DRV", $sformatf("PREADY=1 observed after %0d cycles", waited), UVM_LOW)
        break;
      end
      // if pready is x or z or stuck, time out
      if (waited >= timeout_cycles) begin
        `uvm_error("DRV_TIMEOUT", $sformatf("PREADY not asserted after %0d cycles (time %0t)", waited, $time));
        break;
      end
    end

    // capture response (sampleed on clocking block)
    @(vif.driver_cb);
    req.prdata  = vif.driver_cb.prdata;
    req.pslverr = vif.driver_cb.pslverr;
    `uvm_info("DRV", $sformatf("Captured response: prdata=0x%0h pslverr=%0b", req.prdata, req.pslverr), UVM_LOW)

    // COMPLETE: deassert signals one clock later
    @(vif.driver_cb);
    vif.driver_cb.psel    <= 0;
    vif.driver_cb.penable <= 0;
    // optional: clear pwdata/pwrite/paddr if desired
    @(vif.driver_cb);
    `uvm_info("DRV", "Transfer complete: psel/penable deasserted", UVM_LOW)
  endtask

endclass
`endif
