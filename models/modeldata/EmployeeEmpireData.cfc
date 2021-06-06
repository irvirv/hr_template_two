<cfcomponent output='false' singleton >
	
	
	<!--- Dependencies --->
	<cfproperty name="dsnHRTEST" inject="coldbox:setting:dsnHRTEST" />

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor" >
		<cfreturn this />
	</cffunction>
	
	<!--- get base current info for employee (Empire) --->
	<cffunction name="GetEmpBaseInfo" access="public" output="false" returntype="any">
		<cfargument name="PSUID" type="numeric" required="true" />
		<cfquery name="local.rsData" datasource="#dsnHRTEST.name#">
			SELECT TOP (1) prn.CODE_EMPL_STUDENT, aft.CODE_EMPL_SEX, aft.CODE_EMPL_ETHNIC, prn.CODE_EMPL_STATUS, 
				prn.DATE_EMPL_BIRTH, prn.DATE_EMPL_HIRED, prn.CODE_EMPL_CLASS, prn.CODE_EMPL_PAY_CALC, 
				prn.DATE_EMPL_PAID, prn.DATE_EMPL_RETIRE, ltrim(rtrim(prn.name_empl_last_legal)) name_empl_last_legal, 
				ltrim(rtrim(prn.name_empl_first_legal)) name_empl_first_legal, ltrim(rtrim(VCC.CODESET_VALUE_DESCRIPTION)) HRAreaVAL,
				prn.name_empl_mid_legal, prn.name_empl_sfx_legal, prn.numb_empl_id, apt.code_budg_numb_home, 
				apt.code_budg_loc_home, apt.CODE_POSN_PERS_REP, apt.CODE_BUDG_ADMN_AREA_HOME, apt.CODE_POSN_RANK,
				apt.CODE_APPT, apt.DATE_APPT_BEG, apt.DATE_APPT_END, apt.DATE_EMPL_TERMN, PRN.DATE_RECD_REFRESHED,
				apt.code_budg_numb_home + '' + apt.code_budg_loc_home Home_Budget, apt.OHR_GENERIC_TITLE,
				apt.CODE_POSN_CAMP_LOC
			FROM    Empire_History.dbo.PERSON prn LEFT OUTER JOIN
                	Empire_History.dbo.AFFACT aft ON prn.NUMB_EMPL_ID = aft.NUMB_EMPL_ID LEFT OUTER JOIN
					Empire_History.dbo.APPTPOS apt ON prn.NUMB_EMPL_ID = apt.NUMB_EMPL_ID LEFT OUTER JOIN
					DataMart.dbo.v_cpersrep_curr VCC ON VCC.CODESET_VALUE = apt.CODE_POSN_PERS_REP
			WHERE (prn.numb_empl_id = <cfqueryparam value="#arguments.PSUID#" cfsqltype="cf_sql_varchar">)
			ORDER BY DATE_RECD_REFRESHED DESC
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /get base current info for employee (Empire) --->
	
	<!--- get (primary) Appointment info - Empire --->
	<cffunction name="GetApptPosInfo" access="public" output="false" returntype="any">
		<cfargument name="PSUID" type="numeric" required="true" />
		<cfquery name="local.rsData" datasource="#dsnHRTEST.name#">
			SELECT TOP (1) CODE_POSN_RANK, OHR_GENERIC_TITLE, CODE_APPT, CODE_POSN_CAMP_LOC, 
					CODE_BUDG_ADMN_AREA_HOME, DATE_EMPL_TERMN,DATE_APPT_BEG, DATE_APPT_END
			FROM   Empire_History.dbo.APPTPOS
			WHERE (numb_empl_id = <cfqueryparam value="#arguments.PSUID#" cfsqltype="cf_sql_varchar">)
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /get (primary) Appointment info - Empire --->
	
	<!--- get (secondary) Appointment info - Empire --->
	<cffunction name="GetSecAppInfo" access="public" output="false" returntype="any">
		<cfargument name="PSUID" type="numeric" required="true" />
		<cfquery name="local.rsData" datasource="#dsnHRTEST.name#">
			SELECT TOP (1) CODE_POSN_RANK, OHR_GENERIC_TITLE, CODE_APPT, CODE_POSN_CAMP_LOC, 
					CODE_BUDG_ADMN_AREA_HOME, DATE_EMPL_TERMN,DATE_APPT_BEG, DATE_APPT_END
			FROM    Empire_History.dbo.SECAPP
			WHERE (numb_empl_id = <cfqueryparam value="#arguments.PSUID#" cfsqltype="cf_sql_varchar">)
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /get (secondary) Appointment info - Empire --->
	


</cfcomponent>