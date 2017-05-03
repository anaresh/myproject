%%---------------------------------------------
%% Author : Sanjukta
%% -------------------------------------------
-module(data_handler).
-export([data_usage/2]).
-import(service_handler,[look_up_msisdn/2,update/3]).


data_usage(Msisdn,Data_Usage) when is_number(Data_Usage),is_number(Msisdn)  ->
	Min_data_usage=config:get_env(data_usage,min_val,10),
    Max_data_usage=config:get_env(data_usage,max_val,1*1024),
    case  service_handler:look_up_msisdn(data_handler,Msisdn) of
		[]->
			io:format("Please enter valid MSISDN~n",[]);
		{Total_used_data, Data_balance}->
			case Data_Usage of 
				Data_Usage when Data_Usage < 0->
						io:format("Please enter valid data_usage~n",[]);
				Data_Usage when Data_Usage > Max_data_usage ->
						io:format("current balance: ~pKb ~n this data usage can not be redeemed, because max data usage should not exceed 1MB~n",[Data_balance]);
				Data_Usage when Data_Usage > Data_balance ->
						io:format("current balance: ~pKb ~n Please recharge your data pack, because your data balance is insufficient~n",[Data_balance]);
				Data_Usage when Data_Usage > Min_data_usage,Data_Usage < Max_data_usage ->
						New_Total_used_data= Total_used_data + Data_Usage,
						New_Data_balance= Data_balance - Data_Usage,
						service_handler:update(data_handler,Msisdn,{New_Total_used_data,New_Data_balance}),
						case New_Data_balance of 
							New_Data_balance when  New_Data_balance < 10  ->
										io:format("current balance: ~pKb ~n Your internet access is blocked, current data balance is lesser than 10KB~n",[New_Data_balance]);
							New_Data_balance when  New_Data_balance < 100  ->
								io:format("current balance: ~pKb ~nPlease top up your data balance, it is lesser than 100KB~n",[New_Data_balance]);
							_-> 
                                                           io:format("Success !!! Remaining data balance is ~pKb ~n",[New_Data_balance])
						end;				
				_->	io:format("this data usage can not be redeemed, against company policy~n",[])
			end
	end;

data_usage(_,_)->	
	io:format("Please enter valid inputs~n",[]).
		

