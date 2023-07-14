module atm4_tb();
 reg clk;
 reg reset; 
 reg [11:0] cardnumber; 
 reg [3:0] pin;
 reg [14:0] amount; 
  
 reg withdraw; 
 reg reciept_req; 
 wire [14:0] remaining_balance; 
 wire [3:0]LED;
 
 parameter [3:0] welcome = 4'b0000; 
 parameter [3:0] card_inserted = 4'b0001; 
 parameter [3:0] pin_entered = 4'b0010; 
 parameter [3:0] invalid_pin = 4'b0011; 
 parameter [3:0] account_lock = 4'b0100; 
 parameter [3:0] withdraw_deposit = 4'b0101; 
 parameter [3:0] deposit = 4'b0110; 
 parameter [3:0] enter_amount = 4'b0111; 
 parameter [3:0] insufficient_funds = 4'b1000; 
 parameter [3:0] withdraw_cash = 4'b1001; 
 parameter [3:0] face_recognition = 4'b1010; 
 parameter [3:0] show_balance = 4'b1011; 
 parameter [3:0] eject_card=4'b1100; 
 parameter [3:0] generate_reciept=4'b1101;
 
 atm4 uut(clk, reset,cardnumber,pin,amount,withdraw, 
 reciept_req,remaining_balance,LED);
 
 initial begin
 
 clk=1'b0;
 repeat(110) #5 clk=~clk;
 end
 
 initial begin
 
 reset=0;
 
 //withdraw with one card and pin error
 cardnumber=12'd0;
 #10;
 cardnumber=12'd2136;
 #10;
 cardnumber=12'd2133;
 pin=4'b0001;
 #30;
 pin=4'b0010;
 withdraw=1'b1;
 amount=15'd1000;
 reciept_req=1'b1;
 #95;
 //deposit
 cardnumber=12'd1234;
 pin=4'b0001;
 withdraw=1'b0;
 amount=15'd2000;
 reciept_req=1'b1;
 #80;
 //face recognition
 cardnumber=12'd2133;
 pin=4'b0010;
 withdraw=1'b1;
 amount=15'd10500;
 reciept_req=1'b1;
 #95
 //insufficient balance
 cardnumber=12'd1556;
 pin=4'b0100;
 withdraw=1'b1;
 amount=15'd12500;
 #50;
 amount=15'd2500;
 reciept_req=1'b1;
 #65;
 //locking
 cardnumber=12'd1234;
 pin=4'b0011;
 #30;
 pin=4'b1000;
 #30;
 pin=4'b1001;

 #10; //finish;
 
 end
 endmodule