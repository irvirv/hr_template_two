<cfcomponent output='false' singleton >

	<!--- Dependencies --->
	<cfproperty name="dsn" inject="coldbox:setting:dsnHRTEST" />

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor" >
		<cfreturn this />
	</cffunction>

	<!--- get our nav data --->
	<cffunction name="GetNavData" access="Public" returnType="query" output="false">
		<cfargument name="permissionList" type="string" required="true" />
		<cfquery name="local.rsNavData" datasource="#dsn.name#" cachedwithin="#CreateTimeSpan(0,1,0,0)#"><!--- cached an hour by permissionList --->
			SELECT DISTINCT NavItemID, NavGroupID, NavGroupName, NavGroupDesc, NavGroupText, NavItemText, NavItemEvent, 
				NavItemType, DisplayOrder, NavGroupOrder, icon
			FROM  hr_test.navigation.v_NavItems_By_Role
			WHERE (RoleName IN (<cfqueryparam value="#arguments.permissionList#" cfsqltype="CF_SQL_VARCHAR" list="true">))
			ORDER BY NavGroupOrder, DisplayOrder
		</cfquery>
		<cfreturn local.rsNavData />
	</cffunction>
	<!--- /get our nav data --->
	
</cfcomponent>