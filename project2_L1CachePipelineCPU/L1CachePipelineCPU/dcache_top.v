
module dcache_top
(
    // System clock, reset and stall
	clk_i, 
	rst_i,
	
	// to Data Memory interface		
	mem_data_i, 
	mem_ack_i, 	
	mem_data_o, 
	mem_addr_o, 	
	mem_enable_o, 
	mem_write_o, 
	
	// to CPU interface	
	p1_data_i, 
	p1_addr_i, 	
	p1_MemRead_i, 
	p1_MemWrite_i, 
	p1_data_o, 
	p1_stall_o
);
//
// System clock, start
//
input				clk_i; 
input				rst_i;

//
// to Data Memory interface		
//
input	[256-1:0]	  mem_data_i; 
input				      mem_ack_i; 
	
output	[256-1:0]	mem_data_o; 
output	[32-1:0]	mem_addr_o; 	
output				    mem_enable_o; 
output				    mem_write_o; 
	
//	
// to core interface			
//	
input	[32-1:0]	p1_data_i; 
input	[32-1:0]	p1_addr_i; 	
input				    p1_MemRead_i; 
input				    p1_MemWrite_i; 

output	[32-1:0]p1_data_o; 
output				  p1_stall_o; 

//
// to SRAM interface
//
wire	[4:0]		  cache_sram_index;
wire				    cache_sram_enable;
wire	[23:0]		cache_sram_tag;
wire	[255:0]		cache_sram_data;
wire				    cache_sram_write;
wire	[23:0]		sram_cache_tag;
wire	[255:0]		sram_cache_data;


// cache
wire				sram_valid;
wire				sram_dirty;

// controller
parameter 			STATE_IDLE			  = 3'h0,
					      STATE_READMISS		= 3'h1,
					      STATE_READMISSOK	= 3'h2,
					      STATE_WRITEBACK		= 3'h3,
					      STATE_MISS			  = 3'h4;
reg		[2:0]		state;
reg					  mem_enable;
reg					  mem_write;
reg					  cache_we;
wire				  cache_dirty;
reg					  write_back;

// regs & wires
wire	[4:0]		  p1_offset;
wire	[4:0]		  p1_index;
wire	[21:0]		p1_tag;
wire	[255:0]		r_hit_data;
wire	[21:0]		sram_tag;
wire				    hit;
reg		[255:0]		w_hit_data;
wire				    write_hit;
wire				    p1_req;
reg		[31:0]		p1_data;

// project1 interface
assign 	p1_req     = p1_MemRead_i | p1_MemWrite_i; // if request is read or write
assign	p1_offset  = p1_addr_i[4:0]; // 5 bit for offset in a block
assign	p1_index   = p1_addr_i[9:5];
assign	p1_tag     = p1_addr_i[31:10]; 
assign	p1_stall_o = ~hit & p1_req; // if not hit and we have request, stall pipeline latch
assign	p1_data_o  = p1_data; // register data prepare for cpu

// SRAM interface
assign	sram_valid = sram_cache_tag[23];
assign	sram_dirty = sram_cache_tag[22];
assign	sram_tag   = sram_cache_tag[21:0];
assign	cache_sram_index  = p1_index;
assign	cache_sram_enable = p1_req;
assign	cache_sram_write  = cache_we | write_hit; // if cache is write enable (a read miss cause cache to be written) or write hit(cpu request to write a 32 bit into cache)
assign	cache_sram_tag    = {1'b1, cache_dirty, p1_tag};	
assign	cache_sram_data   = (hit) ? w_hit_data : mem_data_i; // data prepare to write into cache(data_sram) 

// memory interface
assign	mem_enable_o = mem_enable;
assign	mem_addr_o   = (write_back) ? {sram_tag, p1_index, 5'b0} : {p1_tag, p1_index, 5'b0}; // if write_back bit is on, set memory request addr to be sram_address. otherwise, memory request address is p1's address
assign	mem_data_o   = sram_cache_data; // data prepare to write in memory
assign	mem_write_o  = mem_write; // whether to write data into memory

assign	write_hit    = hit & p1_MemWrite_i; // if the cache is hit and p1_MemWrite_i is on, set write_hit
assign	cache_dirty  = write_hit; // if write hit, set cache to be dirty

// tag comparator
//!!! add you code here!  (hit=...?,  r_hit_data=...?)
assign hit = ((sram_tag == p1_tag) && sram_valid)? 1'b1: 1'b0;
assign r_hit_data = sram_cache_data; 
reg [256-1:0] shifted_r_hit_data;
// read data :  256-bit to 32-bit
// if read hit data changed or offset changed(if read hit data is not changed and offset is not changed too, we will just do nothing)
always@(p1_offset or r_hit_data) begin
	//!!! add you code here! (p1_data=...?)

	if (hit == 1)
		begin
			// move r_hit_data to the right offset then retrieve a word(which is 32 bit)
			// a block a 256 bit and there are 32 bytes in a block(32 * 8 bit)
			// however offset is access byte-addressably, so we need to move (offset * 8)
			// which is byte-by-byte move
			shifted_r_hit_data = r_hit_data >> (8 * p1_offset);
			p1_data = shifted_r_hit_data[31:0];
		end
	else begin
		p1_data <= 32'b0;
	end
end

integer i, j;
// write data :  32-bit to 256-bit
// in this case, we will write p1_data_i(32 bit) at the (p1_offset) into a read block
always@(p1_offset or r_hit_data or p1_data_i) begin
	//!!! add you code here! (w_hit_data=...?)
	// byte-wise iteration (this is why 32)
	//w_hit_data = r_hit_data;
	w_hit_data = r_hit_data;
	for(i = 0; i < 32; i += 1) begin
		// if i is the block p1_offset point to
		if(i == p1_offset) begin
			// Use j
			for(j = 0; j < 32; j = j+ 1) begin
				w_hit_data[i*8+j] = p1_data_i[j];
			end
		end
	end
end


// controller 
always@(posedge clk_i or negedge rst_i) begin
	if(~rst_i) begin
		state      <= STATE_IDLE;
		mem_enable <= 1'b0;
		mem_write  <= 1'b0;
		cache_we   <= 1'b0; 
		write_back <= 1'b0;
	end
	else begin
		case(state)		
			STATE_IDLE: begin
				// if get a request and didn't hit
				if(p1_req && !hit) begin	//wait for request
					state <= STATE_MISS;
				end
				// else, do nothing
				else begin
					state <= STATE_IDLE;
				end
			end
			STATE_MISS: begin
				// if dirty, we need to first go to write-back state
				if(sram_dirty) begin		//write back if dirty
	                //!!! add you code here! 
	                mem_enable <= 1'b1;
	                mem_write <= 1'b1;
	                write_back <= 1'b1; // need to write back
	                cache_we <= 1'b0; // no need
					state <= STATE_WRITEBACK;
				end
				// if not dirty, we don't need to write it back, so just go to read-miss state
				else begin					//write allocate: write miss = read miss + write hit; read miss = read miss + read hit
	                //!!! add you code here! 
	                mem_enable <= 1'b1;
	                mem_write <= 1'b0;
	                write_back <= 1'b0;
	                cache_we <= 1'b0; // no need set the bit on cache_write_enable now
					state <= STATE_READMISS;
				end
			end
			STATE_READMISS: begin
				if(mem_ack_i) begin			//wait for data memory acknowledge
	                //!!! add you code here! 
	                mem_enable <= 1'b0; // turn off mem_enable
	                cache_we <= 1'b1; // set cache_write_enable now
	                mem_write <= 1'b0;	//no need
	                write_back <= 1'b0; //no need
					state <= STATE_READMISSOK;
				end
				// if not acked, just stay in read-miss state
				else begin
					state <= STATE_READMISS;
				end
			end
			STATE_READMISSOK: begin			//wait for data memory acknowledge
                //!!! add you code here!
                // turn off all the control bit and move to IDLE state
                cache_we <= 1'b0;
                mem_enable = 1'b0;	//no need
                mem_write <= 1'b0;	//no need
                write_back <= 1'b0; //no need
				state <= STATE_IDLE;
			end
			STATE_WRITEBACK: begin
				if(mem_ack_i) begin			//wait for data memory acknowledge
	                //!!! add you code here!
	                //received ack from memory
	                mem_write <= 1'b0;
	                write_back <= 1'b0;
	                cache_we <= 1'b0;	//no need
	                mem_enable <= 1'b1;	// mem_enable turn on (because need to write back)
					state <= STATE_READMISS;
				end
				else begin
					state <= STATE_WRITEBACK;
				end
			end
		endcase
	end
end

//
// Tag SRAM 0
//
dcache_tag_sram dcache_tag_sram
(
	.clk_i(clk_i),
	.addr_i(cache_sram_index),
	.data_i(cache_sram_tag),
	.enable_i(cache_sram_enable),
	.write_i(cache_sram_write),
	.data_o(sram_cache_tag)
);

//
// Data SRAM 0
//
dcache_data_sram dcache_data_sram
(
	.clk_i(clk_i),
	.addr_i(cache_sram_index),
	.data_i(cache_sram_data),	//from w_hit_data or mem_data_i
	.enable_i(cache_sram_enable),
	.write_i(cache_sram_write),
	.data_o(sram_cache_data)	//to r_hit_data and mem_data_o
);

endmodule