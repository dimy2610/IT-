/* ������� 2. 
�������� ������� � ���� �� ���� ����������� ��� ���������� ������� �����������, ������� �� ����� 
������������ � python. ������� ISIN � ������ ��������� �������� ������� �� ������� � ������������ ������. 
*/
SELECT [ISIN], [CPN] INTO [HW].[dbo].[coupon_data]
FROM [HW].[dbo].[base_prices]
WHERE [CPN] != ' '
GO


/* � ����������� ������ ���� ��������: � �������� ����������� ����������� ��������� �������, ������� ���� ��
�������� � ������ ����. ����� �������� �������. 
*/
UPDATE [HW].[dbo].[coupon_data]
SET [CPN] = REPLACE([CPN], ',', '.');
GO

/* ����� ����� ����� �������� ������ ������� [CPN] �� ��������. */
ALTER TABLE [HW].[dbo].[coupon_data] ALTER COLUMN [CPN] float NOT NULL;
GO

/*��� ������ ���������� ��������� ������� ������ ��������� �������� �������.*/
SELECT [ISIN], AVG([CPN]) as coupon
INTO [HW].[dbo].[coupon_data2]
FROM [HW].[dbo].[coupon_data]
GROUP BY [ISIN]
GO

/* ������� �� ������ ������� [HW].[dbo].[bond_discription] � ������ �� �������� ������ ������� �� ���� 
����������� ��� ���������� ������� 2 �����������. ������ ������� ������ ��� �������� � python.
*/
SELECT [ISIN, RegCode, NRDCode], [IssuerName], [SumMarketVal], [EndMtyDate], [BegDistDate], [SecurityType], [CouponType], [HaveOffer], [CouponPerYear], [Basis], [FaceFTName], [AmortisedMty], [FaceValue], [coupon]
INTO [HW].[dbo].[bond_information]
FROM [HW].[dbo].[bond_discription] LEFT JOIN [HW].[dbo].[coupon_data2]
ON [HW].[dbo].[bond_discription].[ISIN, RegCode, NRDCode] = [HW].[dbo].[coupon_data2].[ISIN]
WHERE [IssuerName] !=' '
GO


/* ��� �������� ���������, ������� ��������� ������������� �������� ������ �).
�����: 446 ��������� (�� 2935).
*/
SELECT [ISIN, RegCode, NRDCode] 
INTO [HW].[dbo].[normal_bonds] 
FROM [HW].[dbo].[bond_information]
WHERE [CouponType] = '����������' AND [HaveOffer] = 0 AND [AmortisedMty] = 0 AND [FaceFTName] = 'RUB'
GO

/* �� ��� � 232 (�� 446) ��� ���������� � �������.*/
SELECT [ISIN, RegCode, NRDCode] 
INTO [HW].[dbo].[normal_bonds_with_uknown_coupon] 
FROM [HW].[dbo].[bond_information]
WHERE [CouponType] = '����������' AND [HaveOffer] = 0 AND [AmortisedMty] = 0 AND [FaceFTName] = 'RUB' AND coupon is null
GO


/* � ������ � 214 (�� 446) ���� ���������� � �������.*/
SELECT *
INTO [HW].[dbo].[normal_bonds_with_known_coupon] 
FROM [HW].[dbo].[bond_information]
WHERE [CouponType] = '����������' AND [HaveOffer] = 0 AND [AmortisedMty] = 0 AND [FaceFTName] = 'RUB' AND coupon is not null
GO

/* �� ���� ��� ������ ���������, �� ������� � ������ �) �������� ��������� ������ ������. ����� 214 �� 2935.*/
SELECT * FROM [HW].[dbo].[normal_bonds_with_known_coupon];
GO