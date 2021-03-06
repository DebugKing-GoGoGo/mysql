SELECT 
base.*,
IFNULL(rlcb.`实际工资`,0) `实际工资`,
IFNULL(fycb.`实际费用`,0) `实际费用`
from (
		SELECT 
			a.ID `预算ID`,
			S_BUDGTCODE `预算编号`,
			S_BUDGTNAME `预算名称`,
			CONCAT(b.dict_name,'-',d.S_GENRENAME) `预算类型`,
			-- c.dict_name `预算状态`,
			DL_TOTAMONEY `预算总额`,
			null `预算费用`,null `预算人力`,
			null `id`, null `编号`, null `名称`,
			u.REAL_NAME `预算建立人`,
			case LENGTH(a.S_BUDGETDPT) 
			when 10 then b1.S_NAME
			when 13 then CONCAT(b1.S_NAME,'-',c1.s_name)
			when 16 then CONCAT(b1.s_name,'-',c1.s_name,'-',d1.s_name)
			end `预算归属部门`
			-- ngoss.getusername(a.OWNER_ID) `预算建立人`,
			-- ngoss.getfullorgname(a.S_BUDGETDPT) `预算归属部门`
			from MDL_AOS_FIBGTAPP a
			left join (SELECT * from plf_aos_dictionary where DICT_TYPE like 'BGTAPLYTP') b on b.dict_code = a.S_BGTAPLYTP
			left join (SELECT * from plf_aos_dictionary where DICT_TYPE = 'TradSte') c on c.dict_code = a.S_BUDGETSTE
			left join mdl_aos_fibgtcost d on a.I_BGTCOSTID = d.ID
			left join plf_aos_auth_user u on u.ID = a.OWNER_ID
			left join mdl_aos_hrorg b1 on left(a.S_BUDGETDPT, 10) = b1.s_orgcode
			left join mdl_aos_hrorg c1 on left(a.S_BUDGETDPT, 13) = c1.s_orgcode
			left join mdl_aos_hrorg d1 on left(a.S_BUDGETDPT, 16) = d1.s_orgcode
			where S_BUDGETSTE = 31 and a.IS_DELETE = 0

			union all
			SELECT 
				ps.ID,
				ps.s_prescode `售前编号`,
				ps.S_PRESNAME `售前名称`,
				CONCAT(psapptype.dict_name, '-', prestype.DICT_NAME) `预算类型`,
				IFNULL(ps.DL_PRESUMFEE,0) + IFNULL(ps.DL_SUMAMT,0) `总额`,
				ps.DL_PRESUMFEE `预计费用总额`,
				ps.DL_SUMAMT `预计人天总额`,
				ps.I_POID `项目商机ID`, po.S_POCODE `项目商机编号`,	po.S_PONAME `项目商机名称`,
			-- 	ngoss.getusername(ps.OWNER_ID),
			-- 	ngoss.getfullorgname(sale.ORG_CODE)
			u.REAL_NAME,
			case LENGTH(sale.ORG_CODE) 
			when 10 then b1.S_NAME
			when 13 then CONCAT(b1.S_NAME,'-',c1.s_name)
			when 16 then CONCAT(b1.s_name,'-',c1.s_name,'-',d1.s_name)
			end
			from MDL_AOS_SAPOPSAPP ps
			left join mdl_aos_sapoinf po on ps.I_POID = po.ID
			left join plf_aos_auth_user sale on sale.ID = ps.S_SALEMAN
			left join (SELECT * from plf_aos_dictionary prestype where DICT_TYPE = 'prestype')prestype on prestype.dict_code = ps.S_PRESTYPE
			left join (SELECT * from plf_aos_dictionary where DICT_TYPE = 'postatus') postatus on postatus.dict_code = po.S_POSTATUS
			left join (SELECT * from plf_aos_dictionary where DICT_TYPE = 'ApproStatus') appstatus on appstatus.dict_code = ps.S_APPSTATUS
			left join (SELECT * from plf_aos_dictionary where DICT_TYPE = 'psapptype') psapptype on psapptype.dict_code = ps.S_OPERTYPE
			left join plf_aos_auth_user u on ps.OWNER_ID = u.ID
			left join mdl_aos_hrorg b1 on left(sale.ORG_CODE, 10) = b1.s_orgcode
			left join mdl_aos_hrorg c1 on left(sale.ORG_CODE, 13) = c1.s_orgcode
			left join mdl_aos_hrorg d1 on left(sale.ORG_CODE, 16) = d1.s_orgcode
			where 1=1
			and ps.IS_DELETE = 0
			and (ps.S_APPSTATUS <> 2 OR ps.S_OPERTYPE <> '001')
			and (ps.S_APPSTATUS <> 3 OR ps.S_OPERTYPE <> '001')
			and (ps.S_APPSTATUS <> 4 OR ps.S_OPERTYPE <> '001')

			union all

			SELECT 
			a.ID,
			S_COCODE `客户商机编号`,
			S_CONAME `客户商机名称`,
			'客户商机' `预算类型`,
			IFNULL(DL_PREFEE,0) `预算总金额`,
			DL_PREFEE `预计费用金额`,
			null `预算人力`,
			null, null, null,
			u.REAL_NAME `建立人`,
			case LENGTH(a.ORG_CODE) 
			when 10 then b.S_NAME
			when 13 then CONCAT(b.S_NAME,'-',c.s_name)
			when 16 then CONCAT(b.s_name,'-',c.s_name,'-',d.s_name)
			end `预算归属部门`
			-- ngoss.getusername(OWNER_ID) `建立人`,
			-- ngoss.getfullorgname(ORG_CODE) `预算归属部门`
			from mdl_aos_sacoinf a
			left join plf_aos_auth_user u on u.ID = a.OWNER_ID
			left join mdl_aos_hrorg b on left(a.ORG_CODE, 10) = b.s_orgcode
			left join mdl_aos_hrorg c on left(a.ORG_CODE, 13) = c.s_orgcode
			left join mdl_aos_hrorg d on left(a.ORG_CODE, 16) = d.s_orgcode
			where 1=1
			and (a.S_APPSTATUS <> 2 OR a.S_OPERTYPE <> 1)
			and (a.S_APPSTATUS <> 3 OR a.S_OPERTYPE <> 1)
			and (a.S_APPSTATUS <> 4 OR a.S_OPERTYPE <> 1)
			and a.IS_DELETE = 0

			union all

			SELECT 
			d.ID, d.s_prjno `项目编号`, d.S_PRJNAME `项目名称`, '研发项目' `预算类型`,
			-- DL_ALLMONEY `计划总金额`,DL_COSTMONEY `费用`, DL_MENMONEY `人力`,
			d.DL_BUDTOLCOS `预算成本`, DL_BUDCOSAMT `预算费用成本`, DL_BUDLABAMT `预算人力成本`,

			a.ID,S_PLANCODE `研发计划编号`,S_PLANNAME `研发计划名称`,
			-- ngoss.getusername(a.OWNER_ID) `建立人`,
			-- ngoss.getfullorgname(a.S_DEPT) `预算归属部门`
			jianliren.REAL_NAME `建立人`,
			case LENGTH(a.S_DEPT) 
			when 10 then b1.S_NAME
			when 13 then CONCAT(b1.S_NAME,'-',c1.s_name)
			when 16 then CONCAT(b1.s_name,'-',c1.s_name,'-',d1.s_name)
			end `预算归属部门`
			from mdl_aos_prplan a
			left join (SELECT * from plf_aos_dictionary where DICT_TYPE = 'FPoperation') b on b.dict_code = a.s_opertype
			left join plf_aos_auth_user jianliren on jianliren.ID = a.OWNER_ID
			left join mdl_aos_prpstage c on c.I_PLANID = a.ID
			left join mdl_aos_project d on d.I_PRPSID = c.ID
			left join mdl_aos_hrorg b1 on left(a.s_dept, 10) = b1.s_orgcode
			left join mdl_aos_hrorg c1 on left(a.s_dept, 13) = c1.s_orgcode
			left join mdl_aos_hrorg d1 on left(a.s_dept, 16) = d1.s_orgcode
			where 1=1
				and a.S_APPSTATUS = 1 and a.IS_DELETE = 0 
				and d.ID is not null and d.IS_DELETE = 0 
			and (d.S_APPSTATUS <> 2 OR d.S_OPERTYPE <> '01')
			and (d.S_APPSTATUS <> 3 OR d.S_OPERTYPE <> '01')
			and (d.S_APPSTATUS <> 4 OR d.S_OPERTYPE <> '01')

			union all

			SELECT 
			d.ID, d.s_prjno `项目编号`, d.S_PRJNAME `项目名称`, '实施项目' `预算类型`,
			-- DL_ALLMONEY `计划总金额`,DL_COSTMONEY `费用`, DL_MENMONEY `人力`,
			d.DL_BUDTOLCOS `预算成本`, DL_BUDCOSAMT `预算费用成本`, DL_BUDLABAMT `预算人力成本`,

			a.ID, a.S_POCODE `项目商机编号`,S_PONAME `项目商机名称`,
			-- ngoss.getusername(a.OWNER_ID) `建立人`,
			-- ngoss.getfullorgname(a.S_DEPT) `预算归属部门`
			jianliren.REAL_NAME `建立人`,
			case LENGTH(d.S_DEPT) 
			when 10 then b1.S_NAME
			when 13 then CONCAT(b1.S_NAME,'-',c1.s_name)
			when 16 then CONCAT(b1.s_name,'-',c1.s_name,'-',d1.s_name)
			end `预算归属部门`
			from mdl_aos_sapoinf a
			left join plf_aos_auth_user jianliren on jianliren.ID = a.OWNER_ID
			left join mdl_aos_sapnotify c on c.I_POID = a.ID
			left join mdl_aos_project d on d.I_PRJNOTICE = c.ID
			left join mdl_aos_hrorg b1 on left(d.s_dept, 10) = b1.s_orgcode
			left join mdl_aos_hrorg c1 on left(d.s_dept, 13) = c1.s_orgcode
			left join mdl_aos_hrorg d1 on left(d.s_dept, 16) = d1.s_orgcode
			where 1=1
				and a.IS_DELETE = 0 
				and d.ID is not null and d.IS_DELETE = 0 
			and (d.S_APPSTATUS <> 2 OR d.S_OPERTYPE <> '01')
			and (d.S_APPSTATUS <> 3 OR d.S_OPERTYPE <> '01')
			and (d.S_APPSTATUS <> 4 OR d.S_OPERTYPE <> '01')
)base
left join (
		SELECT
			budgetno, budgettype,
			SUM(case when type = 1 then amt else 0 end) `标准工资`,
			SUM(case when type = 2 then amt else 0 end) '标准十三薪奖金',
			SUM(case when type = 3 then amt else 0 end) '差旅费',
			SUM(case when type = 4 then amt else 0 end) `实际工资`,
			SUM(case when type = 5 then amt else 0 end) '五险一金' 
		FROM `t_snap_fi_standardcost` standardcost
		where type != 6
		GROUP BY budgetno
)rlcb on rlcb.budgetno = base.`预算编号`
left join (
		SELECT  budgetno, SUM(debit) `实际费用`
		from t_snap_fi_voucher
		where 1=1
		and acctdate is not NULL
		and busitype = '报销申请'
		GROUP BY budgetno
)fycb on fycb.budgetno = base.`预算编号`
-- where base.`预算编号` like 'yy%'