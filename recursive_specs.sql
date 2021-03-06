;WITH tmp(ITEM_NO, ITEM_DESC, LOT_STATUS, LOT_NUM, POUNDS, SUBLOT_NUM, PROD_PLANT, MAJ_PRD_GRP, STATUS_DATE, SPEC_ITEM, SPEC) AS (
	SELECT subQuery.ITEM_NO, subQuery.ITEM_DESC, subQuery.LOT_STATUS, subQuery.LOT_NUM, subQuery.POUNDS, subQuery.SUBLOT_NUM, subQuery.PROD_PLANT, subQuery.MAJ_PRD_GRP, subQuery.STATUS_DATE, LEFT(CAST(subQuery.SPEC AS VARCHAR(MAX)), CHARINDEX('-',subQuery.SPEC+'-')-1), STUFF(subQuery.SPEC, 1, CHARINDEX('-',subQuery.SPEC+'-'), '')
	FROM (
		SELECT 

		inv.item_no AS ITEM_NO,
		inv.item_desc1 AS ITEM_DESC,
		inv.lot_status AS LOT_STATUS,
		inv.lot_no AS LOT_NUM,
		inv.pounds AS POUNDS,
		inv.spec AS SPEC,
		inv.sublot_no AS SUBLOT_NUM,
		inv.production_plant AS PROD_PLANT,
		inv.major_prd_grp AS MAJ_PRD_GRP,
		MAX(inv.RunDate) AS STATUS_DATE

		FROM [DGI].[dbo].[AllocINV_ID_All] inv 
		WHERE inv.lot_status = 'SALE'
		GROUP BY  
		inv.item_no, 
		inv.item_desc1, 
		inv.lot_status, 
		inv.lot_no, 
		inv.pounds, 
		inv.spec, 
		inv.sublot_no, 
		inv.production_plant, 
		inv.major_prd_grp
	) subQuery

	UNION ALL

	SELECT ITEM_NO, ITEM_DESC, LOT_STATUS, LOT_NUM, POUNDS, SUBLOT_NUM, PROD_PLANT, MAJ_PRD_GRP, STATUS_DATE, LEFT(CAST(SPEC AS VARCHAR(MAX)), CHARINDEX('-',SPEC+'-')-1), STUFF(SPEC, 1, CHARINDEX('-',SPEC+'-'), '')
	FROM tmp
	WHERE SPEC > ''

)

SELECT 
nested.ITEM_NO,
nested.ITEM_DESC,
nested.LOT_STATUS,
nested.LOT_NUM,
nested.POUNDS,
nested.SUBLOT_NUM,
nested.PROD_PLANT,
nested.MAJ_PRD_GRP,
MAX(nested.STATUS_DATE) AS STATUS_DATE,
nested.SPEC_ITEM
 
FROM (
	SELECT ITEM_NO, ITEM_DESC, LOT_STATUS, LOT_NUM, POUNDS, SUBLOT_NUM, PROD_PLANT, MAJ_PRD_GRP, STATUS_DATE, SPEC_ITEM
	FROM tmp
) nested

GROUP BY
nested.ITEM_NO,
nested.ITEM_DESC,
nested.LOT_STATUS,
nested.LOT_NUM,
nested.POUNDS,
nested.SUBLOT_NUM,
nested.PROD_PLANT,
nested.MAJ_PRD_GRP,
nested.SPEC_ITEM
