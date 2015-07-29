create or replace PACKAGE BODY       XXNBTY_MSCREP02_CUST_INT_PKG 
 ---------------------------------------------------------------------------------------------
  /*
  Package Name	: XXNBTY_MSCREP02_CUST_INT_PKG
  Author's Name: Albert John Flores
  Date written: 29-Jun-2015
  RICEFW Object: REP02
  Description: Package that will generate detailed error log for Customer Interface Table using FND_FILE. 
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
		SELECT  '"'||ORIG_SYSTEM_CUSTOMER_REF    
				||'","'||SITE_USE_CODE               
				||'","'||ORIG_SYSTEM_ADDRESS_REF  
				||'","'||INTERFACE_STATUS
				||'","'||REQUEST_ID                  
				||'","'||INSERT_UPDATE_FLAG          
				||'","'||VALIDATED_FLAG              
				||'","'||CUSTOMER_NAME               
				||'","'||CUSTOMER_NUMBER                   
				||'","'||CUSTOMER_STATUS                   
				||'","'||CUSTOMER_TYPE                     
				||'","'||ORIG_SYSTEM_PARENT_REF            
				||'","'||PRIMARY_SITE_USE_FLAG             
				||'","'||LOCATION                          
				||'","'||ADDRESS1                          
				||'","'||ADDRESS2                          
				||'","'||ADDRESS3                          
				||'","'||ADDRESS4                          
				||'","'||CITY                              
				||'","'||STATE                             
				||'","'||PROVINCE                          
				||'","'||COUNTY                            
				||'","'||POSTAL_CODE                       
				||'","'||COUNTRY                           
				||'","'||CUSTOMER_ATTRIBUTE_CATEGORY       
				||'","'||CUSTOMER_ATTRIBUTE1               
				||'","'||CUSTOMER_ATTRIBUTE2               
				||'","'||CUSTOMER_ATTRIBUTE3               
				||'","'||CUSTOMER_ATTRIBUTE4               
				||'","'||CUSTOMER_ATTRIBUTE5               
				||'","'||CUSTOMER_ATTRIBUTE6               
				||'","'||CUSTOMER_ATTRIBUTE7               
				||'","'||CUSTOMER_ATTRIBUTE8               
				||'","'||CUSTOMER_ATTRIBUTE9               
				||'","'||ADDRESS_ATTRIBUTE_CATEGORY        
				||'","'||ADDRESS_ATTRIBUTE1                
				||'","'||ADDRESS_ATTRIBUTE2                
				||'","'||ADDRESS_ATTRIBUTE3                
				||'","'||ADDRESS_ATTRIBUTE4                
				||'","'||ADDRESS_ATTRIBUTE5                
				||'","'||ADDRESS_ATTRIBUTE6                
				||'","'||ADDRESS_ATTRIBUTE7                
				||'","'||ADDRESS_ATTRIBUTE8                
				||'","'||ADDRESS_ATTRIBUTE9                
				||'","'||SITE_USE_ATTRIBUTE_CATEGORY       
				||'","'||SITE_USE_ATTRIBUTE1               
				||'","'||SITE_USE_ATTRIBUTE2               
				||'","'||SITE_USE_ATTRIBUTE3               
				||'","'||SITE_USE_ATTRIBUTE4               
				||'","'||SITE_USE_ATTRIBUTE5               
				||'","'||SITE_USE_ATTRIBUTE6               
				||'","'||SITE_USE_ATTRIBUTE7               
				||'","'||SITE_USE_ATTRIBUTE8               
				||'","'||SITE_USE_ATTRIBUTE9               
				||'","'||ADDRESS_KEY                       
				||'","'||CUSTOMER_CATEGORY_CODE            
				||'","'||CUSTOMER_CLASS_CODE               
				||'","'||CUSTOMER_KEY                      
				||'","'||CUST_TAX_CODE                     
				||'","'||CUST_TAX_EXEMPT_NUM               
				||'","'||CUST_TAX_REFERENCE                
				||'","'||DEMAND_CLASS_CODE                 
				||'","'||LOCATION_CCID                     
				||'","'||CUST_SHIP_VIA_CODE                
				||'","'||SITE_USE_TAX_CODE                 
				||'","'||SITE_USE_TAX_EXEMPT_NUM           
				||'","'||SITE_USE_TAX_REFERENCE            
				||'","'||WARNING_TEXT                      
				||'","'||CUSTOMER_ATTRIBUTE10              
				||'","'||CUSTOMER_ATTRIBUTE11              
				||'","'||CUSTOMER_ATTRIBUTE12              
				||'","'||CUSTOMER_ATTRIBUTE13              
				||'","'||CUSTOMER_ATTRIBUTE14              
				||'","'||CUSTOMER_ATTRIBUTE15              
				||'","'||ADDRESS_ATTRIBUTE10               
				||'","'||ADDRESS_ATTRIBUTE11               
				||'","'||ADDRESS_ATTRIBUTE12               
				||'","'||ADDRESS_ATTRIBUTE13               
				||'","'||ADDRESS_ATTRIBUTE14               
				||'","'||ADDRESS_ATTRIBUTE15               
				||'","'||SITE_USE_ATTRIBUTE10              
				||'","'||SITE_USE_ATTRIBUTE11              
				||'","'||SITE_USE_ATTRIBUTE12              
				||'","'||SITE_USE_ATTRIBUTE13              
				||'","'||SITE_USE_ATTRIBUTE14              
				||'","'||SITE_USE_ATTRIBUTE15              
				||'","'||SITE_USE_ATTRIBUTE16              
				||'","'||SITE_USE_ATTRIBUTE17              
				||'","'||SITE_USE_ATTRIBUTE18              
				||'","'||SITE_USE_ATTRIBUTE19              
				||'","'||SITE_USE_ATTRIBUTE20              
				||'","'||SITE_USE_ATTRIBUTE21              
				||'","'||SITE_USE_ATTRIBUTE22              
				||'","'||SITE_USE_ATTRIBUTE23              
				||'","'||SITE_USE_ATTRIBUTE24              
				||'","'||SITE_USE_ATTRIBUTE25              
				||'","'||SITE_SHIP_VIA_CODE                
				||'","'||LAST_UPDATED_BY             
				||'","'||LAST_UPDATE_DATE            
				||'","'||CREATED_BY                  
				||'","'||CREATION_DATE               
				||'","'||LAST_UPDATE_LOGIN                 
				||'","'||MESSAGE_TEXT                      
				||'","'||BILL_TO_ORIG_ADDRESS_REF          
				||'","'||JGZZ_FISCAL_CODE                  
				||'","'||LANGUAGE                          
				||'","'||GLOBAL_ATTRIBUTE_CATEGORY         
				||'","'||GLOBAL_ATTRIBUTE1                 
				||'","'||GLOBAL_ATTRIBUTE2                 
				||'","'||GLOBAL_ATTRIBUTE3                 
				||'","'||GLOBAL_ATTRIBUTE4                 
				||'","'||GLOBAL_ATTRIBUTE5                 
				||'","'||GLOBAL_ATTRIBUTE6                 
				||'","'||GLOBAL_ATTRIBUTE7                 
				||'","'||GLOBAL_ATTRIBUTE8                 
				||'","'||GLOBAL_ATTRIBUTE9                 
				||'","'||GLOBAL_ATTRIBUTE10                
				||'","'||GLOBAL_ATTRIBUTE11                
				||'","'||GLOBAL_ATTRIBUTE12                
				||'","'||GLOBAL_ATTRIBUTE13                
				||'","'||GLOBAL_ATTRIBUTE14                
				||'","'||GLOBAL_ATTRIBUTE15                
				||'","'||GLOBAL_ATTRIBUTE16                
				||'","'||GLOBAL_ATTRIBUTE17                
				||'","'||GLOBAL_ATTRIBUTE18                
				||'","'||GLOBAL_ATTRIBUTE19                
				||'","'||GLOBAL_ATTRIBUTE20                
				||'","'||URL                               
				||'","'||ORG_ID                            
				||'","'||CUSTOMER_PROSPECT_CODE            
				||'","'||CUSTOMER_NAME_PHONETIC            
				||'","'||ADDRESS_LINES_PHONETIC            
				||'","'||TRANSLATED_CUSTOMER_NAME          
				||'","'||TERRITORY                         
				||'","'||GL_ID_REC                         
				||'","'||GL_ID_REV                         
				||'","'||GL_ID_TAX                         
				||'","'||GL_ID_FREIGHT                     
				||'","'||GL_ID_CLEARING                    
				||'","'||GL_ID_UNBILLED                    
				||'","'||GL_ID_UNEARNED                    
				||'","'||PERSON_FLAG                       
				||'","'||PERSON_FIRST_NAME                 
				||'","'||PERSON_LAST_NAME                  
				||'","'||GDF_ADDRESS_ATTR_CAT              
				||'","'||GDF_ADDRESS_ATTRIBUTE1            
				||'","'||GDF_ADDRESS_ATTRIBUTE2            
				||'","'||GDF_ADDRESS_ATTRIBUTE3            
				||'","'||GDF_ADDRESS_ATTRIBUTE4            
				||'","'||GDF_ADDRESS_ATTRIBUTE5            
				||'","'||GDF_ADDRESS_ATTRIBUTE6            
				||'","'||GDF_ADDRESS_ATTRIBUTE7            
				||'","'||GDF_ADDRESS_ATTRIBUTE8            
				||'","'||GDF_ADDRESS_ATTRIBUTE9            
				||'","'||GDF_ADDRESS_ATTRIBUTE10           
				||'","'||GDF_ADDRESS_ATTRIBUTE11           
				||'","'||GDF_ADDRESS_ATTRIBUTE12           
				||'","'||GDF_ADDRESS_ATTRIBUTE13           
				||'","'||GDF_ADDRESS_ATTRIBUTE14           
				||'","'||GDF_ADDRESS_ATTRIBUTE15           
				||'","'||GDF_ADDRESS_ATTRIBUTE16           
				||'","'||GDF_ADDRESS_ATTRIBUTE17           
				||'","'||GDF_ADDRESS_ATTRIBUTE18           
				||'","'||GDF_ADDRESS_ATTRIBUTE19           
				||'","'||GDF_ADDRESS_ATTRIBUTE20           
				||'","'||GDF_SITE_USE_ATTR_CAT             
				||'","'||GDF_SITE_USE_ATTRIBUTE1           
				||'","'||GDF_SITE_USE_ATTRIBUTE2           
				||'","'||GDF_SITE_USE_ATTRIBUTE3           
				||'","'||GDF_SITE_USE_ATTRIBUTE4           
				||'","'||GDF_SITE_USE_ATTRIBUTE5           
				||'","'||GDF_SITE_USE_ATTRIBUTE6           
				||'","'||GDF_SITE_USE_ATTRIBUTE7           
				||'","'||GDF_SITE_USE_ATTRIBUTE8           
				||'","'||GDF_SITE_USE_ATTRIBUTE9           
				||'","'||GDF_SITE_USE_ATTRIBUTE10          
				||'","'||GDF_SITE_USE_ATTRIBUTE11          
				||'","'||GDF_SITE_USE_ATTRIBUTE12          
				||'","'||GDF_SITE_USE_ATTRIBUTE13          
				||'","'||GDF_SITE_USE_ATTRIBUTE14          
				||'","'||GDF_SITE_USE_ATTRIBUTE15          
				||'","'||GDF_SITE_USE_ATTRIBUTE16          
				||'","'||GDF_SITE_USE_ATTRIBUTE17          
				||'","'||GDF_SITE_USE_ATTRIBUTE18          
				||'","'||GDF_SITE_USE_ATTRIBUTE19          
				||'","'||GDF_SITE_USE_ATTRIBUTE20          
				||'","'||GL_ID_UNPAID_REC                  
				||'","'||GL_ID_REMITTANCE                  
				||'","'||GL_ID_FACTOR                      
				||'","'||ORIG_SYSTEM_PARTY_REF             
				||'","'||PARTY_NUMBER                      
				||'","'||PARTY_SITE_NUMBER                 
				||'","'||ADDRESS_CATEGORY_CODE             
				||'","'||ADDRESS_ATTRIBUTE16               
				||'","'||ADDRESS_ATTRIBUTE17               
				||'","'||ADDRESS_ATTRIBUTE18               
				||'","'||ADDRESS_ATTRIBUTE19               
				||'","'||ADDRESS_ATTRIBUTE20               
				||'","'||CUSTOMER_ATTRIBUTE16              
				||'","'||CUSTOMER_ATTRIBUTE17              
				||'","'||CUSTOMER_ATTRIBUTE18              
				||'","'||CUSTOMER_ATTRIBUTE19              
				||'","'||CUSTOMER_ATTRIBUTE20||'"'   CUSTOMER_DATA_INT_TBL           
				FROM ra_customers_interface_all 
				WHERE interface_status IS NOT NULL AND creation_date >= (select a.creation_date from xxnbty_ar_customers_st a where a.request_id >= p_main_request_id and rownum < 2 );
						
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
     v_header := v_header || 'ORIG_SYSTEM_CUSTOMER_REF,SITE_USE_CODE,ORIG_SYSTEM_ADDRESS_REF,INTERFACE_STATUS,REQUEST_ID,INSERT_UPDATE_FLAG,';
	 v_header := v_header || 'VALIDATED_FLAG,CUSTOMER_NAME,CUSTOMER_NUMBER,CUSTOMER_STATUS,CUSTOMER_TYPE,ORIG_SYSTEM_PARENT_REF,';
	 v_header := v_header || 'PRIMARY_SITE_USE_FLAG,LOCATION,ADDRESS1,ADDRESS2,ADDRESS3,ADDRESS4,CITY,STATE,PROVINCE,COUNTY,POSTAL_CODE,';
	 v_header := v_header || 'COUNTRY,CUSTOMER_ATTRIBUTE_CATEGORY,CUSTOMER_ATTRIBUTE1,CUSTOMER_ATTRIBUTE2,CUSTOMER_ATTRIBUTE3,CUSTOMER_ATTRIBUTE4,';
	 v_header := v_header || 'CUSTOMER_ATTRIBUTE5,CUSTOMER_ATTRIBUTE6,CUSTOMER_ATTRIBUTE7,CUSTOMER_ATTRIBUTE8,CUSTOMER_ATTRIBUTE9,';
	 v_header := v_header || 'ADDRESS_ATTRIBUTE_CATEGORY,ADDRESS_ATTRIBUTE1,ADDRESS_ATTRIBUTE2,ADDRESS_ATTRIBUTE3,ADDRESS_ATTRIBUTE4,';
	 v_header := v_header || 'ADDRESS_ATTRIBUTE5,ADDRESS_ATTRIBUTE6,ADDRESS_ATTRIBUTE7,ADDRESS_ATTRIBUTE8,ADDRESS_ATTRIBUTE9,SITE_USE_ATTRIBUTE_CATEGORY,';
	 v_header := v_header || 'SITE_USE_ATTRIBUTE1           ,SITE_USE_ATTRIBUTE2           ,SITE_USE_ATTRIBUTE3           ,';
	 v_header := v_header || 'SITE_USE_ATTRIBUTE4           ,SITE_USE_ATTRIBUTE5           ,SITE_USE_ATTRIBUTE6           ,';
	 v_header := v_header || 'SITE_USE_ATTRIBUTE7           ,SITE_USE_ATTRIBUTE8           ,SITE_USE_ATTRIBUTE9           ,';
	 v_header := v_header || 'ADDRESS_KEY                   ,CUSTOMER_CATEGORY_CODE        ,CUSTOMER_CLASS_CODE           ,';
	 v_header := v_header || 'CUSTOMER_KEY                  ,CUST_TAX_CODE                 ,CUST_TAX_EXEMPT_NUM           ,';
	 v_header := v_header || 'CUST_TAX_REFERENCE            ,DEMAND_CLASS_CODE             ,LOCATION_CCID                 ,';
	 v_header := v_header || 'CUST_SHIP_VIA_CODE            ,SITE_USE_TAX_CODE             ,SITE_USE_TAX_EXEMPT_NUM       ,';
	 v_header := v_header || 'SITE_USE_TAX_REFERENCE        ,WARNING_TEXT                  ,CUSTOMER_ATTRIBUTE10          ,';
	 v_header := v_header || 'CUSTOMER_ATTRIBUTE11          ,CUSTOMER_ATTRIBUTE12          ,CUSTOMER_ATTRIBUTE13          ,';
	 v_header := v_header || 'CUSTOMER_ATTRIBUTE14          ,CUSTOMER_ATTRIBUTE15          ,ADDRESS_ATTRIBUTE10           ,';
	 v_header := v_header || 'ADDRESS_ATTRIBUTE11           ,ADDRESS_ATTRIBUTE12           ,ADDRESS_ATTRIBUTE13           ,';
	 v_header := v_header || 'ADDRESS_ATTRIBUTE14           ,ADDRESS_ATTRIBUTE15           ,SITE_USE_ATTRIBUTE10          ,';
	 v_header := v_header || 'SITE_USE_ATTRIBUTE11          ,SITE_USE_ATTRIBUTE12          ,SITE_USE_ATTRIBUTE13          ,';
	 v_header := v_header || 'SITE_USE_ATTRIBUTE14          ,SITE_USE_ATTRIBUTE15          ,SITE_USE_ATTRIBUTE16          ,';
	 v_header := v_header || 'SITE_USE_ATTRIBUTE17          ,SITE_USE_ATTRIBUTE18          ,SITE_USE_ATTRIBUTE19          ,';
	 v_header := v_header || 'SITE_USE_ATTRIBUTE20          ,SITE_USE_ATTRIBUTE21          ,SITE_USE_ATTRIBUTE22          ,';
	 v_header := v_header || 'SITE_USE_ATTRIBUTE23          ,SITE_USE_ATTRIBUTE24          ,SITE_USE_ATTRIBUTE25          ,';
	 v_header := v_header || 'SITE_SHIP_VIA_CODE            ,LAST_UPDATED_BY               ,LAST_UPDATE_DATE              ,';
	 v_header := v_header || 'CREATED_BY                    ,CREATION_DATE                 ,LAST_UPDATE_LOGIN             ,';
	 v_header := v_header || 'MESSAGE_TEXT                  ,BILL_TO_ORIG_ADDRESS_REF      ,JGZZ_FISCAL_CODE              ,';
	 v_header := v_header || 'LANGUAGE                      ,GLOBAL_ATTRIBUTE_CATEGORY     ,GLOBAL_ATTRIBUTE1             ,';
	 v_header := v_header || 'GLOBAL_ATTRIBUTE2             ,GLOBAL_ATTRIBUTE3             ,GLOBAL_ATTRIBUTE4             ,';
	 v_header := v_header || 'GLOBAL_ATTRIBUTE5             ,GLOBAL_ATTRIBUTE6             ,GLOBAL_ATTRIBUTE7             ,';
	 v_header := v_header || 'GLOBAL_ATTRIBUTE8             ,GLOBAL_ATTRIBUTE9             ,GLOBAL_ATTRIBUTE10            ,';
	 v_header := v_header || 'GLOBAL_ATTRIBUTE11            ,GLOBAL_ATTRIBUTE12            ,GLOBAL_ATTRIBUTE13            ,';
	 v_header := v_header || 'GLOBAL_ATTRIBUTE14            ,GLOBAL_ATTRIBUTE15            ,GLOBAL_ATTRIBUTE16            ,';
	 v_header := v_header || 'GLOBAL_ATTRIBUTE17            ,GLOBAL_ATTRIBUTE18            ,GLOBAL_ATTRIBUTE19            ,';
	 v_header := v_header || 'GLOBAL_ATTRIBUTE20            ,URL                           ,ORG_ID                        ,';
	 v_header := v_header || 'CUSTOMER_PROSPECT_CODE        ,CUSTOMER_NAME_PHONETIC        ,ADDRESS_LINES_PHONETIC        ,';
	 v_header := v_header || 'TRANSLATED_CUSTOMER_NAME      ,TERRITORY                     ,GL_ID_REC                     ,';
	 v_header := v_header || 'GL_ID_REV                     ,GL_ID_TAX                     ,GL_ID_FREIGHT                 ,';
	 v_header := v_header || 'GL_ID_CLEARING                ,GL_ID_UNBILLED                ,GL_ID_UNEARNED                ,';
	 v_header := v_header || 'PERSON_FLAG                   ,PERSON_FIRST_NAME             ,PERSON_LAST_NAME              ,';
	 v_header := v_header || 'GDF_ADDRESS_ATTR_CAT          ,GDF_ADDRESS_ATTRIBUTE1        ,GDF_ADDRESS_ATTRIBUTE2        ,';
	 v_header := v_header || 'GDF_ADDRESS_ATTRIBUTE3        ,GDF_ADDRESS_ATTRIBUTE4        ,GDF_ADDRESS_ATTRIBUTE5        ,';
	 v_header := v_header || 'GDF_ADDRESS_ATTRIBUTE6        ,GDF_ADDRESS_ATTRIBUTE7        ,GDF_ADDRESS_ATTRIBUTE8        ,';
	 v_header := v_header || 'GDF_ADDRESS_ATTRIBUTE9        ,GDF_ADDRESS_ATTRIBUTE10       ,GDF_ADDRESS_ATTRIBUTE11       ,';
	 v_header := v_header || 'GDF_ADDRESS_ATTRIBUTE12       ,GDF_ADDRESS_ATTRIBUTE13       ,GDF_ADDRESS_ATTRIBUTE14       ,';
	 v_header := v_header || 'GDF_ADDRESS_ATTRIBUTE15       ,GDF_ADDRESS_ATTRIBUTE16       ,GDF_ADDRESS_ATTRIBUTE17       ,';
	 v_header := v_header || 'GDF_ADDRESS_ATTRIBUTE18       ,GDF_ADDRESS_ATTRIBUTE19       ,GDF_ADDRESS_ATTRIBUTE20       ,';
	 v_header := v_header || 'GDF_SITE_USE_ATTR_CAT         ,GDF_SITE_USE_ATTRIBUTE1       ,GDF_SITE_USE_ATTRIBUTE2       ,';
	 v_header := v_header || 'GDF_SITE_USE_ATTRIBUTE3       ,GDF_SITE_USE_ATTRIBUTE4       ,GDF_SITE_USE_ATTRIBUTE5       ,';
	 v_header := v_header || 'GDF_SITE_USE_ATTRIBUTE6       ,GDF_SITE_USE_ATTRIBUTE7       ,GDF_SITE_USE_ATTRIBUTE8       ,';
	 v_header := v_header || 'GDF_SITE_USE_ATTRIBUTE9       ,GDF_SITE_USE_ATTRIBUTE10      ,GDF_SITE_USE_ATTRIBUTE11      ,';
	 v_header := v_header || 'GDF_SITE_USE_ATTRIBUTE12      ,GDF_SITE_USE_ATTRIBUTE13      ,GDF_SITE_USE_ATTRIBUTE14      ,';
	 v_header := v_header || 'GDF_SITE_USE_ATTRIBUTE15      ,GDF_SITE_USE_ATTRIBUTE16      ,GDF_SITE_USE_ATTRIBUTE17      ,';
	 v_header := v_header || 'GDF_SITE_USE_ATTRIBUTE18      ,GDF_SITE_USE_ATTRIBUTE19      ,GDF_SITE_USE_ATTRIBUTE20      ,';
	 v_header := v_header || 'GL_ID_UNPAID_REC              ,GL_ID_REMITTANCE              ,GL_ID_FACTOR                  ,';
	 v_header := v_header || 'ORIG_SYSTEM_PARTY_REF         ,PARTY_NUMBER                  ,PARTY_SITE_NUMBER             ,';
	 v_header := v_header || 'ADDRESS_CATEGORY_CODE         ,ADDRESS_ATTRIBUTE16           ,ADDRESS_ATTRIBUTE17           ,';
	 v_header := v_header || 'ADDRESS_ATTRIBUTE18           ,ADDRESS_ATTRIBUTE19           ,ADDRESS_ATTRIBUTE20           ,';
	 v_header := v_header || 'CUSTOMER_ATTRIBUTE16          ,CUSTOMER_ATTRIBUTE17          ,CUSTOMER_ATTRIBUTE18          ,';
	 v_header := v_header || 'CUSTOMER_ATTRIBUTE19          ,CUSTOMER_ATTRIBUTE20          ';
		
	--	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'ORIG_SYSTEM_CUSTOMER_REF,SITE_USE_CODE,ORIG_SYSTEM_ADDRESS_REF,....
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,v_header);		
     -- drodil 17-july-2015  -- end

		
		OPEN c_gen_error(v_main_request_id);
	v_step := 4;	
		FETCH c_gen_error BULK COLLECT INTO l_detailed_error_tab;
		FOR i in 1..l_detailed_error_tab.COUNT
			LOOP
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_detailed_error_tab(i).CUSTOMER_DATA_INT_TBL );
			END LOOP;
		CLOSE c_gen_error;
	v_step := 5;
	
	EXCEPTION
		WHEN OTHERS THEN
		  v_mess := 'At step ['||v_step||'] - SQLCODE [' ||SQLCODE|| '] - ' ||substr(SQLERRM,1,100);
		  x_errbuf  := v_mess;
		  x_retcode := 2; 

   END main_proc;
		
END XXNBTY_MSCREP02_CUST_INT_PKG;
/

show errors;
