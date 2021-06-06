<cfcomponent output='false' singleton >
	
	
	<!--- Dependencies --->
	<cfproperty name="dsnHRTEST" inject="coldbox:setting:dsnHRTEST" />

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor" >
		<cfreturn this />
	</cffunction>

	
	<!--- get hr rep area info --->
	<cffunction name="GetRepByArea" access="Public" returnType="query" output="false">
		<cfargument name="HRRepArea" type="string" required="false" default="" />
		<cfquery name="local.rsData" datasource="#dsnHRTEST.name#">
			SELECT  LTRIM(RTRIM(CODESET_VALUE)) HRRepArea, CODESET_VALUE_DESCRIPTION HRRepAreaDesc, 
			CODE_CPERSREP_USER_ID, NAME_CPERSREP
			FROM   datamart.dbo.v_cpersrep_curr
			<cfif len(trim(arguments.HRRepArea))>
				WHERE (ltrim(rtrim(CODESET_VALUE)) = <cfqueryparam value="#arguments.HRRepArea#" cfsqltype="CF_SQL_VARCHAR">)
			</cfif>
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /get hr rep area info --->
	
	


</cfcomponent>