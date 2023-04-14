`timescale 1ns / 1ps

module hex_calc(input CLK100MHZ, input [7:0] num1, input [7:0] num2, 
input resetSW,input opchanger, output reg [7:0] AN, output reg [7:0] CX, output [1:0] op);
wire [15:0] result, n1, n2;
wire [7:0] C0,C1,C2,C3,C4,C5,C6,C7;
wire dbOutput, signal400;
wire [2:0] segcount;
assign E=1;

assign n1 = {8'h00,num1}; assign n2 = {8'h00,num2};

slowerClkGen clock(resetSW,CLK100MHZ,signal400);
segmentcounter loopsegment(resetSW,signal400,E,segcount);
fsm__moore_debouncer(CLK100MHZ,resetSW,opchanger,dbOutput);
opcounter trackoperation(resetSW,opchanger,op);
math calculator(op,n1,n2,result);

Pattern0_Gen res0(result,C0);
Pattern1_Gen res1(result,C1);
Pattern2_Gen res2(result,C2);
Pattern3_Gen res3(result,C3);
Pattern4_Gen num2_0(n2,C4);
Pattern5_Gen num2_1(n2,C5);
Pattern6_Gen num1_0(n1,C6);
Pattern7_Gen num1_1(n1,C7);
always@*
begin
    case(segcount)
        0:  begin
                AN = 8'hFE;
                CX = C0;
            end
        1:  begin
                AN = 8'hFD;
                CX = C1;
            end
        2:  begin
                AN = 8'hFB;
                CX = C2;
            end
        3:  begin
                AN = 8'hF7;
                CX = C3;
            end
        4:  begin
                AN = 8'hEF;
                CX = C4;
            end
        5:  begin
                AN = 8'hDF;
                CX = C5;
            end
        6:  begin
                AN = 8'hBF;
                CX = C6;
            end
        7:  begin
                AN = 8'h7F;
                CX = C7;
            end
    endcase
end
endmodule

module fsm__moore_debouncer(
input wire clk, reset,
input wire sw,
output reg db
);
// symbolic state declaration
localparam [2:0] zero = 3'b000, wait1_1 = 3'b001,
wait1_2 = 3'b010, wait1_3 = 3'b011, one = 3'b100,
wait0_1 = 3'b101, wait0_2 = 3'b110, wait0_3 = 3'b111;
// 100MHZ = 10ns 
// number of counter bits (2^20 * 1Ons = lOms tick)
localparam N =20;
// signal declaration
reg [N-1:0] q_reg;
wire [N-1:0] q_next;
wire m_tick;
reg [2:0] state_reg, state_next;
// body
// counter to generate 10 ms tick
always@(posedge clk)
    q_reg <= q_next;
// next-state logic
assign q_next = q_reg + 1;
// ozrtput tick
assign m_tick = (q_reg==0) ? 1'b1 : 1'b0;
// debouncing FSM
// state register
always@( posedge clk , posedge reset)
if (reset)
    state_reg <= zero;
else
    state_reg <= state_next;
// next-state logic and output logic
always@*
begin
    state_next = state_reg; // default state: the same
    db = 1'b0; // default output: 0
    case(state_reg)
    zero:
        if(sw)
            state_next = wait1_1;
    wait1_1:
    if(~sw)
        state_next = zero;
    else
        if(m_tick)
            state_next = wait1_2;
    wait1_2:
        if(~sw)
            state_next = zero;
    else
        if(m_tick)
            state_next = wait1_3;
    wait1_3:
    if(~sw)
        state_next = zero;
    else
        if(m_tick)
            state_next = one;
    one:
    begin
        db = 1'b1;
        if(~sw)
            state_next = wait0_1;
    end
    wait0_1:
    begin
        db = 1'b1;
        if(sw)
        state_next = one;
        else
            if(m_tick)
                state_next = wait0_2;
    end
    wait0_2:
    begin
        db = 1'b1;
        if(sw)
            state_next = one;
        else
            if(m_tick)
                state_next = wait0_3;
    end
    wait0_3:
    begin
        db = 1'b1;
        if(sw)
            state_next = one;
        else
            if(m_tick)
                state_next = zero;
    end
    default : state_next = zero;
    endcase
end
endmodule

module slowerClkGen(resetSW, clk, out400Hz);
input clk;
input resetSW;
output reg out400Hz;
reg [26:0] counter400Hz;
always @ (posedge clk)
begin
    if (resetSW)
    begin
        counter400Hz=0;
        out400Hz=0;
    end
    else
    begin
        counter400Hz = counter400Hz +1;
        if (counter400Hz == 125_000)
        begin
            out400Hz=~out400Hz;
            counter400Hz =0;
        end
    end
end
endmodule

module segmentcounter (Resetn, Clock, E, Q);
input Resetn, E;
input wire Clock;
output reg [2:0] Q;

always @(posedge Resetn, posedge Clock)
if (Resetn)
    Q <= 0;
else if (E)
    Q <= Q + 1;
endmodule

module opcounter (Resetn, E, Q);
input Resetn, E;
output reg [1:0] Q;

always @(posedge Resetn, posedge E)
if (Resetn)
    Q <= 0;
else if (E)
    Q <= Q + 1;
endmodule

module math(operation,num1,num2,result);
input wire [1:0] operation;
input wire [15:0] num1,num2;
output reg [15:0] result;
localparam [1:0] ADD = 2'b00,SUBTRACT = 2'b01,
MULTIPLY = 2'b10, DIVIDE = 2'b11;
always@*
begin
case(operation)
    ADD: result = num1+num2;
    SUBTRACT: result = num1-num2;
    MULTIPLY: result = num1*num2;
    DIVIDE: result = num1/num2;
    default: result = num1+num2;
endcase
end
endmodule

module Pattern0_Gen(hexa,CX);
input wire [15:0] hexa;
wire [3:0] hex;
assign hex = hexa[3:0];
output reg [7:0] CX;
always@*
begin
    case(hex)
        0: CX = 8'h81;
        1: CX = 8'hCF;
        2: CX = 8'h92;
        3: CX = 8'h86;
        4: CX = 8'hCC;
        5: CX = 8'hA4;
        6: CX = 8'hA0;
        7: CX = 8'h8F;
        8: CX = 8'h80;
        9: CX = 8'h84;
        10: CX = 8'h88; // A
        11: CX = 8'hE0; // b
        12: CX = 8'hB1; // C
        13: CX = 8'hC2; // d
        14: CX = 8'hB0; // E
        15: CX = 8'hB8; // F
        default: CX = 8'hfF;
    endcase
end
endmodule

module Pattern1_Gen(hexa,CX);
input wire [15:0] hexa;
wire [3:0] hex;
assign hex = hexa[7:4];
output reg [7:0] CX;
always@*
begin
    case(hex)
        0: CX = 8'h81;
        1: CX = 8'hCF;
        2: CX = 8'h92;
        3: CX = 8'h86;
        4: CX = 8'hCC;
        5: CX = 8'hA4;
        6: CX = 8'hA0;
        7: CX = 8'h8F;
        8: CX = 8'h80;
        9: CX = 8'h84;
        10: CX = 8'h88; // A
        11: CX = 8'hE0; // b
        12: CX = 8'hB1; // C
        13: CX = 8'hC2; // d
        14: CX = 8'hB0; // E
        15: CX = 8'hB8; // F
        default: CX = 8'hfF;
    endcase
end
endmodule

module Pattern2_Gen(hexa,CX);
input wire [15:0] hexa;
wire [3:0] hex;
assign hex = hexa[11:8];
output reg [7:0] CX;
always@*
begin
    case(hex)
        0: CX = 8'h81;
        1: CX = 8'hCF;
        2: CX = 8'h92;
        3: CX = 8'h86;
        4: CX = 8'hCC;
        5: CX = 8'hA4;
        6: CX = 8'hA0;
        7: CX = 8'h8F;
        8: CX = 8'h80;
        9: CX = 8'h84;
        10: CX = 8'h88; // A
        11: CX = 8'hE0; // b
        12: CX = 8'hB1; // C
        13: CX = 8'hC2; // d
        14: CX = 8'hB0; // E
        15: CX = 8'hB8; // F
        default: CX = 8'hfF;
    endcase
end
endmodule

module Pattern3_Gen(hexa,CX);
input wire [15:0] hexa;
wire [3:0] hex;
assign hex = hexa[15:12];
output reg [7:0] CX;
always@*
begin
    case(hex)
        0: CX = 8'h81;
        1: CX = 8'hCF;
        2: CX = 8'h92;
        3: CX = 8'h86;
        4: CX = 8'hCC;
        5: CX = 8'hA4;
        6: CX = 8'hA0;
        7: CX = 8'h8F;
        8: CX = 8'h80;
        9: CX = 8'h84;
        10: CX = 8'h88; // A
        11: CX = 8'hE0; // b
        12: CX = 8'hB1; // C
        13: CX = 8'hC2; // d
        14: CX = 8'hB0; // E
        15: CX = 8'hB8; // F
        default: CX = 8'hfF;
    endcase
end
endmodule

module Pattern4_Gen(hexa,CX);
input wire [15:0] hexa;
wire [3:0] hex;
assign hex = hexa[3:0];
output reg [7:0] CX;
always@*
begin
    case(hex)
        0: CX = 8'h81;
        1: CX = 8'hCF;
        2: CX = 8'h92;
        3: CX = 8'h86;
        4: CX = 8'hCC;
        5: CX = 8'hA4;
        6: CX = 8'hA0;
        7: CX = 8'h8F;
        8: CX = 8'h80;
        9: CX = 8'h84;
        10: CX = 8'h88; // A
        11: CX = 8'hE0; // b
        12: CX = 8'hB1; // C
        13: CX = 8'hC2; // d
        14: CX = 8'hB0; // E
        15: CX = 8'hB8; // F
        default: CX = 8'hfF;
    endcase
end
endmodule

module Pattern5_Gen(hexa,CX);
input wire [15:0] hexa;
wire [3:0] hex;
assign hex = hexa[7:4];
output reg [7:0] CX;
always@*
begin
    case(hex)
        0: CX = 8'h81;
        1: CX = 8'hCF;
        2: CX = 8'h92;
        3: CX = 8'h86;
        4: CX = 8'hCC;
        5: CX = 8'hA4;
        6: CX = 8'hA0;
        7: CX = 8'h8F;
        8: CX = 8'h80;
        9: CX = 8'h84;
        10: CX = 8'h88; // A
        11: CX = 8'hE0; // b
        12: CX = 8'hB1; // C
        13: CX = 8'hC2; // d
        14: CX = 8'hB0; // E
        15: CX = 8'hB8; // F
        default: CX = 8'hfF;
    endcase
end
endmodule

module Pattern6_Gen(hexa,CX);
input wire [15:0] hexa;
wire [3:0] hex;
assign hex = hexa[3:0];
output reg [7:0] CX;
always@*
begin
    case(hex)
        0: CX = 8'h81;
        1: CX = 8'hCF;
        2: CX = 8'h92;
        3: CX = 8'h86;
        4: CX = 8'hCC;
        5: CX = 8'hA4;
        6: CX = 8'hA0;
        7: CX = 8'h8F;
        8: CX = 8'h80;
        9: CX = 8'h84;
        10: CX = 8'h88; // A
        11: CX = 8'hE0; // b
        12: CX = 8'hB1; // C
        13: CX = 8'hC2; // d
        14: CX = 8'hB0; // E
        15: CX = 8'hB8; // F
        default: CX = 8'hfF;
    endcase
end
endmodule

module Pattern7_Gen(hexa,CX);
input wire [15:0] hexa;
wire [3:0] hex;
assign hex = hexa[7:4];
output reg [7:0] CX;
always@*
begin
    case(hex)
        0: CX = 8'h81;
        1: CX = 8'hCF;
        2: CX = 8'h92;
        3: CX = 8'h86;
        4: CX = 8'hCC;
        5: CX = 8'hA4;
        6: CX = 8'hA0;
        7: CX = 8'h8F;
        8: CX = 8'h80;
        9: CX = 8'h84;
        10: CX = 8'h88; // A
        11: CX = 8'hE0; // b
        12: CX = 8'hB1; // C
        13: CX = 8'hC2; // d
        14: CX = 8'hB0; // E
        15: CX = 8'hB8; // F
        default: CX = 8'hFF;
    endcase
end
endmodule