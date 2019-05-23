module MUX32_2to1
(
	data1_i,
    data2_i,
    select_i,
    data_o
);

input	[31:0]	data1_i,data2_i;
input			select_i;
output	[31:0]	data_o;

reg		[31:0] 	data_out;

always@(*)
begin
  if(select_i)
    data_out = data2_i;
  else
    data_out = data1_i;
end

assign data_o = data_out;

endmodule