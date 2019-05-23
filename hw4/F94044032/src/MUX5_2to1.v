module MUX5_2to1
(
	data1_i,
    data2_i,
    select_i,
    data_o
);

input	[4:0]	data1_i,data2_i;
input			select_i;
output	[4:0]	data_o;

reg		[4:0] 	data_out;

always@(*)
begin
  if(select_i)
    data_out = data2_i;
  else
    data_out = data1_i;
end

assign data_o = data_out;

endmodule