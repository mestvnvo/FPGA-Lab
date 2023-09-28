`timescale 1ns / 1ps

module Lab4(input [2:0] data, output [7:0] AN, output [7:0] CX);
    wire [7:0] z;
    assign AN = 8'hFE;
    decoder stage0(data,z);
    Seven_Seg num0(z,CX);
endmodule

module decoder (input [2:0] data,  output reg [7:0] y); 
always @(data)
begin
       y=0; 
       y[data]=1; 
end
endmodule

module Seven_Seg (input wire [7:0]z, output reg [7:0]CX);
always@*
begin
    case(z)
        8'b00000001: CX = 8'h81;
        8'b00000010: CX = 8'hCF;
        8'b00000100: CX = 8'h92;
        8'b00001000: CX = 8'h86;
        8'b00010000: CX = 8'hCC;
        8'b00100000: CX = 8'hA4;
        8'b01000000: CX = 8'hA0;
        8'b10000000: CX = 8'h8F;
        default: CX = 8'hFF;
    endcase            
end
endmodule