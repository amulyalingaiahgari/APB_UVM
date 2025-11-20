module apb_slave(
    input              presetn,
    input              pclk,
    input              psel,
    input              penable,
    input              pwrite,
    input  [31:0]      paddr,
    input  [31:0]      pwdata,
    output reg [31:0]  prdata,
    output reg         pready,
    output reg         pslverr
);

    // Simple 32-location register bank
    reg [31:0] mem [0:31];

    // FSM states
    typedef enum {idle = 0, setup = 1, access = 2, transfer = 3} state_type;
    state_type state = idle;

    // Synchronous logic
    always @(posedge pclk) begin
      if (!presetn) begin //active low
            // Reset condition
            state    <= idle;
            prdata   <= 32'h00000000;
            pready   <= 0;
            pslverr  <= 0;

            for (int i = 0; i < 32; i++) begin
                mem[i] <= 0;
            end
        end 
        else begin
            case (state)
                idle: begin
                    prdata  <= 32'h00000000;
                    pready  <= 0;
                    pslverr <= 0;
                    if ((!psel) && (!penable))
                        state <= setup;
                    else
                      state <= idle;
                end
                setup: begin //state of transaction
                    if (psel && (!penable)) begin
                        if (paddr < 32) begin
                            state <= access;
                            pready <= 0;
                        end 
                        else begin
                          state <= access;
                          pready<=0;
                        end
                    end
                    else
                      state <= setup; // Invalid address — stay in setup
                end
                access: begin
                  if (psel && penable && pwrite) begin
                                mem[paddr] <= pwdata;
                                state <= transfer;
                                pslverr <= 0;
                            end
                  else begin
                    if(psel && penable && !pwrite) begin
                      prdata  <= mem[paddr];
                      state <= transfer;
                      pready <= 1;
                                pslverr <= 0;
                            end
                         else begin
                           state<=transfer;
                           pready<=1;
                            prdata  <= 32'hxxxxxxxx;
                            pslverr <= 1;
                        end
                     end
                end
                transfer: begin
                    pready   <= 0;
                    pslverr  <= 0;
                    state    <= setup;
                end
                default: state <= idle;
            endcase
        end
    end
endmodule
