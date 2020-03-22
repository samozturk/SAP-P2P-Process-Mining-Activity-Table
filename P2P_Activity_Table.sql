--DECLARE @CURR AS VARCHAR(3)
--SELECT @CURR = 'TRY';
-- Set date format to day/month/year.  
SET DATEFORMAT dmy;  
GO  
DECLARE @datevar datetime2 = '31/12/2008 09:01:01.1234567';  
SELECT @datevar;  

GO

INSERT INTO [TR_Demo-DB].[dbo].[P2P_TEST]
---------------------------------------PURCHASE REQUISTION-------------------------------------------------
------------------------------------------------------------------------------------------------------

SELECT
	CASE WHEN [TR_Demo-DB].[dbo].[EBAN].EBELN = '' AND [TR_Demo-DB].[dbo].[EBAN].EBELN = 0
			THEN [TR_Demo-DB].[dbo].[EBAN].BANFN + '-' + CAST([TR_Demo-DB].[dbo].[EBAN].BNFPO AS varchar) 	/* PR - Purchase Requisition Number (PR) - Item Number of Purchase Requisition -> EBAN */
			ELSE [TR_Demo-DB].[dbo].[EBAN].EBELN + '-' + CAST([TR_Demo-DB].[dbo].[EBAN].EBELP AS varchar)   /* PO - Purchase Order Number (PO) - Item Number of Purchase Order  -> EKPO (Purchasing Document Item) */
		END AS [CASE]
	,  'Purchase requisition' AS [EVENT]	
	, CONVERT(datetime, [TR_Demo-DB].[dbo].[EBAN].BADAT, 103) AS [CREATION_DATE]
	, YEAR([TR_Demo-DB].[dbo].[EBAN].BADAT) AS [Year]
	, [TR_Demo-DB].[dbo].[EBAN].BSART AS [DOCUMENT_TYPE]					/* Purchase Requisition Document Type */
	, CASE WHEN [TR_Demo-DB].[dbo].[EBAN].BUKRS is not NULL 
		THEN [TR_Demo-DB].[dbo].[EBAN].BUKRS 
		ELSE 'Purchase requisiton company code not set'
	  END AS [CompanyCodeDesc]
	
	, CASE WHEN [TR_Demo-DB].[dbo].[EBAN].ERNAM is not NULL THEN [TR_Demo-DB].[dbo].[EBAN].ERNAM  ELSE 'Not set' END AS [UserName] -- Name of person who created the object
	, CASE WHEN [TR_Demo-DB].[dbo].[EBAN].LIFNR is not NULL THEN [TR_Demo-DB].[dbo].[LFA1].NAME1  ELSE 'Not set' END AS [VendorName]
	, CASE WHEN ([TR_Demo-DB].[dbo].[EBAN].LIFNR is not NULL) AND ([TR_Demo-DB].[dbo].[EBAN].LIFNR = '') THEN [TR_Demo-DB].[dbo].[EBAN].LIFNR  ELSE 'Not set' END AS [VendorCode]
	, CASE WHEN ([TR_Demo-DB].[dbo].[EBAN].MATNR is not NULL) AND ([TR_Demo-DB].[dbo].[MAKT].MAKTX = ' ' )
		THEN upper([TR_Demo-DB].[dbo].[MAKT].MAKTX)  ELSE 'Not set' END AS [MaterialName]
	, [TR_Demo-DB].[dbo].[EBAN].PREIS AS [AMOUNT]
	, [TR_Demo-DB].[dbo].[EBAN].BSTYP AS [DOCUMENT_CATEGORY]
	, CASE WHEN [TR_Demo-DB].[dbo].[EBAN].MATNR is not NULL THEN [TR_Demo-DB].[dbo].[EBAN].MATNR  ELSE 'Not set' END AS [MaterialCode]
	, [TR_Demo-DB].[dbo].[EBAN].EKORG AS [PurchasingOrg] 
	, [TR_Demo-DB].[dbo].[EBAN].MENGE AS [Quantity]
	, [TR_Demo-DB].[dbo].[EKKO].WAERS [Currency] --need a safe switch--
	, 1 AS [SORTING]




FROM [TR_Demo-DB].[dbo].[EBAN]
		LEFT OUTER JOIN [TR_Demo-DB].[dbo].[EKKO] ON [TR_Demo-DB].[dbo].[EBAN].EBELN = [TR_Demo-DB].[dbo].[EKKO].EBELN
		LEFT OUTER JOIN [TR_Demo-DB].[dbo].[T161T] ON [TR_Demo-DB].[dbo].[EBAN].BSART = [TR_Demo-DB].[dbo].[T161T].BSART AND [TR_Demo-DB].[dbo].[EBAN].BSTYP = [TR_Demo-DB].[dbo].[T161T].BSTYP AND [TR_Demo-DB].[dbo].[T161T].SPRAS = 'T'
		LEFT OUTER JOIN [TR_Demo-DB].[dbo].[LFA1] ON [TR_Demo-DB].[dbo].[EBAN].LIFNR = [TR_Demo-DB].[dbo].[LFA1].LIFNR AND [TR_Demo-DB].[dbo].[EBAN].LIFNR is not NULL		-- Vendor Master data
		LEFT OUTER JOIN [TR_Demo-DB].[dbo].[MAKT] ON [TR_Demo-DB].[dbo].[EBAN].MATNR = [TR_Demo-DB].[dbo].[MAKT].MATNR

UNION ALL

-------------------------------------PURCHASE ORDER-----------------------------------------------------------
SELECT
	[TR_Demo-DB].[dbo].[EKPO].EBELN + '-' + CAST([TR_Demo-DB].[dbo].[EKPO].EBELP AS varchar) AS [CASE]
	, 'Purchasing Order' AS [EVENT]	
	, [TR_Demo-DB].[dbo].[EKKO].AEDAT AS [CREATION_DATE]
	, YEAR([TR_Demo-DB].[dbo].[EKKO].AEDAT) AS [Year]
	, [TR_Demo-DB].[dbo].[EKKO].BSART AS [DOCUMENT_TYPE]
	, [TR_Demo-DB].[dbo].[EKKO].BUKRS AS [CompanyCodeDesc]
	, CASE WHEN [TR_Demo-DB].[dbo].[EKKO].ERNAM is not NULL THEN [TR_Demo-DB].[dbo].[EKKO].ERNAM ELSE 'Not set' END AS [UserName]
	, CASE WHEN [TR_Demo-DB].[dbo].[EKKO].LIFNR is not NULL THEN [TR_Demo-DB].[dbo].[LFA1].NAME1 ELSE 'Not set' END AS [VendorName]
	,  CASE WHEN ([TR_Demo-DB].[dbo].[EKKO].LIFNR is not NULL) AND ([TR_Demo-DB].[dbo].[EKKO].LIFNR = '') THEN [TR_Demo-DB].[dbo].[EKKO].LIFNR  ELSE 'Not set' END AS [VendorCode]
	, CASE WHEN [TR_Demo-DB].[dbo].[EKPO].MATNR is not NULL THEN [TR_Demo-DB].[dbo].[MAKT].MAKTX ELSE 'Not set' END AS [MaterialName]
	, CAST([TR_Demo-DB].[dbo].[EKPO].NETWR AS DECIMAL(12,2)) * CAST([TR_Demo-DB].[dbo].[EKKO].WKURS AS DECIMAL(12,2)) AS [AMOUNT] --kontrol gerekli
	, [TR_Demo-DB].[dbo].[EKKO].BSTYP AS [DOCUMENT_CATEGORY]
	, CASE WHEN [TR_Demo-DB].[dbo].[EKPO].MATNR is not NULL THEN [TR_Demo-DB].[dbo].[EKPO].MATNR ELSE 'Not set' END AS [MaterialCode]
	, CASE WHEN [TR_Demo-DB].[dbo].[EKKO].EKORG is not NULL THEN LTRIM(RTRIM([TR_Demo-DB].[dbo].[EKKO].EKORG)) ELSE 'Not set' END AS [PurchasingOrg] 	
	, [TR_Demo-DB].[dbo].[EKPO].MENGE AS [Quantity]
	--# Comment out 7-- ,CASE 
		--WHEN [TR_Demo-DB].[dbo].[EKPO].RETPO IS NOT NULL THEN -1 
		--ELSE 1 
	  --END * 
	  --CASE 
		--WHEN [TR_Demo-DB].[dbo].[EKPO].BSTYP IN ('A', 'F') THEN [TR_Demo-DB].[dbo].[EKPO].MENGE 
		--ELSE [TR_Demo-DB].[dbo].[EKPO].KTMNG 
	  --END AS [Quantity]
	, [TR_Demo-DB].[dbo].[EKKO].WAERS AS [Currency]
	, 23 AS [SORTING]
FROM [TR_Demo-DB].[dbo].[EKKO]

	INNER JOIN [TR_Demo-DB].[dbo].[EKPO] ON [TR_Demo-DB].[dbo].[EKKO].EBELN = [TR_Demo-DB].[dbo].[EKPO].EBELN /*AND dbo.EKKO.BUKRS = dbo.EKPO.BUKRS*/ -- changed with release 7
	LEFT OUTER JOIN [TR_Demo-DB].[dbo].[T001] ON [TR_Demo-DB].[dbo].[EKKO].BUKRS = [TR_Demo-DB].[dbo].[T001].BUKRS
	--LEFT OUTER JOIN [TR_Demo-DB].[dbo].[T161T] ON [TR_Demo-DB].[dbo].[EKKO].BSART = [TR_Demo-DB].[dbo].[T161T].BSART AND [TR_Demo-DB].[dbo].[EKKO].BSTYP = [TR_Demo-DB].[dbo].[T161T].BSTYP AND [TR_Demo-DB].[dbo].[T161T].SPRAS = 'E'
	LEFT OUTER JOIN [TR_Demo-DB].[dbo].[LFA1] ON [TR_Demo-DB].[dbo].[EKKO].LIFNR = [TR_Demo-DB].[dbo].[LFA1].LIFNR AND [TR_Demo-DB].[dbo].[EKKO].LIFNR is not NULL 
	LEFT OUTER JOIN [TR_Demo-DB].[dbo].[MAKT] ON [TR_Demo-DB].[dbo].[EKPO].MATNR = [TR_Demo-DB].[dbo].[MAKT].MATNR AND [TR_Demo-DB].[dbo].[MAKT].SPRAS = 'E'


UNION ALL

----------------------------------------- GOODS RECEIPT------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

SELECT [TR_Demo-DB].[dbo].[MSEG].EBELN + '-' + CAST([TR_Demo-DB].[dbo].[MSEG].EBELP AS varchar) AS [CASE]
,		CASE WHEN [TR_Demo-DB].[dbo].[MSEG].SHKZG = 'S' THEN 'Goods Receipt'
		 WHEN [TR_Demo-DB].[dbo].[MSEG].SHKZG = 'H' THEN 'Goods Return'
	  	 ELSE '(' + [TR_Demo-DB].[dbo].[MSEG].SHKZG + ')'
	  END AS [EVENT]


,	CAST(CONVERT(VARCHAR, CONCAT(CONVERT(varchar,[TR_Demo-DB].[dbo].[MKPF].CPUDT, 103), ' ',[TR_Demo-DB].[dbo].[MKPF].CPUTM), 103) AS datetime) AS [CREATION DATE]

,	[TR_Demo-DB].[dbo].[MSEG].MJAHR AS [Year]
,	[TR_Demo-DB].[dbo].[MKPF].BLART AS [Document Type]
,	CASE WHEN [TR_Demo-DB].[dbo].[MSEG].BUKRS is not NULL THEN [TR_Demo-DB].[dbo].[MSEG].BUKRS ELSE 'Not set' END AS [CompanyCodeDesc]
,	CASE WHEN [TR_Demo-DB].[dbo].[MKPF].USNAM is not NULL THEN [TR_Demo-DB].[dbo].[MKPF].USNAM ELSE 'Not set' END AS [UserName]
,	CASE WHEN [TR_Demo-DB].[dbo].[MSEG].LIFNR is not NULL THEN [TR_Demo-DB].[dbo].[LFA1].NAME1 ELSE 'Not set' END AS [VendorName]
,	CASE WHEN [TR_Demo-DB].[dbo].[MSEG].LIFNR is not NULL THEN [TR_Demo-DB].[dbo].[MSEG].LIFNR ELSE 'Not set' END AS [VendorCode]
,	CASE WHEN [TR_Demo-DB].[dbo].[MSEG].MATNR is not NULL THEN [TR_Demo-DB].[dbo].[MAKT].MAKTX ELSE 'Not set' END AS [MaterialName]
,	CASE WHEN [TR_Demo-DB].[dbo].[MSEG].SHKZG = 'S' THEN 1 ELSE - 1 END 
		* CAST([TR_Demo-DB].[dbo].[MSEG].DMBTR AS float) AS [AMOUNT]
,	[TR_Demo-DB].[dbo].[MKPF].VGART AS [DOCUMENT_CATEGORY]
,	CASE WHEN [TR_Demo-DB].[dbo].[MSEG].MATNR is not NULL THEN [TR_Demo-DB].[dbo].[MSEG].MATNR ELSE 'Not set' END AS [MaterialCode]


,	[TR_Demo-DB].[dbo].[EKKO].EKORG AS [PurchasingOrg] 	
,	CASE WHEN [TR_Demo-DB].[dbo].[MSEG].SHKZG = 'S' THEN 1 ELSE - 1 END
		* [TR_Demo-DB].[dbo].[MSEG].ERFMG AS [Quantity]
,	[TR_Demo-DB].[dbo].[MSEG].WAERS AS [Currency]
,	CASE WHEN [TR_Demo-DB].[dbo].[MSEG].SHKZG = 'S' THEN 49
		 WHEN [TR_Demo-DB].[dbo].[MSEG].SHKZG = 'H' THEN 50 END AS [SORTING]



FROM [TR_Demo-DB].[dbo].[MKPF] 
	JOIN [TR_Demo-DB].[dbo].[MSEG] ON [TR_Demo-DB].[dbo].[MKPF].MBLNR = [TR_Demo-DB].[dbo].[MSEG].MBLNR AND [TR_Demo-DB].[dbo].[MKPF].MJAHR = [TR_Demo-DB].[dbo].[MSEG].MJAHR
	JOIN [TR_Demo-DB].[dbo].[EKPO] ON [TR_Demo-DB].[dbo].[EKPO].EBELN = [TR_Demo-DB].[dbo].[MSEG].EBELN AND [TR_Demo-DB].[dbo].[EKPO].EBELP = [TR_Demo-DB].[dbo].[MSEG].EBELP
	JOIN [TR_Demo-DB].[dbo].[EKKO] ON [TR_Demo-DB].[dbo].[EKKO].EBELN = [TR_Demo-DB].[dbo].[EKPO].EBELN
	LEFT OUTER JOIN [TR_Demo-DB].[dbo].[T001] ON [TR_Demo-DB].[dbo].[MSEG].BUKRS = [TR_Demo-DB].[dbo].[T001].BUKRS
	LEFT OUTER JOIN [TR_Demo-DB].[dbo].[LFA1] ON [TR_Demo-DB].[dbo].[MSEG].LIFNR = [TR_Demo-DB].[dbo].[LFA1].LIFNR 
	LEFT OUTER JOIN [TR_Demo-DB].[dbo].[MAKT] ON [TR_Demo-DB].[dbo].[MSEG].MATNR = [TR_Demo-DB].[dbo].[MAKT].MATNR

UNION ALL
----------------------------------BILLING--------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------


SELECT 
	[TR_Demo-DB].[dbo].[RSEG].EBELN + '-' + CAST([TR_Demo-DB].[dbo].[RSEG].EBELP AS varchar) AS [CASE]
,	CASE WHEN [TR_Demo-DB].[dbo].[RSEG].SHKZG = 'S' THEN 'Invoice Receipt'
		WHEN [TR_Demo-DB].[dbo].[RSEG].SHKZG = 'H' THEN 'Credit Note' END AS [EVENT]  
,	CAST(CONVERT(DATETIME, CONCAT(CONVERT(varchar,[TR_Demo-DB].[dbo].[RBKP].CPUDT, 103), ' ',[TR_Demo-DB].[dbo].[RBKP].CPUTM), 103) AS datetime) AS [CREATION_DATE]
,	[TR_Demo-DB].[dbo].[RBKP].GJAHR AS [Year]
,	CASE WHEN [TR_Demo-DB].[dbo].[RBKP].BUKRS is not NULL THEN [TR_Demo-DB].[dbo].[RBKP].BUKRS ELSE 'Not set' END AS [CompanyCodeDesc]
,	[TR_Demo-DB].[dbo].[RBKP].BLART AS [DOCUMENT_TYPE]
,	CASE WHEN [TR_Demo-DB].[dbo].[RBKP].USNAM is not NULL THEN [TR_Demo-DB].[dbo].[RBKP].USNAM ELSE 'Not set' END AS [UserName]
,	CASE WHEN [TR_Demo-DB].[dbo].[RBKP].LIFNR is not NULL THEN [TR_Demo-DB].[dbo].[LFA1].NAME1 ELSE 'Not set' END AS [VendorName]
,	CASE WHEN [TR_Demo-DB].[dbo].[RBKP].LIFNR is not NULL THEN [TR_Demo-DB].[dbo].[RBKP].LIFNR ELSE 'Not set' END AS [VendorCode]
,	CASE WHEN [TR_Demo-DB].[dbo].[RSEG].MATNR is not NULL THEN [TR_Demo-DB].[dbo].[MAKT].MAKTX ELSE 'Not set' END AS [MaterialName]
,	CASE WHEN [TR_Demo-DB].[dbo].[RSEG].SHKZG = 'S' THEN (1.0) WHEN [TR_Demo-DB].[dbo].[RSEG].SHKZG = 'H' THEN (-1.0) END 
		* CAST([TR_Demo-DB].[dbo].[RSEG].WRBTR AS DECIMAL(10,2)) AS [AMOUNT]--Currency rate ile çarpmamýz gerkeiyor mu?
,	[TR_Demo-DB].[dbo].[RBKP].VGART AS [Document Category]
,	CASE WHEN ([TR_Demo-DB].[dbo].[RSEG].MATNR is not NULL) AND ([TR_Demo-DB].[dbo].[RSEG].MATNR = '') 
		THEN [TR_Demo-DB].[dbo].[RSEG].MATNR ELSE 'Not set' END AS [MaterialCode]
,	[TR_Demo-DB].[dbo].[EKKO].EKORG AS [PurchasingOrg]
,	CASE WHEN [TR_Demo-DB].[dbo].[RSEG].SHKZG = 'S' THEN 1 ELSE - 1 END
		* [TR_Demo-DB].[dbo].[RSEG].MENGE AS [Quantity]
,	[TR_Demo-DB].[dbo].[RBKP].WAERS AS [Currency]
,	CASE WHEN [TR_Demo-DB].[dbo].[RSEG].SHKZG = 'S' THEN 51
		 WHEN [TR_Demo-DB].[dbo].[RSEG].SHKZG = 'H' THEN 52 END AS [SORTING]
	

FROM
	[TR_Demo-DB].[dbo].[RBKP]
	JOIN [TR_Demo-DB].[dbo].[RSEG] ON [TR_Demo-DB].[dbo].[RBKP].BELNR = [TR_Demo-DB].[dbo].[RSEG].BELNR AND [TR_Demo-DB].[dbo].[RBKP].GJAHR = [TR_Demo-DB].[dbo].[RSEG].GJAHR
	LEFT OUTER JOIN [TR_Demo-DB].[dbo].[LFA1] ON [TR_Demo-DB].[dbo].[RBKP].LIFNR = [TR_Demo-DB].[dbo].[LFA1].LIFNR
	LEFT OUTER JOIN [TR_Demo-DB].[dbo].[MAKT] ON [TR_Demo-DB].[dbo].[RSEG].MATNR = [TR_Demo-DB].[dbo].[MAKT].MATNR
	JOIN [TR_Demo-DB].[dbo].[EKPO] ON [TR_Demo-DB].[dbo].[EKPO].EBELN = [TR_Demo-DB].[dbo].[RSEG].EBELN AND [TR_Demo-DB].[dbo].[EKPO].EBELP = [TR_Demo-DB].[dbo].[RSEG].EBELP
	JOIN [TR_Demo-DB].[dbo].[EKKO] ON [TR_Demo-DB].[dbo].[EKKO].EBELN = [TR_Demo-DB].[dbo].[EKPO].EBELN

