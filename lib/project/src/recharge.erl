-module(recharge).
-compile(export_all).
-import(service_handler,[look_up_msisdn/2,update/3]).

recharge_main(Msisdn,Amount) ->
   Min_amount=config:get_env(main_balance,min_amount,1),
   Max_amount=config:get_env(main_balance,max_amount,200),
   Fixed_amount=config:get_env(main_balance,fixed_amount,1000),
   case service_handler:look_up_msisdn(recharge,Msisdn) of
		[]->
				io:format("Hey !! This is an incorrect msisdn!! ~n");
		{Main_balance,Data_balance}->
			case is_number(Amount) of 
				false -> io:format("Hey !! This is not an amount!! ~n");
				true ->  case Amount of 
							Amount when Amount < Min_amount; Amount > Max_amount->
								io:format("Invalid entry of amount!!!! ~n");
							Amount when Amount >= Min_amount; Amount =< Max_amount ->	  
								New_Main_balance=Main_balance + Amount,
									case New_Main_balance of 
										New_Main_balance when New_Main_balance > Fixed_amount -> 
												io:format("failed to recharge!!!");
										_-> 		
											service_handler:update(recharge,Msisdn,{New_Main_balance,Data_balance}),
                                                                                        io:format("Last Updated main balance is ~p ~n",[New_Main_balance])
                                                     
									end
						end
			end					
	end.

recharge_data(Msisdn,Data) ->
	Min_data=config:get_env(main_data_balance,min_data,10),
	Max_data=config:get_env(main_data_balance,max_data,200000),
	Fixed_data=config:get_env(main_data_balance,fixed_data,500000),
	case service_handler:look_up_msisdn(recharge,Msisdn) of
		[]->
			io:format("Hey !! This is not an correct msisdn!! ~n");
		{Main_balance,Data_balance}->
			case is_number(Data) of 
				false -> io:format("Invalid! This is not an exact amount ~n");
				true -> case Data of 
							Data when Data < Min_data; Data > Max_data->
								io:format("Invalid data entry!!!! ~n");
							Data when Data >= Min_data; Data =< Max_data -> 
								New_Data_balance=Data_balance + Data,
									case New_Data_balance of
										New_Data_balance when New_Data_balance > Fixed_data ->
											io:format("failed to recharge because more than 500000kb is not available");
										_->  
											service_handler:update(recharge,Msisdn,{Main_balance,New_Data_balance}),
                                                                                        io:format("Last Updated data balance is ~p ~n",[New_Data_balance])
									end
						end
			end			
	end.
		
