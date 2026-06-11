// -----------------------------------------------------------------------------
// File: testbench.sv
// Description: Layered Testbench components (Transaction, Driver, Generator)
// -----------------------------------------------------------------------------

class transaction;
  rand bit wr;
  rand bit [7:0] addr;
  rand bit [15:0] wdata;
  bit [15:0] rdata;

  // constraint wr2 {wr==1'b1;} 

  function void display(string tag);
    $display("[%s] %0t | wr=%0d addr=0x%h wdata=0x%h rdata=0x%h", 
             tag, $time, wr, addr, wdata, rdata);
  endfunction
endclass

class driver;
  virtual mem_intf.TB vif;
  mailbox #(transaction) mbx;

  function new(virtual mem_intf.TB vif, mailbox #(transaction) mbx);
    this.vif = vif;
    this.mbx = mbx;
  endfunction

  task run();
    transaction tr;
    vif.cb.CS <= 0;
    vif.cb.wr <= 0;
    @(vif.cb);
    forever begin
      mbx.get(tr);
      wait(vif.cb.ready);
      @(vif.cb);
      vif.cb.CS <= 1;
      vif.cb.wr <= tr.wr;
      vif.cb.addr <= tr.addr;
      vif.cb.wdata <= tr.wdata;
      tr.display("DRIVER");
      
      @(vif.cb);
      vif.cb.CS <= 0;
      @(vif.cb);
      
      if(!tr.wr) begin
        tr.rdata = vif.cb.Rdata;
      end
    end
  endtask
endclass

class generator;
  mailbox #(transaction) mbx;
  int count = 20;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task run();
    transaction tr;
    repeat(count) begin
      tr = new();
      assert(tr.randomize());
      tr.display("GEN");
      mbx.put(tr);
    end
  endtask
endclass

module simple_tb;
  logic clk;

  mem_intf intf(clk);
  memctr m(intf.DUT);

  always #5 clk = ~clk;

  initial begin
    mailbox #(transaction) mbx;
    driver dr;
    generator gen;

    $dumpfile("dump.vcd"); $dumpvars;
    clk = 0;

    // Reset Sequence
    intf.rst = 0;
    repeat(1) @(posedge clk);
    intf.rst = 1;

    $display("=== Simple Testbench ===");
    mbx = new();
    gen = new(mbx);
    dr = new(intf.TB, mbx);

    fork
      gen.run();
      dr.run();
    join_any
    
    #700;
    $display("=== Complete ===");
    $finish;
  end
endmodule
