%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   Author: Vijayalakshmi DK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
-module(main_balance).
-export([main_balance_usage/2,check_for_main_balance/3,transaction/3,main_balance_after_transaction/1]).
-import(service_handler,[look_up_msisdn/2,update/3]).

%% Getting the inputs (Msisdn,Amount) from the user.
main_balance_usage(Msisdn,Amount)->
%% Configs for the transaction_limits
    Min_amount=config:get_env(main_balance_usage,min_amount,1),
    Max_amount=config:get_env(main_balance_usage,max_amount,100),
case service_handler:look_up_msisdn(main_balance,Msisdn) of
		[]->
				io:format("Incorrect Msisdn! ~n");
		{Main_balance}->  
%% To check whether the given amount is in integer or not.
case is_number(Amount) of 
    false -> io:format("Invalid! The amount should be in integer or float ~n");
    true -> 

%% To check whether the given amount is under the specified limit.
case Amount of		 
		Amount when Amount < Min_amount ; Amount > Max_amount ->
               io:format("Invalid! Amount not under limit! ~n");	          

       Amount when Amount >= Min_amount , Amount =< Max_amount ->
               io:format("Your transaction is on process ~n"),
	               check_for_main_balance(Msisdn,Main_balance,Amount)
    end
  end
end.
	 
%% Verifying the main_balance before transaction.
check_for_main_balance(Msisdn,Main_balance,Amount) ->
case Main_balance of
    0 ->
     io:format("Blocked! Please recharge your account soon! ~n");
   Main_balance when Main_balance < Amount ->
     io:format("Sorry! Your Main_balance is less for this transaction ~n Please recharge you account soon ~n");  
   Main_balance when Main_balance >= Amount ->
        transaction(Msisdn,Main_balance,Amount)
end.   
   
%% Transaction process.
transaction(Msisdn,Main_balance,Amount) ->	 
    New_main_balance = Main_balance - Amount,
	io:format("Your Current main_balance after transaction is: ~p ~n", [New_main_balance]),
	service_handler:update(main_balance,Msisdn,{New_main_balance}),
     main_balance_after_transaction(New_main_balance).
 
%% To Check whether the New_main_balance is under the limit after the transaction.
main_balance_after_transaction(New_main_balance)-> 
case New_main_balance of 
  New_main_balance when New_main_balance =:= 0 ; New_main_balance =:= 0.0 ->
         io:format("Blocked! Please recharge your account soon! ~n");
  New_main_balance when New_main_balance < 10, New_main_balance > 0.0 ->
         io:format (" Your balance is less than Rs.10 ~n Please recharge your account ~n");
  New_main_balance when New_main_balance > 10 ->
         io:format("Success! ~n")        
end.


	 
	 
	 
	 
	
	
	
	

   
	

	  



