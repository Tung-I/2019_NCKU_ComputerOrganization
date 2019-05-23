module Shift_Left_2_26to28
(
	data_i,
	data_o
);

input	[25:0]	data_i;
output	[27:0]	data_o;

assign data_o = data_i << 2 ;

endmodule