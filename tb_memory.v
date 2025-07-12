`timescale 1ns/1ps

module tb;
  parameter WIDTH = 8;
  parameter DEPTH = 8;

  reg CS, RE, WE, CLK, RESET;
  reg [WIDTH-1:0] WDATA;
  reg [$clog2(DEPTH)-1:0] WADDR, RADDR;
  wire [WIDTH-1:0] RDATA;

  memory #(WIDTH, DEPTH) dut (
    .CS(CS), .RE(RE), .WE(WE), .CLK(CLK), .RESET(RESET),
    .WDATA(WDATA), .WADDR(WADDR), .RDATA(RDATA), .RADDR(RADDR)
  );

  always #5 CLK = ~CLK;

  task delay(input integer n);
    begin repeat(n) @(posedge CLK); end
  endtask

  
  task write_addr(input [$clog2(DEPTH)-1:0] addr, input [WIDTH-1:0] data);
    begin
      @(posedge CLK);
      CS = 1; WE = 1; WADDR = addr; WDATA = data;
      delay(1);
      WE = 0;
      $display("addr:%d|data=%h",addr,data);
    end
  endtask

 
  task read_addr(input [$clog2(DEPTH)-1:0] addr, input [WIDTH-1:0] expected);
    begin
      @(posedge CLK);
      CS = 1; RE = 1; RADDR = addr;
      delay(1);
      RE = 0;
      if (RDATA !== expected)
        $display(" [FAIL] Addr %0d: Expected %h, Got %h", addr, expected, RDATA);
      else
        $display("[PASS] Addr %0d: Read correct value %h", addr, RDATA);
    end
  endtask

  task reset_mem();
    integer i;
    begin
      $display("\n--- Performing RESET ---");
      CS = 1; RESET = 0;
      for(i=0;i<5;i=i+1)
        begin
          WE=1;
          WADDR=i;
          WDATA=$random%(2**WIDTH);
          $display($time," : WADDR=%d WDATA=%h",WADDR,WDATA);
          delay(1);
        end
      RESET = 1;
//       delay(1);
//       RESET=0;
      for(i=1;i<4;i=i+1)
        begin
          WE=0;
          RADDR=i;
          
          $display($time," : RADDR=%d RDATA=%h",RADDR,RDATA);
          delay(1);
        end
    end
  endtask

  // Main test sequence
  initial begin
    CLK = 0; CS = 0; RE = 0; WE = 0; RESET = 0;
    WDATA = 0; WADDR = 0; RADDR = 0;

    delay(2);

    if ($test$plusargs("reset")) begin
      reset_mem();
    end

    if ($test$plusargs("write")) begin
      $display("\n--- Performing MULTI-LOCATION WRITE Test ---");
      for (int i = 0; i < DEPTH; i++) begin
        write_addr(i[$clog2(DEPTH)-1:0], i*10); // Write 0,10,20,...
      end
    end

    if ($test$plusargs("_read")) begin
      $display("\n--- Performing MULTI-LOCATION READ Test ---");
      for (int i = 0; i < DEPTH; i++) begin
        read_addr(i[$clog2(DEPTH)-1:0], i*10);
      end
    end

    if ($test$plusargs("overwrite")) begin
      $display("\n--- Performing OVERWRITE Test ---");
      write_addr(2, 8'hAA);       // old data
      write_addr(2, 8'hBB);       // overwrite
      read_addr(2, 8'hBB);        // should be new data
    end

    if ($test$plusargs("readwrite_sameaddr")) begin
      $display("\n--- Performing READ & WRITE at SAME Address ---");
        CS = 1; WE = 1; RE = 0;
        write_addr(4, 8'hAA);
        delay(1);
        WE = 1; RE = 1; WADDR = 4; RADDR = 4; WDATA = 8'h77;
        delay(1);
        $display("Cycle 1 - Simultaneous R/W at addr 4 => RDATA = %0h (Expecting OLD: 8'hAA)", RDATA);

        WE = 0; RE = 1;
        delay(1); 
        $display("Cycle 2 - Read after previous write => RDATA = %0h (Expecting NEW: 8'h77)", RDATA);

        RE = 0;
end


    if ($test$plusargs("readwrite_diffaddr")) begin
        $display("\n--- Performing READ & WRITE at DIFFERENT Addresses ---");
        CS = 1; WE = 1; RE = 0;
        write_addr(5, 8'h33); 
        delay(1);

        CS = 1; WE = 1; RE = 1;
        WADDR = 6; WDATA = 8'h88;  
        RADDR = 5;                
        delay(1);                  
        $display("Cycle 1 - Wrote 0x88 to addr 6 while reading addr 5 => RDATA = %0h (Expecting: 8'h33)", RDATA);

        WE = 0; RE = 1;
        RADDR = 6;
        delay(1);
        $display("Cycle 2 - Reading from addr 6 => RDATA = %0h (Expecting: 8'h88)", RDATA);

        RE = 0;
      end


    $display("\n ALL ENABLED TESTS FINISHED \n");
    $finish;
  end

  initial begin
    $dumpvars();
    $dumpfile("dump.vcd");
  end
  
endmodule
