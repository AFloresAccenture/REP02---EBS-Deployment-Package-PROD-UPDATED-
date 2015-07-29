create or replace PACKAGE BODY       XXNBTY_MSCREP02_BOM_BICI_PKG 
 ---------------------------------------------------------------------------------------------
  /*
  Package Name	: XXNBTY_MSCREP02_BOM_BICI_PKG
  Author's Name: Albert John Flores
  Date written: 29-Jun-2015
  RICEFW Object: REP02
  Description: Package that will generate detailed error log for BOM Interface table (bom_inventory_comps_interface) using FND_FILE. 
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
				||'","'||bici.COMPONENT_ITEM_NUMBER
				||'","'||bici.BOM_ITEM_TYPE
				||'","'||bici.ASSEMBLY_ITEM_NUMBER
				||'","'||bici.ORGANIZATION_CODE
				||'","'||bici.PRIMARY_UNIT_OF_MEASURE
				||'","'||bici.EFFECTIVITY_DATE
				||'","'||bici.DISABLE_DATE
				||'","'||bici.OPERATION_SEQ_NUM
				||'","'||bici.COMPONENT_REVISION_CODE
				||'","'||bici.PARENT_REVISION_CODE
				||'","'||bici.TRANSACTION_TYPE
				||'","'||bici.ITEM_NUM
				||'","'||bici.COMPONENT_ITEM_ID
				||'","'||bici.LAST_UPDATE_DATE
				||'","'||bici.LAST_UPDATED_BY
				||'","'||bici.CREATION_DATE
				||'","'||bici.CREATED_BY
				||'","'||bici.LAST_UPDATE_LOGIN
				||'","'||bici.COMPONENT_QUANTITY
				||'","'||bici.COMPONENT_YIELD_FACTOR
				||'","'||bici.COMPONENT_REMARKS
				||'","'||bici.CHANGE_NOTICE
				||'","'||bici.IMPLEMENTATION_DATE
				||'","'||bici.ATTRIBUTE_CATEGORY
				||'","'||bici.ATTRIBUTE1
				||'","'||bici.ATTRIBUTE2
				||'","'||bici.ATTRIBUTE3
				||'","'||bici.ATTRIBUTE4
				||'","'||bici.ATTRIBUTE5
				||'","'||bici.ATTRIBUTE6
				||'","'||bici.ATTRIBUTE7
				||'","'||bici.ATTRIBUTE8
				||'","'||bici.ATTRIBUTE9
				||'","'||bici.ATTRIBUTE10
				||'","'||bici.ATTRIBUTE11
				||'","'||bici.ATTRIBUTE12
				||'","'||bici.ATTRIBUTE13
				||'","'||bici.ATTRIBUTE14
				||'","'||bici.ATTRIBUTE15
				||'","'||bici.PLANNING_FACTOR
				||'","'||bici.QUANTITY_RELATED
				||'","'||bici.SO_BASIS
				||'","'||bici.OPTIONAL
				||'","'||bici.MUTUALLY_EXCLUSIVE_OPTIONS
				||'","'||bici.INCLUDE_IN_COST_ROLLUP
				||'","'||bici.CHECK_ATP
				||'","'||bici.SHIPPING_ALLOWED
				||'","'||bici.REQUIRED_TO_SHIP
				||'","'||bici.REQUIRED_FOR_REVENUE
				||'","'||bici.INCLUDE_ON_SHIP_DOCS
				||'","'||bici.LOW_QUANTITY
				||'","'||bici.HIGH_QUANTITY
				||'","'||bici.ACD_TYPE
				||'","'||bici.OLD_COMPONENT_SEQUENCE_ID
				||'","'||bici.COMPONENT_SEQUENCE_ID
				||'","'||bici.BILL_SEQUENCE_ID
				||'","'||bici.REQUEST_ID
				||'","'||bici.PROGRAM_APPLICATION_ID
				||'","'||bici.PROGRAM_ID
				||'","'||bici.PROGRAM_UPDATE_DATE
				||'","'||bici.WIP_SUPPLY_TYPE
				||'","'||bici.SUPPLY_SUBINVENTORY
				||'","'||bici.SUPPLY_LOCATOR_ID
				||'","'||bici.REVISED_ITEM_SEQUENCE_ID
				||'","'||bici.MODEL_COMP_SEQ_ID
				||'","'||bici.ASSEMBLY_ITEM_ID
				||'","'||bici.ALTERNATE_BOM_DESIGNATOR
				||'","'||bici.ORGANIZATION_ID
				||'","'||bici.REVISED_ITEM_NUMBER
				||'","'||bici.LOCATION_NAME
				||'","'||bici.REFERENCE_DESIGNATOR
				||'","'||bici.SUBSTITUTE_COMP_ID
				||'","'||bici.SUBSTITUTE_COMP_NUMBER
				||'","'||bici.TRANSACTION_ID
				||'","'||bici.PROCESS_FLAG
				||'","'||bici.OPERATION_LEAD_TIME_PERCENT
				||'","'||bici.COST_FACTOR
				||'","'||bici.INCLUDE_ON_BILL_DOCS
				||'","'||bici.PICK_COMPONENTS
				||'","'||bici.DDF_CONTEXT1
				||'","'||bici.DDF_CONTEXT2
				||'","'||bici.NEW_OPERATION_SEQ_NUM
				||'","'||bici.OLD_OPERATION_SEQ_NUM
				||'","'||bici.NEW_EFFECTIVITY_DATE
				||'","'||bici.OLD_EFFECTIVITY_DATE
				||'","'||bici.ASSEMBLY_TYPE
				||'","'||bici.INTERFACE_ENTITY_TYPE
				||'","'||bici.BOM_INVENTORY_COMPS_IFCE_KEY
				||'","'||bici.ENG_REVISED_ITEMS_IFCE_KEY
				||'","'||bici.ENG_CHANGES_IFCE_KEY
				||'","'||bici.TO_END_ITEM_UNIT_NUMBER
				||'","'||bici.FROM_END_ITEM_UNIT_NUMBER
				||'","'||bici.NEW_FROM_END_ITEM_UNIT_NUMBER
				||'","'||bici.DELETE_GROUP_NAME
				||'","'||bici.DG_DESCRIPTION
				||'","'||bici.ORIGINAL_SYSTEM_REFERENCE
				||'","'||bici.ENFORCE_INT_REQUIREMENTS
				||'","'||bici.OPTIONAL_ON_MODEL
				||'","'||bici.PARENT_BILL_SEQ_ID
				||'","'||bici.PLAN_LEVEL
				||'","'||bici.AUTO_REQUEST_MATERIAL
				||'","'||bici.SUGGESTED_VENDOR_NAME
				||'","'||bici.UNIT_PRICE
				||'","'||bici.NEW_REVISED_ITEM_REVISION
				||'","'||bici.BASIS_TYPE
				||'","'||bici.INVERSE_QUANTITY
				||'","'||bici.OBJ_NAME
				||'","'||bici.PK1_VALUE
				||'","'||bici.PK2_VALUE
				||'","'||bici.PK3_VALUE
				||'","'||bici.PK4_VALUE
				||'","'||bici.PK5_VALUE
				||'","'||bici.FROM_OBJECT_REVISION_CODE
				||'","'||bici.FROM_OBJECT_REVISION_ID
				||'","'||bici.TO_OBJECT_REVISION_CODE
				||'","'||bici.TO_OBJECT_REVISION_ID
				||'","'||bici.FROM_MINOR_REVISION_CODE
				||'","'||bici.FROM_MINOR_REVISION_ID
				||'","'||bici.TO_MINOR_REVISION_CODE
				||'","'||bici.TO_MINOR_REVISION_ID
				||'","'||bici.FROM_END_ITEM_MINOR_REV_CODE
				||'","'||bici.FROM_END_ITEM_MINOR_REV_ID
				||'","'||bici.TO_END_ITEM_MINOR_REV_CODE
				||'","'||bici.TO_END_ITEM_MINOR_REV_ID
				||'","'||bici.RETURN_STATUS
				||'","'||bici.FROM_END_ITEM
				||'","'||bici.FROM_END_ITEM_ID
				||'","'||bici.FROM_END_ITEM_REV_CODE
				||'","'||bici.FROM_END_ITEM_REV_ID
				||'","'||bici.TO_END_ITEM_REV_CODE
				||'","'||bici.TO_END_ITEM_REV_ID
				||'","'||bici.COMPONENT_REVISION_ID
				||'","'||bici.BATCH_ID
				||'","'||bici.COMP_SOURCE_SYSTEM_REFERENCE
				||'","'||bici.COMP_SOURCE_SYSTEM_REFER_DESC
				||'","'||bici.PARENT_SOURCE_SYSTEM_REFERENCE
				||'","'||bici.CATALOG_CATEGORY_NAME
				||'","'||bici.ITEM_CATALOG_GROUP_ID
				||'","'||bici.CHANGE_ID
				||'","'||bici.TEMPLATE_NAME
				||'","'||bici.ITEM_DESCRIPTION
				||'","'||bici.COMMON_COMPONENT_SEQUENCE_ID
				||'","'||bici.CHANGE_TRANSACTION_TYPE
				||'","'||bici.INTERFACE_TABLE_UNIQUE_ID
				||'","'||bici.PARENT_REVISION_ID
				||'","'||bici.BUNDLE_ID||'"'  BOM_BICI_INT_TBL
				FROM bom_inventory_comps_interface bici, mtl_interface_errors mie 
				WHERE bici.process_flag = 3 AND bici.transaction_id = mie.transaction_id  AND abs(bici.request_id) >= p_main_request_id;
						
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
     v_header := v_header || 'ERROR_MESSAGE,COMPONENT_ITEM_NUMBER,BOM_ITEM_TYPE,ASSEMBLY_ITEM_NUMBER,ORGANIZATION_CODE,PRIMARY_UNIT_OF_MEASURE,';
	 v_header := v_header || 'EFFECTIVITY_DATE,DISABLE_DATE,OPERATION_SEQ_NUM,COMPONENT_REVISION_CODE,PARENT_REVISION_CODE,TRANSACTION_TYPE,';
	 v_header := v_header || 'ITEM_NUM,COMPONENT_ITEM_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,';
	 v_header := v_header || 'COMPONENT_QUANTITY,COMPONENT_YIELD_FACTOR,COMPONENT_REMARKS,CHANGE_NOTICE,IMPLEMENTATION_DATE,ATTRIBUTE_CATEGORY,';
	 v_header := v_header || 'ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,';
	 v_header := v_header || 'ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,PLANNING_FACTOR,QUANTITY_RELATED,SO_BASIS,OPTIONAL,';
	 v_header := v_header || 'MUTUALLY_EXCLUSIVE_OPTIONS,INCLUDE_IN_COST_ROLLUP,CHECK_ATP,SHIPPING_ALLOWED,REQUIRED_TO_SHIP,REQUIRED_FOR_REVENUE,';
	 v_header := v_header || 'INCLUDE_ON_SHIP_DOCS,LOW_QUANTITY,HIGH_QUANTITY,ACD_TYPE,OLD_COMPONENT_SEQUENCE_ID,COMPONENT_SEQUENCE_ID,';
	 v_header := v_header || 'BILL_SEQUENCE_ID,REQUEST_ID,PROGRAM_APPLICATION_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE,WIP_SUPPLY_TYPE,';
	 v_header := v_header || 'SUPPLY_SUBINVENTORY,SUPPLY_LOCATOR_ID,REVISED_ITEM_SEQUENCE_ID,MODEL_COMP_SEQ_ID,ASSEMBLY_ITEM_ID,';
	 v_header := v_header || 'ALTERNATE_BOM_DESIGNATOR,ORGANIZATION_ID,REVISED_ITEM_NUMBER,LOCATION_NAME,REFERENCE_DESIGNATOR,SUBSTITUTE_COMP_ID,';
	 v_header := v_header || 'SUBSTITUTE_COMP_NUMBER,TRANSACTION_ID,PROCESS_FLAG,OPERATION_LEAD_TIME_PERCENT,COST_FACTOR,INCLUDE_ON_BILL_DOCS,';
	 v_header := v_header || 'PICK_COMPONENTS,DDF_CONTEXT1,DDF_CONTEXT2,NEW_OPERATION_SEQ_NUM,OLD_OPERATION_SEQ_NUM,NEW_EFFECTIVITY_DATE,';
	 v_header := v_header || 'OLD_EFFECTIVITY_DATE,ASSEMBLY_TYPE,INTERFACE_ENTITY_TYPE,BOM_INVENTORY_COMPS_IFCE_KEY,ENG_REVISED_ITEMS_IFCE_KEY,';
	 v_header := v_header || 'ENG_CHANGES_IFCE_KEY,TO_END_ITEM_UNIT_NUMBER,FROM_END_ITEM_UNIT_NUMBER,NEW_FROM_END_ITEM_UNIT_NUMBER,DELETE_GROUP_NAME,';
	 v_header := v_header || 'DG_DESCRIPTION,ORIGINAL_SYSTEM_REFERENCE,ENFORCE_INT_REQUIREMENTS,OPTIONAL_ON_MODEL,PARENT_BILL_SEQ_ID,PLAN_LEVEL,';
	 v_header := v_header || 'AUTO_REQUEST_MATERIAL,SUGGESTED_VENDOR_NAME,UNIT_PRICE,NEW_REVISED_ITEM_REVISION,BASIS_TYPE,INVERSE_QUANTITY,OBJ_NAME,';
	 v_header := v_header || 'PK1_VALUE,PK2_VALUE,PK3_VALUE,PK4_VALUE,PK5_VALUE,FROM_OBJECT_REVISION_CODE,FROM_OBJECT_REVISION_ID,TO_OBJECT_REVISION_CODE,';
	 v_header := v_header || 'TO_OBJECT_REVISION_ID,FROM_MINOR_REVISION_CODE,FROM_MINOR_REVISION_ID,TO_MINOR_REVISION_CODE,TO_MINOR_REVISION_ID,';
	 v_header := v_header || 'FROM_END_ITEM_MINOR_REV_CODE,FROM_END_ITEM_MINOR_REV_ID,TO_END_ITEM_MINOR_REV_CODE,TO_END_ITEM_MINOR_REV_ID,';
	 v_header := v_header || 'RETURN_STATUS,FROM_END_ITEM,FROM_END_ITEM_ID,FROM_END_ITEM_REV_CODE,FROM_END_ITEM_REV_ID,TO_END_ITEM_REV_CODE,';
	 v_header := v_header || 'TO_END_ITEM_REV_ID,COMPONENT_REVISION_ID,BATCH_ID,COMP_SOURCE_SYSTEM_REFERENCE,COMP_SOURCE_SYSTEM_REFER_DESC,';
	 v_header := v_header || 'PARENT_SOURCE_SYSTEM_REFERENCE,CATALOG_CATEGORY_NAME,ITEM_CATALOG_GROUP_ID,CHANGE_ID,TEMPLATE_NAME,ITEM_DESCRIPTION,';
	 v_header := v_header || 'COMMON_COMPONENT_SEQUENCE_ID,CHANGE_TRANSACTION_TYPE,INTERFACE_TABLE_UNIQUE_ID,PARENT_REVISION_ID,BUNDLE_ID';
		
	--	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'ERROR_MESSAGE,COMPONENT_ITEM_NUMBER,BOM_ITEM_TYPE,...
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,v_header);		
     -- drodil 17-july-2015  -- end
		
		OPEN c_gen_error(v_main_request_id);
	v_step := 4;	
		FETCH c_gen_error BULK COLLECT INTO l_detailed_error_tab;
		FOR i in 1..l_detailed_error_tab.COUNT
			LOOP
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_detailed_error_tab(i).BOM_BICI_INT_TBL );
			END LOOP;
		CLOSE c_gen_error;
	v_step := 5;
	
	EXCEPTION
		WHEN OTHERS THEN
		  v_mess := 'At step ['||v_step||'] - SQLCODE [' ||SQLCODE|| '] - ' ||substr(SQLERRM,1,100);
		  x_errbuf  := v_mess;
		  x_retcode := 2; 

   END main_proc;
		
END XXNBTY_MSCREP02_BOM_BICI_PKG;
/

show errors;
