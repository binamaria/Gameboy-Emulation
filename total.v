`define START 0
`define FETCH 1
`define DECODE 2
`define EXECUTE 3
`define WRITEBACK 4
module processor();

reg[7:0] pc;
reg[7:0] instruction;
reg[7:0] A;
reg[7:0] B;
reg[7:0] C;
reg[7:0] D;
reg[7:0] imm;
reg[7:0] memory[255:0];
reg[7:0] result;
reg[7:0] Rrd;
reg[7:0] Rrs;
reg[7:0] Rrt;
reg[7:0] cycle;
reg[7:0] opCode_2;
reg[7:0] opCode_4;
reg clk=0;


wire[7:0] instruction_in;
wire[7:0] Rrd_in;
wire[7:0] Rrs_in;
wire [7:0] Rrt_in;
wire[1:0] rd;
wire[1:0] rs;
wire[1:0] rt;
wire[7:0] PC_in;
wire[7:0] result_in;
wire[7:0] register_in;
wire[7:0] opCode_2_in;
wire[7:0] opCode_4_in;
wire[7:0] imm_in;


assign instruction_in=memory[pc];
assign opCode_2_in=instruction[7:6];
assign opCode_4_in=instruction[7:4];
assign imm_in=instruction[3:0];
assign rt=instruction[5:4];
assign rd=instruction[3:2];
assign rs=instruction[1:0];
assign PC_in=pc+1;
assign Rrd_in  =  rd==0 ? A:
				  rd==1 ? B:
				  rd==2 ? C:
				  D;

assign Rrs_in = rs==0 ? A:
				rs==1 ? B:
				rs==2 ? C:
				D;
assign Rrt_in = rt==0 ? A:
				rt==1 ? B:
				rt==2 ? C:
				D;
				
assign result_in=Rrd+Rrs;
assign register_in=result;

initial begin 
	pc=0;
	cycle=`START;
	A=0;
	B=0;
	C=00;
	D=00;
	/*memory[0]=8'ha9;
	memory[1]=8'hd2;
	memory[2]=8'h0b;
	memory[3]=8'hff;*/
	memory[0]=8'hbf; memory[1]=8'hfe; memory[2]=8'h2b; memory[3]=8'h10; memory[4]=8'h90; memory[5]=8'hd1; memory[6]=8'hb1; memory[7]=8'hf3; memory[8]=8'h4e;
		memory[9]=8'h1f; memory[10]=8'h0d; memory[11]=8'h04; memory[12]=8'h10; memory[13]=8'h03; memory[14]=8'hb0; memory[15]=8'hf1;
		memory[16]=8'h1b; memory[17]=8'hb0; memory[18]=8'hf6;memory[19]=8'h5f;memory[20]=8'hbf;memory[21]=8'hff;memory[22]=8'h37; memory[23]=8'h70; memory[254]=8'h06;
	//memory[0]=8'hbf;
	//memory[1]=8'hfe;
	//memory[2]=255;
	//memory[3]=00;
	//memory[4]=255;	
end
always 
		#1 clk=~clk;

always @(posedge clk)
begin 
$display("Memory=%h",memory[255]);

	case(cycle)
	`START: 
		begin
			cycle <= `FETCH;
		end
	`FETCH: 
		begin
			cycle <= `DECODE;
			pc<= PC_in;
			instruction <=instruction_in;
		end
	`DECODE: 
		begin
			cycle <= `EXECUTE;
			opCode_2 <= opCode_2_in;
			opCode_4 <= opCode_4_in;
			Rrd <=Rrd_in;
			Rrs <= Rrs_in;
			Rrt <= Rrt_in;
			imm <= imm_in;
		end
	`EXECUTE: 
		begin
			cycle <= `WRITEBACK;
			case(opCode_2)
				
				2:
					begin
						$display("opcode = %h,Rrt=%h",opCode_2,Rrt);
						result <= (imm<<4) | Rrt[3:0];
					end
				3:
					begin
					$display("opcode = %h,Rrt=%h",opCode_2,Rrt);
						result <= (Rrt[7:4]<<4) | imm;
						$display("Result in LLI result=%h,Rrt=%h,Imm=%h ",result,Rrt,imm,instruction[3:0]);
					end	
			endcase
			
			case(opCode_4)
				0:
					begin
						result <= Rrd + Rrs;
					end
				1:
					begin
						result <= Rrd - Rrs;
					end
				2: 	
					begin
						result <= memory[Rrs];					
					end
				3:
					begin
						memory[Rrs] <= Rrd;
					end
				4:
					begin
						if(Rrs<=0)
							pc<= Rrd;
										
					end
				5:
					begin
						result <= pc;
					
					end
			//result <= Rrd+Rrs;
			endcase
			$display("A=%h, B=%h, C=%h, D=%h, cycle=%h, pc=%h,instruction=%h, result=%h,opCode_2=%h,imm=%h,Rrt=%h",A,B,C,D,cycle,pc,instruction,result,opCode_2,imm,Rrt);
		end
		

	`WRITEBACK: 
		begin
			cycle <=`FETCH;
			case(opCode_2)
				
				2:
					begin
						case(rt)
							0: 
								begin
									A <=register_in;
								end
							1:	
								begin
									B<=register_in;
								end 
							2:
								begin
									C<=register_in;
								end
							3: 
								begin
									D<=register_in;
								end
						endcase
						$display("opcode = %h,Rrt=%h",opCode_2,Rrt);
						//result <= (imm<<4) | Rrt[3:0];
					end
				3:
					begin
						case(rt)
							0: 
								begin
									A <=register_in;
								end
							1:	
								begin
									B<=register_in;
								end 
							2:
								begin
									C<=register_in;
								end
							3: 
								begin
									D<=register_in;
								end
						endcase
					$display("opcode = %h,Rrt=%h",opCode_2,Rrt);
						//result <= (Rrt[7:4]<<4) | imm;
					end	
			endcase
			
			case(opCode_4)
				0:
					begin
						case(rd)
							0: 
								begin
									A <=register_in;
								end
							1:	
								begin
									B<=register_in;
								end 
							2:
								begin
									C<=register_in;
								end
							3: 
								begin
									D<=register_in;
								end
						endcase
						//result <= Rrd + Rrs;
					end
				1:
					begin
						case(rd)
							0: 
								begin
									A <=register_in;
								end
							1:	
								begin
									B<=register_in;
								end 
							2:
								begin
									C<=register_in;
								end
							3: 
								begin
									D<=register_in;
								end
						endcase
						//result <= Rrd - Rrs;
					end
				2: 	
					begin
						case(rd)
							0: 
								begin
									A <=register_in;
								end
							1:	
								begin
									B<=register_in;
								end 
							2:
								begin
									C<=register_in;
								end
							3: 
								begin
									D<=register_in;
								end
						endcase
						//result <= memory[Rrs];					
					end
				
				4:
					begin
					if(Rrs<=0)
						case(rd)
							0: 
								begin
									A <=register_in;
								end
							1:	
								begin
									B<=register_in;
								end 
							2:
								begin
									C<=register_in;
								end
							3: 
								begin
									D<=register_in;
								end
						endcase
						
						/*if(Rrs<=0)
							pc<= memory[Rrd];*/
										
					end
				5:
					begin
						case(rs)
							0: 
								begin
									A <=register_in;
									
								end
							1:	
								begin
									B<=register_in;
								end 
							2:
								begin
									C<=register_in;
								end
							3: 
								begin
									D<=register_in;
								end
						endcase
						pc <= Rrd;
					
					end
			//result <= Rrd+Rrs;
			endcase
			
			
			/*case(rd)
				0: 
					begin
						//A <=register_in;
					end
				1:	
					begin
						//B<=register_in;
					end 
				2:
					begin
						//C<=register_in;
					end
				3: 
					begin
						//D<=register_in;
					end
			endcase	*/
		end
	
	endcase
	
	//$display("A=%h, B=%h, C=%h, D=%h, cycle=%h, pc=%h,instruction=%h",A,B,C,D,cycle,pc,instruction);
	$display("Memory=%h",memory[255]);
	if(instruction==112) $finish;

end

endmodule