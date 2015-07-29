create or replace PACKAGE BODY       XXNBTY_MSCREP02_BOM_BBMI_PKG 
 ---------------------------------------------------------------------------------------------
  /*
  Package Name	: XXNBTY_MSCREP02_BOM_BBMI_PKG
  Author's Name: Albert John Flores
  Date written: 29-Jun-2015
  RICEFW Object: REP02
  Description: Package that will generate detailed error log for BOM Interface table (bom_bill_of_mtls_interface) using FND_FILE. 
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
		SELECT '"'||mie.ERROR_MESSAGE
				||'","'||bbmi.ITEM_NUMBER
				||'","'||bbmi.ORGANIZATION_CODE
				||'","'||bbmi.PRIMARY_UNIT_OF_MEASURE
				||'","'||bbmi.TRANSACTION_TYPE
				||'","'||bbmi.ASSEMBLY_ITEM_ID
				||'","'||bbmi.ORGANIZATION_ID
				||'","'||bbmi.ALTERNATE_BOM_DESIGNATOR
				||'","'||bbmi.LAST_UPDATE_DATE
				||'","'||bbmi.LAST_UPDATED_BY
				||'","'||bbmi.CREATION_DATE
				||'","'||bbmi.CREATED_BY
				||'","'||bbmi.LAST_UPDATE_LOGIN
				||'","'||bbmi.COMMON_ASSEMBLY_ITEM_ID
				||'","'||bbmi.SPECIFIC_ASSEMBLY_COMMENT
				||'","'||bbmi.PENDING_FROM_ECN
				||'","'||bbmi.ATTRIBUTE_CATEGORY
				||'","'||bbmi.ATTRIBUTE1
				||'","'||bbmi.ATTRIBUTE2
				||'","'||bbmi.ATTRIBUTE3
				||'","'||bbmi.ATTRIBUTE4
				||'","'||bbmi.ATTRIBUTE5
				||'","'||bbmi.ATTRIBUTE6
				||'","'||bbmi.ATTRIBUTE7
				||'","'||bbmi.ATTRIBUTE8
				||'","'||bbmi.ATTRIBUTE9
				||'","'||bbmi.ATTRIBUTE10
				||'","'||bbmi.ATTRIBUTE11
				||'","'||bbmi.ATTRIBUTE12
				||'","'||bbmi.ATTRIBUTE13
				||'","'||bbmi.ATTRIBUTE14
				||'","'||bbmi.ATTRIBUTE15
				||'","'||bbmi.ASSEMBLY_TYPE
				||'","'||bbmi.COMMON_BILL_SEQUENCE_ID
				||'","'||bbmi.BILL_SEQUENCE_ID
				||'","'||bbmi.REQUEST_ID
				||'","'||bbmi.PROGRAM_APPLICATION_ID
				||'","'||bbmi.PROGRAM_ID
				||'","'||bbmi.PROGRAM_UPDATE_DATE
				||'","'||bbmi.DEMAND_SOURCE_LINE
				||'","'||bbmi.SET_ID
				||'","'||bbmi.COMMON_ORGANIZATION_ID
				||'","'||bbmi.DEMAND_SOURCE_TYPE
				||'","'||bbmi.DEMAND_SOURCE_HEADER_ID
				||'","'||bbmi.TRANSACTION_ID
				||'","'||bbmi.PROCESS_FLAG
				||'","'||bbmi.COMMON_ORG_CODE
				||'","'||bbmi.COMMON_ITEM_NUMBER
				||'","'||bbmi.NEXT_EXPLODE_DATE
				||'","'||bbmi.REVISION
				||'","'||bbmi.DELETE_GROUP_NAME
				||'","'||bbmi.DG_DESCRIPTION
				||'","'||bbmi.ORIGINAL_SYSTEM_REFERENCE
				||'","'||bbmi.IMPLEMENTATION_DATE
				||'","'||bbmi.OBJ_NAME
				||'","'||bbmi.PK1_VALUE
				||'","'||bbmi.PK2_VALUE
				||'","'||bbmi.PK3_VALUE
				||'","'||bbmi.PK4_VALUE
				||'","'||bbmi.PK5_VALUE
				||'","'||bbmi.STRUCTURE_TYPE_NAME
				||'","'||bbmi.STRUCTURE_TYPE_ID
				||'","'||bbmi.EFFECTIVITY_CONTROL
				||'","'||bbmi.RETURN_STATUS
				||'","'||bbmi.IS_PREFERRED
				||'","'||bbmi.SOURCE_SYSTEM_REFERENCE
				||'","'||bbmi.SOURCE_SYSTEM_REFERENCE_DESC
				||'","'||bbmi.BATCH_ID
				||'","'||bbmi.CHANGE_ID
				||'","'||bbmi.CATALOG_CATEGORY_NAME
				||'","'||bbmi.ITEM_CATALOG_GROUP_ID
				||'","'||bbmi.ITEM_DESCRIPTION
				||'","'||bbmi.TEMPLATE_NAME
				||'","'||bbmi.SOURCE_BILL_SEQUENCE_ID
				||'","'||bbmi.ENABLE_ATTRS_UPDATE
				||'","'||bbmi.INTERFACE_TABLE_UNIQUE_ID
				||'","'||bbmi.BUNDLE_ID||'"'  BOM_BBMI_INT_TBL
				FROM bom_bill_of_mtls_interface bbmi, mtl_interface_errors mie
				WHERE bbmi.process_flag = 3 AND bbmi.transaction_id = mie.transaction_id AND abs(bbmi.request_id) >= p_main_request_id;
						
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
     v_header := v_header || 'ERROR_MESSAGE,ITEM_NUMBER,ORGANIZATION_CODE,PRIMARY_UNIT_OF_MEASURE,TRANSACTION_TYPE,ASSEMBLY_ITEM_ID,ORGANIZATION_ID,';
	 v_header := v_header || 'ALTERNATE_BOM_DESIGNATOR,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,';
	 v_header := v_header || 'COMMON_ASSEMBLY_ITEM_ID,SPECIFIC_ASSEMBLY_COMMENT,PENDING_FROM_ECN,ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,';
	 v_header := v_header || 'ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,';
	 v_header := v_header || 'ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,ASSEMBLY_TYPE,COMMON_BILL_SEQUENCE_ID,BILL_SEQUENCE_ID,';
	 v_header := v_header || 'REQUEST_ID,PROGRAM_APPLICATION_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE,DEMAND_SOURCE_LINE,SET_ID,COMMON_ORGANIZATION_ID,';
	 v_header := v_header || 'DEMAND_SOURCE_TYPE,DEMAND_SOURCE_HEADER_ID,TRANSACTION_ID,PROCESS_FLAG,COMMON_ORG_CODE,COMMON_ITEM_NUMBER,';
	 v_header := v_header || 'NEXT_EXPLODE_DATE,REVISION,DELETE_GROUP_NAME,DG_DESCRIPTION,ORIGINAL_SYSTEM_REFERENCE,IMPLEMENTATION_DATE,';
	 v_header := v_header || 'OBJ_NAME,PK1_VALUE,PK2_VALUE,PK3_VALUE,PK4_VALUE,PK5_VALUE,STRUCTURE_TYPE_NAME,STRUCTURE_TYPE_ID,EFFECTIVITY_CONTROL,';
	 v_header := v_header || 'RETURN_STATUS,IS_PREFERRED,SOURCE_SYSTEM_REFERENCE,SOURCE_SYSTEM_REFERENCE_DESC,BATCH_ID,CHANGE_ID,';
	 v_header := v_header || 'CATALOG_CATEGORY_NAME,ITEM_CATALOG_GROUP_ID,ITEM_DESCRIPTION,TEMPLATE_NAME,SOURCE_BILL_SEQUENCE_ID,ENABLE_ATTRS_UPDATE,';
	 v_header := v_header || 'INTERFACE_TABLE_UNIQUE_ID,BUNDLE_ID';
	 
		
	--	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'ERROR_MESSAGE,ITEM_NUMBER,ORGANIZATION_CODE,...
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,v_header);		
     -- drodil 17-july-2015  -- end
		
		OPEN c_gen_error(v_main_request_id);
	v_step := 4;	
		FETCH c_gen_error BULK COLLECT INTO l_detailed_error_tab;
		FOR i in 1..l_detailed_error_tab.COUNT
			LOOP
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_detailed_error_tab(i).BOM_BBMI_INT_TBL );
			END LOOP;
		CLOSE c_gen_error;
	v_step := 5;
	
	EXCEPTION
		WHEN OTHERS THEN
		  v_mess := 'At step ['||v_step||'] - SQLCODE [' ||SQLCODE|| '] - ' ||substr(SQLERRM,1,100);
		  x_errbuf  := v_mess;
		  x_retcode := 2; 

   END main_proc;
		
END XXNBTY_MSCREP02_BOM_BBMI_PKG;
/

show errors;
