/* ����� 1.
������� ��������� 2 ������� � ������� � ������ � ����.*/
SELECT * INTO [HW].[dbo].[base_prices] FROM [HW].[dbo].[base1]
UNION ALL
SELECT * FROM [HW].[dbo].[base2];
GO

/*������� � ����� ������� ������ ������ � ���������� ID � ISIN ��� �������� ��� ��������� ������� ������.*/
ALTER TABLE [HW].[dbo].[base_prices] ALTER COLUMN ID int NOT NULL;
ALTER TABLE [HW].[dbo].[base_prices] ALTER COLUMN ISIN varchar(50) NOT NULL;
GO

/*������� � ������� [bond_discription] ������ ������ � ���������� [ISIN, RegCode, NRDCode] ��� �������� 
��� ��������� ���������� ����� ������ �������.*/
ALTER TABLE [HW].[dbo].[bond_discription] ALTER COLUMN [ISIN, RegCode, NRDCode] varchar(50) NOT NULL;
GO

/*������� � ������� [instrs] ������ ������ � ���������� [ID] ��� �������� ��� ��������� ���������� ����� ������ �������.*/
ALTER TABLE [HW].[dbo].[instrs] ALTER COLUMN ID int NOT NULL;
GO

/*������ ��������� ���� � ������� [instrs].*/
ALTER TABLE [HW].[dbo].[instrs] ADD PRIMARY KEY (ID);
GO

/*������ ��������� ���� � ������� [bond_discription].*/
ALTER TABLE [HW].[dbo].[bond_discription] ADD PRIMARY KEY ([ISIN, RegCode, NRDCode]);
GO

/*������ ������� ���� � ������� � ������������ ������ �� ���������� ID (��������� ������ � ������� [instrs]), 
������� ����� ��������� ������ ������� � �������� [instrs].*/
ALTER TABLE [HW].[dbo].[base_prices] ADD CONSTRAINT FK_base1 FOREIGN KEY (ID) 
REFERENCES [HW].[dbo].[instrs] (ID); 
GO 

/*���������� ISIN � ������� [base_prices] �����  ��������� ����� ��������, ������� �� ��������� ���������� [ISIN, RegCode, NRDCode]
 �� ������� [bond_discription]. ������� �����, ��� �� ��� �� ������� �� ��������� ������� ������� [bond_discription] � [instrs].
 ��� ����, ����� ������� ������� [base_prices] � [bond_discription], ���������� ��������� ���. ������� �� �������� ID �� ������� [base_prices],
 ��� ������� ��� ��������������� ISIN � ������� [bond_discription], ����� ����� ������� ��� �������.*/
 SELECT [HW].[dbo].[base_prices].[ID] INTO [HW].[dbo].[uknownISINs_ID]
 FROM [HW].[dbo].[base_prices] LEFT JOIN [HW].[dbo].[bond_discription] 
	ON [base_prices].[ISIN] = [bond_discription].[ISIN, RegCode, NRDCode]
	WHERE [bond_discription].[ISIN, RegCode, NRDCode] IS NULL;
	GO

/*�������� ���������� �� �������, ������� ���������� �������, � ��������� ������� [HW].[dbo].[uknownISINs_ID].*/
SELECT * INTO [HW].[dbo].[uknownISINs_prices]
 FROM [HW].[dbo].[base_prices]  
		WHERE [ID] IN (SELECT [ID] FROM [HW].[dbo].[uknownISINs_ID]) ;
	GO

/*������� ������� �� ������� [base_prices],  ��� ������� ��� ��������������� ISIN � ������� [bond_discription] .*/
DELETE FROM [HW].[dbo].[base_prices]  
		WHERE [ID] IN (SELECT [ID] FROM [HW].[dbo].[uknownISINs_ID]) ;
	GO

/*������ ������� ���� � ������� � ������������ ������ �� ���������� ISIN (��������� ������ � ������� [bond_discription]), 
������� ����� ��������� ������ ������� � �������� [bond_discription].*/
ALTER TABLE [HW].[dbo].[base_prices] ADD CONSTRAINT FK_base2 FOREIGN KEY (ISIN)     
    REFERENCES [HW].[dbo].[bond_discription] ([ISIN, RegCode, NRDCode]);    
GO


/* ����� 2.
������ �������� ������� ���� � ��������� ������ ����� � ������� [ISIN144A].*/
SELECT COUNT(*)*100/(SELECT COUNT(*) FROM [HW].[dbo].[bond_discription]) FROM [HW].[dbo].[bond_discription] WHERE [ISIN144A]=' ';
GO

 /*�������� 99%. ������ � ������� ������, ��� � 10% ����� ���� ��������.
������� ����� ������.
��������� �������� ��������� �������� �������� ����� � ������� [ISIN144A] � ����� �������,
����� � ������ ������������� ������ ���������� ���� ����� �����.*/
SELECT [ISIN, RegCode, NRDCode], [ISIN144A] INTO [HW].[dbo].[bond_discription_ISIN144A] FROM [HW].[dbo].[bond_discription] WHERE [ISIN144A] !=' ';
GO

 /*����� ����� ������� ����� �������.*/
ALTER TABLE [HW].[dbo].[bond_discription] DROP COLUMN [ISIN144A];
GO
 /*���� ������ ������� �� ����� ������� �������. ��� ���� ��������� � ��� ���������� ���������.*/


 /* ����� 3.
������ ���������, �� ����� ������ ������� ���� ����, � ������� ��� ��������� ��� �������� �� ����, 
���� �� ����� 10%. ������ ��� ����� ������� � ������� � ������. 
��� ������ ������� ������ ������ � ������� [TIME] � ���������� �� �������������, 
�.�. � ������� ��� ����� ����� �������� ���������� �� ������� �������.*/
ALTER TABLE [HW].[dbo].[base_prices] ALTER COLUMN [TIME] INT;
GO

/* ��������� ������� � ������� � ������ � ��������� ������� [HW].[dbo].[task3] � �������� � ��� ���������� �� �������.*/
SELECT * INTO [HW].[dbo].[task3] FROM [HW].[dbo].[base_prices]	
ORDER BY [TIME];	
GO
/* ������� ������ ������ ��� ����������  ID, [TIME], ASK, � ����� �������� ���������� �������� ���������� ID, ASK.
�������� ���������� ����� ������� �� ID. ���������� �� ������� � �� ID ��������� ��� ������� ������� ����������� ������ � �������.*/
SELECT ID, [TIME], ISIN, ASK, LAG(ASK,1,0) OVER (ORDER BY ID) AS ASK_prev, LAG(ID,1,0) OVER (ORDER BY ID) AS ID_prev
INTO [HW].[dbo].[task3_1] FROM [HW].[dbo].[task3]
ORDER BY [ID];	
GO

/* ������ �� ������� "������" ��� ������ (���, � ������� ��� ���������� � ������ �� ������ ������ ������ 
� ������� ���� ������), ���� � ��� ��� ���� ���������.*/
DELETE FROM [HW].[dbo].[task3_1] WHERE ID != ID_prev AND ASK != ' ';
GO

/* ��� ������ ������ ������ ���������, ������� ���� �� ��� �� ���� ������ ��� ���������*/
SELECT ID, COUNT([TIME]) AS n_days 
INTO [HW].[dbo].[task3_2] FROM [HW].[dbo].[task3_1] 
WHERE ASK=ASK_prev OR ASK=' ' GROUP BY ID;
GO

/* ��� ������ ������ ������ ���������, �� �������� ���� � ��� ���� ����������.*/
SELECT ID, COUNT([TIME]) AS N
INTO [HW].[dbo].[task3_3] FROM [HW].[dbo].[task3_1] 
GROUP BY ID;
GO

/* ��������� ������ � ������ ��� ������ ������ ������ ���� ����, � ������� �� ��� �� ���� ������ ��� ���������.
������� ������ �� ������ ������, �� ������� ���� ����, � ������� ��� ��������� ��� �������� �� ����, ���� �� ����� 10%.
������ ��� ��������.*/
SELECT [HW].[dbo].[task3_3].[ID],n_days, N, n_days*100/N AS share
INTO [HW].[dbo].[task3_4]
FROM [HW].[dbo].[task3_2] RIGHT JOIN [HW].[dbo].[task3_3]
ON [HW].[dbo].[task3_3].[ID]= [HW].[dbo].[task3_2].[ID]
WHERE [HW].[dbo].[task3_2].[n_days] IS NULL OR n_days*100/N <= 10; 
GO

/* ������ �� ��������� ������ ����� ����� �������� ������ ��, ������� �������� ����������� � 
��������� �� ���������� ����� � ������ �������� ������. 
��� ����� ��� ����� ������� ������ �� ��������� ID �� ������� [instrs] � ��������� ��������������� �������.*/
SELECT [HW].[dbo].[task3_4].[ID], Exchange, CFIName, EmitentName
INTO [HW].[dbo].[task3_5]
FROM [HW].[dbo].[task3_4] INNER JOIN [HW].[dbo].[instrs]
ON [HW].[dbo].[task3_4].[ID]= [HW].[dbo].[instrs].[ID]
WHERE Exchange = '���������� ����� / �� - ��������' 
AND (CFIName = '��������� / ������ / �������������' OR CFIName = '��������� / ������ / ������������');  
GO

/* ��������, ��� ��� ��������� �� ������ ���� ������ ������ ��������� �����������, ���������� �� ���������� ����� � �������� ������. 
����� 11 ������ �����. ��� ����� ������ �� ���� ���������. �������, ��������, ���� ������. ������� ���������.*/
SELECT TOP(3) EmitentName
FROM [HW].[dbo].[task3_5]
GROUP BY EmitentName;
GO