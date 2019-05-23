module Sign_Extend_20to32(data_i, data_o);
  input[19:0] data_i;
  output[31:0] data_o;
  assign data_o[19:0] = data_i;
  assign data_o[31:20] = 12'b0;

endmodule 
