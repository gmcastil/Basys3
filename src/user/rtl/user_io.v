module user_io //#(
//)
(
  inout   wire  [7:0]     pmod_ja,
  inout   wire  [7:0]     pmod_ja_pad
);

  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin
      OBUF //(
      //)
      OBUF_pmod_ja (
        .I        (pmod_ja[i]),
        .O        (pmod_ja_pad[i])
      );
    end
  endgenerate

endmodule

