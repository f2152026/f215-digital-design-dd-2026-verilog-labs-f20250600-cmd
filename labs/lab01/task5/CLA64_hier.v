// CLA64_hier.v
// Hierarchical 64-bit carry-lookahead adder

module cla64_hier(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  wire [15:0] Pblk;
  wire [15:0] Gblk;
  wire [15:0] Cblk;

  wire [63:0] p;
  wire [63:0] g;

  // Bit propagate/generate
  genvar i;

  generate
    for (i = 0; i < 64; i = i + 1) begin : PG
      xor #(2) (p[i], a[i], b[i]);
      and #(2) (g[i], a[i], b[i]);
    end
  endgenerate

  // Block propagate:
  // Pblk[k] = p[4k+3] & p[4k+2] & p[4k+1] & p[4k]
  genvar k;

  generate
    for (k = 0; k < 16; k = k + 1) begin : BLOCK_P
      and #(2) (
        Pblk[k],
        p[4*k+3],
        p[4*k+2],
        p[4*k+1],
        p[4*k]
      );
    end
  endgenerate

  // Block generate.
  // Gblk[k] = g3 + p3.g2 + p3.p2.g1
  //         + p3.p2.p1.g0
  generate
    for (k = 0; k < 16; k = k + 1) begin : BLOCK_G
      wire t1, t2, t3;

      and #(2) (t1, p[4*k+3], g[4*k+2]);
      and #(2) (t2, p[4*k+3], p[4*k+2], g[4*k+1]);
      and #(2) (t3, p[4*k+3], p[4*k+2], p[4*k+1], g[4*k]);

      or #(2) (
        Gblk[k],
        g[4*k+3],
        t1,
        t2,
        t3
      );
    end
  endgenerate

  // Block carry-ins.
  // This is the second-level lookahead between the 16 four-bit blocks.
  assign #(2) Cblk[0] = cin;

  generate
    for (k = 1; k < 16; k = k + 1) begin : BLOCK_CARRY
      assign #(2) Cblk[k] =
          Gblk[k-1] |
          (Pblk[k-1] & Cblk[k-1]);
    end
  endgenerate

  // 16 four-bit CLA blocks.
  generate
    for (k = 0; k < 16; k = k + 1) begin : CLA_BLOCKS

      cla4 CLA (
        .a    (a[4*k +: 4]),
        .b    (b[4*k +: 4]),
        .cin  (Cblk[k]),
        .sum  (sum[4*k +: 4]),
        .cout ()
      );

    end
  endgenerate

  // Final carry
  assign #(2) cout =
      Gblk[15] |
      (Pblk[15] & Cblk[15]);

endmodule