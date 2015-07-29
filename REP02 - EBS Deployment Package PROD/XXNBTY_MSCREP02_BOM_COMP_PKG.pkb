create or replace PACKAGE BODY       XXNBTY_MSCREP02_BOM_COMP_PKG 
 ---------------------------------------------------------------------------------------------
  /*
  Package Name	: XXNBTY_MSCREP02_BOM_COMP_PKG
  Author's Name: Albert John Flores
  Date written: 29-Jun-2015
  RICEFW Object: REP02
  Description: Package that will generate detailed error log for BOM Component staging table (xxnbty_bom_components_st) using FND_FILE. 
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
				||'","'||COMPONENT_ITEM_NUMBER
				||'","'||BOM_ITEM_TYPE
				||'","'||ASSEMBLY_ITEM_NUMBER
				||'","'||ORGANIZATION_CODE
				||'","'||BOM_NAME
				||'","'||PRIMARY_UNIT_OF_MEASURE
				||'","'||EFFECTIVITY_DATE
				||'","'||DISABLE_DATE
				||'","'||OPERATION_SEQ_NUM
				||'","'||COMPONENT_REVISION_CODE
				||'","'||PARENT_REVISION_CODE
				||'","'||TRANSACTION_TYPE
				||'","'||ITEM_NUM
				||'","'||BASIS_TYPE
				||'","'||COMPONENT_QUANTITY
				||'","'||COMPONENT_ITEM_ID
				||'","'||LAST_UPDATE_DATE
				||'","'||LAST_UPDATED_BY
				||'","'||CREATION_DATE
				||'","'||CREATED_BY
				||'","'||LAST_UPDATE_LOGIN
				||'","'||COMPONENT_YIELD_FACTOR
				||'","'||COMPONENT_REMARKS
				||'","'||CHANGE_NOTICE
				||'","'||IMPLEMENTATION_DATE
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
				||'","'||PLANNING_FACTOR
				||'","'||QUANTITY_RELATED
				||'","'||SO_BASIS
				||'","'||OPTIONAL
				||'","'||MUTUALLY_EXCLUSIVE_OPTIONS
				||'","'||INCLUDE_IN_COST_ROLLUP
				||'","'||CHECK_ATP
				||'","'||SHIPPING_ALLOWED
				||'","'||REQUIRED_TO_SHIP
				||'","'||REQUIRED_FOR_REVENUE
				||'","'||INCLUDE_ON_SHIP_DOCS
				||'","'||LOW_QUANTITY
				||'","'||HIGH_QUANTITY
				||'","'||ACD_TYPE
				||'","'||OLD_COMPONENT_SEQUENCE_ID
				||'","'||COMPONENT_SEQUENCE_ID
				||'","'||BILL_SEQUENCE_ID
				||'","'||REQUEST_ID
				||'","'||PROGRAM_APPLICATION_ID
				||'","'||PROGRAM_ID
				||'","'||PROGRAM_UPDATE_DATE
				||'","'||WIP_SUPPLY_TYPE
				||'","'||SUPPLY_SUBINVENTORY
				||'","'||SUPPLY_LOCATOR_ID
				||'","'||REVISED_ITEM_SEQUENCE_ID
				||'","'||MODEL_COMP_SEQ_ID
				||'","'||ASSEMBLY_ITEM_ID
				||'","'||ALTERNATE_BOM_DESIGNATOR
				||'","'||ORGANIZATION_ID
				||'","'||REVISED_ITEM_NUMBER
				||'","'||LOCATION_NAME
				||'","'||REFERENCE_DESIGNATOR
				||'","'||SUBSTITUTE_COMP_ID
				||'","'||SUBSTITUTE_COMP_NUMBER
				||'","'||TRANSACTION_ID
				||'","'||PROCESS_FLAG
				||'","'||OPERATION_LEAD_TIME_PERCENT
				||'","'||COST_FACTOR
				||'","'||INCLUDE_ON_BILL_DOCS
				||'","'||PICK_COMPONENTS
				||'","'||DDF_CONTEXT1
				||'","'||DDF_CONTEXT2
				||'","'||NEW_OPERATION_SEQ_NUM
				||'","'||OLD_OPERATION_SEQ_NUM
				||'","'||NEW_EFFECTIVITY_DATE
				||'","'||OLD_EFFECTIVITY_DATE
				||'","'||ASSEMBLY_TYPE
				||'","'||INTERFACE_ENTITY_TYPE
				||'","'||BOM_INVENTORY_COMPS_IFCE_KEY
				||'","'||ENG_REVISED_ITEMS_IFCE_KEY
				||'","'||ENG_CHANGES_IFCE_KEY
				||'","'||TO_END_ITEM_UNIT_NUMBER
				||'","'||FROM_END_ITEM_UNIT_NUMBER
				||'","'||NEW_FROM_END_ITEM_UNIT_NUMBER
				||'","'||DELETE_GROUP_NAME
				||'","'||DG_DESCRIPTION
				||'","'||ORIGINAL_SYSTEM_REFERENCE
				||'","'||ENFORCE_INT_REQUIREMENTS
				||'","'||OPTIONAL_ON_MODEL
				||'","'||PARENT_BILL_SEQ_ID
				||'","'||PLAN_LEVEL
				||'","'||AUTO_REQUEST_MATERIAL
				||'","'||SUGGESTED_VENDOR_NAME
				||'","'||UNIT_PRICE
				||'","'||NEW_REVISED_ITEM_REVISION
				||'","'||INVERSE_QUANTITY
				||'","'||OBJ_NAME
				||'","'||PK1_VALUE
				||'","'||PK2_VALUE
				||'","'||PK3_VALUE
				||'","'||PK4_VALUE
				||'","'||PK5_VALUE
				||'","'||FROM_OBJECT_REVISION_CODE
				||'","'||FROM_OBJECT_REVISION_ID
				||'","'||TO_OBJECT_REVISION_CODE
				||'","'||TO_OBJECT_REVISION_ID
				||'","'||FROM_MINOR_REVISION_CODE
				||'","'||FROM_MINOR_REVISION_ID
				||'","'||TO_MINOR_REVISION_CODE
				||'","'||TO_MINOR_REVISION_ID
				||'","'||FROM_END_ITEM_MINOR_REV_CODE
				||'","'||FROM_END_ITEM_MINOR_REV_ID
				||'","'||TO_END_ITEM_MINOR_REV_CODE
				||'","'||TO_END_ITEM_MINOR_REV_ID
				||'","'||RETURN_STATUS
				||'","'||FROM_END_ITEM
				||'","'||FROM_END_ITEM_ID
				||'","'||FROM_END_ITEM_REV_CODE
				||'","'||FROM_END_ITEM_REV_ID
				||'","'||TO_END_ITEM_REV_CODE
				||'","'||TO_END_ITEM_REV_ID
				||'","'||COMPONENT_REVISION_ID
				||'","'||BATCH_ID
				||'","'||COMP_SOURCE_SYSTEM_REFERENCE
				||'","'||COMP_SOURCE_SYSTEM_REFER_DESC
				||'","'||PARENT_SOURCE_SYSTEM_REFERENCE
				||'","'||CATALOG_CATEGORY_NAME
				||'","'||ITEM_CATALOG_GROUP_ID
				||'","'||CHANGE_ID
				||'","'||TEMPLATE_NAME
				||'","'||ITEM_DESCRIPTION
				||'","'||COMMON_COMPONENT_SEQUENCE_ID
				||'","'||CHANGE_TRANSACTION_TYPE
				||'","'||INTERFACE_TABLE_UNIQUE_ID
				||'","'||PARENT_REVISION_ID
				||'","'||BUNDLE_ID||'"'  BOM_COMP_ST_TBL
				FROM xxnbty_bom_components_st 
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
     v_header := v_header || 'ERROR_DESCRIPTION,COMPONENT_ITEM_NUMBER,BOM_ITEM_TYPE,ASSEMBLY_ITEM_NUMBER,ORGANIZATION_CODE,BOM_NAME,PRIMARY_UNIT_OF_MEASURE,';
	 v_header := v_header || 'EFFECTIVITY_DATE,DISABLE_DATE,OPERATION_SEQ_NUM,COMPONENT_REVISION_CODE,PARENT_REVISION_CODE,TRANSACTION_TYPE,ITEM_NUM,';
	 v_header := v_header || 'BASIS_TYPE,COMPONENT_QUANTITY,COMPONENT_ITEM_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,';
	 v_header := v_header || 'COMPONENT_YIELD_FACTOR,COMPONENT_REMARKS,CHANGE_NOTICE,IMPLEMENTATION_DATE,ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,';
	 v_header := v_header || 'ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,';
	 v_header := v_header || 'ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,PLANNING_FACTOR,QUANTITY_RELATED,SO_BASIS,OPTIONAL,MUTUALLY_EXCLUSIVE_OPTIONS,';
	 v_header := v_header || 'INCLUDE_IN_COST_ROLLUP,CHECK_ATP,SHIPPING_ALLOWED,REQUIRED_TO_SHIP,REQUIRED_FOR_REVENUE,INCLUDE_ON_SHIP_DOCS,LOW_QUANTITY,';
	 v_header := v_header || 'HIGH_QUANTITY,ACD_TYPE,OLD_COMPONENT_SEQUENCE_ID,COMPONENT_SEQUENCE_ID,BILL_SEQUENCE_ID,REQUEST_ID,PROGRAM_APPLICATION_ID,';
	 v_header := v_header || 'PROGRAM_ID,PROGRAM_UPDATE_DATE,WIP_SUPPLY_TYPE,SUPPLY_SUBINVENTORY,SUPPLY_LOCATOR_ID,REVISED_ITEM_SEQUENCE_ID,MODEL_COMP_SEQ_ID,';
	 v_header := v_header || 'ASSEMBLY_ITEM_ID,ALTERNATE_BOM_DESIGNATOR,ORGANIZATION_ID,REVISED_ITEM_NUMBER,LOCATION_NAME,REFERENCE_DESIGNATOR,';
	 v_header := v_header || 'SUBSTITUTE_COMP_ID,SUBSTITUTE_COMP_NUMBER,TRANSACTION_ID,PROCESS_FLAG,OPERATION_LEAD_TIME_PERCENT,COST_FACTOR,';
	 v_header := v_header || 'INCLUDE_ON_BILL_DOCS,PICK_COMPONENTS,DDF_CONTEXT1,DDF_CONTEXT2,NEW_OPERATION_SEQ_NUM,OLD_OPERATION_SEQ_NUM,';
	 v_header := v_header || 'NEW_EFFECTIVITY_DATE,OLD_EFFECTIVITY_DATE,ASSEMBLY_TYPE,INTERFACE_ENTITY_TYPE,BOM_INVENTORY_COMPS_IFCE_KEY,';
	 v_header := v_header || 'ENG_REVISED_ITEMS_IFCE_KEY,ENG_CHANGES_IFCE_KEY,TO_END_ITEM_UNIT_NUMBER,FROM_END_ITEM_UNIT_NUMBER,';
	 v_header := v_header || 'NEW_FROM_END_ITEM_UNIT_NUMBER,DELETE_GROUP_NAME,DG_DESCRIPTION,ORIGINAL_SYSTEM_REFERENCE,ENFORCE_INT_REQUIREMENTS,';
	 v_header := v_header || 'OPTIONAL_ON_MODEL,PARENT_BILL_SEQ_ID,PLAN_LEVEL,AUTO_REQUEST_MATERIAL,SUGGESTED_VENDOR_NAME,UNIT_PRICE,';
	 v_header := v_header || 'NEW_REVISED_ITEM_REVISION,INVERSE_QUANTITY,OBJ_NAME,PK1_VALUE,PK2_VALUE,PK3_VALUE,PK4_VALUE,PK5_VALUE,';
	 v_header := v_header || 'FROM_OBJECT_REVISION_CODE,FROM_OBJECT_REVISION_ID,TO_OBJECT_REVISION_CODE,TO_OBJECT_REVISION_ID,FROM_MINOR_REVISION_CODE,';
	 v_header := v_header || 'FROM_MINOR_REVISION_ID,TO_MINOR_REVISION_CODE,TO_MINOR_REVISION_ID,FROM_END_ITEM_MINOR_REV_CODE,FROM_END_ITEM_MINOR_REV_ID,';
	 v_header := v_header || 'TO_END_ITEM_MINOR_REV_CODE,TO_END_ITEM_MINOR_REV_ID,RETURN_STATUS,FROM_END_ITEM,FROM_END_ITEM_ID,FROM_END_ITEM_REV_CODE,';
	 v_header := v_header || 'FROM_END_ITEM_REV_ID,TO_END_ITEM_REV_CODE,TO_END_ITEM_REV_ID,COMPONENT_REVISION_ID,BATCH_ID,COMP_SOURCE_SYSTEM_REFERENCE,';
	 v_header := v_header || 'COMP_SOURCE_SYSTEM_REFER_DESC,PARENT_SOURCE_SYSTEM_REFERENCE,CATALOG_CATEGORY_NAME,ITEM_CATALOG_GROUP_ID,CHANGE_ID,';
	 v_header := v_header || 'TEMPLATE_NAME,ITEM_DESCRIPTION,COMMON_COMPONENT_SEQUENCE_ID,CHANGE_TRANSACTION_TYPE,INTERFACE_TABLE_UNIQUE_ID,';
	 v_header := v_header || 'PARENT_REVISION_ID,BUNDLE_ID';
		
	--	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'ERROR_DESCRIPTION,COMPONENT_ITEM_NUMBER,BOM_ITEM_TYPE,...
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,v_header);		
     -- drodil 17-july-2015  -- end
		
		OPEN c_gen_error(v_main_request_id);
	v_step := 4;	
		FETCH c_gen_error BULK COLLECT INTO l_detailed_error_tab;
		FOR i in 1..l_detailed_error_tab.COUNT
			LOOP
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_detailed_error_tab(i).BOM_COMP_ST_TBL );
			END LOOP;
		CLOSE c_gen_error;
	v_step := 5;
	
	EXCEPTION
		WHEN OTHERS THEN
		  v_mess := 'At step ['||v_step||'] - SQLCODE [' ||SQLCODE|| '] - ' ||substr(SQLERRM,1,100);
		  x_errbuf  := v_mess;
		  x_retcode := 2; 

   END main_proc;
		
END XXNBTY_MSCREP02_BOM_COMP_PKG;
/

show errors;
