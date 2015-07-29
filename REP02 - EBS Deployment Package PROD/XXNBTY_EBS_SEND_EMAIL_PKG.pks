--------------------------------------------------------
--  File created - Wednesday-December-24-2014   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package XXNBTY_EBS_SEND_EMAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "APPS"."XXNBTY_EBS_SEND_EMAIL_PKG" 
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
12/19/2014				 	Mark Anthony Geamoga	Initial Development
15-Apr-2015					Erwin Ramos				Update the v_with_error_msg to g_with_error_msg
29-Jun-2015					Albert John Flores		REP02

*/
--------------------------------------------------------------------------------------------
IS
  g_with_error_msg  BOOLEAN := FALSE; 
  --Start 6/29/2015 Albert Flores
  g_det_batch_with_error  	  	  BOOLEAN := FALSE;
  g_det_customer_stg_with_error   BOOLEAN := FALSE;
  g_det_customer_int_with_error   BOOLEAN := FALSE;
  g_det_formula_mtl_with_error    BOOLEAN := FALSE;
  g_det_formula_mst_with_error    BOOLEAN := FALSE;
  g_det_formula_upl_with_error    BOOLEAN := FALSE;
  g_det_bom_comp_with_error    	  BOOLEAN := FALSE;
  g_det_bom_head_with_error    	  BOOLEAN := FALSE;
  g_det_bom_bici_with_error    	  BOOLEAN := FALSE;
  g_det_bom_bbmi_with_error    	  BOOLEAN := FALSE;
  --End 6/29/2015 Albert Flores
  
  --main procedure that will call another procedure to generate error log
  PROCEDURE send_email_main (x_retcode             OUT VARCHAR2, 
                             x_errbuf              OUT VARCHAR2,
                             p_ricefw_name            VARCHAR2,
                             p_allow_send_if_no_error VARCHAR2);
                        
  --procedure that will send access error log file and send it to recepients using lookups
  PROCEDURE generate_email (x_retcode   		OUT VARCHAR2, 
                            x_errbuf    		OUT VARCHAR2,
                            p_ricefw_name  			VARCHAR2,
                            p_new_filename 			VARCHAR2,
                            p_old_filename 			VARCHAR2,
                            p_lookup_name  			VARCHAR2,
                            p_int02_old_filename  	VARCHAR2,
                            p_int06_stg_old_filename  	VARCHAR2,
                            p_int06_int_old_filename  	VARCHAR2,
                            p_conv03_mtl_old_filename  	VARCHAR2,
                            p_conv03_mst_old_filename  	VARCHAR2,
                            p_conv03_upl_old_filename  	VARCHAR2,
							p_lf08_comp_old_filename	VARCHAR2,
							p_lf08_head_old_filename	VARCHAR2,
							p_lf08_bici_old_filename	VARCHAR2,
							p_lf08_bbmi_old_filename	VARCHAR2); 
  
  --procedure to generate error log per ricefw using FND_FILE
  PROCEDURE generate_err_log (x_retcode   OUT VARCHAR2, 
                              x_errbuf    OUT VARCHAR2,
                              p_ricefw_name VARCHAR2,
                              p_width       NUMBER);
							  
  --6/29/2015 AFlores
  --procedure to generate detailed error log per ricefw using FND_FILE
  PROCEDURE generate_detailed_err_log ( x_retcode     OUT VARCHAR2,
										x_errbuf      OUT VARCHAR2,
										p_det_ricefw_name VARCHAR2,
										p_req_id      OUT  NUMBER);
  
END XXNBTY_EBS_SEND_EMAIL_PKG;

/

show errors;
