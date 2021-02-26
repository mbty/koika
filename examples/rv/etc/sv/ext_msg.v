// -*- mode: verilog -*-
module ext_msg(
  input wire CLK, input wire RST_N, input wire[1:0] arg, output wire out
);
   wire active;
   wire code;

   assign {active, code} = arg;
   assign out = 1'b1;

`ifndef STDERR
  `define STDERR 32'h80000002
`endif

`ifdef SIMULATION
   always @(posedge CLK)
     if (active) begin
       $fwrite(`STDERR, "MSG: %0d\n", code);
   end
`endif
endmodule // ext_msg
