DECLARE @CalendarMonths AS TABLE (
  PICKUP_MONTH_DATE DATETIME PRIMARY KEY
)

DECLARE
  @basedate DATETIME,
  @offset   INT
SELECT
  @basedate = '01 Jan 2015'

WHILE (@basedate <= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
BEGIN
  INSERT INTO @CalendarMonths VALUES(@basedate) 
  SET @basedate = DATEADD(MONTH, 1, @basedate)
END

SELECT

final_set.PICKUP_MONTH_DATE,
final_set.PRODUCER_ID,
final_set.PRODUCER_DESC,
final_set.PAYZONE_ID,
final_set.PRODUCER_STATE,
final_set.PLANT_ID,
final_set.PLANT_DESC,
ISNULL(final_set.MILK_POUNDS, 0) AS MILK_POUNDS

FROM
(
	SELECT * FROM
		(
			SELECT * FROM @CalendarMonths months
			CROSS JOIN (
				SELECT DISTINCT
			 
				 producerCd AS PRODUCER_ID,
				 Producerdesc AS PRODUCER_DESC,
				 PayZoneCD AS PAYZONE_ID,
				 FarmState AS PRODUCER_STATE,
				 PlantCd AS PLANT_ID,
				 Plantdesc AS PLANT_DESC
    
				FROM [Logistics_Test].[dbo].[MPIS_LoadSheet_Logistics_vw]

				/*WHERE PayZone = Conventional and Year >= 2015*/
				WHERE YEAR(PickupDatetime) >= 2015 AND PayZoneCD NOT IN(11,12,55,90,91,92,93,94,95,96,98,99,-998)

			) AS combos

		) AS unique_result_set

	LEFT JOIN 

			(SELECT 

			DATEFROMPARTS(YEAR(PickupDatetime), MONTH(PickupDatetime), 1) AS PICKUP_MONTH_DATE2,
			SUM(MilkPounds) AS MILK_POUNDS,
			producerCd AS PRODUCER_ID2,
			Producerdesc AS PRODUCER_DESC2,
			PayZoneCD AS PAYZONE_ID2,
			FarmState AS PRODUCER_STATE2,
			PlantCd AS PLANT_ID2,
			Plantdesc AS PLANT_DESC2
    
			FROM [Logistics_Test].[dbo].[MPIS_LoadSheet_Logistics_vw] logistics

			/*WHERE PayZone = Conventional and Year >= 2015*/
			WHERE YEAR(PickupDatetime) >= 2015 AND PayZoneCD NOT IN(11,12,55,90,91,92,93,94,95,96,98,99,-998)

			GROUP BY DATEFROMPARTS(YEAR(PickupDatetime), MONTH(PickupDatetime), 1),
			producerCd, Producerdesc, PayZoneCD, FarmState, PlantCd, Plantdesc

			) AS main_query

	ON unique_result_set.PICKUP_MONTH_DATE = main_query.PICKUP_MONTH_DATE2
	AND unique_result_set.PRODUCER_ID = main_query.PRODUCER_ID2
	AND unique_result_set.PRODUCER_DESC = main_query.PRODUCER_DESC2
	AND unique_result_set.PAYZONE_ID = main_query.PAYZONE_ID2
	AND unique_result_set.PRODUCER_STATE = main_query.PRODUCER_STATE2
	AND unique_result_set.PLANT_ID = main_query.PLANT_ID2
	AND unique_result_set.PLANT_DESC = main_query.PLANT_DESC2

) AS final_set

WHERE final_set.PLANT_ID = 101 OR final_set.PLANT_ID = 102 OR final_set.PLANT_ID = 100 OR final_set.PLANT_ID = 105 OR final_set.PLANT_ID = 103

