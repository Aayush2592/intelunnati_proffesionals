module atm6_tb();
 reg clk;
 reg reset; 
 reg  card;
 reg [1:0] pin;
 reg [6:0] amount; 
 reg withdraw; 
 reg reciept_req;
 
 wire [6:0] Led_disp; 
 wire [6:0] remaining_balance; 
 wire [2:0]LED;
 
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
 
 atm6 uut(clk, reset,card,pin,amount,withdraw, 
 reciept_req,Led_disp,remaining_balance,LED);
 
 initial begin
 
 clk=1'b0;
 repeat(110) #5 clk=~clk;
 end
 
 initial begin
 
 reset=1;
 //withdraw with one card and pin error
 card=1'b1;
 #10;
 card=1'b0;
 pin=2'b01;
 #30;
 pin=2'b10;
 withdraw=1'b1;
 amount=7'd80;
 reciept_req=1'b0;
 #95;
 //deposit
 card=1'b0;
 pin=2'b10;
 withdraw=1'b0;
 amount=7'd15;
 reciept_req=1'b0;
 #80;
 //face recognition
 card=1'b0;
 pin=2'b10;
 withdraw=1'b1;
 amount=15'd98;
 reciept_req=1'b0;
 #95;
 //insufficient balance
 card=1'b0;
 pin=2'b10;
 withdraw=1'b1;
 amount=7'd115;
 #50;
 amount=7'd25;
 reciept_req=1'b0;
 #65;
 //locking
 card=1'b0;
 pin=2'b11;
 #30;
 pin=2'b01;
 #30;
 pin=2'b11;

 #10; 
 
 end
 endmodule