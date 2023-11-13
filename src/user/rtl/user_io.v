module user_io //#(
//)
(
  inout   wire  [7:0]     pmod_ja,
  inout   wire  [7:0]     pmod_ja_pad
);

  OBUF //#(
  //)
  OBUF_pmod_ja_i0 (
    .I        (pmod_ja[0]),
    .O        (pmod_ja_pad[0])
  );

  genvar i;
  generate
    for (i = 1; i < 8; i = i + 1) begin
      OBUF //(
      //)
      OBUF_pmod_ja_unused (
        .I        (pmod_ja[i]),
        .O        (pmod_ja_pad[i])
      );
    end
  endgenerate

endmodule

