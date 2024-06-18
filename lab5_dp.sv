module lab5_dp #(parameter DW=8, AW=8, lfsr_bitwidth=5) (
// TODO: Declare your ports for your datapath
// TODO: for example							 
// TODO: ... 
// output logic foundOne, // found one matching LFSR solution
output logic [7:0] plainByte,
output logic fInValid,
output logic preambleDone,
output logic packetDone,
	
input logic [7:0] encryptByte, // encrypted byte from the lab5_tb
//input logic getseed,
input logic loadLFSR,		   // from seqsm, seed enable
input logic lfsrEn,
input logic payLoad,
input logic incByteCnt,
input logic getNext,
input logic validIn,
// input logic packetEnd,
input logic done,

input logic 	      clk, // clock signal 
input logic 	      rst           // reset
);



logic [lfsr_bitwidth-1:0] start;       // the seed value
logic [DW-1:0] 	    	  pre_len  = 'd7;  // preamble (~) length is fixed to 7 bytes         
logic foundOne;
logic [DW-1:0] 	           byteCount;
//logic [7:0] plain[6];

// FIFO
// This fifo takes data from the outside (testbench) and captures it
// Your logic reads from this fifo.
logic [7:0] fInEncryptByte;  // data from the fifo

fifo fm (.rdDat(fInEncryptByte), // fifo out data
		.valid(fInValid), // data valid

		.wrDat(encryptByte), // write into fifo
		.push(validIn), // write_en
		.pop(getNext),  // rd_en
		.clk(clk), 
		.rst(rst));

// TODO:
// TODO: detect preambleDone
assign preambleDone = ((pre_len == byteCount));
// assign en = preambleDone ? l_en : {6{lfsr_en}};
// TODO:

// TODO:
// TODO: detect packet end (i.e. 32 bytes have been processed)
assign packetDone = (byteCount == 32);
// TODO:

// TODO: you might want to have 6 different sets of LFSR_state
// TODO: signals, one belonging to each of six different possible
// TODO: LFSRs.
// TODO: for example: 
logic [7:0] LFSR_state[6];
logic [4:0] LFSR0_state;
logic [4:0] LFSR1_state;
logic [4:0] LFSR2_state;
logic [4:0] LFSR3_state;
logic [4:0] LFSR4_state;
logic [4:0] LFSR5_state;

//
// sticky bit logic to find matching LFSR
//
logic [5:0] match;   // match status for each lfsr

// TODO:
// TODO: and for each LFSR, keep a sticky bit 
// TODO: (e.g. logic [5:0] match;)
// TODO: that assumes the LFSR works, and on each
// TODO: successive byte of the preamble, either remains
// TODO: set or get's reset (and never set again).
// TODO: At the end of 7 bytes of premable, you should have
// TODO: only one of the six lfsr's still decoding premable bytes
// TODO: correctly.
// TODO:
// TODO: Instantiate 6 LFSRs here (one for each of the 6 possible
// TODO: polynomials (taps)).
// TODO:
// TODO: for example:
lfsr5b l0 (.clk ,
			.en   (lfsrEn),      // advance LFSR on rising clk
			.init (loadLFSR),    // initialize LFSR
			.taps(5'h1E)  , 	     // tap pattern
			.start(start), 	     // starting state for LFSR
			.state(LFSR0_state));	  // LFSR state = LFSR output 
// TODO: lfsr5b l1 ( . . . );
lfsr5b l1 (.clk ,
			.en   (lfsrEn),      // advance LFSR on rising clk
			.init (loadLFSR),    // initialize LFSR
			.taps(5'h1D)  , 	     // tap pattern
			.start(start) , 	     // starting state for LFSR
			.state(LFSR1_state));	  // LFSR state = LFSR output 
// TODO: lfsr5b l2 ( . . . );
lfsr5b l2 (.clk ,
			.en   (lfsrEn),      // advance LFSR on rising clk
			.init (loadLFSR),    // initialize LFSR
			.taps(5'h1B)  , 	     // tap pattern
			.start(start) , 	     // starting state for LFSR
			.state(LFSR2_state));	  // LFSR state = LFSR output 
// TODO: lfsr5b l3 ( . . . );
lfsr5b l3 (.clk ,
			.en   (lfsrEn),      // advance LFSR on rising clk
			.init (loadLFSR),    // initialize LFSR
			.taps(5'h17)  , 	     // tap pattern
			.start(start) , 	     // starting state for LFSR
			.state(LFSR3_state));	  // LFSR state = LFSR output 
// TODO: lfsr5b l4 ( . . . );
lfsr5b l4 (.clk ,
			.en   (lfsrEn),      // advance LFSR on rising clk
			.init (loadLFSR),    // initialize LFSR
			.taps(5'h14)  , 	     // tap pattern
			.start(start) , 	     // starting state for LFSR
			.state(LFSR4_state));	  // LFSR state = LFSR output 
// TODO: lfsr5b l5 ( . . . );
lfsr5b l5 (.clk ,
			.en   (lfsrEn),      // advance LFSR on rising clk
			.init (loadLFSR),    // initialize LFSR
			.taps(5'h12)  , 	     // tap pattern
			.start(start) , 	     // starting state for LFSR
			.state(LFSR5_state));	  // LFSR state = LFSR output 
			
always @(posedge clk) begin 
	if(rst) begin 
	match <= 6'h3F;
	foundOne <= 0;
	end 
	else begin  
	// TODO: for each of the 6 LFSRS
	// TODO: maintain a match bit
	// TODO: need to check for matches during the
	// TODO: preamble.  One way to determine we
	// TODO: are processing the preamble is
	// TODO: fInValid & getNext & ~payload // processing a preamble byte

	if(preambleDone) begin
		foundOne <= 1;
	end
	else if(fInValid && getNext && ~payLoad) begin
		match[0] = (LFSR_state[0] == 8'h7e);
		match[1] = (LFSR_state[1] == 8'h7e);
		match[2] = (LFSR_state[2] == 8'h7e);
		match[3] = (LFSR_state[3] == 8'h7e);
		match[4] = (LFSR_state[4] == 8'h7e);
		match[5] = (LFSR_state[5] == 8'h7e);
	end
	// TODO:
	// TODO: OR
	// TODO:
	// TODO: you can create a signal from your controller
	// TODO: that says we are processing a preamble byte
	// TODO:
	// TODO: if(.. processing a preamble byte .. ) begin
	// TODO:    sticky bit logic for match[0], match[1], ... match[5]
	// TODO: end 
	
	end 
end 





// TODO: write an expression for plainByte
// TODO: for example:
// TODO: assign plainByte = {         };
always_comb begin	
		if(!payLoad) begin
		LFSR_state[0] = fInEncryptByte ^ {3'b0,LFSR0_state};
		LFSR_state[1] = fInEncryptByte ^ {3'b0,LFSR1_state};
		LFSR_state[2] = fInEncryptByte ^ {3'b0,LFSR2_state};
		LFSR_state[3] = fInEncryptByte ^ {3'b0,LFSR3_state};
		LFSR_state[4] = fInEncryptByte ^ {3'b0,LFSR4_state};
		LFSR_state[5] = fInEncryptByte ^ {3'b0,LFSR5_state};
		end
		else if(payLoad) begin
		LFSR_state[0] = fInEncryptByte ^ {3'b100,LFSR0_state};
		LFSR_state[1] = fInEncryptByte ^ {3'b100,LFSR1_state};
		LFSR_state[2] = fInEncryptByte ^ {3'b100,LFSR2_state};
		LFSR_state[3] = fInEncryptByte ^ {3'b100,LFSR3_state};
		LFSR_state[4] = fInEncryptByte ^ {3'b100,LFSR4_state};
		LFSR_state[5] = fInEncryptByte ^ {3'b100,LFSR5_state};
		end
end


always_comb begin 
	if(byteCount > 6) begin
		if(match[0]) begin
			plainByte = LFSR_state[0];
		end 
		else if (match[1]) begin
			plainByte = LFSR_state[1];
		end 
		else if (match[2]) begin
			plainByte = LFSR_state[2];
		end 
		else if (match[3]) begin
			plainByte = LFSR_state[3];
		end 
		else if (match[4]) begin
			plainByte = LFSR_state[4];
		end
		else if (match[5]) begin
			plainByte = LFSR_state[5];
		end else 
			plainByte = 0;
	end else 
		plainByte = 8'h7e;
end
// TODO: write an expression for the starting seed (the start value)
// TODO: for the LFSRs.  You should be able to figure this out based on
// TODO: the value of the first encrypted byte and the knowledged that
// TODO: the unencrypted value is the preamble byte.
//assign start = (getseed && fInValid)? (8'h7e ^ fInEncryptByte) : 'hx;
assign start = (fInValid)? (8'h7e ^ fInEncryptByte) : start;


// byte counter - count the number of bytes processed
//
always_ff @(posedge clk) begin 
	if (rst) byteCount <= 'd0;
	else begin
		if(incByteCnt) byteCount <= byteCount + 'd1; 
		else byteCount <= byteCount;
	end
end 	
	

endmodule // lab5_dp