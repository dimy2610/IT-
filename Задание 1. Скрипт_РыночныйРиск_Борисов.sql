/* Пункт 1.
Сначала объединим 2 таблицы с данными о торгах в одну.*/
SELECT * INTO [HW].[dbo].[base_prices] FROM [HW].[dbo].[base1]
UNION ALL
SELECT * FROM [HW].[dbo].[base2];
GO

/*Изменим в новой таблице формат данных у переменных ID и ISIN для удобства при установки внешних ключей.*/
ALTER TABLE [HW].[dbo].[base_prices] ALTER COLUMN ID int NOT NULL;
ALTER TABLE [HW].[dbo].[base_prices] ALTER COLUMN ISIN varchar(50) NOT NULL;
GO

/*Изменим в таблице [bond_discription] формат данных у переменной [ISIN, RegCode, NRDCode] для удобства 
при установке первичного ключа данной таблицы.*/
ALTER TABLE [HW].[dbo].[bond_discription] ALTER COLUMN [ISIN, RegCode, NRDCode] varchar(50) NOT NULL;
GO

/*Изменим в таблице [instrs] формат данных у переменной [ID] для удобства при установке первичного ключа данной таблицы.*/
ALTER TABLE [HW].[dbo].[instrs] ALTER COLUMN ID int NOT NULL;
GO

/*Ставим первичный ключ в таблице [instrs].*/
ALTER TABLE [HW].[dbo].[instrs] ADD PRIMARY KEY (ID);
GO

/*Ставим первичный ключ в таблице [bond_discription].*/
ALTER TABLE [HW].[dbo].[bond_discription] ADD PRIMARY KEY ([ISIN, RegCode, NRDCode]);
GO

/*Ставим внешний ключ в таблице с результатами торгов на переменной ID (первичным ключом в таблице [instrs]), 
который будет связывать данную таблицу с таблицей [instrs].*/
ALTER TABLE [HW].[dbo].[base_prices] ADD CONSTRAINT FK_base1 FOREIGN KEY (ID) 
REFERENCES [HW].[dbo].[instrs] (ID); 
GO 

/*Переменная ISIN в таблице [base_prices] может  принимать такие значения, которые не принимает переменная [ISIN, RegCode, NRDCode]
 из таблицы [bond_discription]. Отметим также, что по той же причине не удавалось связать таблицы [bond_discription] и [instrs].
 Для того, чтобы связать таблицы [base_prices] и [bond_discription], необходимо исправить это. Выберем те значения ID из таблицы [base_prices],
 для которых нет соответствующих ISIN в таблице [bond_discription], чтобы потом удалить эти строчки.*/
 SELECT [HW].[dbo].[base_prices].[ID] INTO [HW].[dbo].[uknownISINs_ID]
 FROM [HW].[dbo].[base_prices] LEFT JOIN [HW].[dbo].[bond_discription] 
	ON [base_prices].[ISIN] = [bond_discription].[ISIN, RegCode, NRDCode]
	WHERE [bond_discription].[ISIN, RegCode, NRDCode] IS NULL;
	GO

/*Сохраним информацию из строчек, которые собираемся удалить, в отдельную таблицу [HW].[dbo].[uknownISINs_ID].*/
SELECT * INTO [HW].[dbo].[uknownISINs_prices]
 FROM [HW].[dbo].[base_prices]  
		WHERE [ID] IN (SELECT [ID] FROM [HW].[dbo].[uknownISINs_ID]) ;
	GO

/*Удаляем строчки из таблицы [base_prices],  для которых нет соответствующих ISIN в таблице [bond_discription] .*/
DELETE FROM [HW].[dbo].[base_prices]  
		WHERE [ID] IN (SELECT [ID] FROM [HW].[dbo].[uknownISINs_ID]) ;
	GO

/*Ставим внешний ключ в таблице с результатами торгов на переменной ISIN (первичным ключом в таблице [bond_discription]), 
который будет связывать данную таблицу с таблицей [bond_discription].*/
ALTER TABLE [HW].[dbo].[base_prices] ADD CONSTRAINT FK_base2 FOREIGN KEY (ISIN)     
    REFERENCES [HW].[dbo].[bond_discription] ([ISIN, RegCode, NRDCode]);    
GO


/* Пункт 2.
Первым запросом считаем долю в процентах пустых строк в столбце [ISIN144A].*/
SELECT COUNT(*)*100/(SELECT COUNT(*) FROM [HW].[dbo].[bond_discription]) FROM [HW].[dbo].[bond_discription] WHERE [ISIN144A]=' ';
GO

 /*Получили 99%. Значит в столбце меньше, чем в 10% ячеек есть значения.
Столбец нужно убрать.
Следующим запросом сохраняем значения непустых строк в столбце [ISIN144A] в новую таблицу,
чтобы в случае необходимости данную информацию было можно найти.*/
SELECT [ISIN, RegCode, NRDCode], [ISIN144A] INTO [HW].[dbo].[bond_discription_ISIN144A] FROM [HW].[dbo].[bond_discription] WHERE [ISIN144A] !=' ';
GO

 /*После этого столбец можно удалить.*/
ALTER TABLE [HW].[dbo].[bond_discription] DROP COLUMN [ISIN144A];
GO
 /*База данных очищена от почти пустого столбца. При этом имеющаяся в нем информация сохранена.*/


 /* Пункт 3.
Первым определим, по каким ценным бумагам доля дней, в которые нет котировки или торговли не было, 
была не более 10%. Значит нам нужна таблица с данными о торгах. 
Для начала изменим формат данных в столбце [TIME] с текстового на целочисленный, 
т.к. в будущем нам нужно будет провести сортировку по данныму столбцу.*/
ALTER TABLE [HW].[dbo].[base_prices] ALTER COLUMN [TIME] INT;
GO

/* Скопируем таблицу с данными о торгах в отдельную таблицу [HW].[dbo].[task3] и проведем в ней сортировку по времени.*/
SELECT * INTO [HW].[dbo].[task3] FROM [HW].[dbo].[base_prices]	
ORDER BY [TIME];	
GO
/* Возьмем только нужные нам переменные  ID, [TIME], ASK, а также значения предыдущих периодов переменных ID, ASK.
Проведем сортировку новой таблице по ID. Сортировки по времени и по ID позволили нам удобным образом расположить строки в таблице.*/
SELECT ID, [TIME], ISIN, ASK, LAG(ASK,1,0) OVER (ORDER BY ID) AS ASK_prev, LAG(ID,1,0) OVER (ORDER BY ID) AS ID_prev
INTO [HW].[dbo].[task3_1] FROM [HW].[dbo].[task3]
ORDER BY [ID];	
GO

/* Удалим из таблицы "первые" дни торгов (дни, в которые нет информации о торгах по данной ценной бумаге 
в прошлый день торгов), если в эти дни были котировки.*/
DELETE FROM [HW].[dbo].[task3_1] WHERE ID != ID_prev AND ASK != ' ';
GO

/* Для каждой ценной бумаги посчитаем, сколько дней по ней не было торгов или котировки*/
SELECT ID, COUNT([TIME]) AS n_days 
INTO [HW].[dbo].[task3_2] FROM [HW].[dbo].[task3_1] 
WHERE ASK=ASK_prev OR ASK=' ' GROUP BY ID;
GO

/* Для каждой ценной бумаги посчитаем, по скольким дням о ней есть информация.*/
SELECT ID, COUNT([TIME]) AS N
INTO [HW].[dbo].[task3_3] FROM [HW].[dbo].[task3_1] 
GROUP BY ID;
GO

/* Объединим данные и найдем для каждой ценной бумаги долю дней, в которые по ней не было торгов или котировки.
Выберем только те ценные бумаги, по которым доля дней, в которые нет котировки или торговли не было, была не более 10%.
Первый шаг зывершен.*/
SELECT [HW].[dbo].[task3_3].[ID],n_days, N, n_days*100/N AS share
INTO [HW].[dbo].[task3_4]
FROM [HW].[dbo].[task3_2] RIGHT JOIN [HW].[dbo].[task3_3]
ON [HW].[dbo].[task3_3].[ID]= [HW].[dbo].[task3_2].[ID]
WHERE [HW].[dbo].[task3_2].[n_days] IS NULL OR n_days*100/N <= 10; 
GO

/* Теперь из имеющихся ценных бумаг нужно отобрать только те, которые являются облигациями и 
торгуются на Московской Бирже в режиме Основных торгов. 
Для этого нам нужно выбрать данные по имеющимся ID из таблицы [instrs] и поставить соответствующие фильтры.*/
SELECT [HW].[dbo].[task3_4].[ID], Exchange, CFIName, EmitentName
INTO [HW].[dbo].[task3_5]
FROM [HW].[dbo].[task3_4] INNER JOIN [HW].[dbo].[instrs]
ON [HW].[dbo].[task3_4].[ID]= [HW].[dbo].[instrs].[ID]
WHERE Exchange = 'Московская Биржа / МБ - Основной' 
AND (CFIName = 'Облигации / Сектор / Корпоративные' OR CFIName = 'Облигации / Сектор / Региональные');  
GO

/* Получили, что все выбранные на первом шаге ценные бумаги оказались облигациями, торгуемыми на Московской Бирже в основном режиме. 
Всего 11 ценных бумаг. Нам нужен список из трех эмитентов. Возьмем, например, трех первых. Задание выполнено.*/
SELECT TOP(3) EmitentName
FROM [HW].[dbo].[task3_5]
GROUP BY EmitentName;
GO