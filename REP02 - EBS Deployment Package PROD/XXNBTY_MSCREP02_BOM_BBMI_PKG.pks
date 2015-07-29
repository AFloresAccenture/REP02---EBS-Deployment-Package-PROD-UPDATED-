create or replace PACKAGE       XXNBTY_MSCREP02_BOM_BBMI_PKG 
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

  */
  ----------------------------------------------------------------------------------------------
 IS
 --Procedure that will generate a .out file for the detailed error report
 PROCEDURE main_proc ( x_retcode   OUT VARCHAR2
				      ,x_errbuf    OUT VARCHAR2);
					
END XXNBTY_MSCREP02_BOM_BBMI_PKG;
/

show errors;
					