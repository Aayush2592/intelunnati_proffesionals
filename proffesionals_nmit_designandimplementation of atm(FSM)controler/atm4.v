`define threshold 15'd10000 
`define true 1'b1
`define false 1'b0

module atm4( input clk, 
 input reset, 
 input [11:0] cardnumber, 
 input [3:0] pin, 
 input [14:0] amount, 

 input withdraw, 
 input reciept_req, 
 output reg [14:0] remaining_balance, 
 output reg [3:0]LED//to show output on fpga 
 ); 
 //states 
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
 reg[3:0] state = welcome; 
 reg [2:0]count;
 reg lock; 
 reg [14:0]dep_amount;
 
 reg [11:0]card_database[0:2];
 reg [3:0]pin_database[0:2];
 reg [14:0]balance[0:2];
 reg card_found;
 initial begin
 //card_found=1'b0;
 card_database[0]=12'd1234; pin_database[0]=4'b0001;balance[0]=15'd15000;//even balance can be added for
 card_database[1]=12'd2133; pin_database[1]=4'b0010;balance[1]=15'd13000;//each account in same way
 card_database[2]=12'd1556; pin_database[2]=4'b0100;balance[2]=15'd12000;
 end
 integer i;
 integer acc;
 //Counter countermodule(pin,pin_database[acc],count); 
 //account_lock accmodule(count,cardnumber,lock); 
 
 //always block for changing states 
 always @ (posedge clk)// or reset) 
 begin 
 //$display("Initial count= %d",count);
 if(reset || lock==1)begin
 lock=`false;
 state<=welcome;
 end 
 else 
 begin 
   
 case(state) 
   
 welcome: 
 begin 
 $display("please insert your card(enter card number)"); 
 if(!cardnumber) 
 begin 
 state=welcome; 
 $display("error in getting card number try again");
 end 
 else
 begin
 LED=4'b1111;//to display on fpga
 card_found=1'b0;
 acc=0;
 count=3'b0;
 for(i=0;i<3;i=i+1)begin
   if(cardnumber==card_database[i])begin
		card_found=1'b1;
		acc=i;
		//$display("acc value %d;velue of i %d;cardnumber:%d",acc,i,cardnumber);//for testing-remove later
	end
 end
 if(card_found)
 state<=card_inserted;
 else begin
 $display("Card number %d not found!",cardnumber);
 LED=4'b0000;
 state<=welcome;
 end
 end
 end   
   
 card_inserted:
 begin 
 $display("please enter the pin");
 //$display("correct pin %b",pin_database[acc]);//for testing-remove later 
 if(pin) 
 state<=pin_entered; 
 end
  
 pin_entered: 
 begin 
 if(pin==pin_database[acc])
 begin 
 $display("pin was entered succesfully"); 
 state<=withdraw_deposit; 
 end  
 else
 begin
 $display("pin entered was invalid please try again"); 
 //$display("%d",count);
 state<=invalid_pin; 
 end
 end  
   
 invalid_pin: 
 begin
 count=count+1'b1; 
 $display("pin error try %d",count);
 if(count>=3) 
 state<=account_lock; 
 else     
 state<=card_inserted;  
 end
   
 account_lock:
 begin
 $display("your account %d is locked for the next 24hours",cardnumber);
 lock=`true; 
 state<=welcome; 
 end
   
 withdraw_deposit:
 begin
 $display("do you want to withdraw or deposit the money?"); 
 if(withdraw) 
 state<=enter_amount; 
 else 
 state<=deposit; 
 end
 
 deposit:
 begin
 $display("enter the amount to be deposited");
 dep_amount=amount;
 $display("the money was deposited succesfully"); 
 state<=show_balance;
 end
   
 enter_amount: 
 begin 
 $display("enter the amount to be withdrawn");  
 if(amount>balance[acc]) 
 state<=insufficient_funds; 
 else if(amount >`threshold && amount< balance[acc]) 
 state<=face_recognition;
 
 else 
 state<=withdraw_cash; 
 end
   
 insufficient_funds:
 begin
 $display("not enough balance!try again");   
 state<=enter_amount; 
 end
 
 withdraw_cash:
  begin 
 $display("the cash was withdrawn succesfully"); 
 LED=4'b1001;  
 state<=show_balance; 
  end
   
 face_recognition:
 begin
   $display("the entered amount is greater than 10,000 face recognition will be performed"); 
 state<=withdraw_cash;
 end
   
 show_balance:
 begin
 $display("the old balance was %d",balance[acc]);
 if(withdraw)begin
 remaining_balance=balance[acc]-amount;
 $display("the balance now is %d",remaining_balance);
 end 
 else begin
 remaining_balance=balance[acc]+amount;
 $display("the balance now is %d",remaining_balance);
 end
 state<=eject_card; 
 end
   
 eject_card: 
 begin 
 $display("the card is ejected"); 
 if(reciept_req) 
 state<=generate_reciept; 
 else 
 state<=welcome; 
  end
   
 generate_reciept:
 begin
 $display("reciept"); 
 $display("card number:%d",cardnumber); 
 if(withdraw) begin
 $display("the total amount withdrawn:%d",amount); 
 $display("the total balance left is:%d",remaining_balance); 
 end
 else begin
 $display("the total amount deposited:%d",amount); 
 $display("the total balance left is:%d",remaining_balance); 
 end
 state<=welcome; 
 end
 endcase 
 end 
 end 
endmodule