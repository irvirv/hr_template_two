<cfcomponent output='false' singleton >

	<!--- Dependencies --->
	<cfproperty name="dsn" inject="coldbox:setting:dsnRMS" />

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor" >
		<cfreturn this />
	</cffunction>

	

	<!--- look up RMS User --->
	<cffunction name="GetRMSUser" access="public" output="false" returntype="query" >
		<cfargument name="accessID" type="string" required="true" />
		<cfquery name="local.rsData" datasource="#dsn.name#" >
			SELECT  TOP (1) accessID, accessType
			FROM  ohr_rms2.RMSUser.tbl_RMSUsers
			WHERE (accessID = <cfqueryparam value="#arguments.accessID#" cfsqltype="cf_sql_varchar" >)
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /look up RMS User --->
	
	
</cfcomponent>