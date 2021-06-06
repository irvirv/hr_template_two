<cfcomponent output='false' singleton >

	<!--- Dependencies --->
	<cfproperty name="dsn" inject="coldbox:setting:dsnRMS" />
	<cfproperty name="rightsApplicationName" inject="coldbox:setting:rightsApplicationName" />

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor" >
		<cfreturn this />
	</cffunction>

	<!--- get budget areas this person is a helper for an FO --->
	<cffunction name="GetProxyBudgetAreas" access="Public" returnType="any" output="false">
		<cfargument name="accessID" type="string" required="true" />
		<cfquery name="local.rsData" datasource="#dsn.name#">
			SELECT  UserAppSID, ApplicationID, ProxyUserSID, ApplicationName, ProxyUID, Proxy_Status, Date_Created, IPAddress, 
				Granted_By, Granted_For, friendlyname, AccessTypeID, AccessDescription, AccessAbbrev, FORepArea, UserAppBudgID, 
				Expire_date, display
			FROM   ohr_rms2.proxyusers.v_proxy_user_with_BudgetAreas
			WHERE (ApplicationName = <cfqueryparam value="#rightsApplicationName#" cfsqltype="cf_sql_varchar">) 
				AND (ProxyUID = <cfqueryparam value="#arguments.accessID#" cfsqltype="cf_sql_varchar">)
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /get budget areas this person is a helper for an FO --->
	
	<!--- get budget areas this person is a helper for an FO --->
	<cffunction name="GetAllProxies" access="Public" returnType="any" output="false">
		<cfquery name="local.rsData" datasource="#dsn.name#">
			SELECT distinct  ProxyUID
			FROM   ohr_rms2.proxyusers.v_proxy_user_with_BudgetAreas
			WHERE (ApplicationName = <cfqueryparam value="#rightsApplicationName#" cfsqltype="cf_sql_varchar">)  
				AND  (Proxy_Status = 1)
			order by ProxyUID
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /get budget areas this person is a helper for an FO --->
	
	
</cfcomponent>