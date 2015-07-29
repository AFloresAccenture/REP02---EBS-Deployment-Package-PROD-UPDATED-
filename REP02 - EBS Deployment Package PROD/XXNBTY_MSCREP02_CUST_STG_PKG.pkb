create or replace PACKAGE BODY       XXNBTY_MSCREP02_CUST_STG_PKG 
 ---------------------------------------------------------------------------------------------
  /*
  Package Name	: XXNBTY_MSCREP02_CUST_STG_PKG
  Author's Name: Albert John Flores
  Date written: 29-Jun-2015
  RICEFW Object: REP02
  Description: Package that will generate detailed error log for Customer Staging Table using FND_FILE. 
  Program Style:
  Maintenance History:
  Date         Issue#  Name         			    Remarks
  -----------  ------  -------------------		------------------------------------------------
  29-Jun-2015          Albert John Flores	  	Initial Development
  17-Jul-2015          Daniel Rodil             modified output due to limitation in SQL*Plus when compiling 
                                                  encountered SP2-0027: Input is too long (> 2499 characters) - line ignored 
												  use v_header
  22-Jul-2015		   Albert John Flores		Removed the creation_date = sysdate in the where clause of the query
  */
  ----------------------------------------------------------------------------------------------
 IS 
  PROCEDURE main_proc ( x_retcode   OUT VARCHAR2
					   ,x_errbuf    OUT VARCHAR2)
  IS
   v_request_id    		NUMBER := fnd_global.conc_request_id;  
   v_main_request_id 	NUMBER; 
   v_child_request_id 	NUMBER; 
   v_header  VARCHAR2(32000);  -- drodil 17-july-2015
	
		CURSOR c_req_id (p_request_id NUMBER) 
		IS 
		SELECT a.parent_request_id 
		FROM apps.fnd_concurrent_requests a 
		WHERE a.request_id = p_request_id;
		
		CURSOR c_gen_error (p_main_request_id NUMBER)
		IS
		SELECT '"'||ERROR_MESSAGE
				||'","'||INSERT_UPDATE_FLAG            
				||'","'||ORIG_SYSTEM_CUSTOMER_REF      
				||'","'||SITE_USE_CODE                 
				||'","'||ORIG_SYSTEM_ADDRESS_REF       
				||'","'||CUSTOMER_NAME                 
				||'","'||CUSTOMER_NUMBER               
				||'","'||CUSTOMER_STATUS               
				||'","'||PRIMARY_SITE_USE_FLAG         
				||'","'||LOCATION                      
				||'","'||ADDRESS1                      
				||'","'||ADDRESS2                      
				||'","'||ADDRESS3                      
				||'","'||ADDRESS4                      
				||'","'||CITY                          
				||'","'||STATE                         
				||'","'||POSTAL_CODE                   
				||'","'||COUNTRY                       
				||'","'||CUSTOMER_CATEGORY_CODE        
				||'","'||PROVINCE                      
				||'","'||COUNTY                        
				||'","'||ORG_ID                        
				||'","'||RECORD_ID                     
				||'","'||RECORD_STATUS                 
				||'","'||INTERFACE_STATUS              
				||'","'||LAST_UPDATE_DATE              
				||'","'||LAST_UPDATE_BY                
				||'","'||CREATION_DATE                 
				||'","'||CREATED_BY                    
				||'","'||LAST_UPDATE_LOGIN             
				||'","'||LAST_UPDATED_BY                                
				||'","'||PROCESS_FLAG                  
				||'","'||REQUEST_ID||'"'    CUSTOMER_DATA_TABLE
				FROM xxnbty_ar_customers_st 
				WHERE process_flag = 'E' ;
						
	TYPE err_tab_type		   IS TABLE OF c_gen_error%ROWTYPE;
	  
	l_detailed_error_tab	   err_tab_type; 
	v_step          		   NUMBER;
	v_mess          		   VARCHAR2(500);
	
   BEGIN
	v_step := 1;
		v_child_request_id := v_request_id; 
		
		LOOP 
			OPEN c_req_id(v_child_request_id); 
			FETCH c_req_id INTO v_main_request_id; 
			EXIT WHEN c_req_id%notfound; 
			
			IF v_main_request_id = -1 THEN 
				v_main_request_id := v_child_request_id; 
				EXIT; 
			ELSE 
				v_child_request_id := v_main_request_id; 
			END IF;
			CLOSE c_req_id; 
		END LOOP;
	v_step := 2;		
		IF c_req_id%isopen THEN 
			CLOSE c_req_id; 
		END IF; 
	v_step := 3;	
		FND_FILE.PUT_LINE(FND_FILE.LOG,'v_main_request_id : ' || v_main_request_id);		

     -- drodil 17-july-2015 start
     v_header := null;
     v_header := v_header || 'ERROR_MESSAGE,INSERT_UPDATE_FLAG,ORIG_SYSTEM_CUSTOMER_REF,SITE_USE_CODE,ORIG_SYSTEM_ADDRESS_REF,CUSTOMER_NAME,';
	 v_header := v_header || 'CUSTOMER_NUMBER,CUSTOMER_STATUS,PRIMARY_SITE_USE_FLAG,LOCATION,ADDRESS1,ADDRESS2,ADDRESS3,ADDRESS4,CITY,STATE,';
	 v_header := v_header || 'POSTAL_CODE,COUNTRY,CUSTOMER_CATEGORY_CODE,PROVINCE,COUNTY,ORG_ID,RECORD_ID,RECORD_STATUS,INTERFACE_STATUS,';
	 v_header := v_header || 'LAST_UPDATE_DATE,LAST_UPDATE_BY,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,LAST_UPDATED_BY,PROCESS_FLAG,REQUEST_ID';
		
	--	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'ERROR_MESSAGE,INSERT_UPDATE_FLAG,ORIG_SYSTEM_CUSTOMER_REF,....
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,v_header);		
     -- drodil 17-july-2015  -- end

		
		OPEN c_gen_error(v_main_request_id);
	v_step := 4;	
		FETCH c_gen_error BULK COLLECT INTO l_detailed_error_tab;
		FOR i in 1..l_detailed_error_tab.COUNT
			LOOP
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_detailed_error_tab(i).CUSTOMER_DATA_TABLE );
			END LOOP;
		CLOSE c_gen_error;
	v_step := 5;
	
	EXCEPTION
		WHEN OTHERS THEN
		  v_mess := 'At step ['||v_step||'] - SQLCODE [' ||SQLCODE|| '] - ' ||substr(SQLERRM,1,100);
		  x_errbuf  := v_mess;
		  x_retcode := 2; 

   END main_proc;
		
END XXNBTY_MSCREP02_CUST_STG_PKG;
/

show errors;
