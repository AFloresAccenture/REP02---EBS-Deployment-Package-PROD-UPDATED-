create or replace PACKAGE BODY       XXNBTY_MSCREP02_BOM_HEAD_PKG 
 ---------------------------------------------------------------------------------------------
  /*
  Package Name	: XXNBTY_MSCREP02_BOM_HEAD_PKG
  Author's Name: Albert John Flores
  Date written: 29-Jun-2015
  RICEFW Object: REP02
  Description: Package that will generate detailed error log for BOM Header staging table (xxnbty_bom_headers_st) using FND_FILE. 
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
				||'","'||ITEM_NUMBER
				||'","'||ORGANIZATION_CODE
				||'","'||ASSEMBLY_TYPE
				||'","'||ASSEMBLY_QTY
				||'","'||PRIMARY_UNIT_OF_MEASURE
				||'","'||REVISION
				||'","'||TRANSACTION_TYPE
				||'","'||ASSEMBLY_ITEM_ID
				||'","'||COMMON_BILL_SEQUENCE_ID
				||'","'||BILL_SEQUENCE_ID
				||'","'||PROCESS_FLAG
				||'","'||COMMON_ITEM_NUMBER
				||'","'||ALTERNATE_BOM_DESIGNATOR
				||'","'||LAST_UPDATE_LOGIN
				||'","'||COMMON_ASSEMBLY_ITEM_ID
				||'","'||SPECIFIC_ASSEMBLY_COMMENT
				||'","'||PENDING_FROM_ECN
				||'","'||ATTRIBUTE_CATEGORY
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
				||'","'||REQUEST_ID
				||'","'||PROGRAM_APPLICATION_ID
				||'","'||PROGRAM_ID
				||'","'||PROGRAM_UPDATE_DATE
				||'","'||DEMAND_SOURCE_LINE
				||'","'||SET_ID
				||'","'||COMMON_ORGANIZATION_ID
				||'","'||DEMAND_SOURCE_TYPE
				||'","'||DEMAND_SOURCE_HEADER_ID
				||'","'||TRANSACTION_ID
				||'","'||COMMON_ORG_CODE
				||'","'||NEXT_EXPLODE_DATE
				||'","'||DELETE_GROUP_NAME
				||'","'||DG_DESCRIPTION
				||'","'||ORIGINAL_SYSTEM_REFERENCE
				||'","'||IMPLEMENTATION_DATE
				||'","'||OBJ_NAME
				||'","'||PK1_VALUE
				||'","'||PK2_VALUE
				||'","'||PK3_VALUE
				||'","'||PK4_VALUE
				||'","'||PK5_VALUE
				||'","'||STRUCTURE_TYPE_NAME
				||'","'||STRUCTURE_TYPE_ID
				||'","'||EFFECTIVITY_CONTROL
				||'","'||RETURN_STATUS
				||'","'||IS_PREFERRED
				||'","'||SOURCE_SYSTEM_REFERENCE
				||'","'||SOURCE_SYSTEM_REFERENCE_DESC
				||'","'||BATCH_ID
				||'","'||CHANGE_ID
				||'","'||CATALOG_CATEGORY_NAME
				||'","'||ITEM_CATALOG_GROUP_ID
				||'","'||ITEM_DESCRIPTION
				||'","'||TEMPLATE_NAME
				||'","'||SOURCE_BILL_SEQUENCE_ID
				||'","'||ENABLE_ATTRS_UPDATE
				||'","'||INTERFACE_TABLE_UNIQUE_ID
				||'","'||BUNDLE_ID
				||'","'||RECORD_ID
				||'","'||STATUS
				||'","'||ORGANIZATION_ID
				||'","'||LAST_UPDATE_DATE
				||'","'||LAST_UPDATED_BY
				||'","'||CREATION_DATE
				||'","'||CREATED_BY||'"'  BOM_HEAD_ST_TBL
				FROM xxnbty_bom_headers_st 
				WHERE process_flag = 3;
						
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
     v_header := v_header || 'ERROR_DESCRIPTION,ITEM_NUMBER,ORGANIZATION_CODE,ASSEMBLY_TYPE,ASSEMBLY_QTY,PRIMARY_UNIT_OF_MEASURE,REVISION,';
	 v_header := v_header || 'TRANSACTION_TYPE,ASSEMBLY_ITEM_ID,COMMON_BILL_SEQUENCE_ID,BILL_SEQUENCE_ID,PROCESS_FLAG,COMMON_ITEM_NUMBER,';
	 v_header := v_header || 'ALTERNATE_BOM_DESIGNATOR,LAST_UPDATE_LOGIN,COMMON_ASSEMBLY_ITEM_ID,SPECIFIC_ASSEMBLY_COMMENT,PENDING_FROM_ECN,';
	 v_header := v_header || 'ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,';
	 v_header := v_header || 'ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,REQUEST_ID,PROGRAM_APPLICATION_ID,';
	 v_header := v_header || 'PROGRAM_ID,PROGRAM_UPDATE_DATE,DEMAND_SOURCE_LINE,SET_ID,COMMON_ORGANIZATION_ID,DEMAND_SOURCE_TYPE,';
	 v_header := v_header || 'DEMAND_SOURCE_HEADER_ID,TRANSACTION_ID,COMMON_ORG_CODE,NEXT_EXPLODE_DATE,DELETE_GROUP_NAME,DG_DESCRIPTION,';
	 v_header := v_header || 'ORIGINAL_SYSTEM_REFERENCE,IMPLEMENTATION_DATE,OBJ_NAME,PK1_VALUE,PK2_VALUE,PK3_VALUE,PK4_VALUE,PK5_VALUE,';
	 v_header := v_header || 'STRUCTURE_TYPE_NAME,STRUCTURE_TYPE_ID,EFFECTIVITY_CONTROL,RETURN_STATUS,IS_PREFERRED,SOURCE_SYSTEM_REFERENCE,';
	 v_header := v_header || 'SOURCE_SYSTEM_REFERENCE_DESC,BATCH_ID,CHANGE_ID,CATALOG_CATEGORY_NAME,ITEM_CATALOG_GROUP_ID,ITEM_DESCRIPTION,';
	 v_header := v_header || 'TEMPLATE_NAME,SOURCE_BILL_SEQUENCE_ID,ENABLE_ATTRS_UPDATE,INTERFACE_TABLE_UNIQUE_ID,BUNDLE_ID,RECORD_ID,STATUS,';
	 v_header := v_header || 'ORGANIZATION_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY';
		
	--	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'ERROR_DESCRIPTION,ITEM_NUMBER,ORGANIZATION_CODE,ASSEMBLY_TYPE,...
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,v_header);		
     -- drodil 17-july-2015  -- end
		
		OPEN c_gen_error(v_main_request_id);
	v_step := 4;	
		FETCH c_gen_error BULK COLLECT INTO l_detailed_error_tab;
		FOR i in 1..l_detailed_error_tab.COUNT
			LOOP
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_detailed_error_tab(i).BOM_HEAD_ST_TBL );
			END LOOP;
		CLOSE c_gen_error;
	v_step := 5;
	
	EXCEPTION
		WHEN OTHERS THEN
		  v_mess := 'At step ['||v_step||'] - SQLCODE [' ||SQLCODE|| '] - ' ||substr(SQLERRM,1,100);
		  x_errbuf  := v_mess;
		  x_retcode := 2; 

   END main_proc;
		
END XXNBTY_MSCREP02_BOM_HEAD_PKG;
/

show errors;
