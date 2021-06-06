<cfcomponent output='false' singleton >
	
	
	<!--- Dependencies --->
	<cfproperty name="dsnHRTEST" inject="coldbox:setting:dsnHRTEST" />

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor" >
		<cfreturn this />
	</cffunction>
	
	
	<!--- get base current info for employee  --->
	<cffunction name="GetEmpBaseInfo" access="public" output="false" returntype="any">
		<cfargument name="PSUID" type="numeric" required="true" />
		<!--- empire lookup --->
		<cfquery name="local.rsData" datasource="#dsnHRTEST.name#">
			SELECT TOP (1) PP.CODE_EMPL_STUDENT, PP.CODE_EMPL_SEX, PP.CODE_EMPL_ETHNIC, PP.CODE_EMPL_STATUS, 
				PP.DATE_EMPL_BIRTH, PP.DATE_EMPL_HIRED, PP.CODE_EMPL_CLASS, PP.CODE_EMPL_PAY_CALC, 
				PP.DATE_EMPL_PAID, PP.DATE_EMPL_RETIRE, ltrim(rtrim(PP.name_empl_last_legal)) name_empl_last_legal, 
				ltrim(rtrim(PP.name_empl_first_legal)) name_empl_first_legal,
				PP.name_empl_mid_legal, PP.name_empl_sfx_legal, PP.numb_empl_id, PP.HOME_BUDGET, 
				PP.ASSIGNED_SUP_ORG_SP, PP.CODE_BUDG_ADMN_AREA_HOME, PP.CODE_POSN_RANK,
				PP.CODE_APPT, PP.DATE_APPT_BEG, PP.DATE_APPT_END, PP.DATE_EMPL_TERMN, 
				LEFT(SO.Assigned_Sup_Org_Name, CHARINDEX('(',Assigned_Sup_Org_Name) -1) SUP_ORG_DESCRIPTION,
				PP.CODE_POSN_WORK_LOC_CAMPUS CODE_POSN_CAMP_LOC, PP.OHR_GENERIC_TITLE, PP.SUP_ORG
			FROM Dynasty.dbo.v_Position_Person PP LEFT OUTER JOIN 
			Dynasty.WorkDayRoles.tbl_Distinct_SP_Assigned_Sup_Orgs SO ON SO.Assigned_Sup_Org = PP.ASSIGNED_SUP_ORG_SP
			WHERE (PP.numb_empl_id = <cfqueryparam value="#arguments.PSUID#" cfsqltype="cf_sql_varchar">)
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /get base current info for employee --->
	
	<!--- get (primary) Appointment info  --->
	<cffunction name="GetApptPosInfo" access="public" output="false" returntype="any">
		<cfargument name="PSUID" type="numeric" required="true" />
		<cftry>
		<cfquery name="local.rsData" datasource="#dsnHRTEST.name#">
			SELECT TOP (1) CODE_POSN_RANK, OHR_GENERIC_TITLE, CODE_APPT, CODE_POSN_WORK_LOC_CAMPUS CODE_POSN_CAMP_LOC, 
					CODE_BUDG_ADMN_AREA_HOME, DATE_EMPL_TERMN,DATE_APPT_BEG, DATE_APPT_END
			FROM    Dynasty.dbo.v_Position_Person
			WHERE (numb_empl_id = <cfqueryparam value="#arguments.PSUID#" cfsqltype="cf_sql_varchar">)
		</cfquery>
		<cfreturn local.rsData />
			<cfcatch type="database">
				<cfdump var=#cfcatch# abort=true />
			</cfcatch>
		</cftry>
	</cffunction>
	<!--- /get (primary) Appointment info  --->

	<!--- get SP assigned Sup Org based on one emp works in --->
	<cffunction name="GetSPAssignedSupOrg" access="public" output="false" returntype="any">
		<cfargument name="inheritedSupOrg" type="string" required="true" />
		<cfquery name="local.rsData" datasource="#dsnHRTEST.name#">
			SELECT   TOP (1) Inherited_Sup_Org, Assigned_Sup_Org, Assigned_Sup_Org_Name, Inherited_Sup_Org_Name, Strategic_Partner_Position_ID
			FROM    Dynasty.WorkDayRoles.tbl_SP_Sup_Org_Hierarchy
			WHERE (Inherited_Sup_Org = <cfqueryparam value="#arguments.inheritedSupOrg#" cfsqltype="cf_sql_varchar">)
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>

</cfcomponent>