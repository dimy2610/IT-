/* Задание 3. 
Создадим таблицу в СУБД с данными о доходностях облигаций, которые мы будем обрабатывать в python. 
Возьмем эту информацию из таблицы с результатами торгов и создадим новую таблицу, из которой 
мы будем тянуть данные по определенной облигации в python. 
*/
SELECT [TIME],[Y2O_ASK], [Y2O_BID], [YIELD_ASK],[YIELD_BID],[ISIN]
INTO [HW].[dbo].[bond_yields]
FROM [HW].[dbo].[base_prices];
GO

/* В выгруженных данных есть проблема: в качестве десятичного разделителя выступает запятая, которую СУБД не
признает в данной роли. Решим проблему заменой. 
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

/* Теперь можем заменить форматы столбцов на числовой. */
ALTER TABLE [HW].[dbo].[bond_yields] ALTER COLUMN [Y2O_ASK] float;
ALTER TABLE [HW].[dbo].[bond_yields] ALTER COLUMN [Y2O_BID] float;
ALTER TABLE [HW].[dbo].[bond_yields] ALTER COLUMN [YIELD_ASK] float;
ALTER TABLE [HW].[dbo].[bond_yields] ALTER COLUMN [YIELD_BID] float;
GO

/* Теперь таблица готова.*/
SELECT * FROM [HW].[dbo].[bond_yields];
GO


