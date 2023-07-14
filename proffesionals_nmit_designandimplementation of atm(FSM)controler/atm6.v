

`define threshold 7'd90 
`define balance 7'd110
`define correct_pin 2'b10
`define true 1'b1
`define false 1'b0


module atm6( input clk, 
 input reset, 
 input card,
 input [1:0] pin, 
 input [6:0] amount, 

 input withdraw, 
 input reciept_req,
 output reg [6:0] Led_disp, //Seven segment display
 output reg [6:0] remaining_balance, 
 output reg [2:0]LED//to show output on fpga 
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
 reg w;
 wire clk_1;
 
 
 
 //always block for changing states
 
 always @ (posedge clk)// or reset) 
 begin 
 //$display("Initial count= %d",count);
 if(!reset || lock==1)begin
 lock=`false;
 Led_disp=7'b1111111;
 LED=3'b000;
 state<=welcome;
 end 
 
 else 
 begin 
   
 case(state) 
   
 welcome: 
 begin 
 $display("please insert your card(enter card number)"); 
 if(card) 
 begin 
 LED=3'b000;
 state=welcome; 
 $display("error in getting card number try again");
 end 
 else
 begin
 LED=3'b001;//to display on fpga
 count=3'b0;
 state<=card_inserted;
 end
 end   
   
 card_inserted:
 begin 
 $display("please enter the pin");
 LED=3'b010;
 //$display("correct pin %b",pin_database[acc]);//for testing-remove later 
 if(pin) 
 state<=pin_entered;
 else
 state<=card_inserted; 
 end
  
 pin_entered: 
 begin 
 if(pin==`correct_pin)
 begin 
 $display("pin was entered succesfully");
 LED=3'b011; 
 state<=withdraw_deposit; 
 end  
 else
 begin
 $display("pin entered was invalid please try again");
 LED=3'b010; 
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
 $display("your account is locked for the next 24hours");
 lock=`true;
 LED=3'b111;
 Led_disp=7'b1000111;//Display 'L' 
 state<=welcome; 
 end
   
 withdraw_deposit:
 begin
 $display("do you want to withdraw or deposit the money?"); 
 if(withdraw)begin //need to press simultaneously- checking required
 LED=3'b100;
 w=`true;
 state<=enter_amount;
 end 
 else if(!withdraw) begin
 LED=3'b110;
 w=`false;
 state<=deposit;
 end
 else
 state<=withdraw_deposit; 
 end
 
 deposit:
 begin
 $display("enter the amount to be deposited");
 
 LED=3'b101;
 $display("the money was deposited succesfully"); 
 state<=show_balance;
 end
   
 enter_amount: 
 begin 
 $display("enter the amount to be withdrawn"); 
  
 if(amount>`balance) 
 state<=insufficient_funds; 
 else if(amount >`threshold && amount<`balance) 
 state<=face_recognition;//face recognition
 else 
 state<=withdraw_cash; 
 
 end
   
 insufficient_funds:
 begin
 $display("not enough balance!try again");
 Led_disp=7'b0000110; //Display 'E'
 state<=enter_amount; 
 end
 
 withdraw_cash:
  begin 
 $display("the cash was withdrawn succesfully"); 
 LED=3'b101;
 Led_disp=7'b1111111; 
 state<=show_balance; 
  end
   
 face_recognition:
 begin
   $display("the entered amount is greater than 90 face recognition will be performed");
    Led_disp=7'b0001110;	//Display 'F'
 state<=withdraw_cash;
 end
   
 show_balance:
 begin
 $display("the old balance was %d",`balance);
 if(w)begin
 remaining_balance=(`balance)-amount;
 $display("the balance now is %d",remaining_balance);
 end 
 else begin
 remaining_balance=(`balance)+amount;
 $display("the balance now is %d",remaining_balance);
 end
 state<=eject_card; 
 end
   
 eject_card: 
 begin 
 $display("the card is ejected"); 
 if(!reciept_req) 
 state<=generate_reciept; 
 else 
 state<=welcome; 
  end
   
 generate_reciept:
 begin
 $display("reciept"); 
 Led_disp=7'b0101111; 
 if(w) begin
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