-module(db).
-compile(export_all).
-include_lib("subscriber_profile.hrl"). 
  
init() ->
    mnesia:create_schema([node()]),
    mnesia:start(),
	application:start(config),
    mnesia:create_table(subscriber_profile,
        [ {disc_copies, [node()] },
             {attributes,      
                record_info(fields,subscriber_profile)} ]).
 
insert(Msisdn, Name,Age, Address, Main_balance, Total_used_data, Data_balance)
when is_integer(Msisdn),is_integer(Age),is_number(Main_balance),
is_number(Total_used_data),is_number(Data_balance)->
	Len= string:len(integer_to_list(Msisdn)),
	case Len of 
		10->
				Fun = fun() ->
					mnesia:write(#subscriber_profile{ msisdn = Msisdn,
														name = Name,
														age = Age,
														address = Address,
														main_balance = Main_balance, 
														total_used_data = Total_used_data, 
														data_balance = Data_balance} )
						end,
				mnesia:transaction(Fun);
		_->{cant_insert_msisdn_length_not_correct}
	end;
insert(_, _,_,_, _, _, _)->{cant_insert}.  
  
lookup(Msisdn) ->
    Fun = 
        fun() ->
            mnesia:read({subscriber_profile, Msisdn}) 
					
        end,
    case mnesia:transaction(Fun) of
				{atomic, [Row]}->{Row#subscriber_profile.msisdn,Row#subscriber_profile.name, Row#subscriber_profile.age,Row#subscriber_profile.address,Row#subscriber_profile.main_balance,Row#subscriber_profile.total_used_data,Row#subscriber_profile.data_balance} ;
				{atomic,Other}->Other
	end.
	
	
lookup_msisdn(Msisdn) ->
    Fun = 
        fun() ->
            mnesia:read({subscriber_profile, Msisdn}) 
					
        end,
    case mnesia:transaction(Fun) of
				{atomic, [Row]}->io:format("msisdn: ~p~nName: ~p~nAge: ~p~naddress: ~p~nmain balance: ~p~ntotal used data: ~p~ndatabalance: ~p~n",
									[Row#subscriber_profile.msisdn,Row#subscriber_profile.name, Row#subscriber_profile.age,Row#subscriber_profile.address,Row#subscriber_profile.main_balance,
												Row#subscriber_profile.total_used_data,Row#subscriber_profile.data_balance]) ;
				{atomic,Other}->Other
	end.	
	
update(Msisdn, Name,Age, Address, Main_balance, Total_used_data, Data_balance)
	when is_integer(Msisdn),is_integer(Age),is_number(Main_balance),
	is_number(Total_used_data),is_number(Data_balance) ->
		Fun = 
			fun() ->
			case  mnesia:read({subscriber_profile, Msisdn}) of
					[] -> {error, instance}; 
					[_] -> mnesia:write(
										#subscriber_profile{ msisdn = Msisdn,
										name = Name,
										age = Age,
										address = Address,
										main_balance = Main_balance, 
										total_used_data = Total_used_data, 
										data_balance = Data_balance} )
				end	
			end,
	{atomic, _}=mnesia:transaction(Fun);
	 
update(_, _,_,_, _, _, _)->{cant_insert}.  
  

  
close()->
	mnesia:stop(),
	application:stop(config),
	mnesia:delete_schema([node()]).