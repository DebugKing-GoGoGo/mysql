SELECT
b.username,
a.*
from 
(
	SELECT 
		projectid, projectno, projectname, -- 项目id 编号 名称
		translatedict('IDFS000091',projecttype) as '项目类型',
		getusername(saleid) as sale,-- 销售代表
		(SELECT getunitname(parentunitid) from t_sys_mngunitinfo WHERE unitid = (SELECT deptid from t_sys_mnguserinfo WHERE userid = saleid)) salearea, -- 销售代表所属销售大区
		getusername(pm) as pmname, getusername(pd)pdname,-- 项目经理 总监
		getusername(cust.tecpersonid) tecperson, (SELECT remark4 from t_sys_mngunitinfo WHERE unitid = (select deptid from t_sys_mnguserinfo WHERE userid = cust.tecpersonid)) tecpersonunit,-- 客户经理 客户经理部门
		getunitname(gatheringunitid)signcompany,-- 签约公司
		getcustname(signedcustomer)signcust,-- 签约客户
		getunitname(deptid) unitname,
		DATE_FORMAT(predictstartdate, '%Y-%m-%d') predictstartdate,-- 预计项目开始时间
		DATE_FORMAT(predictenddate, '%Y-%m-%d') predictenddate,-- 预计项目结束时间
		DATE_FORMAT(maintenancedate, '%Y-%m-%d') maintenancedate,-- 维护期结束时间
		case when projstatus= '9' then '项目已取消'  when projstatus= '7'  then '项目暂停' when projstatus= '6' then '是' else '否' end isprojstatus, -- 是否结项
		budgetcontractamout,-- 立项金额
		case when  SUBSTR(p.createtime FROM 1 FOR 4)=DATE_FORMAT(current_timestamp(),'%Y' ) then budgetcontractamout else 0 END yearprojectfigure -- 当年立项金额
	from  t_project_projectinfo p
	join t_sale_custbasicdata cust on p.finalcustomer = cust.custid
	where p.projecttype  not in (5,8) and businesstype in (4,10) and SUBSTRING_INDEX(projectno,'-',1) != 'zl'
) a
join (
	SELECT *
	from t_project_projectperson
) b on a.projectid = b.projectid
where b.salepricelevel is null