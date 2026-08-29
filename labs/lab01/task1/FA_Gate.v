// FA_Gate.v

// Gate-level model of a 1-bit full adder. No delays yet -- that starts in
// Task 2. This task is purely about gate ordering.

module FA_Gate(

  input a,

  input b,

  input cin,

  output sum,

  output cout

);

  wire ps, pc1, pc2;

  xor (ps,  a,   b);

  and (pc1, a,   b);

  xor (sum, cin, ps);

  and (pc2, cin, ps);

  or  (cout, pc1, pc2);

endmodule