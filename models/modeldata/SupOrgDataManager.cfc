<cfcomponent output='false' singleton >

	<!--- Dependencies --->
	<cfproperty name="dsn" inject="coldbox:setting:someDSN" />

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor" >
		<cfreturn this />
	</cffunction>
	
	
	<!--- get sup org info --->
	<cffunction name="GetSupOrgData" access="public" output="false" returntype="any">
		<cfargument name="assignedSupOrg" type="string" required="false" default="" />
		<cfargument name="spAccessID" type="string" required="false" default="" /> 
		<cftry>
		<cfquery name="local.rsData" datasource="#dsn.name#">
			<!--- some query --->
		</cfquery>
		<cfreturn local.rsData />
		<cfcatch type="database">
				<cfdump var=#cfcatch# abort=true />
			</cfcatch>
		</cftry>
	</cffunction>
	<!--- /get sup org info --->


	<cfscript>

		/**
		* script version using sql server stored procedure
		*
		**/
		public query function GetSupOrgData2( required string assignedSupOrg, required string spAccessID ){
			cfstoredproc( procedure="[dbo].[get_sup_org_something]",datasource="#datasources.demouser#" ){
				cfprocparam(cfsqltype="cf_sql_varchar", value=arguments.assignedSupOrg);
				cfprocparam(cfsqltype="cf_sql_varchar", value=arguments.spAccessID);
				cfprocresult(name="local.qSupOrgItem", resultset=1);
			}
			return local.qSupOrgItem;
		}


	</cfscript>

	
	
	
</cfcomponent>