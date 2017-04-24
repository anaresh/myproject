
-module(provisioning).

-import(service_handler, [insert/3,look_up_msisdn/2,update/3]).

-compile([export_all]).


add(Msisdn,Name,Age,Address) ->
  A=msisdn(Msisdn),
  B=name(Name),
  C=age(Age),
  D=address(Address),  
  Main_balance=config:get_env(provisioning,main_balance,0),
  Data_balance=config:get_env(provisioning,data_balance,0),  
  Total_used_data=0, 
  if 
     A =:= 1 , B =:= 1, C =:= 1, D =:= 1 ->
	     service_handler:insert(provisioning, Msisdn, {Name,Age, Address, Main_balance, Total_used_data, Data_balance}),
	     io:format("~n Successfully! data is added into the database ~n"),
		 Value=service_handler:look_up_msisdn(provisioning,Msisdn),
		 io:format("~n Value is ~p ~n",[Value]);
	 true ->
	     io:format("~n Sorry, data is not added into the database ~n")
  end.
  
msisdn(Msisdn) ->
  case is_integer(Msisdn) of
    true ->
		Len=string:len(integer_to_list(Msisdn)),
		case Len of  
		  10 ->		    
			case Msisdn of 
			   Msisdn when Msisdn > 0 ->
			       1;
			   Msisdn when Msisdn < 0 ->
			      io:format(" ~n Sorry, please enter the Msisdn in positive value ~n"),
				  0
		    end;
				  
	       _  ->
		      io:format("~n please enter a valid mobile number (mobile number must be in 10 digits) ~n"),
			  0
		end;
    false ->
		io:format(" ~n Sorry, please enter the Msisdn in number ~n"),
		0
  end.
  
name(Name) ->
    case is_number(Name) of
      true ->
  	     io:format("~n Sorry, Please Enter a Name in alphabets ~n"),
           0; 
  		 
  	  false ->
  	     case is_list(Name) of
  			true ->
  				io:format("~n Name is ~p ~n",[Name]),
				check(Name);
  			false ->
  				Name1=atom_to_list(Name),
				check(Name1)	
  		 end
    end.
	
	
check([]) ->
  1;
	
check([H|T]) ->
  if
     H > 64 , H < 91 ; H =:= 32 -> 
					check(T);
	 
	 H > 96 , H < 123 ; H =:= 32 -> 
					check(T);
	 true ->
	     io:format("~nSorry, Enter the Name only in alphabets ~n"),
		 0
  end.
  

  
age(Age) ->
  case is_integer(Age) of
   true ->
	 if 
       Age<18 ->
  	        io:format("~n Sorry, below 18 Age is not valid ~n"),
			0;
  	    					
	   Age>17 ->
			1
     end;
   false ->
       io:format("~n Sorry, please enter the Age in number~n"),
	   0
  end.
          
address(Address) ->
  case is_number(Address) of
     true ->
	     io:format("~n Sorry, please enter a valid Address ~n"),
         0;   
	 false ->	 
		 1
  end.

  
change(Msisdn,New_Main_balance,New_Total_used_data,New_Data_balance) ->
  A=msisdn(Msisdn),  
  case A of
	0 ->
       io:format("~n");
	1 ->
       io:format("~n Msisdn is in number ~n"),	   
  B=case is_number(New_Main_balance) of
     true ->
	    io:format("~n New_Main_balance is ~p ~n",[New_Main_balance]),
		case Msisdn of 
			Msisdn when Msisdn > 0 ->
			       1;
			Msisdn when Msisdn < 0 ->
			      io:format(" ~n Sorry, please enter the Msisdn in positive value ~n"),
				  0
		end;    
	 false ->
	    io:format("~n Sorry, please enter the New_Main_balance in number ~n"),
		0
    end,
  C=case is_number(New_Total_used_data) of
     true ->
	     io:format("~n New_Total_used_data is ~p ~n",[New_Total_used_data]),
		 1;	     
	 false ->
	     io:format("~n Sorry, please enter the New_Total_used_data in number~n"),
		 0
    end,
  D=case is_number(New_Data_balance) of
     true ->
	     io:format("~n New_Data_balance is ~p ~n",[New_Data_balance]),
		 1;	     
	 false ->
	     io:format("~n Sorry, please enter the New_Data_balance in number ~n"),
		 0
    end,
  if 
    A =:= 1 , B =:= 1, C =:= 1, D =:= 1 ->
	    Value=service_handler:look_up_msisdn(provisioning,Msisdn),
		io:format("~n Value is ~p ~n",[Value]),		 
		case service_handler:look_up_msisdn(provisioning,Msisdn) of
			[] ->
				io:format("~n This Msisdn have no data ~n");
				
			{Name,Age,Address,_,_,_} ->
				service_handler:update(provisioning,Msisdn,{Name,Age, Address, New_Main_balance, New_Total_used_data, New_Data_balance}),
				io:format("~n Successfully! New balance is added into the database ~n"),
				Value1=service_handler:look_up_msisdn(provisioning,Msisdn),
				io:format("~n Value is ~p ~n",[Value1])
		end;
		
	true ->
	     io:format("~n Sorry, New balance is not added into the database ~n")

  end  
 end. 

 
modify(Msisdn,New_Name,New_Age,New_Address) ->
  A=msisdn(Msisdn),
  B=name(New_Name),
  C=age(New_Age),
  D=address(New_Address),
  if 
     A =:= 1 , B =:= 1, C =:= 1, D =:= 1 ->
		case service_handler:look_up_msisdn(provisioning,Msisdn) of
		  [] ->
		      io:format("~n ~p Msisdn is not present in the db ~n",[Msisdn]);
			  
		  {_,_,_,Main_balance,Total_used_data,Data_balance} ->
		 service_handler:update(provisioning,Msisdn,{New_Name,New_Age, New_Address, Main_balance, Total_used_data, Data_balance}),
		 io:format("~n Successfully! New Data  is updated into the database ~n"),
		 Value=service_handler:look_up_msisdn(provisioning,Msisdn),
		 io:format("~n Value is ~p ~n",[Value])
		end;
		
	 true ->
	     io:format("~n Sorry, New Data is not updated into the database ~n")
 
  end.
  

  
