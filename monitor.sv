`ifndef APB_MONITOR_SV
`define APB_MONITOR_SV

class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)

  virtual apb_if.MONITOR vif;
  uvm_analysis_port #(apb_seq_item) mon_ap;

  function new(string name="apb_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_if.MONITOR)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "NO virtual interface assigned to monitor")

      mon_ap = new("mon_ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    apb_seq_item trans;

    forever begin
      @(vif.monitor_cb);

      if(vif.monitor_cb.psel && vif.monitor_cb.penable) begin
        `uvm_info("MONITOR", "Detected APB transaction", UVM_MEDIUM)
        trans = apb_seq_item::type_id::create("trans", this);

        trans.paddr = vif.monitor_cb.paddr;
        trans.pwrite = vif.monitor_cb.pwrite;
        trans.pslverr = vif.monitor_cb.pslverr;
        trans.pwdata = vif.monitor_cb.pwdata;
        trans.prdata = vif.monitor_cb.prdata;

        mon_ap.write(trans);
      end
    end
  endtask
  
endclass
`endif
