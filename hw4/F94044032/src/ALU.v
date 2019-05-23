module ALU(
	data1,
	data2,
	ALUCtr,
	dataout
);

input[31:0] data1;
input[31:0] data2;
input[2:0] ALUCtr;
output[31:0] dataout;

reg[31:0] d;

always@(*)
begin
  if(ALUCtr == 3'b000)
  	d = data1 + data2;
  else if(ALUCtr == 3'b001)
    d = data1 - data2;
  else if(ALUCtr == 3'b010)
    d = data1 | data2;
  else if(ALUCtr == 3'b011)
    d = data1 & data2;
  else if(ALUCtr == 3'b100)
    d = data1 * data2;
end

assign dataout = d;

endmodule



