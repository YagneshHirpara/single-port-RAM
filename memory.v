module  memory #(parameter WIDTH=8,DEPTH=8)(
  input CS,RE,WE,CLK,RESET,
  input [WIDTH-1:0]WDATA,
  input [$clog2(DEPTH)-1:0]WADDR,
  output reg [WIDTH-1:0]RDATA,
  input [$clog2(DEPTH)-1:0]RADDR
);
  integer i;
  reg [WIDTH-1:0]mem[DEPTH-1:0];
  
  always@(posedge CLK) begin
    if(RESET&&CS)begin
      for(i=0;i<DEPTH;i=i+1)
        begin
          mem[i]<=0;
        end
      RDATA=0;
    end
  end
  
  always@(posedge CLK) begin
    if(RE&&(!RESET)&&(CS)) RDATA<=mem[RADDR];
  end 
     
  always@(posedge CLK) begin
    if(WE&&(!RESET)&&CS) mem[WADDR]<=WDATA;
  end
    
endmodule


