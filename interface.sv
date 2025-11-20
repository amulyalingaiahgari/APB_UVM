`ifndef APB_IF_SV
`define APB_IF_SV

interface apb_if (
  input logic pclk,
  input logic presetn
);

  //apb signals
  logic        psel;
  logic        penable;
  logic        pwrite;
  logic [31:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic        pready;
  logic        pslverr;

  // ----- driver clocking block -----
  clocking driver_cb @(posedge pclk);
    default input #1ns output #1ns;
    output psel, penable, pwrite, paddr, pwdata;
    input prdata, pready, pslverr;
  endclocking

  // -----. monitor clocking block -----
  clocking monitor_cb @(posedge pclk);
    default input #1ns;
    input psel, penable, pwrite, paddr, pwdata, prdata, pready, pslverr;
  endclocking

  // ---------- modports ----------
  modport DRIVER(clocking driver_cb, input presetn);
    modport MONITOR(clocking monitor_cb, input presetn);

endinterface
`endif
