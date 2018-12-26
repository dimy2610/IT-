/* ������� 3. 
�������� ������� � ���� � ������� � ����������� ���������, ������� �� ����� ������������ � python. 
������� ��� ���������� �� ������� � ������������ ������ � �������� ����� �������, �� ������� 
�� ����� ������ ������ �� ������������ ��������� � python. 
*/
SELECT [TIME],[Y2O_ASK], [Y2O_BID], [YIELD_ASK],[YIELD_BID],[ISIN]
INTO [HW].[dbo].[bond_yields]
FROM [HW].[dbo].[base_prices];
GO

/* � ����������� ������ ���� ��������: � �������� ����������� ����������� ��������� �������, ������� ���� ��
�������� � ������ ����. ����� �������� �������. 
*/
UPDATE [HW].[dbo].[bond_yields]
SET [Y2O_ASK] = REPLACE([Y2O_ASK], ',', '.')
GO

UPDATE [HW].[dbo].[bond_yields]
SET [Y2O_BID] = REPLACE([Y2O_BID], ',', '.')
GO

UPDATE [HW].[dbo].[bond_yields]
SET [YIELD_ASK] = REPLACE([YIELD_ASK], ',', '.')
GO

UPDATE [HW].[dbo].[bond_yields]
SET [YIELD_BID] = REPLACE([YIELD_BID], ',', '.');
GO

/* ������ ����� �������� ������� �������� �� ��������. */
ALTER TABLE [HW].[dbo].[bond_yields] ALTER COLUMN [Y2O_ASK] float;
ALTER TABLE [HW].[dbo].[bond_yields] ALTER COLUMN [Y2O_BID] float;
ALTER TABLE [HW].[dbo].[bond_yields] ALTER COLUMN [YIELD_ASK] float;
ALTER TABLE [HW].[dbo].[bond_yields] ALTER COLUMN [YIELD_BID] float;
GO

/* ������ ������� ������.*/
SELECT * FROM [HW].[dbo].[bond_yields];
GO


