LOAD DATA
INFILE 'Customer.dat'
REPLACE
INTO TABLE xxnbty_ar_customers_st
FIELDS TERMINATED BY '~'
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
( 
		orig_system_customer_ref		"TRIM (:orig_system_customer_ref)"
		,Customer_name					"TRIM (:Customer_name)"
		,orig_system_address_ref		"TRIM (:orig_system_address_ref)"
		,Address1						"TRIM (:Address1)"
		,Address2						"TRIM (:Address2)"
		,Address3						"TRIM (:Address3)"
		,Address4						"TRIM (:Address4)"
		,City							"TRIM (:City)"
		,County							"TRIM (:County)"
		,State							"TRIM (:State)"
		,Province						"TRIM (:Province)"
		,Country						"TRIM (:Country)"
		,Postal_code					"TRIM (:Postal_code)"
		,Site_Use_Code					"TRIM (:Site_use_Code)"
		,insert_update_flag				"TRIM (:insert_update_flag)"
		,org_id 						"TRIM (:org_id)"
		,record_id  					RECNUM 			
		,record_status 					CONSTANT 'NEW' 
		,interface_status 				CONSTANT 'NEW'
		,last_update_date				SYSDATE
		,created_by						CONSTANT '-1'
		,last_updated_by				CONSTANT '-1'
		,last_update_login				CONSTANT '-1'
		,creation_date					SYSDATE
		
)