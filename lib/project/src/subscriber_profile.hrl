%%---------------------------------------------
%%%%%% Author : Mohit Choudhary
%%%%%%%% -------------------------------------------

-record(subscriber_profile,     {  msisdn,
						name,
						age ,
						address,
						main_balance=0,
						total_used_data=0, 
						data_balance=0}).
