module control_unit(
  op,
  RegDst,
  ALUSrc,
  MemtoReg,
  RegWrite,
  MemWrite,
  Branch,
  Jump,
  ExtOp,
  ALUOp,
  MemRead
);

input[5:0] op;
output RegDst;
output ALUSrc;
output MemtoReg;
output RegWrite;
output MemWrite;
output Branch;
output Jump;
output ExtOp;
output MemRead;
output[1:0] ALUOp;

reg rd;
reg as;
reg mtr;
reg rw;
reg mw;
reg br;
reg jp;
reg ex;
reg mr;
reg[1:0] ao;

always@(*)
begin
  if(op == 6'b000000) // R-type
  begin
    rd = 1;
    as = 0;
    mtr = 0;
    rw = 1;
    mw = 0;
    br = 0;
    jp = 0;
    ex = 0;
    mr = 0;
    ao = 2'b00; // Rtype
  end
  else if(op == 6'b001000) // addi
  begin
    rd = 0; 
    as = 1;
    mtr = 0;
    rw = 1;
    mw = 0;
    br = 0;
    jp = 0;
    ex = 0;
    mr = 0;
    ao = 2'b01; // add
  end
  else if(op == 6'b100011) // lw
  begin
    rd = 0;
    as = 1;
    mtr = 1;
    rw = 1;
    mw = 0;
    br = 0;
    jp = 0;
    ex = 1;
    mr = 1;
    ao =  2'b01; // Add
  end
  else if(op == 6'b101011) // sw
  begin
    rd = 0;
    as = 1;
    mtr = 0;
    rw = 0;
    mw = 1;
    br = 0;
    jp = 0;
    ex = 1;
    mr = 0;
    ao = 2'b01; // Add
  end
  else if(op == 6'b000100) // beq
  begin
    rd = 0;
    as = 0;
    mtr = 0;
    rw = 0;
    mw = 0;
    br = 1;
    jp = 0;
    ex = 0;
    mr = 0;
    ao = 2'b10; // Sub
  end 
  else if(op == 6'b000010) // jump
  begin
    rd = 0;
    as = 0;
    mtr = 0;
    rw = 0;
    mw = 0;
    br = 0;
    jp = 1;
    ex = 0;
    mr = 0;
    ao = 2'bxx;
  end
end

assign RegDst = rd;
assign ALUSrc = as;
assign MemtoReg = mtr;
assign RegWrite = rw;
assign MemWrite = mw;
assign Branch = br;
assign Jump = jp;
assign ExtOp = ex;
assign ALUOp = ao;
assign MemRead = mr;

endmodule

  
  

