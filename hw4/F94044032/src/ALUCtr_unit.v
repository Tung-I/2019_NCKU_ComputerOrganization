module ALUCtr_unit(
	ALUOp,
	func,
	ALUCtr
);

/* add: 000
   sub: 001
   or : 010
   and: 011
   mul: 100  */


input[1:0] ALUOp;
input[5:0] func;
output[2:0] ALUCtr;

reg[2:0] ac;

always@(*)
begin
  if(ALUOp == 2'b00) // Rtype
  begin
  	if(func == 6'b100000 || func == 6'b000000) // add
  		ac = 3'b000;
  	else if(func == 6'b100010) // sub
  		ac = 3'b001;
  	else if(func == 6'b100101) // or
  		ac = 3'b010;
  	else if(func == 6'b100100) // and
  		ac = 3'b011;
  	else if(func == 6'b011000) // mul
  		ac = 3'b100;
  end
  else if(ALUOp == 2'b01) // add
  	ac = 3'b000;
  else if(ALUOp == 2'b10) // sub
    ac = 3'b001;
  else
    ac = 3'bxxx;
end

assign ALUCtr = ac;

endmodule





