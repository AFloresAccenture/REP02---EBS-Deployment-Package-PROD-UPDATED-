--------------------------------------------------------
--  File created - Monday-December-29-2014   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body XXNBTY_EBS_SEND_EMAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "APPS"."XXNBTY_EBS_SEND_EMAIL_PKG" 

----------------------------------------------------------------------------------------------
/*
Package Name: XXNBTY_EBS_SEND_EMAIL_PKG
Author's Name: Mark Anthony Geamoga
Date written: 12/19/2014
RICEFW Object: N/A
Description: Package will generate an error output file for all or specific VCP/EBS RICEFW. 
             This output file will be sent to identified recipient(s) using UNIX program.
Program Style: 

Maintenance History: 

Date			Issue#		Name					Remarks	
-----------		------		-----------				------------------------------------------------
19-Dec-2014				 	Mark Anthony Geamoga	Initial Development
15-Apr-2015		 151 		Erwin Ramos				Update the generate_email procedure to resolved the defect 151 email verbiage.
													Changed the SQLCODE to 2
													Add the UPPER command in the p_allow_send_if_no_error to change into not to be case sensitive.
23-Apr-2015		170			Erwin Ramos				Update the v_query.EXTEND() to resolved defect 170. It will get the current error records only.
29-Apr-2015		170	   		Erwin Ramos				Added the CURSOR c1, v_main_request_id, v_child_request_id in the generate line to fixed defect #170 and INC960237. This will get the parent_request_id of the concurrent program.  
29-Jun-2015					Albert John Flores		REP02
22-Jul-2015		   			Albert John Flores		Removed the creation_date = sysdate in the where clause of the query
*/
--------------------------------------------------------------------------------------------




IS
  --main procedure that will call another procedure to generate error log
  PROCEDURE send_email_main (x_retcode             OUT VARCHAR2, 
                             x_errbuf              OUT VARCHAR2,
                             p_ricefw_name            VARCHAR2,
                             p_allow_send_if_no_error VARCHAR2)
  IS 
    v_request_id    			NUMBER := fnd_global.conc_request_id; 
	v_batch_req_id 	   	   		NUMBER; --Request id for batch detailed error report               --Start 6/29/2015 AFlores
	v_cust_stg_req_id 	   		NUMBER; --Request id for customer staging detailed error report    
	v_cust_int_req_id  	   		NUMBER; --Request id for customer interface detailed error report  
	v_frmla_mtl_req_id			NUMBER; --Request id for formula mtl detailed error report         
	v_frmla_mst_req_id			NUMBER; --Request id for formula mst detailed error report         
	v_frmla_upl_req_id			NUMBER; --Request id for formula upl detailed error report         
	v_bom_comp_req_id			NUMBER; --Request id for bom comp detailed error report            
	v_bom_head_req_id			NUMBER; --Request id for bom head detailed error report            
	v_bom_bici_req_id			NUMBER; --Request id for bom bici detailed error report            
	v_bom_bbmi_req_id			NUMBER; --Request id for bom bbmi detailed error report            --End 6/29/2015 AFlores
    v_max_length    			NUMBER;
    v_side_length   			NUMBER;
    v_new_filename  			VARCHAR2(200);
    v_old_filename  			VARCHAR2(1000);
    v_int02_old_filename   		VARCHAR2(1000); --Start 6/29/2015 AFlores
    v_int06_stg_old_filename   	VARCHAR2(1000); 
    v_int06_int_old_filename   	VARCHAR2(1000); 
	v_conv03_mtl_old_filename   VARCHAR2(1000); 
	v_conv03_mst_old_filename	VARCHAR2(1000); 
	v_conv03_upl_old_filename	VARCHAR2(1000); 
	v_lf08_comp_old_filename	VARCHAR2(1000); 
	v_lf08_head_old_filename    VARCHAR2(1000); 
	v_lf08_bici_old_filename    VARCHAR2(1000); 
	v_lf08_bbmi_old_filename    VARCHAR2(1000); --End 6/29/2015 AFlores
    v_query         			VARCHAR2(4000);
    v_report_title  			VARCHAR2(200);
    v_report_footer 			VARCHAR2(200);
    v_lookup_name   			VARCHAR2(100);
	
	CURSOR c_get_file ( p_det_req_id       NUMBER)
	IS
	SELECT outfile_name
      FROM fnd_concurrent_requests
     WHERE request_id = p_det_req_id;	

  BEGIN
    
    IF p_ricefw_name IN ('ALL_VCP_RICEFW', 'ON_HAND_DATA', 'IN_TRANSIT', 'WORK_ORDERS', 'WIP', 'SALES_ORDERS', 'ITEM_COSTS') THEN
      --retrieve width of report for specific or all VCP RICEFW
      v_query := 'SELECT MAX(NVL(maximum_length, 0)) + 16
                    FROM (
                      SELECT MAX(LENGTH(error_text)) maximum_length 
                        FROM MSC_ST_SUPPLIES
                       WHERE process_flag = 3 AND order_type = 18 AND TRUNC(creation_date) = TRUNC(SYSDATE) 
                         AND DECODE(''' || p_ricefw_name || ''',''ALL_VCP_RICEFW'',1,''ON_HAND_DATA'',1,0) = 1
                    UNION
                      SELECT MAX(LENGTH(error_text)) maximum_length 
                        FROM MSC_ST_SUPPLIES
                       WHERE process_flag = 3 AND order_type = 11 AND TRUNC(creation_date) = TRUNC(SYSDATE) 
                         AND DECODE(''' || p_ricefw_name || ''',''ALL_VCP_RICEFW'',1,''IN_TRANSIT'',1,0) = 1
                    UNION
                      SELECT MAX(LENGTH(error_text)) maximum_length 
                        FROM MSC_ST_SUPPLIES
                       WHERE process_flag = 3 AND order_type = 3 AND TRUNC(creation_date) = TRUNC(SYSDATE) 
                         AND DECODE(''' || p_ricefw_name || ''',''ALL_VCP_RICEFW'',1,''WORK_ORDERS'',1,0) = 1
                    UNION
                      SELECT MAX(LENGTH(error_text)) maximum_length 
                        FROM MSC_ST_DEMANDS
                       WHERE process_flag = 3 AND TRUNC(creation_date) = TRUNC(SYSDATE) 
                         AND DECODE(''' || p_ricefw_name || ''',''ALL_VCP_RICEFW'',1,''WIP'',1,0) = 1
                    UNION
                      SELECT MAX(LENGTH(error_text)) maximum_length 
                        FROM MSC_ST_SALES_ORDERS
                       WHERE process_flag = 3 AND TRUNC(creation_date) = TRUNC(SYSDATE) 
                         AND DECODE(''' || p_ricefw_name || ''',''ALL_VCP_RICEFW'',1,''SALES_ORDERS'',1,0) = 1
                    UNION
                      SELECT MAX(LENGTH(error_description)) maximum_length 
                        FROM XXMSC_CUS_COST_TBL
                       WHERE status = ''E'' AND TRUNC(creation_date) = TRUNC(SYSDATE) 
                         AND DECODE(''' || p_ricefw_name || ''',''ALL_VCP_RICEFW'',1,''ITEM_COSTS'',1,0) = 1
                    )';
      v_lookup_name := 'XXNBTY_VCP_COLL_REP_ADD_LKP';              
      
    ELSIF p_ricefw_name IN ('ALL_EBS_RICEFW', 'BOM', 'FORMULA', 'BATCH', 'CUSTOMER_INTERFACE') THEN
      --retrieve width of report for specific or all EBS RICEFW
      v_query := 'SELECT MAX(NVL(maximum_length, 0)) + 16
                    FROM (
                      SELECT MAX(LENGTH(error_description)) maximum_length 
                        FROM xxnbty_bom_components_st 
                       WHERE process_flag = 3 AND TRUNC(creation_date) = TRUNC(SYSDATE) 
                         AND DECODE(''' || p_ricefw_name || ''',''ALL_EBS_RICEFW'',1,''BOM'',1,0) = 1
                    UNION
                      SELECT MAX(LENGTH(error_description)) maximum_length 
                        FROM xxnbty_bom_headers_st 
                       WHERE process_flag = 3 AND TRUNC(creation_date) = TRUNC(SYSDATE) 
                         AND DECODE(''' || p_ricefw_name || ''',''ALL_EBS_RICEFW'',1,''BOM'',1,0) = 1
                    UNION
                      SELECT MAX(LENGTH(error_text)) maximum_length 
                        FROM xxnbty_opm_matl_dtl_st 
                       WHERE status NOT IN (''P'', ''V'') 
                         AND DECODE(''' || p_ricefw_name || ''',''ALL_EBS_RICEFW'',1,''FORMULA'',1,0) = 1
                    UNION
                      SELECT MAX(LENGTH(error_text)) maximum_length 
                        FROM xxnbty_opm_form_mst_st 
                       WHERE status NOT IN (''P'', ''V'') 
                         AND DECODE(''' || p_ricefw_name || ''',''ALL_EBS_RICEFW'',1,''FORMULA'',1,0) = 1
                    UNION
                      SELECT MAX(LENGTH(attribute30)) maximum_length 
                        FROM xxnbty_opm_formula_upload
                       WHERE attribute29 NOT IN (''P'', ''V'') AND TRUNC(creation_date) = TRUNC(SYSDATE) 
                         AND DECODE(''' || p_ricefw_name || ''',''ALL_EBS_RICEFW'',1,''FORMULA'',1,0) = 1
                    UNION
                      SELECT MAX(LENGTH(error_description)) maximum_length 
                        FROM xxnbty_opm_batches_st 
                       WHERE error_description IS NOT NULL AND TRUNC(creation_date) = TRUNC(SYSDATE) 
                         AND DECODE(''' || p_ricefw_name || ''',''ALL_EBS_RICEFW'',1,''BATCH'',1,0) = 1
                    UNION
                      SELECT MAX(LENGTH(error_message)) maximum_length 
                        FROM xxnbty_ar_customers_st 
                       WHERE process_flag = ''E'' AND TRUNC(creation_date) = TRUNC(SYSDATE) 
                         AND DECODE(''' || p_ricefw_name || ''',''ALL_EBS_RICEFW'',1,''CUSTOMER_INTERFACE'',1,0) = 1
                    )';
      v_lookup_name := 'XXNBTY_EBS_COLL_REP_ADD_LKP';              
    END IF;
    
    --retrive report width
    EXECUTE IMMEDIATE v_query INTO v_max_length;   
    
    --set default width of report to 100
    IF NVL(v_max_length,99) < 100 THEN
      v_max_length := 100;
    END IF;
  
    --get new filename of the output file
    v_new_filename := 'XXNBTY_' || p_ricefw_name || '_' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '.txt';
    
    --get report title
    v_report_title := 'SUMMARY REPORT FOR ' || p_ricefw_name;
    
    v_side_length := TRUNC((v_max_length - LENGTH(v_report_title)) / 2);
    
    --display header of the output file
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  ' || RPAD(RTRIM(v_new_filename, '.txt'), v_max_length - 17, ' ') || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM') || '  ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,LPAD(' ', v_side_length + 4, ' ') || v_report_title);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
    
    IF p_ricefw_name = 'ALL_VCP_RICEFW' THEN --generate output file for all ricefw in VCP
      generate_err_log(x_retcode, x_errbuf, 'ON_HAND_DATA', v_max_length);
      generate_err_log(x_retcode, x_errbuf, 'IN_TRANSIT', v_max_length);
      generate_err_log(x_retcode, x_errbuf, 'WORK_ORDERS', v_max_length);
      generate_err_log(x_retcode, x_errbuf, 'WIP', v_max_length);
      generate_err_log(x_retcode, x_errbuf, 'SALES_ORDERS', v_max_length);
      generate_err_log(x_retcode, x_errbuf, 'ITEM_COSTS', v_max_length);
    ELSIF p_ricefw_name = 'ALL_EBS_RICEFW' THEN --generate output file for all ricefw in EBS
      generate_err_log(x_retcode, x_errbuf, 'BOM', v_max_length);
      generate_err_log(x_retcode, x_errbuf, 'FORMULA', v_max_length);
      generate_err_log(x_retcode, x_errbuf, 'BATCH', v_max_length);
      generate_err_log(x_retcode, x_errbuf, 'CUSTOMER_INTERFACE', v_max_length);
		  --6/29/2015 Start AFlores
          --Generate Detailed error log per object
		  --Batch
          IF g_det_batch_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'BATCH', v_batch_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling batch ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 batch: ' || v_batch_req_id); 
          END IF;
		  --Customer Staging table
          IF g_det_customer_stg_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'CUSTOMER_STAGING', v_cust_stg_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling customer staging errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 customer staging: ' || v_cust_stg_req_id); 
          END IF;	
		  --Customer Interface table
          IF g_det_customer_int_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'CUSTOMER_INTERFACE', v_cust_int_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling customer interface errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 customer interface: ' || v_cust_int_req_id); 
          END IF;	
		  --Formula xxnbty_opm_matl_dtl_st table
          IF g_det_formula_mtl_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'FORMULA_MTL', v_frmla_mtl_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling formula mtl errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 formula mtl: ' || v_frmla_mtl_req_id); 
          END IF;
		  --Formula xxnbty_opm_form_mst_st table
          IF g_det_formula_mst_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'FORMULA_MST', v_frmla_mst_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling formula mst errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 formula mst: ' || v_frmla_mst_req_id); 
          END IF;
		  --Formula xxnbty_opm_formula_upload table
          IF g_det_formula_upl_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'FORMULA_UPL', v_frmla_upl_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling formula upl errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 formula upl: ' || v_frmla_upl_req_id); 
          END IF;
		  --BOM component staging table
          IF g_det_bom_comp_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'BOM_COMP', v_bom_comp_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling BOM component staging table errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 BOM component staging table: ' || v_bom_comp_req_id); 
          END IF;		  
		  --BOM header staging table
          IF g_det_bom_head_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'BOM_HEAD', v_bom_head_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling BOM header staging table errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 BOM header staging table: ' || v_bom_head_req_id); 
          END IF;	
		  --BOM BICI interface table
          IF g_det_bom_bici_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'BOM_BICI', v_bom_bici_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling BOM BICI interface table errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 BOM BICI interface table: ' || v_bom_bici_req_id); 
          END IF;
		  --BOM BBMI interface table
          IF g_det_bom_bbmi_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'BOM_BBMI', v_bom_bbmi_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling BOM BBMI interface table errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 BOM BBMI interface table: ' || v_bom_bbmi_req_id); 
          END IF;
    ELSE --generate output file for specific ricefw
      generate_err_log(x_retcode, x_errbuf, p_ricefw_name, v_max_length);
	  
		  --6/29/2015 Start AFlores
          --Generate Detailed error log per object
		  --Batch
          IF g_det_batch_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'BATCH', v_batch_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling batch ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 batch: ' || v_batch_req_id); 
          END IF;
		  --Customer Staging table
          IF g_det_customer_stg_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'CUSTOMER_STAGING', v_cust_stg_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling customer staging errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 customer staging: ' || v_cust_stg_req_id); 
          END IF;	
		  --Customer Interface table
          IF g_det_customer_int_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'CUSTOMER_INTERFACE', v_cust_int_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling customer interface errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 customer interface: ' || v_cust_int_req_id); 
          END IF;
		  --Formula xxnbty_opm_matl_dtl_st table
          IF g_det_formula_mtl_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'FORMULA_MTL', v_frmla_mtl_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling formula mtl errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 formula mtl: ' || v_frmla_mtl_req_id); 
          END IF;
		  --Formula xxnbty_opm_form_mst_st table
          IF g_det_formula_mst_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'FORMULA_MST', v_frmla_mst_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling formula mst errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 formula mst: ' || v_frmla_mst_req_id); 
          END IF;
		  --Formula xxnbty_opm_formula_upload table
          IF g_det_formula_upl_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'FORMULA_UPL', v_frmla_upl_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling formula upl errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 formula upl: ' || v_frmla_upl_req_id); 
          END IF;
		  --BOM component staging table
          IF g_det_bom_comp_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'BOM_COMP', v_bom_comp_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling BOM component staging table errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 BOM component staging table: ' || v_bom_comp_req_id); 
          END IF;		  
		  --BOM header staging table
          IF g_det_bom_head_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'BOM_HEAD', v_bom_head_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling BOM header staging table errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 BOM header staging table: ' || v_bom_head_req_id); 
          END IF;	
		  --BOM BICI interface table
          IF g_det_bom_bici_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'BOM_BICI', v_bom_bici_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling BOM BICI interface table errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 BOM BICI interface table: ' || v_bom_bici_req_id); 
          END IF;
		  --BOM BBMI interface table
          IF g_det_bom_bbmi_with_error THEN
              generate_detailed_err_log(x_retcode, x_errbuf, 'BOM_BBMI', v_bom_bbmi_req_id); --6/29/2015 AFlores
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered REP02 Calling BOM BBMI interface table errors ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for REP02 BOM BBMI interface table: ' || v_bom_bbmi_req_id); 
          END IF;		  
		  
		  
    END IF;
    
    --get report footer
    v_report_footer := 'END OF REPORT';
    
    v_side_length := TRUNC((v_max_length - LENGTH(v_report_footer)) / 2);
    
    --display footer of the output file
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  ' || RPAD(LPAD(v_report_footer, v_side_length + LENGTH(v_report_footer), '*'), v_max_length + 6, '*') || '  ');
    
    --check if generation of output file is successful before sending email.
    IF v_request_id != 0 THEN
      
    --  IF (p_allow_send_if_no_error = 'Yes' AND NOT g_with_error_msg) --send email though output log has no error messages. 
	  IF (UPPER(p_allow_send_if_no_error )= 'YES' AND NOT g_with_error_msg) --15-Apr-2015: Add the UPPER command to change into not to be case sensitive.
         OR g_with_error_msg THEN 
		/*
        SELECT outfile_name
          INTO v_old_filename 					--6/29/2015 AFlores
          FROM fnd_concurrent_requests
         WHERE request_id = v_request_id;
		*/
		--For Error Summary old file name
		OPEN c_get_file (v_request_id);
		FETCH c_get_file INTO v_old_filename;   --6/29/2015 AFlores
		CLOSE c_get_file;
		
		--For Batch file name
		OPEN c_get_file (v_batch_req_id);		--6/29/2015 AFlores
		FETCH c_get_file INTO v_int02_old_filename;
		CLOSE c_get_file;
		v_int02_old_filename := NVL(v_int02_old_filename , 'NONE');
		
		--For Customer Staging file name
		OPEN c_get_file (v_cust_stg_req_id);		--6/29/2015 AFlores
		FETCH c_get_file INTO v_int06_stg_old_filename;
		CLOSE c_get_file;
		v_int06_stg_old_filename := NVL(v_int06_stg_old_filename , 'NONE');
		
		--For Customer Interface file name
		OPEN c_get_file (v_cust_int_req_id);		--6/29/2015 AFlores
		FETCH c_get_file INTO v_int06_int_old_filename;
		CLOSE c_get_file;
		v_int06_int_old_filename := NVL(v_int06_int_old_filename , 'NONE');
		
		--For Formula mtl file name
		OPEN c_get_file (v_frmla_mtl_req_id);		--6/29/2015 AFlores
		FETCH c_get_file INTO v_conv03_mtl_old_filename;
		CLOSE c_get_file;
		v_conv03_mtl_old_filename := NVL(v_conv03_mtl_old_filename , 'NONE');	

		--For Formula mst file name
		OPEN c_get_file (v_frmla_mst_req_id);		--6/29/2015 AFlores
		FETCH c_get_file INTO v_conv03_mst_old_filename;
		CLOSE c_get_file;
		v_conv03_mst_old_filename := NVL(v_conv03_mst_old_filename , 'NONE');	

		--For Formula upl file name
		OPEN c_get_file (v_frmla_upl_req_id);		--6/29/2015 AFlores
		FETCH c_get_file INTO v_conv03_upl_old_filename;
		CLOSE c_get_file;
		v_conv03_upl_old_filename := NVL(v_conv03_upl_old_filename , 'NONE');	

		--For BOM comp file name
		OPEN c_get_file (v_bom_comp_req_id);		--6/29/2015 AFlores
		FETCH c_get_file INTO v_lf08_comp_old_filename;
		CLOSE c_get_file;
		v_lf08_comp_old_filename := NVL(v_lf08_comp_old_filename , 'NONE');	

		--For BOM head file name
		OPEN c_get_file (v_bom_head_req_id);		--6/29/2015 AFlores
		FETCH c_get_file INTO v_lf08_head_old_filename;
		CLOSE c_get_file;
		v_lf08_head_old_filename := NVL(v_lf08_head_old_filename , 'NONE');	

		--For BOM BICI file name
		OPEN c_get_file (v_bom_bici_req_id);		--6/29/2015 AFlores
		FETCH c_get_file INTO v_lf08_bici_old_filename;
		CLOSE c_get_file;
		v_lf08_bici_old_filename := NVL(v_lf08_bici_old_filename , 'NONE');	

		--For BOM BBMI file name
		OPEN c_get_file (v_bom_bbmi_req_id);		--6/29/2015 AFlores
		FETCH c_get_file INTO v_lf08_bbmi_old_filename;
		CLOSE c_get_file;
		v_lf08_bbmi_old_filename := NVL(v_lf08_bbmi_old_filename , 'NONE');			
        
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Sending e-mail in progress...');
        generate_email(x_retcode,
                       x_errbuf,
                       p_ricefw_name,
                       v_new_filename,
                       v_old_filename,
                       v_lookup_name,
					   v_int02_old_filename,
					   v_int06_stg_old_filename,
					   v_int06_int_old_filename,
					   v_conv03_mtl_old_filename,
					   v_conv03_mst_old_filename,
					   v_conv03_upl_old_filename,
					   v_lf08_comp_old_filename,
					   v_lf08_head_old_filename,
					   v_lf08_bici_old_filename,
					   v_lf08_bbmi_old_filename);
                       
        g_with_error_msg 				:= FALSE; --reset global variable in package    
		g_det_batch_with_error  		:= FALSE; --reset global variable in package --6/29/2015 AFlores
		g_det_customer_stg_with_error	:= FALSE; --reset global variable in package --6/29/2015 AFlores
		g_det_customer_int_with_error	:= FALSE; --reset global variable in package --6/29/2015 AFlores
		g_det_formula_mtl_with_error    := FALSE; --reset global variable in package --6/29/2015 AFlores
		g_det_formula_mst_with_error    := FALSE; --reset global variable in package --6/29/2015 AFlores
		g_det_formula_upl_with_error    := FALSE; --reset global variable in package --6/29/2015 AFlores
		g_det_bom_comp_with_error       := FALSE; --reset global variable in package --6/29/2015 AFlores
		g_det_bom_head_with_error       := FALSE; --reset global variable in package --6/29/2015 AFlores
		g_det_bom_bici_with_error       := FALSE; --reset global variable in package --6/29/2015 AFlores
		g_det_bom_bbmi_with_error       := FALSE; --reset global variable in package --6/29/2015 AFlores
		
      ELSE
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Sending e-mail is off.');
      END IF;
    ELSE
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Sending e-mail failed. No error report to be sent.');
    END IF;
    
  EXCEPTION
   WHEN OTHERS THEN
      x_retcode := SQLCODE;
      x_errbuf := SQLERRM; 
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error message : ' || x_errbuf);
  END send_email_main;
  
  --procedure that will send access error log file and send it to recipients using lookups
  PROCEDURE generate_email (x_retcode   			OUT VARCHAR2, 
                            x_errbuf    			OUT VARCHAR2,
                            p_ricefw_name  				VARCHAR2,
                            p_new_filename 				VARCHAR2,
                            p_old_filename 				VARCHAR2,
                            p_lookup_name  				VARCHAR2,
							p_int02_old_filename 		VARCHAR2,
							p_int06_stg_old_filename	VARCHAR2,
							p_int06_int_old_filename    VARCHAR2,
                            p_conv03_mtl_old_filename  	VARCHAR2,
                            p_conv03_mst_old_filename  	VARCHAR2,
                            p_conv03_upl_old_filename  	VARCHAR2,
							p_lf08_comp_old_filename	VARCHAR2,
							p_lf08_head_old_filename	VARCHAR2,
							p_lf08_bici_old_filename	VARCHAR2,
							p_lf08_bbmi_old_filename	VARCHAR2)

  IS
    v_request_id    NUMBER;
    v_subject       VARCHAR2(200);
    v_message       VARCHAR2(1000);
    lp_email_to     VARCHAR2(1000);
    lp_email_to_cc  VARCHAR2(1000);
    lp_email_to_bcc VARCHAR2(1000);
    
    CURSOR c_lookup_email_ad (p_lookup_name VARCHAR2, p_tag VARCHAR2) --lookup for recipient(s)
    IS
       SELECT meaning
        FROM fnd_lookup_values
       WHERE lookup_type = p_lookup_name
         AND enabled_flag = 'Y'
         AND tag = p_tag
         AND SYSDATE BETWEEN start_date_active AND NVL(end_date_active,SYSDATE);
         
  BEGIN
  
    --check all direct recipients in lookup 
    FOR rec_send IN c_lookup_email_ad (p_lookup_name, 'TO')
    LOOP
      lp_email_to := LTRIM(lp_email_to||','||rec_send.meaning,',');
    END LOOP;
    
    --check all cc recipients in lookup 
    FOR rec_send_cc IN c_lookup_email_ad (p_lookup_name, 'CC')
    LOOP
      lp_email_to_cc := LTRIM(lp_email_to_cc||','||rec_send_cc.meaning,',');
    END LOOP;
    
    --check all bcc recipients in lookup 
    FOR rec_send_bcc IN c_lookup_email_ad (p_lookup_name, 'BCC')
    LOOP
      lp_email_to_bcc := LTRIM(lp_email_to_bcc||','||rec_send_bcc.meaning,',');
    END LOOP;
    
	IF g_with_error_msg THEN 
	
	-- 15-Apr-2015: Update the subject base on the verbiage provided.
		v_message := 'EBS_NOTIFICATION_ERROR';
	
		IF p_ricefw_name = 'ALL_EBS_RICEFW' THEN
		  v_subject := 'Supply Planning - EBS Data Collection Errors'; 
		ELSIF p_ricefw_name = 'BOM' THEN
		  v_subject := 'Supply Planning - EBS Data Collection Errors For Bill of Materials Collection Report'; 
		ELSIF p_ricefw_name = 'FORMULA' THEN
		  v_subject := 'Supply Planning - EBS Data Collection Errors For Formula/Recipe Collection Report';   
		ELSIF p_ricefw_name = 'BATCH' THEN
		  v_subject := 'Supply Planning - EBS Data Collection Errors For Batch Collection Report';  
		ELSIF p_ricefw_name = 'CUSTOMER_INTERFACE' THEN
		  v_subject := 'Supply Planning - EBS Data Collection Errors For Customer Collection Report';   
		ELSE
		   v_subject := 'Supply Planning - EBS Data Collection Errors for ' || p_ricefw_name;
		END IF;
		
	ELSE --15-Apr-2015: Added this syntax if no error encountered the subject will change to success base on the verbiage provided. 
		v_message := 'EBS_NOTIFICATION_SUCCESS';
		
		IF p_ricefw_name = 'ALL_EBS_RICEFW' THEN
		  v_subject := 'Supply Planning - EBS Data Collection Process Completed Successfully'; 
		ELSIF p_ricefw_name = 'BOM' THEN
		  v_subject := 'Supply Planning - EBS Data Collection Process Completed Successfully For Bills and Materials Collection Report'; 
		ELSIF p_ricefw_name = 'FORMULA' THEN
		  v_subject := 'Supply Planning - EBS Data Collection Process Completed Successfully For Formula/Recipe Collection Report';   
		ELSIF p_ricefw_name = 'BATCH' THEN
		  v_subject := 'Supply Planning - EBS Data Collection Process Completed Successfully For Batch Collection Report';  
		ELSIF p_ricefw_name = 'CUSTOMER_INTERFACE' THEN
		  v_subject := 'Supply Planning - EBS Data Collection Process Completed Successfully For Customer Collection Report';   
		ELSE
		   v_subject := 'Supply Planning - EBS Data Collection Process Completed Successfully For ' || p_ricefw_name;
		END IF;
	END IF;
   -- v_message := 'Hi, \n\nAttached is the ' || v_subject ||'.\n\n*****This is an auto-generated e-mail. Please do not reply.*****'; --15-Apr-2015: Comment this message to resolved defect 151. Message already included in the unix script. 
	
    FND_FILE.PUT_LINE(FND_FILE.LOG,'New Filename : ' || p_new_filename); 
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Old Filename : ' || p_old_filename);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Direct Recipient : ' || lp_email_to);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Carbon Copy Recipient : ' || lp_email_to_cc);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Blind Carbon Copy Recipient : ' || lp_email_to_bcc);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Email Subject : ' || v_subject);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Email Content : ' || v_message);
    
    IF lp_email_to_bcc IS NOT NULL AND lp_email_to_cc IS NULL THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Cannot proceed in sending email due to BCC recipient contains a value and CC recipient is missing.');
    ELSE --send email if recipient is valid.
    --get request id generated after running concurrent program
    v_request_id := FND_REQUEST.SUBMIT_REQUEST(application  => 'XXNBTY'
                                               ,program      => 'XXNBTY_EBS_SEND_EMAIL_LOG'
                                               ,start_time   => TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
                                               ,sub_request  => FALSE
                                               ,argument1    => p_new_filename
                                               ,argument2    => p_old_filename
                                               ,argument3    => lp_email_to
                                               ,argument4    => lp_email_to_cc
                                               ,argument5    => lp_email_to_bcc
                                               ,argument6    => v_subject
                                               ,argument7    => v_message  --Start 6/29/2015 AFlores
											   ,argument8    => p_int02_old_filename
											   ,argument9	 => p_int06_stg_old_filename
											   ,argument10	 => p_int06_int_old_filename
                                               ,argument11	 => p_conv03_mtl_old_filename
                                               ,argument12	 => p_conv03_mst_old_filename
                                               ,argument13	 => p_conv03_upl_old_filename
											   ,argument14	 => p_lf08_comp_old_filename
											   ,argument15	 => p_lf08_head_old_filename
											   ,argument16	 => p_lf08_bici_old_filename
											   ,argument17	 => p_lf08_bbmi_old_filename --End 6/29/2015 AFlores

                                               );
    COMMIT;
    END IF; 
    
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID of XXNBTY_SendEmailLog : ' || v_request_id);  
                                               
    IF v_request_id != 0 THEN 
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Sending successful.');     
    ELSE
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in sending email.'); 
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      x_retcode := 2;
      x_errbuf := SQLERRM; 
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error message : ' || x_errbuf);
  END generate_email;
  
  --procedure to generate error log per ricefw using FND_FILE
  PROCEDURE generate_err_log (x_retcode   OUT VARCHAR2, 
                              x_errbuf    OUT VARCHAR2,
                              p_ricefw_name VARCHAR2,
                              p_width       NUMBER)
  IS
    TYPE err_type   IS RECORD (error_msg VARCHAR2(4000),
                               ctr       NUMBER);
    TYPE query_type IS RECORD (column_name      VARCHAR2(200),
                               table_name       VARCHAR2(200),
                               table_type       VARCHAR2(200),
                               where_clause     VARCHAR2(200),
                               group_by_clause  VARCHAR2(200));
    TYPE err_tab    IS TABLE OF err_type;  
    TYPE query_tab  IS TABLE OF query_type;

    v_err           err_tab;
    v_rec           query_type;
    v_query         query_tab := query_tab();
    v_header        VARCHAR2(1000);
    v_side_length   NUMBER;
    cur             SYS_REFCURSOR;
	v_request_id    NUMBER := fnd_global.conc_request_id; -- 29-Apr-2015:  Added this line to fixed defect #170 and INC960237. This will get the parent_request_id of the concurrent program. 
	v_main_request_id number; 
	v_child_request_id number; 
	
	CURSOR c1 (p_request_id number) 
		IS 
		SELECT a.parent_request_id 
		FROM apps.fnd_concurrent_requests a 
		WHERE a.request_id = p_request_id;
    
  BEGIN
    -- 29-Apr-2015: Added this line to fixed defect #170 and INC960237. This will get the parent_request_id of the concurrent program.  
	 
	v_child_request_id := v_request_id; 
	
	LOOP 
		OPEN c1(v_child_request_id); 
		FETCH c1 INTO v_main_request_id; 
		EXIT WHEN c1%notfound; 
		
		IF v_main_request_id = -1 THEN 
			v_main_request_id := v_child_request_id; 
			EXIT; 
		ELSE 
			v_child_request_id := v_main_request_id; 
		END IF;
		CLOSE c1; 
	END LOOP; 
	IF c1%isopen THEN 
		CLOSE c1; 
	END IF; 
	FND_FILE.PUT_LINE(FND_FILE.LOG,'v_main_request_id : ' || v_main_request_id);
  -- 29-Apr-2015: End of line for defect #170 and INC960237.  
  
    v_query.EXTEND();
    CASE p_ricefw_name
    WHEN 'ON_HAND_DATA' THEN 
      v_rec.column_name      := 'error_text, count(*)';
      v_rec.table_name       := 'MSC_ST_SUPPLIES';
      v_rec.table_type       := 'STAGING';
      v_rec.where_clause     := 'process_flag = 3 AND order_type = 18 AND TRUNC(creation_date) = TRUNC(SYSDATE)';
      v_rec.group_by_clause  := 'error_text';
      v_query(1)             := v_rec;
    WHEN 'IN_TRANSIT' THEN
      v_rec.column_name      := 'error_text, count(*)';
      v_rec.table_name       := 'MSC_ST_SUPPLIES';
      v_rec.table_type       := 'STAGING';
      v_rec.where_clause     := 'process_flag = 3 AND order_type = 11 AND TRUNC(creation_date) = TRUNC(SYSDATE)';
      v_rec.group_by_clause  := 'error_text';
      v_query(1)             := v_rec;
    WHEN 'WORK_ORDERS' THEN
      v_rec.column_name      := 'error_text, count(*)';
      v_rec.table_name       := 'MSC_ST_SUPPLIES';
      v_rec.table_type       := 'STAGING';
      v_rec.where_clause     := 'process_flag = 3 AND order_type = 3 AND TRUNC(creation_date) = TRUNC(SYSDATE)';
      v_rec.group_by_clause  := 'error_text';
      v_query(1)             := v_rec;
    WHEN 'WIP' THEN
      v_rec.column_name      := 'error_text, count(*)';
      v_rec.table_name       := 'MSC_ST_DEMANDS';
      v_rec.table_type       := 'STAGING';
      v_rec.where_clause     := 'process_flag = 3 AND TRUNC(creation_date) = TRUNC(SYSDATE)';
      v_rec.group_by_clause  := 'error_text';
      v_query(1)             := v_rec;
    WHEN 'SALES_ORDERS' THEN
      v_rec.column_name      := 'error_text, count(*)';
      v_rec.table_name       := 'MSC_ST_SALES_ORDERS';
      v_rec.table_type       := 'STAGING';
      v_rec.where_clause     := 'process_flag = 3 AND TRUNC(creation_date) = TRUNC(SYSDATE)';
      v_rec.group_by_clause  := 'error_text';
      v_query(1)             := v_rec;
    WHEN 'ITEM_COSTS' THEN
      v_rec.column_name      := 'error_description, count(*)';
      v_rec.table_name       := 'XXMSC_CUS_COST_TBL';
      v_rec.table_type       := 'STAGING';
      v_rec.where_clause     := 'status = ''E'' AND TRUNC(creation_date) = TRUNC(SYSDATE)';
      v_rec.group_by_clause  := 'error_description';
      v_query(1)             := v_rec;
    WHEN 'BOM' THEN
      v_rec.column_name      := 'error_description, count(*)';
      v_rec.table_name       := 'xxnbty_bom_components_st';
      v_rec.table_type       := 'STAGING';
      v_rec.where_clause     := 'process_flag = 3 ';-- AND TRUNC(creation_date) = TRUNC(SYSDATE)';
      v_rec.group_by_clause  := 'error_description';
      v_query(1)             := v_rec;
      
      v_query.EXTEND();
      v_rec.column_name      := 'error_description, count(*)';
      v_rec.table_name       := 'xxnbty_bom_headers_st';
      v_rec.table_type       := 'STAGING';
      v_rec.where_clause     := 'process_flag = 3 ';--AND TRUNC(creation_date) = TRUNC(SYSDATE)';
      v_rec.group_by_clause  := 'error_description';
      v_query(2)             := v_rec;
      
      v_query.EXTEND();
      v_rec.column_name      := 'mie.error_message, count(*)';
      v_rec.table_name       := 'bom_inventory_comps_interface bici, mtl_interface_errors mie';
      v_rec.table_type       := 'INTERFACE';
      v_rec.where_clause     := 'bici.process_flag = 3 AND bici.transaction_id = mie.transaction_id AND abs(bici.request_id) >= '||v_main_request_id;  --- 23-Apr-2015: Added the "AND TRUNC(creation_date) = TRUNC(SYSDATE)" to get the current error and error message to resolved defect 170.
      v_rec.group_by_clause  := 'mie.error_message';
      v_query(3)             := v_rec;
     
      v_query.EXTEND();
      v_rec.column_name      := 'mie.error_message, count(*)';
      v_rec.table_name       := 'bom_bill_of_mtls_interface bbmi, mtl_interface_errors mie';
      v_rec.table_type       := 'INTERFACE';
      v_rec.where_clause     := 'bbmi.process_flag = 3 AND bbmi.transaction_id = mie.transaction_id AND abs(bbmi.request_id) >= '||v_main_request_id; --- 23-Apr-2015: Added the "AND TRUNC(creation_date) = TRUNC(SYSDATE)" to get the current error and error message to resolved defect 170.
      v_rec.group_by_clause  := 'mie.error_message';
      v_query(4)             := v_rec;
    WHEN 'FORMULA' THEN 
      v_rec.column_name      := 'error_text, count(*)';
      v_rec.table_name       := 'xxnbty_opm_matl_dtl_st';
      v_rec.table_type       := 'STAGING';
      v_rec.where_clause     := 'status NOT IN (''P'', ''V'')';
      v_rec.group_by_clause  := 'error_text';
      v_query(1)             := v_rec;
      
      v_query.EXTEND();
      v_rec.column_name      := 'error_text, count(*)';
      v_rec.table_name       := 'xxnbty_opm_form_mst_st';
      v_rec.table_type       := 'STAGING';
      v_rec.where_clause     := 'status NOT IN (''P'', ''V'')';
      v_rec.group_by_clause  := 'error_text';
      v_query(2)             := v_rec;
      
      v_query.EXTEND();
      v_rec.column_name      := 'attribute30, NULL';
      v_rec.table_name       := 'xxnbty_opm_formula_upload';
      v_rec.table_type       := 'STAGING';
      v_rec.where_clause     := 'attribute29 NOT IN (''P'', ''V'') ';--AND TRUNC(creation_date) = TRUNC(SYSDATE)';
      v_rec.group_by_clause  := 'attribute30';
      v_query(3)             := v_rec;
    WHEN 'BATCH' THEN
      v_rec.column_name      := 'error_description, count(*)';
      v_rec.table_name       := 'xxnbty_opm_batches_st';
      v_rec.table_type       := 'STAGING';
      v_rec.where_clause     := 'error_description IS NOT NULL ';--AND TRUNC(creation_date) = TRUNC(SYSDATE)';
      v_rec.group_by_clause  := 'error_description';
      v_query(1)             := v_rec;
    WHEN 'CUSTOMER_INTERFACE' THEN
      v_rec.column_name      := 'error_message, count(*)';
      v_rec.table_name       := 'xxnbty_ar_customers_st';
      v_rec.table_type       := 'STAGING';
      v_rec.where_clause     := 'process_flag = ''E'' ';--AND TRUNC(creation_date) = TRUNC(SYSDATE)';
      v_rec.group_by_clause  := 'error_message';
      v_query(1)             := v_rec;
      
      v_query.EXTEND();
      v_rec.column_name      := 'NULL, count(*)';
      v_rec.table_name       := 'ra_customers_interface_all';
      v_rec.table_type       := 'INTERFACE';
     -- v_rec.where_clause     := 'interface_status IS NOT NULL AND TRUNC(creation_date) = TRUNC(SYSDATE) AND abs(request_id)>= '||v_main_request_id; ---Feedback by Dani Rodil
      v_rec.where_clause     := 'interface_status IS NOT NULL AND creation_date >= (select a.creation_date from xxnbty_ar_customers_st a where rownum < 2 and a.request_id >= '|| v_main_request_id ||')';
	  v_rec.group_by_clause  := 1;
      v_query(2)             := v_rec;
    END CASE;
 
    FOR i IN 1..v_query.COUNT
    LOOP
      OPEN cur FOR ' SELECT ' || v_query(i).column_name || 
                     ' FROM ' || v_query(i).table_name || 
                    ' WHERE ' || v_query(i).where_clause || 
                 ' GROUP BY ' || v_query(i).group_by_clause;    
      LOOP
        FETCH cur BULK COLLECT INTO v_err;
          
          v_header := v_query(i).table_name ||  '(' || p_ricefw_name || ')';
            v_side_length := TRUNC((p_width - LENGTH(v_header)) / 2);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
            
            --display header
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  ' || RPAD(LPAD(v_header, v_side_length + LENGTH(v_header) + 3, '*'), p_width + 6, '*')  || '  ');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
          
          IF v_err.COUNT = 0 THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'     ALL RECORDS FOR ' || v_query(i).table_name || '(' || p_ricefw_name || ') ARE VALID.');
          ELSE
            g_with_error_msg := TRUE; --set global variable if there's an error in RICEFW.
			
			--Start 6/29/2015 AFlores
			--Set global variable to true if there will be errors per object
			--BATCH
			IF p_ricefw_name = 'BATCH' THEN
				g_det_batch_with_error := TRUE;
			END IF;
			--Customer staging table
			IF p_ricefw_name = 'CUSTOMER_INTERFACE' AND v_query(i).table_name = 'xxnbty_ar_customers_st' THEN
				g_det_customer_stg_with_error := TRUE;
			END IF;
			--Customer interface table
			IF p_ricefw_name = 'CUSTOMER_INTERFACE' AND v_query(i).table_name = 'ra_customers_interface_all' THEN
				g_det_customer_int_with_error := TRUE;
			END IF;
			--Formula mtl table
			IF p_ricefw_name = 'FORMULA' AND v_query(i).table_name = 'xxnbty_opm_matl_dtl_st' THEN
				g_det_formula_mtl_with_error := TRUE;
			END IF;
			--Formula mst table
			IF p_ricefw_name = 'FORMULA' AND v_query(i).table_name = 'xxnbty_opm_form_mst_st' THEN
				g_det_formula_mst_with_error := TRUE;
			END IF;
			--Formula upl table
			IF p_ricefw_name = 'FORMULA' AND v_query(i).table_name = 'xxnbty_opm_formula_upload' THEN
				g_det_formula_upl_with_error := TRUE;
			END IF;
			--BOM comp table
			IF p_ricefw_name = 'BOM' AND v_query(i).table_name = 'xxnbty_bom_components_st' THEN
				g_det_bom_comp_with_error := TRUE;
			END IF;	
			--BOM head table
			IF p_ricefw_name = 'BOM' AND v_query(i).table_name = 'xxnbty_bom_headers_st' THEN
				g_det_bom_head_with_error := TRUE;
			END IF;	
			--BOM BICI table
			IF p_ricefw_name = 'BOM' AND v_query(i).table_name = 'bom_inventory_comps_interface bici, mtl_interface_errors mie' THEN
				g_det_bom_bici_with_error := TRUE;
			END IF;	
			--BOM BBMI table
			IF p_ricefw_name = 'BOM' AND v_query(i).table_name = 'bom_bill_of_mtls_interface bbmi, mtl_interface_errors mie' THEN
				g_det_bom_bbmi_with_error := TRUE;
			END IF;				
			
			--End 6/29/2015 AFlores	
            
            --display column header
            IF v_err(1).error_msg IS NOT NULL AND v_err(1).ctr IS NOT NULL THEN --display all columns
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'     Error Count     Error Message');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'     -----------     -------------');
            ELSIF v_err(1).error_msg IS NULL THEN --display error count only if message is null
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'     Error Count');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'     -----------');
            ELSIF v_err(1).ctr IS NULL THEN --display error message only if count is null
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'     Error Message');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'     -------------');
            END IF;
          END IF;
          
          FOR ii IN 1..v_err.COUNT
          LOOP
            IF v_err(ii).error_msg IS NOT NULL AND v_err(ii).ctr IS NOT NULL THEN --display all columns
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'     ' || RPAD(TO_CHAR(v_err(ii).ctr, 'fm999,999,999,999,999'), 16, ' ') || v_err(ii).error_msg);
            ELSIF v_err(ii).error_msg IS NULL THEN --display error count only if message is null
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'     ' || TO_CHAR(v_err(ii).ctr, 'fm999,999,999,999,999'));
            ELSIF v_err(ii).ctr IS NULL THEN --display error message only if count is null
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'     ' || v_err(ii).error_msg);
            END IF;
          END LOOP;
          EXIT WHEN cur%NOTFOUND;
      END LOOP;
      CLOSE cur;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      x_retcode := SQLCODE;
      x_errbuf := SQLERRM; 
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error message : ' || x_errbuf); 
  END generate_err_log;
  
  PROCEDURE generate_detailed_err_log ( x_retcode     OUT VARCHAR2,
										x_errbuf      OUT VARCHAR2,
										p_det_ricefw_name VARCHAR2,
										p_req_id      OUT  NUMBER)
  IS
  --------------------------------------------------------------------------------------------
  /*
  Procedure Name: generate_detailed_err_log
  Author's Name: Albert John Flores
  Date written: 29-Jun-2015
  RICEFW Object: REP02
  Description: Procedure for generate detailed error log per ricefw using FND_FILE. 
  Program Style:
  Maintenance History:
  Date         Issue#  Name         			    Remarks
  -----------  ------  -------------------		------------------------------------------------
  29-Jun-2015          Albert John Flores	 	Initial Development

  */
  --------------------------------------------------------------------------------------------
  	ln_wait             BOOLEAN;
	lc_phase            VARCHAR2(100)   := NULL;
	lc_status           VARCHAR2(30)    := NULL;
	lc_devphase         VARCHAR2(100)   := NULL;
	lc_devstatus        VARCHAR2(100)   := NULL;
	lc_mesg             VARCHAR2(50)    := NULL;
  
  BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered procedure generate_detailed_err_log' );   
  
  CASE p_det_ricefw_name
  WHEN 'BATCH' THEN
		p_req_id := FND_REQUEST.SUBMIT_REQUEST(application  => 'XXNBTY'
													,program      => 'XXNBTY_OPM_INT02_DET_ERR_REP'
													,start_time   => NULL
													,sub_request  => FALSE
													);
													
		FND_CONCURRENT.AF_COMMIT;
				
		ln_wait := fnd_concurrent.wait_for_request( request_id      => p_req_id
												  , interval        => 30
												  , max_wait        => ''
												  , phase           => lc_phase
												  , status          => lc_status
												  , dev_phase       => lc_devphase
												  , dev_status      => lc_devstatus
												  , message         => lc_mesg
												  );
		FND_CONCURRENT.AF_COMMIT;
		
		--check for the report completion
		IF (lc_devphase = 'COMPLETE' AND lc_devstatus = 'NORMAL') THEN 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent program for detailed error report has completed successfully'); 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID of XXNBTY Batch Detailed Error Report is ' || p_req_id); 
		ELSE
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Generating detailed error report for '|| p_det_ricefw_name || ' failed.' );   
		END IF;	

  WHEN 'CUSTOMER_STAGING' THEN
		p_req_id := FND_REQUEST.SUBMIT_REQUEST(application  => 'XXNBTY'
													,program      => 'XXNBTY_AR_INT06_STG_DET_ER_REP'
													,start_time   => NULL
													,sub_request  => FALSE
													);
													
		FND_CONCURRENT.AF_COMMIT;
				
		ln_wait := fnd_concurrent.wait_for_request( request_id      => p_req_id
												  , interval        => 30
												  , max_wait        => ''
												  , phase           => lc_phase
												  , status          => lc_status
												  , dev_phase       => lc_devphase
												  , dev_status      => lc_devstatus
												  , message         => lc_mesg
												  );
		FND_CONCURRENT.AF_COMMIT;
		
		--check for the report completion
		IF (lc_devphase = 'COMPLETE' AND lc_devstatus = 'NORMAL') THEN 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent program for detailed error report has completed successfully'); 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID of XXNBTY Customer Staging Detailed Error Report is ' || p_req_id); 
		ELSE
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Generating detailed error report for '|| p_det_ricefw_name || ' failed.' );   
		END IF;	
		
  WHEN 'CUSTOMER_INTERFACE' THEN
		p_req_id := FND_REQUEST.SUBMIT_REQUEST(application  => 'XXNBTY'
													,program      => 'XXNBTY_AR_INT06_INT_DET_ER_REP'
													,start_time   => NULL
													,sub_request  => FALSE
													);
													
		FND_CONCURRENT.AF_COMMIT;
				
		ln_wait := fnd_concurrent.wait_for_request( request_id      => p_req_id
												  , interval        => 30
												  , max_wait        => ''
												  , phase           => lc_phase
												  , status          => lc_status
												  , dev_phase       => lc_devphase
												  , dev_status      => lc_devstatus
												  , message         => lc_mesg
												  );
		FND_CONCURRENT.AF_COMMIT;
		
		--check for the report completion
		IF (lc_devphase = 'COMPLETE' AND lc_devstatus = 'NORMAL') THEN 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent program for detailed error report has completed successfully'); 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID of XXNBTY Customer Interface Detailed Error Report is ' || p_req_id); 
		ELSE
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Generating detailed error report for '|| p_det_ricefw_name || ' failed.' );   
		END IF;	
		
  WHEN 'FORMULA_MTL' THEN
		p_req_id := FND_REQUEST.SUBMIT_REQUEST(application  => 'XXNBTY'
													,program      => 'XXNBTY_OPM_CNV03_ML_DET_ER_REP'
													,start_time   => NULL
													,sub_request  => FALSE
													);
													
		FND_CONCURRENT.AF_COMMIT;
				
		ln_wait := fnd_concurrent.wait_for_request( request_id      => p_req_id
												  , interval        => 30
												  , max_wait        => ''
												  , phase           => lc_phase
												  , status          => lc_status
												  , dev_phase       => lc_devphase
												  , dev_status      => lc_devstatus
												  , message         => lc_mesg
												  );
		FND_CONCURRENT.AF_COMMIT;
		
		--check for the report completion
		IF (lc_devphase = 'COMPLETE' AND lc_devstatus = 'NORMAL') THEN 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent program for detailed error report has completed successfully'); 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID of XXNBTY Formula MTL Detailed Error Report is ' || p_req_id); 
		ELSE
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Generating detailed error report for '|| p_det_ricefw_name || ' failed.' );   
		END IF;	

  WHEN 'FORMULA_MST' THEN
		p_req_id := FND_REQUEST.SUBMIT_REQUEST(application  => 'XXNBTY'
													,program      => 'XXNBTY_OPM_CNV03_MS_DET_ER_REP'
													,start_time   => NULL
													,sub_request  => FALSE
													);
													
		FND_CONCURRENT.AF_COMMIT;
				
		ln_wait := fnd_concurrent.wait_for_request( request_id      => p_req_id
												  , interval        => 30
												  , max_wait        => ''
												  , phase           => lc_phase
												  , status          => lc_status
												  , dev_phase       => lc_devphase
												  , dev_status      => lc_devstatus
												  , message         => lc_mesg
												  );
		FND_CONCURRENT.AF_COMMIT;
		
		--check for the report completion
		IF (lc_devphase = 'COMPLETE' AND lc_devstatus = 'NORMAL') THEN 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent program for detailed error report has completed successfully'); 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID of XXNBTY Formula MST Detailed Error Report is ' || p_req_id); 
		ELSE
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Generating detailed error report for '|| p_det_ricefw_name || ' failed.' );   
		END IF;
		
  WHEN 'FORMULA_UPL' THEN
		p_req_id := FND_REQUEST.SUBMIT_REQUEST(application  => 'XXNBTY'
													,program      => 'XXNBTY_OPM_CNV03_UP_DET_ER_REP'
													,start_time   => NULL
													,sub_request  => FALSE
													);
													
		FND_CONCURRENT.AF_COMMIT;
				
		ln_wait := fnd_concurrent.wait_for_request( request_id      => p_req_id
												  , interval        => 30
												  , max_wait        => ''
												  , phase           => lc_phase
												  , status          => lc_status
												  , dev_phase       => lc_devphase
												  , dev_status      => lc_devstatus
												  , message         => lc_mesg
												  );
		FND_CONCURRENT.AF_COMMIT;
		
		--check for the report completion
		IF (lc_devphase = 'COMPLETE' AND lc_devstatus = 'NORMAL') THEN 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent program for detailed error report has completed successfully'); 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID of XXNBTY Formula UPL Detailed Error Report is ' || p_req_id); 
		ELSE
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Generating detailed error report for '|| p_det_ricefw_name || ' failed.' );   
		END IF;
		
  WHEN 'BOM_COMP' THEN
		p_req_id := FND_REQUEST.SUBMIT_REQUEST(application  => 'XXNBTY'
													,program      => 'XXNBTY_BOM_LF08_COM_DET_ER_REP'
													,start_time   => NULL
													,sub_request  => FALSE
													);
													
		FND_CONCURRENT.AF_COMMIT;
				
		ln_wait := fnd_concurrent.wait_for_request( request_id      => p_req_id
												  , interval        => 30
												  , max_wait        => ''
												  , phase           => lc_phase
												  , status          => lc_status
												  , dev_phase       => lc_devphase
												  , dev_status      => lc_devstatus
												  , message         => lc_mesg
												  );
		FND_CONCURRENT.AF_COMMIT;
		
		--check for the report completion
		IF (lc_devphase = 'COMPLETE' AND lc_devstatus = 'NORMAL') THEN 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent program for detailed error report has completed successfully'); 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID of XXNBTY BOM Component Detailed Error Report is ' || p_req_id); 
		ELSE
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Generating detailed error report for '|| p_det_ricefw_name || ' failed.' );   
		END IF;	

  WHEN 'BOM_HEAD' THEN
		p_req_id := FND_REQUEST.SUBMIT_REQUEST(application  => 'XXNBTY'
													,program      => 'XXNBTY_BOM_LF08_HED_DET_ER_REP'
													,start_time   => NULL
													,sub_request  => FALSE
													);
													
		FND_CONCURRENT.AF_COMMIT;
				
		ln_wait := fnd_concurrent.wait_for_request( request_id      => p_req_id
												  , interval        => 30
												  , max_wait        => ''
												  , phase           => lc_phase
												  , status          => lc_status
												  , dev_phase       => lc_devphase
												  , dev_status      => lc_devstatus
												  , message         => lc_mesg
												  );
		FND_CONCURRENT.AF_COMMIT;
		
		--check for the report completion
		IF (lc_devphase = 'COMPLETE' AND lc_devstatus = 'NORMAL') THEN 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent program for detailed error report has completed successfully'); 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID of XXNBTY BOM Header Detailed Error Report is ' || p_req_id); 
		ELSE
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Generating detailed error report for '|| p_det_ricefw_name || ' failed.' );   
		END IF;	

  WHEN 'BOM_BICI' THEN
		p_req_id := FND_REQUEST.SUBMIT_REQUEST(application  => 'XXNBTY'
													,program      => 'XXNBTY_BOM_LF08_BIC_DET_ER_REP'
													,start_time   => NULL
													,sub_request  => FALSE
													);
													
		FND_CONCURRENT.AF_COMMIT;
				
		ln_wait := fnd_concurrent.wait_for_request( request_id      => p_req_id
												  , interval        => 30
												  , max_wait        => ''
												  , phase           => lc_phase
												  , status          => lc_status
												  , dev_phase       => lc_devphase
												  , dev_status      => lc_devstatus
												  , message         => lc_mesg
												  );
		FND_CONCURRENT.AF_COMMIT;
		
		--check for the report completion
		IF (lc_devphase = 'COMPLETE' AND lc_devstatus = 'NORMAL') THEN 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent program for detailed error report has completed successfully'); 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID of XXNBTY BOM BICI Detailed Error Report is ' || p_req_id); 
		ELSE
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Generating detailed error report for '|| p_det_ricefw_name || ' failed.' );   
		END IF;	

  WHEN 'BOM_BBMI' THEN
		p_req_id := FND_REQUEST.SUBMIT_REQUEST(application  => 'XXNBTY'
													,program      => 'XXNBTY_BOM_LF08_BBM_DET_ER_REP'
													,start_time   => NULL
													,sub_request  => FALSE
													);
													
		FND_CONCURRENT.AF_COMMIT;
				
		ln_wait := fnd_concurrent.wait_for_request( request_id      => p_req_id
												  , interval        => 30
												  , max_wait        => ''
												  , phase           => lc_phase
												  , status          => lc_status
												  , dev_phase       => lc_devphase
												  , dev_status      => lc_devstatus
												  , message         => lc_mesg
												  );
		FND_CONCURRENT.AF_COMMIT;
		
		--check for the report completion
		IF (lc_devphase = 'COMPLETE' AND lc_devstatus = 'NORMAL') THEN 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent program for detailed error report has completed successfully'); 
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID of XXNBTY BOM BBMI Detailed Error Report is ' || p_req_id); 
		ELSE
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Generating detailed error report for '|| p_det_ricefw_name || ' failed.' );   
		END IF;			
		
  END CASE;
  
    EXCEPTION
    WHEN OTHERS THEN
      x_retcode := 2;
      x_errbuf := SQLERRM;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error message : ' || x_errbuf);
  END generate_detailed_err_log;
  
END XXNBTY_EBS_SEND_EMAIL_PKG;
/

show errors;

