module fpadder (
    input  [31:0] src1,
    input  [31:0] src2,
    output reg [31:0] out
);

  

  reg [31:0] bigNum, smallNum; //to seperate big and small numbers
  reg [22:0] big_fra, small_fra; //to hold fraction part
  reg [7:0] big_ex, small_ex; //to hold exponent part
  reg big_sig, small_sig; //to hold signs

  reg [7:0] ex_diff; //difrence between exponentials
  reg [23:0] small_float, big_float; //with overflowbit, integer bit
  reg [47:0] shift_small_float, shift_big_float;

  reg [7:0] tmp_ex;

  reg [47:0] sum;

  reg [7:0] sum_ex;
  reg [22:0] sum_fra;
  reg sum_sig;

  reg [2:0] GRS;

 

 

  always@(src1 or src2) //determine big number
    begin
      if(src2[30:23] > src1[30:23])
        begin
          bigNum = src2;
          smallNum = src1;
        end
      else if(src2[30:23] == src1[30:23])
        begin
          if(src2[22:0] > src1[22:0])
            begin
              bigNum = src2;
              smallNum = src1;
            end
          else
            begin
              bigNum = src1;
              smallNum = src2;
            end
        end
      else
        begin
          bigNum = src1;
          smallNum = src2;
        end
    end

  always@(bigNum or smallNum)
	begin
	big_sig = bigNum[31];
	big_ex = bigNum[30:23];
	big_fra = bigNum[22:0];
	small_sig = smallNum[31];
	small_ex = smallNum[30:23];
	small_fra = smallNum[22:0];
	end


  always@(big_fra or small_fra)
    begin 
	//exception
	if(big_ex==0)
		begin
		big_float = {1'b0, big_fra};
		big_ex = 1;
		end
	else
		begin
		big_float = {1'b1, big_fra};
		end
	if(small_ex==0)
		begin
		small_float = {1'b0, small_fra};
		small_ex = 1;
		end
	else
		begin
		small_float = {1'b1, small_fra};
		end
	ex_diff = big_ex - small_ex;
	sum_ex = big_ex;
    end

  always@(big_float or small_float) //shift the smaller one
    begin
	shift_small_float = {1'b0, small_float, 23'b0};
	shift_big_float = {1'b0, big_float, 23'b0};
        shift_small_float = (shift_small_float >> ex_diff);
    end


  always@(shift_small_float or shift_big_float) //add 
    begin
	sum_sig = big_sig;
	if(big_sig==small_sig)
		begin
		sum = shift_small_float + shift_big_float;
		end
	else
		begin
		sum = shift_big_float - shift_small_float;
		end	
    end


   always@(sum)
 	begin
	if(sum[47]==1)
		begin
		sum_ex = sum_ex + 1;
		sum_fra = sum[46:24];
		GRS = sum[23:21];
		GRS[0] = (sum[21:0]==0)?0:1;
		end
	else if(sum==0)
		begin
		sum_ex = 0;
		sum_sig = 0;
		sum_fra = 0;
		end
	else
		begin
		while(sum[46]==0)
			begin   
			sum = sum << 1;
			sum_ex = sum_ex - 1;
			end
		sum_fra = sum[45:23];
		GRS = sum[22:20];
		GRS[0] = (sum[20:0]==0)?0:1;
		end
	if(GRS>3'b100)
		begin
		sum_fra = sum_fra + 1;
		end
	else if(GRS==3'b100)
		begin
		sum_fra = sum_fra + sum_fra[0];
		end
	else
		begin
		end
	//exception
	sum_fra = (sum_ex==8'b11111111)?0:sum_fra;
	//
	if(src1[22:0]==src2[22:0] && src1[31]!=src2[31] && src1[30:23]==src2[30:23])
		begin
		sum_sig = 0;
		sum_ex = 0;
		sum_fra = 0;
		end
	
	else
		begin
		end
	out = {sum_sig, sum_ex, sum_fra};
	end
	
    

	  




endmodule