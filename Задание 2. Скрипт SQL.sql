/* Задание 2. 
Создадим таблицу в СУБД со всей необходимой для выполнения задания информацией, которую мы будем 
обрабатывать в python. Возьмем ISIN и размер ближайшей купонной выплаты из таблицы с результатами торгов. 
*/
SELECT [ISIN], [CPN] INTO [HW].[dbo].[coupon_data]
FROM [HW].[dbo].[base_prices]
WHERE [CPN] != ' '
GO


/* В выгруженных данных есть проблема: в качестве десятичного разделителя выступает запятая, которую СУБД не
признает в данной роли. Решим проблему заменой. 
*/
UPDATE [HW].[dbo].[coupon_data]
SET [CPN] = REPLACE([CPN], ',', '.');
GO

/* После этого можем изменить формат столбца [CPN] на числовой. */
ALTER TABLE [HW].[dbo].[coupon_data] ALTER COLUMN [CPN] float NOT NULL;
GO

/*Для каждой облигациии посчитаем средний размер ближайшей купонной выплаты.*/
SELECT [ISIN], AVG([CPN]) as coupon
INTO [HW].[dbo].[coupon_data2]
FROM [HW].[dbo].[coupon_data]
GROUP BY [ISIN]
GO

/* Создаем на основе таблицы [HW].[dbo].[bond_discription] и данных по среднему купону таблицу со всей 
необходимой для выполнения задания 2 информацией. Данная таблица готова для выгрузки в python.
*/
SELECT [ISIN, RegCode, NRDCode], [IssuerName], [SumMarketVal], [EndMtyDate], [BegDistDate], [SecurityType], [CouponType], [HaveOffer], [CouponPerYear], [Basis], [FaceFTName], [AmortisedMty], [FaceValue], [coupon]
INTO [HW].[dbo].[bond_information]
FROM [HW].[dbo].[bond_discription] LEFT JOIN [HW].[dbo].[coupon_data2]
ON [HW].[dbo].[bond_discription].[ISIN, RegCode, NRDCode] = [HW].[dbo].[coupon_data2].[ISIN]
WHERE [IssuerName] !=' '
GO


/* Для интереса посмотрим, сколько облигаций удовлетворяют условиям пункта е).
Всего: 446 облигации (из 2935).
*/
SELECT [ISIN, RegCode, NRDCode] 
INTO [HW].[dbo].[normal_bonds] 
FROM [HW].[dbo].[bond_information]
WHERE [CouponType] = 'Постоянный' AND [HaveOffer] = 0 AND [AmortisedMty] = 0 AND [FaceFTName] = 'RUB'
GO

/* Из них у 232 (из 446) нет информации о купонах.*/
SELECT [ISIN, RegCode, NRDCode] 
INTO [HW].[dbo].[normal_bonds_with_uknown_coupon] 
FROM [HW].[dbo].[bond_information]
WHERE [CouponType] = 'Постоянный' AND [HaveOffer] = 0 AND [AmortisedMty] = 0 AND [FaceFTName] = 'RUB' AND coupon is null
GO


/* И только у 214 (из 446) есть информация о купонах.*/
SELECT *
INTO [HW].[dbo].[normal_bonds_with_known_coupon] 
FROM [HW].[dbo].[bond_information]
WHERE [CouponType] = 'Постоянный' AND [HaveOffer] = 0 AND [AmortisedMty] = 0 AND [FaceFTName] = 'RUB' AND coupon is not null
GO

/* То есть вот список облигаций, по которым в пункте е) возможно построить график выплат. Всего 214 из 2935.*/
SELECT * FROM [HW].[dbo].[normal_bonds_with_known_coupon];
GO