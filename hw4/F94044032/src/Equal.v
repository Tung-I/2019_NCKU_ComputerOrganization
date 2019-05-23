module Equal
(
	data1_i,
    data2_i,
    Eq_o
);

input	[31:0]	data1_i,data2_i;
output			Eq_o;

assign Eq_o = (data1_i == data2_i)? 1 : 0 ;

endmodule