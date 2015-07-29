create or replace PACKAGE BODY       XXNBTY_MSCREP02_BATCH_PKG 
 ---------------------------------------------------------------------------------------------
  /*
  Package Name	: XXNBTY_MSCREP02_BATCH_PKG
  Author's Name: Albert John Flores
  Date written: 29-Jun-2015
  RICEFW Object: REP02
  Description: Package that will generate detailed error log for BATCH using FND_FILE. 
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
		SELECT '"'||ERROR_DESCRIPTION 
				||'","'||AS400_BATCH_NUM   
				||'","'||BATCH_STATUS  
				||'","'||BATCH_SIZE        
				||'","'||BATCH_SIZE_UOM  
				||'","'||ORGANIZATION_CODE 
				||'","'||PLAN_START_DATE   
				||'","'||PLAN_CMPLT_DATE   
				||'","'||DUE_DATE            
				||'","'||ITEM              
				||'","'||ITEM_REVISION     
				||'","'||LOAD_TYPE             
				||'","'||ACTUAL_START_DATE 
				||'","'||ACTUAL_CMPLT_DATE 
				||'","'||PROCESS_FLAG      
				||'","'||LAST_UPDATE_DATE  
				||'","'||CREATION_DATE     
				||'","'||CREATED_BY        
				||'","'||LAST_UPDATED_BY   
				||'","'||LAST_UPDATE_LOGIN||'"' BATCH_DATA_TABLE
				FROM xxnbty_opm_batches_st 
				WHERE error_description IS NOT NULL;
						
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
     v_header := v_header || 'ERROR_DESCRIPTION,AS400_BATCH_NUM,BATCH_STATUS,BATCH_SIZE,BATCH_SIZE_UOM,ORGANIZATION_CODE,PLAN_START_DATE,PLAN_CMPLT_DATE,';
	 v_header := v_header || 'DUE_DATE,ITEM,ITEM_REVISION,LOAD_TYPE,ACTUAL_START_DATE,ACTUAL_CMPLT_DATE,PROCESS_FLAG,LAST_UPDATE_DATE,CREATION_DATE,';
	 v_header := v_header || 'CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_LOGIN';
		
	--	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'ERROR_DESCRIPTION,AS400_BATCH_NUM,BATCH_STATUS,....
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,v_header);		
     -- drodil 17-july-2015  -- end
		
		OPEN c_gen_error(v_main_request_id);
	v_step := 4;	
		FETCH c_gen_error BULK COLLECT INTO l_detailed_error_tab;
		FOR i in 1..l_detailed_error_tab.COUNT
			LOOP
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_detailed_error_tab(i).BATCH_DATA_TABLE );
			END LOOP;
		CLOSE c_gen_error;
	v_step := 5;
	
	EXCEPTION
		WHEN OTHERS THEN
		  v_mess := 'At step ['||v_step||'] - SQLCODE [' ||SQLCODE|| '] - ' ||substr(SQLERRM,1,100);
		  x_errbuf  := v_mess;
		  x_retcode := 2; 

   END main_proc;
		
END XXNBTY_MSCREP02_BATCH_PKG;
/

show errors;
