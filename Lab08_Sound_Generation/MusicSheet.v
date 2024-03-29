`timescale 1ns / 1ps

module MusicSheet( input [9:0] number,
output reg [19:0] note,//what is the max frequency
output reg [4:0] duration);
parameter QUARTER = 5'b00100;
parameter EIGHTH = 5'b00010;
parameter SIXTH = 5'b00001;
parameter WHOLE = 5'b10000;

parameter 
C4= 50_000_000/261.63,
C5 = 50_000_000/523.25,
Eb5 = 50_000_000/622.25, 
F5= 50_000_000/698.46, 
Gb5 = 50_000_000/739.99,
Bb5= 50_000_000/466.16, 
D5 = 50_000_000/587.33,
G4 = 50_000_000/392,
REST = 1;
always @ (number) begin
case(number) // Among Us (trap remix) - Leonz
    0: begin note = C4; duration = QUARTER; end // First Bar
    1: begin note = C5; duration = EIGHTH; end 
    2: begin note = Eb5; duration = EIGHTH; end 
    3: begin note = F5; duration = EIGHTH; end 
    4: begin note = Gb5; duration = EIGHTH; end 
    5: begin note = F5; duration = EIGHTH; end 
    6: begin note = Eb5; duration = EIGHTH; end
    
    7: begin note = C5; duration = QUARTER; end  // Second Bar 
    8: begin note = REST; duration = EIGHTH; end  
    9: begin note = Bb5; duration = SIXTH; end 
    10: begin note = D5; duration = SIXTH; end
    11: begin note = C5; duration = QUARTER; end 
    12: begin note = REST; duration = EIGHTH; end  
    13: begin note = G4; duration = EIGHTH; end 
    
    14: begin note = C4; duration = QUARTER; end // Third Bar
    15: begin note = C5; duration = EIGHTH; end 
    16: begin note = Eb5; duration = EIGHTH; end 
    17: begin note = F5; duration = EIGHTH; end 
    18: begin note = Gb5; duration = EIGHTH; end 
    19: begin note = F5; duration = EIGHTH; end 
    20: begin note = Eb5; duration = EIGHTH; end
    
    21: begin note = Gb5; duration = QUARTER; end // Fourth Bar
    22: begin note = REST; duration = QUARTER; end
    23: begin note = Gb5; duration = SIXTH; end 
    24: begin note = F5; duration = SIXTH; end 
    25: begin note = Eb5; duration = SIXTH; end
    26: begin note = REST; duration = SIXTH; end 
    27: begin note = Gb5; duration = SIXTH; end 
    28: begin note = F5; duration = SIXTH; end 
    29: begin note = Eb5; duration = SIXTH; end
    30: begin note = REST; duration = SIXTH; end 
    
    default: begin note = C5; duration = QUARTER; end
endcase
end
endmodule

module SongPlayer( input clock, input reset, input playSound, output reg
audioOut, output wire aud_sd);
reg [19:0] counter;
reg [31:0] time1, noteTime;
reg [9:0] msec, number; //millisecond counter, and sequence number of musical note.
wire [4:0] note, duration;
wire [19:0] notePeriod;
parameter clockFrequency = 100_000_000;
assign aud_sd = 1'b1;
MusicSheet mysong(number, notePeriod, duration );
always @ (posedge clock)
begin
if(reset | ~playSound)
    begin
    counter <=0;
    time1<=0;
    number <=0;
    audioOut <=1;
    end
else
    begin
    counter <= counter + 1;
    time1<= time1+1;
    if( counter >= notePeriod)
        begin
        counter <=0;
        audioOut <= ~audioOut ;
        end //toggle audio output
    if( time1 >= noteTime)
        begin
        time1 <=0;
        number <= number + 1;
        end //play next note
    if(number == 30) number <=0; // Make the number reset at the end of the song
    end
end
    always @(duration) noteTime = duration * clockFrequency/8;
//number of FPGA clock periods in one note.
endmodule
