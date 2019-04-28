module fpadder (
    input  [31:0] src1,
    input  [31:0] src2,
    output reg [31:0] out
);

  

  reg [31:0] bigNum, smallNum; //to seperate big and small numbers
  wire [22:0] big_fra, small_fra; //to hold fraction part
  wire [7:0] big_ex, small_ex; //to hold exponent part
  wire big_sig, small_sig; //to hold signs

  wire [7:0] ex_diff; //difrence between exponentials
  reg [23:0] small_float, big_float; //with integer 
  reg [23:0] shift_small_float;
  reg [24:0] sign_shift_small_float, sign_big_float; //with sign bit and integer
 
  reg [25:0] overflow;

  reg G;
  reg R;
  reg S;
  wire[2:0] GRS;
  reg shift_cnt;
  reg [23:0] tmp;

  reg [24:0] sum;

  reg [7:0] sum_ex;
  reg [22:0] sum_fra;
  reg sum_sig;

  assign {big_sig, big_ex, big_fra} = bigNum;
  assign {small_sig, small_ex, small_fra} = smallNum;
  assign ex_diff = big_ex - small_ex;
  assign GRS = {G, R, S};
 
 

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

  always@(big_fra or small_fra)
    begin 
      //exception
      big_float = (big_ex==0)?{1'b0, big_fra}:{1'b1, big_fra};
      small_float = (small_ex==0)?{1'b0, small_fra}:{1'b1, small_fra};
      sum_ex = (big_ex==0 && small_ex==0)?(big_ex+1):big_ex;
    end

  always@(big_float or small_float) //shift the smaller one
    begin
      case(ex_diff)
	0: begin G = 0; R = 0; S = 0; end
	1: begin G = small_float[0]; R = 0; S = 0; end
	2: begin G = small_float[1]; R = small_float[0]; S = 0; end
	default: begin G = small_float[ex_diff-1];
	         R = small_float[ex_diff-2];
		 tmp = small_float;
	         tmp = tmp << (24 - ex_diff + 2);
	         S = (tmp==0)?0:1; end
      endcase 
      shift_small_float = (small_float >> ex_diff);
    end


  always@(shift_small_float or big_float) //add the sign bit
    begin
      if(big_sig!=small_sig && big_float==shift_small_float) //if zero
	begin
	  sum_sig = 0;
	  sum_ex = 0;
	  sum_fra = 0;
	end
      else
	begin
          sign_big_float = (big_sig==1)?(~{1'b0, big_float} + 25'b1):({1'b0, big_float});
          sign_shift_small_float = (small_sig==1)?(~{1'b0, shift_small_float} + 25'b1):({1'b0, shift_small_float});
	end
    end

  always@(sign_shift_small_float or sign_big_float) //sum
    begin
      overflow = {1'b0, sign_shift_small_float} + {1'b0, sign_big_float};
    end

  always@(overflow) //extract
    begin
      // - -
      if(small_sig==1 && big_sig==1)
	begin
	  sum_sig = 1;
          overflow = ~overflow + 26'b1;
	  sum = overflow[24:0];
	end
      // + +
      else if(small_sig==0 && big_sig==0)
	begin
	  sum_sig = 0;
	  sum = overflow[24:0];
	end
      // + -
      else 
	begin 
	  if(small_sig==1)
	    begin
	      sum_sig = 0;
	      sum = overflow[24:0];
	    end
	  else
	    begin
	      sum_sig = 1;
	      overflow = ~overflow + 26'b1;
	      sum = overflow[24:0];
	    end
	end
    end

   always@(sum)
    begin
      if(sum[24]==1)
	begin
	  sum_ex = sum_ex + 1;
	  S = S|R;
	  R = G;
	  G = sum[0];
	  sum = sum >> 1;
	  sum_fra = sum[22:0];
	end
      else
	begin
          while(sum[23]!=1)
	    begin
	      sum  = sum << 1;
	      sum_ex = sum_ex - 1;
	    end
	  sum_fra = sum[22:0];
	end
      //round
      if(GRS > 3'b100)
	begin
	  sum_fra = sum_fra + 1;
	end
      else if(GRS == 3'b100)
	begin
	  sum_fra = (sum_fra[0]==1)?(sum_fra+1):sum_fra;
	end
      else
	begin
	  sum_fra = sum_fra;
	end
      //exception
      sum_fra = (sum_ex==8'b11111111)?0:sum_fra;
    end

	  
  always@(sum_fra)
    begin    
      out = {sum_sig, sum_ex, sum_fra};
    end



endmodule
