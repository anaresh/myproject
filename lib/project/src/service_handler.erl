-module(service_handler).
-compile(export_all).
-import(db,[look_up/1,update/7]).

look_up_msisdn(Req_source,Msisdn)->
	case db:lookup(Msisdn) of 
			[] ->
				[];
			{Msisdn, Name,Age, Address, Main_balance, Total_used_data, Data_balance}->
					case Req_source of
							recharge->{Main_balance,Data_balance};
							provisioning-> {Name,Age, Address, Main_balance, Total_used_data, Data_balance};
							main_balance->{Main_balance};
							data_handler->{Total_used_data, Data_balance};
							_->{}
					end;			
			{Other}->{Other}
	end.
		


	
update(Req_source, Msisdn, New_info) ->	
	case db:lookup(Msisdn) of
		{Msisdn, Name,Age, Address, Main_balance, Total_used_data, Data_balance}->
				case Req_source of 
						recharge-> {New_Main_balance,New_Data_balance}=New_info,
										db:update(Msisdn, Name,Age, Address, New_Main_balance, Total_used_data, New_Data_balance);
						data_handler->{New_Total_used_data, New_Data_balance}=New_info,
										db:update(Msisdn,Name,Age, Address, Main_balance, New_Total_used_data, New_Data_balance);
						main_balance->{New_Main_balance}=New_info,
										db:update(Msisdn,Name,Age, Address, New_Main_balance, Total_used_data, Data_balance);
						provisioning->{New_Name,New_Age, New_Address, New_Main_balance, New_Total_used_data, New_Data_balance}=New_info,
									db:update(Msisdn,New_Name,New_Age, New_Address, New_Main_balance, New_Total_used_data, New_Data_balance)
				end,
				{updated};
		_->{cant_update}
	end.



insert(Req_source, Msisdn, {Name,Age, Address, Main_balance, Total_used_data, Data_balance}) ->	
	db:insert(Msisdn,Name,Age, Address, Main_balance, Total_used_data, Data_balance).

	