module Sign_Extend_12to32(data_i, data_o);
  input[11:0] data_i;
  output[31:0] data_o;
  assign data_o[11:0] = data_i;
  assign data_o[31:12] = 20'b0;

endmodule 
