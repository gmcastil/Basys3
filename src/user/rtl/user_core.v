module user_core //#(
//)
(
  input   wire          clk_ext,
  inout   wire  [7:0]   pmod_ja
);

  assign pmod_ja[0] = pmod_ja_r;
  reg pmod_ja_r = 1'b0;

  always @(posedge clk_ext) begin
    pmod_ja_r <= ~pmod_ja_r;
  end

endmodule
