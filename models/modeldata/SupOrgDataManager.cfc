<cfcomponent output='false' singleton >

	<!--- Dependencies --->
	<cfproperty name="dsn" inject="coldbox:setting:dsnHRTEST" />

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor" >
		<cfreturn this />
	</cffunction>
	
	
	<!--- get sup org info --->
	<cffunction name="GetSupOrgData" access="public" output="false" returntype="any">
		<cfargument name="Assigned_Sup_Org" type="string" required="false" default="" />
		<cfargument name="SPAccessID" type="string" required="false" default="" /> 
		<cftry>
		<cfquery name="local.rsData" datasource="#dsn.name#">
			SELECT  Assigned_Sup_Org, Sup_Org_Name, SP_Position_ID, SP_Access_ID, SP_Numb_Empl_ID, SP_Assigned_To_Name
			FROM    Dynasty.WorkDayRoles.tbl_Strategic_Partner_Info
			<cfif len(arguments.Assigned_Sup_Org)>
				WHERE (Assigned_Sup_Org = <cfqueryparam value="#arguments.Assigned_Sup_Org#" cfsqltype="cf_sql_varchar">)
			</cfif>
			<cfif len(arguments.SPAccessID)>
				AND (SP_Access_ID = <cfqueryparam value="#arguments.SPAccessID#" cfsqltype="cf_sql_varchar">)
			</cfif>
		</cfquery>
		<cfreturn local.rsData />
		<cfcatch type="database">
				<cfdump var=#cfcatch# abort=true />
			</cfcatch>
		</cftry>
	</cffunction>
	<!--- /get sup org info --->

	<!--- get sup orgs --->
	<cffunction name="GetSupOrgs" access="Public" returnType="any" output="false">
		<cfargument name="supOrgList" type="string" required="false" default="" /> 
		<cfquery name="local.rsData" datasource="#dsn.name#">
			SELECT  Assigned_Sup_Org, Assigned_Sup_Org_Name
			FROM   Dynasty.WorkDayRoles.tbl_Distinct_SP_Assigned_Sup_Orgs
			WHERE (1=1) 
			<cfif len(arguments.supOrgList)>
				AND (Assigned_Sup_Org IN (<cfqueryparam value="#arguments.supOrgList#" cfsqltype="cf_sql_varchar" list="true" >))
			</cfif>
			ORDER BY Assigned_Sup_Org
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /get sup orgs--->
	
	<!--- get sup org by rep area --->
	<cffunction name="GetSupOrgByRepArea" access="Public" returnType="any" output="false">
		<cfargument name="HRRepArea" type="string" required="true"  /> 
		<cfquery name="local.rsData" datasource="#dsn.name#">
			SELECT  sup_org, rep_area
			FROM   Datamart.dbo.temp_SupOrg_HR_Match 
			WHERE  (rep_area = <cfqueryparam value="#arguments.HRRepArea#" cfsqltype="cf_sql_varchar">)
			ORDER BY sup_org
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /get sup org by rep area --->
	
	
	<!--- get rep area by sup org  --->
	<cffunction name="GetRepAreasBySupOrgs" access="Public" returnType="any" output="false">
		<cfargument name="supOrgs" type="string" required="true"  /> 
		<cfquery name="local.rsData" datasource="#dsn.name#">
			SELECT  sup_org, rep_area
			FROM   Datamart.dbo.temp_SupOrg_HR_Match 
			WHERE  (sup_org IN (<cfqueryparam value="#arguments.supOrgs#" cfsqltype="cf_sql_varchar" list="true" >))
			ORDER BY rep_area
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /get rep area by sup org  --->
	
	<!--- get sup org by rep area --->
	<cffunction name="GetSupOrgRoleMembers" access="Public" returnType="any" output="false">
		<cfargument name="permissionName" type="string" required="false" default=""  /> 
		<cfquery name="local.rsData" datasource="#dsn.name#">
			SELECT  UserRole, PermissionID, PermissionRoleLookupID, ApplicationID, permissionDescription, permissionName, ApplicationName, 
				friendlyname, ExpirationRequired, AllowNonEmployees, Constrained
			FROM  ohr_rms2.OHRApplication.v_WorkdayRoles
			WHERE ApplicationName = 'UCIS'
			<cfif len(arguments.permissionName)>
				AND   (permissionName = <cfqueryparam value="#arguments.permissionName#" cfsqltype="cf_sql_varchar">)
			</cfif>
			ORDER BY UserRole
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /get strategic partner info --->
	
	<!--- get match of sup_org and role --->
	<cffunction name="ListSupOrgRoleMatch" access="Public" returnType="any" output="false">
		<cfargument name="workdayRoles" type="string" required="true" /> 
		<cfargument name="supOrg" type="string" required="true" /> 
		<cfquery name="local.rsData" datasource="#dsn.name#">
			SELECT DISTINCT ERA.Numb_Empl_ID, ERA.Assigned_To_Name, ERA.Role_Name, ERA.Role_Description, ERA.Assigned_Sup_Org, ERA.Assigned_Sup_Org_Name,
				P.ADDR_EMPL_EMAIL, P.CODE_PERS_ACCESS_ACCT_ID
			FROM  Dynasty.WorkDayRoles.v_Employee_Role_Assignment ERA LEFT OUTER JOIN 
				Dynasty.dbo.Person P ON P.NUMB_EMPL_ID = ERA.Numb_Empl_ID
			WHERE  (ERA.Role_Name IN (<cfqueryparam value="#arguments.workdayRoles#" cfsqltype="cf_sql_varchar" list="true" >))
				AND (ERA.Assigned_Sup_Org = <cfqueryparam value="#arguments.supOrg#" cfsqltype="cf_sql_varchar">)
			ORDER BY Assigned_To_Name
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /get match of sup_org and role --->
	
	
	<!--- get unconstrained users --->
	<!--- get match of sup_org and role --->
	<cffunction name="ListUnconstrainedRoleMatch" access="Public" returnType="any" output="false">
		<cfargument name="workdayRoles" type="string" required="true" /> 
		<cfquery name="local.rsData" datasource="#dsn.name#">
			SELECT distinct  ERA.Numb_Empl_ID, ERA.Assigned_To_Name, P.ADDR_EMPL_EMAIL
  			FROM Dynasty.WorkDayRoles.v_Employee_Role_Assignment ERA inner join 
				dynasty.dbo.Person P ON ERA.Numb_Empl_ID = P.NUMB_EMPL_ID
  			where Role_Name IN (<cfqueryparam value="#arguments.workdayRoles#" cfsqltype="cf_sql_varchar" list="true" >)
			ORDER BY Assigned_To_Name
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /get match of sup_org and role --->
	
	
	
</cfcomponent>