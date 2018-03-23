# 025352 :BOEING ST. LOUIS / 3350 NW 22 TER #200B / ST. LOUIS, MO 45677
# 025414 :BOEING C-17 (MILITARY) JIT / 2400 E. WARDLOW RD. / LONG BEACH, CA 90807
# 025415 :BOEING MESA JIT / 6909 WEST REY ROAD / CHANDLER, AZ 85226
#<option value="025424"> 025417:BOEING MACON / 3350 NW 22 TER #200B / MACON, GA 56778</option>

# Note: Don't Change sequence of it will effect in kit history page
CUST_FORECAST_USER_ARR = ["025415","025414","025424","025352"]

SUPERSEDENCE_SEARCH_USER_ARR = ["025352","025400"]

APP_URL = "https://mmaero3/cm"
#CUSTOMER_REPORT_PATH = "/apps/w/customer_reports/"
# Note if you want to give a different path for MANUAL_REPORTS then uncomment the next line and make change in the reports controller accordingly
#MANUAL_REPORT_PATH = :PATH

MENU_ARRAY = ['RMA','RMA Request', 'FILE TRANSFER STATUS', 'View Cert: Stk Transfer','View Certification', 'Open Order Status',
              'Kitting', 'Reports', 'BIN LOCATOR', 'Critical & Watch', 'Engineering Check', 'STOCK REQUEST',
              'Supersedence', 'Floor View', 'QC LAB','PN Cross Reference', 'REFILL ORDER STATUS', 'Min/Max Report',
              "Sikorsky Web Order","Variable Quantity Bin Order","Stock Lookup"]

AGUSTA_REPORTS=["_wkly_kit.xls","_DESK.REQUEST.RPT.xls"]