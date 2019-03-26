module traffic_light (
    input  clk,
    input  rst,
    input  pass,
    output reg R,
    output reg G,
    output reg Y
);


reg [2:0] CurrentState, NextState;
reg [15:0] clk_cnt, bound;

parameter [2:0] ST0 = 3'b000, ST1 = 3'b001, ST2 = 3'b010, 
		ST3 = 3'b011, ST4 = 3'b100, ST5 = 3'b101, ST6 = 3'b110;


always@(posedge clk or negedge rst)
	if (rst) 
		begin CurrentState<=ST0; clk_cnt<=0; end
	else
		begin 
			if(clk_cnt>=bound) 
				begin CurrentState<=NextState; clk_cnt<=1; end
			else
				clk_cnt <= clk_cnt+1;
		end

always@(pass)
	if(pass) begin
		if(CurrentState!=ST0) begin
			CurrentState = ST0; clk_cnt = 0; end
		else ;
		end
	else ;

always@(CurrentState)
	begin
		case(CurrentState)
			ST0:begin NextState = ST1; bound = 1024; end
			ST1:begin NextState = ST2; bound = 128; end
			ST2:begin NextState = ST3; bound = 128; end
			ST3:begin NextState = ST4; bound = 128; end
			ST4:begin NextState = ST5; bound = 128; end
			ST5:begin NextState = ST6; bound = 512; end
			ST6:begin NextState = ST0; bound = 1024; end
		endcase
	end


always@(CurrentState)
	begin
	case(CurrentState)
	ST0:
		begin R=0;G=1;Y=0; end
	ST1:
		begin R=0;G=0;Y=0; end
	ST2:
		begin R=0;G=1;Y=0; end
	ST3:
		begin R=0;G=0;Y=0; end
	ST4:
		begin R=0;G=1;Y=0; end
	ST5:
		begin R=0;G=0;Y=1; end
	ST6:
		begin R=1;G=0;Y=0; end
	endcase
	end

	





endmodule
