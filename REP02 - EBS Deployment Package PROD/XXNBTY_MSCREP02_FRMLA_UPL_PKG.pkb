create or replace PACKAGE BODY       XXNBTY_MSCREP02_FRMLA_UPL_PKG 
 ---------------------------------------------------------------------------------------------
  /*
  Package Name	: XXNBTY_MSCREP02_FRMLA_UPL_PKG
  Author's Name: Albert John Flores
  Date written: 29-Jun-2015
  RICEFW Object: REP02
  Description: Package that will generate detailed error log for Formula table (xxnbty_opm_formula_upload) using FND_FILE. 
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
		SELECT '"'||ATTRIBUTE30 
				||'","'||RECORD_TYPE                  
				||'","'||FORMULA_NO                   
				||'","'||FORMULA_VERS                 
				||'","'||FORMULA_TYPE                 
				||'","'||FORMULA_DESC1                
				||'","'||FORMULA_DESC2                
				||'","'||FORMULA_CLASS                
				||'","'||FMCONTROL_CLASS              
				||'","'||INACTIVE_IND                 
				||'","'||OWNER_ORGANIZATION_ID        
				||'","'||TOTAL_INPUT_QTY              
				||'","'||TOTAL_OUTPUT_QTY             
				||'","'||YIELD_UOM                    
				||'","'||FORMULA_STATUS               
				||'","'||OWNER_ID                     
				||'","'||FORMULA_ID                   
				||'","'||FORMULALINE_ID               
				||'","'||LINE_TYPE                    
				||'","'||LINE_NO                      
				||'","'||ITEM_NO                      
				||'","'||INVENTORY_ITEM_ID            
				||'","'||REVISION                     
				||'","'||QTY                          
				||'","'||DETAIL_UOM                   
				||'","'||MASTER_FORMULA_ID            
				||'","'||RELEASE_TYPE                 
				||'","'||SCRAP_FACTOR                 
				||'","'||SCALE_TYPE_HDR               
				||'","'||SCALE_TYPE_DTL               
				||'","'||COST_ALLOC                   
				||'","'||PHANTOM_TYPE                 
				||'","'||REWORK_TYPE                  
				||'","'||BUFFER_IND                   
				||'","'||BY_PRODUCT_TYPE              
				||'","'||INGREDIENT_END_DATE          
				||'","'||ATTRIBUTE1                   
				||'","'||ATTRIBUTE2                   
				||'","'||ATTRIBUTE3                   
				||'","'||ATTRIBUTE4                   
				||'","'||ATTRIBUTE5                   
				||'","'||ATTRIBUTE6                   
				||'","'||ATTRIBUTE7                   
				||'","'||ATTRIBUTE8                   
				||'","'||ATTRIBUTE9                   
				||'","'||ATTRIBUTE10                  
				||'","'||ATTRIBUTE11                  
				||'","'||ATTRIBUTE12                  
				||'","'||ATTRIBUTE13                  
				||'","'||ATTRIBUTE14                  
				||'","'||ATTRIBUTE15                  
				||'","'||ATTRIBUTE16                  
				||'","'||ATTRIBUTE17                  
				||'","'||ATTRIBUTE18                  
				||'","'||ATTRIBUTE19                  
				||'","'||ATTRIBUTE20                  
				||'","'||ATTRIBUTE21                  
				||'","'||ATTRIBUTE22                  
				||'","'||ATTRIBUTE23                  
				||'","'||ATTRIBUTE24                  
				||'","'||ATTRIBUTE25                  
				||'","'||ATTRIBUTE26                  
				||'","'||ATTRIBUTE27                  
				||'","'||ATTRIBUTE28                  
				||'","'||ATTRIBUTE29                                   
				||'","'||DTL_ATTRIBUTE1               
				||'","'||DTL_ATTRIBUTE2               
				||'","'||DTL_ATTRIBUTE3               
				||'","'||DTL_ATTRIBUTE4               
				||'","'||DTL_ATTRIBUTE5               
				||'","'||DTL_ATTRIBUTE6               
				||'","'||DTL_ATTRIBUTE7               
				||'","'||DTL_ATTRIBUTE8               
				||'","'||DTL_ATTRIBUTE9               
				||'","'||DTL_ATTRIBUTE10              
				||'","'||DTL_ATTRIBUTE11              
				||'","'||DTL_ATTRIBUTE12              
				||'","'||DTL_ATTRIBUTE13              
				||'","'||DTL_ATTRIBUTE14              
				||'","'||DTL_ATTRIBUTE15              
				||'","'||DTL_ATTRIBUTE16              
				||'","'||DTL_ATTRIBUTE17              
				||'","'||DTL_ATTRIBUTE18              
				||'","'||DTL_ATTRIBUTE19              
				||'","'||DTL_ATTRIBUTE20              
				||'","'||DTL_ATTRIBUTE21              
				||'","'||DTL_ATTRIBUTE22              
				||'","'||DTL_ATTRIBUTE23              
				||'","'||DTL_ATTRIBUTE24              
				||'","'||DTL_ATTRIBUTE25              
				||'","'||DTL_ATTRIBUTE26              
				||'","'||DTL_ATTRIBUTE27              
				||'","'||DTL_ATTRIBUTE28              
				||'","'||DTL_ATTRIBUTE29              
				||'","'||DTL_ATTRIBUTE30              
				||'","'||ATTRIBUTE_CATEGORY           
				||'","'||DTL_ATTRIBUTE_CATEGORY       
				||'","'||TPFORMULA_ID                 
				||'","'||IAFORMULA_ID                 
				||'","'||SCALE_MULTIPLE               
				||'","'||CONTRIBUTE_YIELD_IND         
				||'","'||SCALE_UOM                    
				||'","'||CONTRIBUTE_STEP_QTY_IND      
				||'","'||SCALE_ROUNDING_VARIANCE      
				||'","'||ROUNDING_DIRECTION           
				||'","'||TEXT_CODE_HDR                
				||'","'||TEXT_CODE_DTL                
				||'","'||USER_ID                      
				||'","'||CREATION_DATE                
				||'","'||CREATED_BY                   
				||'","'||LAST_UPDATED_BY              
				||'","'||LAST_UPDATE_DATE             
				||'","'||LAST_UPDATE_LOGIN            
				||'","'||USER_NAME                    
				||'","'||DELETE_MARK                  
				||'","'||AUTO_PRODUCT_CALC            
				||'","'||PROD_PERCENT||'"' FORMULA_UPLOAD_TBL
				FROM xxnbty_opm_formula_upload 
				WHERE attribute29 NOT IN ('P', 'V') ;
						
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
     v_header := v_header || 'ATTRIBUTE30,RECORD_TYPE,FORMULA_NO,FORMULA_VERS,FORMULA_TYPE,FORMULA_DESC1,FORMULA_DESC2,FORMULA_CLASS,FMCONTROL_CLASS,';
	 v_header := v_header || 'INACTIVE_IND,OWNER_ORGANIZATION_ID,TOTAL_INPUT_QTY,TOTAL_OUTPUT_QTY,YIELD_UOM,FORMULA_STATUS,OWNER_ID,FORMULA_ID,';
	 v_header := v_header || 'FORMULALINE_ID,LINE_TYPE,LINE_NO,ITEM_NO,INVENTORY_ITEM_ID,REVISION,QTY,DETAIL_UOM,MASTER_FORMULA_ID,RELEASE_TYPE,';
	 v_header := v_header || 'SCRAP_FACTOR,SCALE_TYPE_HDR,SCALE_TYPE_DTL,COST_ALLOC,PHANTOM_TYPE,REWORK_TYPE,BUFFER_IND,BY_PRODUCT_TYPE,';
	 v_header := v_header || 'INGREDIENT_END_DATE,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5 ,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,';
	 v_header := v_header || 'ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,ATTRIBUTE16,ATTRIBUTE17,ATTRIBUTE18,';
	 v_header := v_header || 'ATTRIBUTE19,ATTRIBUTE20,ATTRIBUTE21,ATTRIBUTE22,ATTRIBUTE23,ATTRIBUTE24,ATTRIBUTE25,ATTRIBUTE26,ATTRIBUTE27,';
	 v_header := v_header || 'ATTRIBUTE28,ATTRIBUTE29,DTL_ATTRIBUTE1,DTL_ATTRIBUTE2,DTL_ATTRIBUTE3,DTL_ATTRIBUTE4,DTL_ATTRIBUTE5,DTL_ATTRIBUTE6,';
	 v_header := v_header || 'DTL_ATTRIBUTE7,DTL_ATTRIBUTE8,DTL_ATTRIBUTE9,DTL_ATTRIBUTE10,DTL_ATTRIBUTE11,DTL_ATTRIBUTE12,DTL_ATTRIBUTE13,';
	 v_header := v_header || 'DTL_ATTRIBUTE14,DTL_ATTRIBUTE15,DTL_ATTRIBUTE16,DTL_ATTRIBUTE17,DTL_ATTRIBUTE18,DTL_ATTRIBUTE19,DTL_ATTRIBUTE20,';
	 v_header := v_header || 'DTL_ATTRIBUTE21,DTL_ATTRIBUTE22,DTL_ATTRIBUTE23,DTL_ATTRIBUTE24,DTL_ATTRIBUTE25,DTL_ATTRIBUTE26,DTL_ATTRIBUTE27,';
	 v_header := v_header || 'DTL_ATTRIBUTE28,DTL_ATTRIBUTE29,DTL_ATTRIBUTE30,ATTRIBUTE_CATEGORY,DTL_ATTRIBUTE_CATEGORY,TPFORMULA_ID,IAFORMULA_ID,';
	 v_header := v_header || 'SCALE_MULTIPLE,CONTRIBUTE_YIELD_IND,SCALE_UOM,CONTRIBUTE_STEP_QTY_IND,SCALE_ROUNDING_VARIANCE,ROUNDING_DIRECTION,';
	 v_header := v_header || 'TEXT_CODE_HDR,TEXT_CODE_DTL,USER_ID,CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,';
	 v_header := v_header || 'USER_NAME,DELETE_MARK,AUTO_PRODUCT_CALC,PROD_PERCENT';
		
	--			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'ATTRIBUTE30,RECORD_TYPE,FORMULA_NO,FORMULA_VERS,...
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,v_header);		
     -- drodil 17-july-2015  -- end
		
		OPEN c_gen_error(v_main_request_id);
	v_step := 4;	
		FETCH c_gen_error BULK COLLECT INTO l_detailed_error_tab;
		FOR i in 1..l_detailed_error_tab.COUNT
			LOOP
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_detailed_error_tab(i).FORMULA_UPLOAD_TBL);
			END LOOP;
		CLOSE c_gen_error;
	v_step := 5;
	
	EXCEPTION
		WHEN OTHERS THEN
		  v_mess := 'At step ['||v_step||'] - SQLCODE [' ||SQLCODE|| '] - ' ||substr(SQLERRM,1,100);
		  x_errbuf  := v_mess;
		  x_retcode := 2; 

   END main_proc;
		
END XXNBTY_MSCREP02_FRMLA_UPL_PKG;
/

show errors;
