-- This script creates activity table for process mining.--
https://github.com/samozturk/SAP-P2P-Process-Mining-Activity-Table
CREATE TABLE [TR_Demo-DB].[dbo].[P2P_ACTIVITY_TABLE](
	[CASE]					varchar (20)	NOT NULL,
	[EVENT]					varchar(20)	NOT NULL,
	[CREATION DATA]				datetime	NOT NULL,
	[YEAR]					date		NOT NULL,
	[DOCUMENT_TYPE]				varchar(3)	NOT NULL,
	[Company]				varchar(4)	NOT NULL,
	[User Name]				varchar(20)	NOT NULL,
	[Vendor Name]				varchar(50)	NOT NULL,
	[Vendor Code]				varchar(10)	NOT NULL,
	[Material Name]				varchar(50)	NOT NULL,
	[AMOUNT]				decimal(10,2)	NOT NULL,
	[DOCUMENT_CATEGORY]			varchar(3)	NOT NULL,
	[Material Code]				varchar(10)	NOT NULL,
	[Purchasing Organization]		varchar(5)	NOT NULL,
	[Quantity]				int		NOT NULL,
	[Currency]				varchar(3)	NOT NULL,
	[SORTING]				int		NOT NULL,
	[Currency Rate]				decimal(19,4)	NOT NULL
)
