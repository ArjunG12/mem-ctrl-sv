// -----------------------------------------------------------------------------
// File: design.sv
// Description: Memory Controller Interface and DUT Module
// -----------------------------------------------------------------------------

interface mem_intf(input clk);
  logic rst, CS, wr, ready;
  logic [7:0] addr;
  logic [15:0] Rdata, wdata;

  clocking cb @(posedge clk);
    default input #1ns output #2ns;
    output rst, CS, wr, addr, wdata;
    input ready, Rdata;
  endclocking

  modport DUT(
    input clk, rst, CS, wr, addr, wdata,
    output ready, Rdata
  );
  
  modport TB(clocking cb, input clk);
endinterface

module memctr(mem_intf.DUT intf);
  logic [15:0] mem [255:0];
  reg [1:0] state;
  logic ready;

  assign ready = (state[1:0] == 2'b00);
  assign intf.ready = ready;

  // Memory Write Logic
  always_ff @(posedge intf.clk, negedge intf.rst) begin
    if (!intf.rst) begin
      foreach(mem[i]) mem[i] <= 16'hABCD; // Reset value specified in documentation
    end
    else if (intf.CS && ready && intf.wr) begin
      mem[intf.addr] <= intf.wdata;
    end
  end

  // Memory Read Logic
  always_ff @(posedge intf.clk, negedge intf.rst) begin
    if (!intf.rst)
      intf.Rdata <= 0;
    else if (intf.CS && ready && !intf.wr)
      intf.Rdata <= mem[intf.addr];
    else
      intf.Rdata <= 0;
  end

  // Ready Signal State Machine
  always_ff @(posedge intf.clk, negedge intf.rst) begin
    if (!intf.rst)
      state <= 0;
    else if (intf.CS && ready)
      state <= 2'b01;
    else begin
      if (intf.wr) begin
        case(state)
          2'b01: state <= 2'b10;
          2'b10: state <= 2'b11;
          2'b11: state <= 2'b00;
        endcase
      end
      else begin
        case(state)
          2'b01: state <= 2'b00;
        endcase
      end
    end
  end
endmodule
