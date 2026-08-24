module demo_control_module
(
input                   sys_clk,
input                   rst_n,
output [23:0]           Number_Sig
);
 parameter T100MS = 23'd4_999_999;          //100ms count
parameter ST0          =8'b00000001;
parameter ST1          =8'b00000010;
parameter ST2          =8'b00000100;
parameter ST3          =8'b00001000;
parameter ST4          =8'b00010000;
parameter ST5          =8'b00100000;
parameter ST6          =8'b01000000;
parameter ST7          =8'b10000000;
reg [22:0]              time_cnt;               //time count
reg [7:0]               cur_state;
reg [7:0]               next_state;
reg [23:0]              rNum;
reg [23:0]              rNumber;
 assign Number_Sig = rNumber;
always @ ( posedge sys_clk or negedge rst_n )
begin
 if( !rst_n )
      time_cnt<= 23'd0;
  else if(time_cnt== T100MS )
      time_cnt<= 23'd0;
  else 
      time_cnt <=time_cnt+ 1'b1;
end          
always@(posedge sys_clk)
begin 
if(!rst_n)
    cur_state<=ST0;
 else
    cur_state<=next_state;
end
/***************************************************************************
Counting numbers to 10 produces a carry
****************************************************************************/
always @ ( posedge sys_clk or negedge rst_n )
begin
if( !rst_n )
  begin
      next_state<=ST0;
      rNum <= 24'd0;
      rNumber <= 24'd0;
    end
  else
    begin
      case(cur_state)    
          ST0:
             begin
                if(time_cnt== T100MS ) 
                    begin
                        rNum[3:0] <= rNum[3:0] + 1'b1;
                        next_state<=ST1;
                     end
                 else
                        next_state<=ST0;
             end          
          ST1:
             begin
                if( rNum[3:0] > 4'd9 )
                    begin
                        rNum[7:4] <= rNum[7:4] + 1'b1; 
                        rNum[3:0] <= 4'd0; 
                        next_state<=ST2;
                     end
                 else
                        next_state<=ST2;
             end    
          ST2:
             begin
                if( rNum[7:4] > 4'd9 ) 
                    begin
                         rNum[11:8] <= rNum[11:8] + 1'b1; 
                         rNum[7:4] <= 4'd0;
                         next_state<=ST3;
                    end
                 else
                         next_state<=ST3;
             end     
           ST3:
             begin
                if( rNum[11:8] > 4'd9 ) 
                    begin
                        rNum[15:12] <= rNum[15:12] + 1'b1;
                        rNum[11:8] <= 4'd0;
                        next_state<=ST4;
                    end
                 else
                        next_state<=ST4;
             end    
          ST4:
             begin
                if( rNum[15:12] > 4'd9 )
                    begin
                         rNum[19:16] <= rNum[19:16] + 1'b1; 
                         rNum[15:12] <= 4'd0; 
                         next_state<=ST5;
                    end
                 else
                         next_state<=ST5;
                end
          ST5:
             begin
                if( rNum[19:16] > 4'd9 )
                    begin 
                         rNum[23:20] <= rNum[23:20] + 1'b1; 
                         rNum[19:16] <= 4'd0;
                         next_state<=ST6;
                    end
                 else
                         next_state<=ST6;
             end
          ST6:
             begin
                if( rNum[23:20] > 4'd9 )
                    begin 
                        rNum <= 24'd0;
                        next_state<=ST7;
                    end
                 else
                        next_state<=ST7;
             end
            ST7:
             begin
                    rNumber <= rNum;
                    next_state<=ST0;
             end
           default: next_state<=ST0;                
        endcase
    end
end
endmodule
