module seqsm #(parameter DW=8, AW=8, byte_count=2**AW) 
(
// TODO: define your outputs and inputs
	input logic clk,
	input logic rst,
	
	input logic decRqst,
	input logic packetDone,
	input logic preambleDone,
	input logic fInValid,
	
	output logic getNext, 
	output logic loadLFSR,
	output logic lfsrEn,
	output logic incByteCnt,
	output logic payLoad,
	output logic validOut,
	output logic done
);


   // TODO: define your states
   // TODO: here is one suggestion, but you can implmenet any number of states
   // TODO: you like
	typedef enum {
			 Idle, LoadLFSR, ProcessPreamble, Decrypt, Done
			 } states_t;
			 
			states_t curState;
			states_t nxtState;
   // TODO: for example
   // TODO:  1: Idle -> 
   // TODO:  2: LoadLFSR ->
   // TODO:  3: ProcessPreamble (and select LFSR)
   // TODO:  4: Decrypt
   // TODO:  5: Done
always_ff @(posedge clk) begin
	if (rst) curState <= Idle;
	else curState <= nxtState;
end 
always_comb begin
	nxtState = curState;
	getNext = 0;
	loadLFSR = 0;
	lfsrEn = 0;
	incByteCnt = 0;
	payLoad = 1;
	validOut = 0;
	done = 0;
	
	unique case (curState)
	
	Idle:begin
		if(decRqst) begin 
			nxtState = LoadLFSR;
			done = 1'b0;
		end
		else begin
			nxtState = Idle;
			done = 1'b1;
		end 
	end
	
	LoadLFSR:begin
		loadLFSR = 0;
		if(fInValid) begin 
			nxtState = ProcessPreamble;
			loadLFSR = 1;
		end
		else         nxtState = LoadLFSR;
	end

	ProcessPreamble : begin
		if(fInValid) begin
			lfsrEn = 1;
			incByteCnt = 1;
			getNext = 1; 
			payLoad = 0;
			validOut = 1;
		end
		if(preambleDone) begin
			payLoad = 1;
			nxtState = Decrypt;
		end
		else nxtState = ProcessPreamble;
	end

	Decrypt : begin				
		if(fInValid) begin
			lfsrEn = 1;
			incByteCnt = 1;
			getNext = 1;
			validOut = 1;
		end
			
		if(packetDone) nxtState = Done;
		else nxtState = Decrypt;
	end
		
	Done : begin
		done = 1;
		nxtState = Idle;
	end
		
	default: nxtState = Idle;
	endcase //(unique case)
end // end comb
   // TODO: implement your state machine
   // TODO:
   // TODO: // sequential part
   // TODO: always_ff @(posedge clk) begin 
   // TODO:     . . .
   // TODO: end
   // TODO:
   // TODO: // combinatorial part
   // TODO: always_comb begin
   // TODO:     . . .
   // TODO: end
endmodule // seqsm