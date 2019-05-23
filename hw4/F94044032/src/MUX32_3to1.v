module MUX32_3to1
(
    data1_i,
    data2_i,
    data3_i,
    select_i,
    data_o
);

input     [31:0]     data1_i,data2_i,data3_i;
input     [1:0]      select_i;
output    [31:0]     data_o;

reg       [31:0]     data_out;


always@(*)
begin
  if(select_i == 2'b00)
      data_out = data1_i;
  else if(select_i == 2'b01)
      data_out = data2_i;
  else if(select_i == 2'b10)
      data_out = data3_i;
end

assign data_o = data_out;

endmodule