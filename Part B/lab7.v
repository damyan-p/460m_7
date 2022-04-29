// You can use this skeleton testbench code, the textbook testbench code, or your own
module MIPS_Testbench ();
  reg CLK;
  wire CS;
  wire WE;
  wire [31:0] Mem_Bus;
  wire [6:0] Address, Address_mux;
  reg [6:0] Address_TB;
  reg [31:0] expected [10:1];
  wire [1:0] swi;
  wire WE_mux, CS_mux;
  reg init, WE_TB, CS_TB;
  wire btnR;
  reg [3:0] an;
  reg [6:0] sseg;

integer i;

  initial
  begin
    CLK = 0;
    expected[1] = 32'h00000006;
    expected[2] = 32'h12;
    expected[3] = 32'h18;
    expected[4] = 32'hC;
    expected[5] = 32'h2;
    expected[6] = 32'h16;
    expected[7] = 32'h00000001;
    expected[8] = 32'h120;
    expected[9] = 32'h3;
    expected[10] = 32'h00412022;
    
    
    
  end

assign Address_mux = (init)? Address_TB : Address;
assign WE_mux = (init)? WE_TB : WE;
assign CS_mux = (init)? CS_TB : CS;

  MIPS CPU(.CLK(CLK), .swi(swi), .CS(CS), .WE(WE), .ADDR(Address), .Mem_Bus(Mem_Bus),.an(an),.sseg(sseg));
  Memory MEM(.CS(CS_mux), .WE(WE_mux), .CLK(CLK), .ADDR(Address_mux), .Mem_Bus(Mem_Bus));

  always
  begin
    #5 CLK = !CLK;
  end

  always
  begin
    //RST = 1'b1; //reset the processor
    //Notice that the memory is initialize in the in the memory module not here
    @(posedge CLK);
    init <= 1;
    CS_TB <= 1;
    WE_TB <= 1;
    @(posedge CLK);
    CS_TB <= 0;
    WE_TB <= 0;
    init <= 0;
    @(posedge CLK);
    // driving reset low here puts processor in normal operating mode
    //RST = 1'b0;

    for(i = 1; i <= 10; i = i + 1) begin
    @(posedge WE);
    @(negedge CLK);
    if(Mem_Bus != expected[i])
    $display("Incorrect calculation: got %d, expected %d", Mem_Bus, expected[i]);
    end
    $display("TEST COMPLETE");
    $stop;
    /* add your testing code here */
    // you can add in a 'Halt' signal here as well to test Halt operation
    // you will be verifying your program operation using the
    // waveform viewer and/or self-checking operations
  end

endmodule

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

module Complete_MIPS(CLK, swi, btnR, an, sseg);
  // Will need to be modified to add functionality
  input CLK;
  input [1:0] swi;
  input btnR;
  output [3:0] an;
  output [6:0] sseg;

  wire CS, WE;
  wire [6:0] ADDR;
  wire [31:0] Mem_Bus;
  wire CLK_2;
  reg [31:0] R2;
  wire [6:0] in0, in1, in2, in3;
  
  initial begin
  R2 = 0;
  end
  
  dispFSM display(.CLK_2(CLK_2),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.an(an),.sseg(sseg));
  clk_div slow(.CLK(CLK),.CLK_2(CLK_2));
  MIPS CPU(.CLK(CLK), .swi(swi), .CS(CS), .WE(WE), .ADDR(ADDR), .Mem_Bus(Mem_Bus),.btnR(btnR),.in0(in0),.in1(in1),.in2(in2),.in3(in3));
  Memory MEM(.CS(CS), .WE(WE), .CLK(CLK_2), .ADDR(ADDR), .Mem_Bus(Mem_Bus));

endmodule

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

module Memory(CS, WE, CLK, ADDR, Mem_Bus);
  input CS;
  input WE;
  input CLK;
  input [6:0] ADDR;
  inout [31:0] Mem_Bus;

  reg [31:0] data_out;
  reg [31:0] RAM [0:127];


  initial begin
    /* Write your Verilog-Text IO code here */
    $readmemh("data.mem",RAM);
  end

  assign Mem_Bus = ((CS == 1'b0) || (WE == 1'b1)) ? 32'bZ : data_out;

  always @(negedge CLK)
  begin

    if((CS == 1'b1) && (WE == 1'b1))
      RAM[ADDR] <= Mem_Bus[31:0];

    data_out <= RAM[ADDR];
  end
endmodule

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

module REG(CLK, RegW, swi, DR, SR1, SR2, Reg_In, ReadReg1, ReadReg2,Rout);
  input CLK;
  input RegW;
  input [1:0] swi;
  input [4:0] DR;
  input [4:0] SR1;
  input [4:0] SR2;
  input [31:0] Reg_In;
  output reg [31:0] ReadReg1;
  output reg [31:0] ReadReg2;
  output reg [31:0] Rout;
  

  reg [31:0] REG [0:31];
  integer i;

  initial begin
    Rout = 0;
    ReadReg1 = 0;
    ReadReg2 = 0;
  end

  always @(posedge CLK)
  begin
    Rout <= REG[2];
    if(RegW == 1'b1)
      REG[DR] <= Reg_In[31:0];
    else REG[1] <= swi[1:0];

    ReadReg1 <= REG[SR1];
    ReadReg2 <= REG[SR2];
    
  end
endmodule


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

`define opcode instr[31:26]
`define sr1 instr[25:21]
`define sr2 instr[20:16]
`define f_code instr[5:0]
`define numshift instr[10:6]

module MIPS (CLK, swi, CS, WE, ADDR, Mem_Bus, btnR, in0, in1, in2, in3);
  input CLK;
  input [1:0] swi;
  output reg CS, WE;
  output [6:0] ADDR;
  inout [31:0] Mem_Bus;
  input btnR;
  output [6:0] in0, in1, in2, in3;

  //special instructions (opcode == 000000), values of F code (bits 5-0):
  parameter add = 6'b100000;
  parameter sub = 6'b100010;
  parameter xor1 = 6'b100110;
  parameter and1 = 6'b100100;
  parameter or1 = 6'b100101;
  parameter slt = 6'b101010;
  parameter srl = 6'b000010;
  parameter sll = 6'b000000;
  parameter jr = 6'b001000;
  parameter rbit = 6'b101111;
  parameter rev = 6'b110000;
  parameter add8 = 6'b101101;
  parameter sadd = 6'b110001;
  parameter ssub = 6'b110010;

  //non-special instructions, values of opcodes:
  parameter addi = 6'b001000;
  parameter andi = 6'b001100;
  parameter ori = 6'b001101;
  parameter lw = 6'b100011;
  parameter sw = 6'b101011;
  parameter beq = 6'b000100;
  parameter bne = 6'b000101;
  parameter lui = 6'b001111;

  //instruction format
  parameter R = 2'd0;
  parameter I = 2'd1;
  parameter J = 2'd2;

  //internal signals
  reg [5:0] op, opsave;
  wire [1:0] format;
  reg [31:0] instr, alu_result;
  reg [6:0] pc, npc;
  wire [31:0] imm_ext, alu_in_A, alu_in_B, reg_in, readreg1, readreg2;
  reg [31:0] alu_result_save;
  reg alu_or_mem, alu_or_mem_save, regw, writing, reg_or_imm, reg_or_imm_save;
  reg fetchDorI;
  wire [4:0] dr;
  reg [2:0] state, nstate;
  reg [15:0] rR2;
  reg [31:0] temp;
  reg [31:0] Rout;
  integer loop;

  //combinational
  
  hex_to_sseg c0(.x(Rout[15:12]),.r(in3));
  hex_to_sseg c1(.x(Rout[11:8]),.r(in2));
  hex_to_sseg c2(.x(Rout[7:4]),.r(in1));
  hex_to_sseg c3(.x(Rout[3:0]),.r(in0));
  
  assign imm_ext = (instr[15] == 1)? {16'hFFFF, instr[15:0]} : {16'h0000, instr[15:0]};//Sign extend immediate field
  assign dr = (format == R)? instr[15:11] : instr[20:16]; //Destination Register MUX (MUX1)
  assign alu_in_A = readreg1;
  assign alu_in_B = (reg_or_imm_save)? imm_ext : readreg2; //ALU MUX (MUX2)
  assign reg_in = (alu_or_mem_save)? Mem_Bus : alu_result_save; //Data MUX
  assign format = (`opcode == 6'd0)? R : ((`opcode == 6'd2)? J : I);
  assign Mem_Bus = (writing)? readreg2 : 32'bZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ;

  //drive memory bus only during writes
  assign ADDR = (fetchDorI)? pc : alu_result_save[6:0]; //ADDR Mux
  REG Register(CLK, regw, swi, dr, `sr1, `sr2, reg_in, readreg1, readreg2,Rout);

  initial begin
  rR2 = 0;
    op = and1; opsave = and1;
    state = 3'b0; nstate = 3'b0;
    alu_or_mem = 0;
    regw = 0;
    fetchDorI = 0;
    writing = 0;
    reg_or_imm = 0; reg_or_imm_save = 0;
    alu_or_mem_save = 0;
  end

  always @(*)
  begin
    
    
    fetchDorI = 0; CS = 0; WE = 0; regw = 0; writing = 0; alu_result = 32'd0;
    npc = pc; op = jr; reg_or_imm = 0; alu_or_mem = 0; nstate = 3'd0;
    case (state)
      0: begin //fetch
        npc = pc + 7'd1; CS = 1; nstate = 3'd1;
        fetchDorI = 1;
      end
      1: begin //decode
        nstate = 3'd2; reg_or_imm = 0; alu_or_mem = 0;
        if (format == J) begin //jump, and finish
        if(instr[0]) begin  //jal
          alu_result = pc + 7'd1;
          npc = instr[6:0];
          nstate = 3'd0;
        end
        else begin  //j
          npc = instr[6:0];
          nstate = 3'd0;
        end
        
        end
        else if (format == R) //register instructions
          op = `f_code;
        else if (format == I) begin //immediate instructions
          reg_or_imm = 1;
          if(`opcode == lw) begin
            op = add;
            alu_or_mem = 1;
          end
          else if ((`opcode == lw)||(`opcode == sw)||(`opcode == addi)) op = add;
          else if ((`opcode == beq)||(`opcode == bne)) begin
            op = sub;
            reg_or_imm = 0;
          end
          else if (`opcode == andi) op = and1;
          else if (`opcode == ori) op = or1;
          else if (`opcode == rbit) op = rbit;
          else if (`opcode == rev) op = rev;
          else if (`opcode == lui) op = lui;
        end
      end
      2: begin //execute
        nstate = 3'd3;
        if (opsave == and1) alu_result = alu_in_A & alu_in_B;
        else if (opsave == or1) alu_result = alu_in_A | alu_in_B;
        else if (opsave == add) alu_result = alu_in_A + alu_in_B;
        else if (opsave == sub) alu_result = alu_in_A - alu_in_B;
        else if (opsave == srl) alu_result = alu_in_B >> `numshift;
        else if (opsave == sll) alu_result = alu_in_B << `numshift;
        else if (opsave == slt) alu_result = (alu_in_A < alu_in_B)? 32'd1 : 32'd0;
        else if (opsave == xor1) alu_result = alu_in_A ^ alu_in_B;
        else if (opsave == rbit) begin
        for(loop = 0; loop <= 31; loop = loop + 1) begin
        temp[loop] = alu_in_B[31-loop];
        end
        alu_result = temp;
        end
        else if (opsave == rev) begin
        temp[7:0] = alu_in_B[31:24];
        temp[15:8] = alu_in_B[23:16];
        temp[23:16] = alu_in_B[15:8];
        temp[31:24] = alu_in_B[7:0];
        alu_result = temp;
        end
        else if (opsave == lui) alu_result = (alu_in_B[15:0] << 16);
        else if (opsave == add8) begin
        alu_result[31:24] = alu_in_A[31:24] + alu_in_B[31:24];
        alu_result[23:16] = alu_in_A[23:16] + alu_in_B[23:16];
        alu_result[15:8] = alu_in_A[15:8] + alu_in_B[15:8];
        alu_result[7:0] = alu_in_A[7:0] + alu_in_B[7:0];
        end
        else if (opsave == sadd) alu_result = ((alu_in_A + alu_in_B < alu_in_A) || (alu_in_A + alu_in_B > alu_in_A)) ? 32'hFFFFFFFF:(alu_in_A + alu_in_B); 
        else if (opsave == ssub) alu_result = (alu_in_A - alu_in_B > alu_in_A) ? 32'h0:(alu_in_A - alu_in_B);
        if (((alu_in_A == alu_in_B)&&(`opcode == beq)) || ((alu_in_A != alu_in_B)&&(`opcode == bne))) begin
          npc = pc + imm_ext[6:0];
          nstate = 3'd0;
        end
        else if ((`opcode == bne)||(`opcode == beq)) nstate = 3'd0;
        else if (opsave == jr) begin
          npc = alu_in_A[6:0];
          nstate = 3'd0;
        end
        
      end
      3: begin //prepare to write to mem
        nstate = 3'd0;
        if ((format == R)||(`opcode == addi)||(`opcode == andi)||(`opcode == ori)) regw = 1;
        else if((format == J) || (instr[0])) regw = 1;
        else if (`opcode == sw) begin
          CS = 1;
          WE = 1;
          writing = 1;
        end
        else if (`opcode == lw) begin
          CS = 1;
          nstate = 3'd4;
        end
      end
      4: begin
        nstate = 3'd0;
        CS = 1;
        if (`opcode == lw) regw = 1;
      end
    endcase
  end //always

  always @(posedge CLK) begin
    rR2 = Rout;
    if(btnR) rR2[15:0] = Rout[31:16];
    else rR2[15:0] = Rout[15:0];
    /*
    if (RST) begin
      state <= 3'd0;
      pc <= 7'd0;
    end
    */
    //else if(~HALT) begin
      state <= nstate;
      pc <= npc;
    //end

    if (state == 3'd0) instr <= Mem_Bus;
    else if (state == 3'd1) begin
      opsave <= op;
      reg_or_imm_save <= reg_or_imm;
      alu_or_mem_save <= alu_or_mem;
    end
    else if (state == 3'd2) alu_result_save <= alu_result;

  end //always

endmodule
