<cfcomponent output='false' singleton >

	<!--- Dependencies --->
	<cfproperty name="dsn" inject="coldbox:setting:dsnHRTEST" />

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor" >
		<cfreturn this />
	</cffunction>
	
	<!--- verify FO access based on homebudget and charge number  --->
	<cffunction name="GetFOAccess" access="public" output="false" returntype="numeric">
		<cfargument name="homebudget" type="string" required="true" />
		<cfargument name="code_budg_numb_home" type="string" required="true" /> 
		<cfargument name="code_budg_loc_home" type="string" required="true" />
		<cfif NOT len(trim(arguments.homebudget)) OR NOT len(trim(arguments.code_budg_numb_home)) OR NOT len(trim(arguments.code_budg_loc_home))>
			<cfreturn 0 />
		</cfif>
		<cftry>
		<cfquery name="local.rsData" datasource="#dsn.name#">
			SELECT  COUNT(1) AS numFound
			FROM  datamart.dbo.v_UCIS_FOAccount
			WHERE  (code_budg_admn_area_home = <cfqueryparam value="#arguments.homebudget#" cfsqltype="cf_sql_varchar">)
				AND (code_budg_numb_home = <cfqueryparam value="#arguments.code_budg_numb_home#" cfsqltype="cf_sql_varchar">)
				AND (code_budg_loc_home = <cfqueryparam value="#arguments.code_budg_loc_home#" cfsqltype="cf_sql_varchar">)
		</cfquery>
		<cfreturn local.rsData.numFound />
			<cfcatch type="database">
				<cfdump var=#cfcatch# abort=true />
			</cfcatch>
		</cftry>
	</cffunction>
	<!--- /verify FO access based on homebudget and charge number  --->
	
	<!--- get current char of accounts --->
	<!--- note that we're trimming out all whitespace in our account numbers in this particular view --->
	<!--- today some of these fields are always filled 1 char short of field length to allow for expansion but spaces are being input into the fields --->
	<!--- this is troublesome for good input "scrubbing" so we're stripping out all spaces in both input and table to make this easier and more foolproof --->
	<cffunction name="GetCurrChartAccounts" access="public" output="false" returntype="any">
		<cfargument name="acctNum" type="string" required="false" />
		<cfargument name="AcctPre" type="string" required="false" />
		<cftry>
		<cfquery name="local.rsData" datasource="#dsn.name#">
			SELECT  acct_num
			FROM  Datamart.dbo.v_UCISchart_accounts_curr
			WHERE (1=1)
			<cfif StructKeyExists(arguments,"acctNum") AND len(trim(arguments.acctNum))>
			 	AND (acct_num = <cfqueryparam value="#arguments.acctNum#" cfsqltype="cf_sql_varchar">)
			</cfif>
			<cfif StructKeyExists(arguments,"acctPre") AND len(trim(arguments.acctPre))>
			 	AND (acct_num like <cfqueryparam value="#arguments.acctPre#%" cfsqltype="cf_sql_varchar">)
			</cfif>
		</cfquery>
		<cfreturn local.rsData />
			<cfcatch type="database">
				<cfdump var=#cfcatch# abort=true />
			</cfcatch>
		</cftry>
	</cffunction>
	<!--- /get current char of accounts --->
	
	
	<!--- get chart of accounts (including expired) --->
	<!--- note that we're trimming out all whitespace in our account numbers in this particular view --->
	<!--- today some of these fields are always filled 1 char short of field length to allow for expansion but spaces are being input into the fields --->
	<!--- this is troublesome for good input "scrubbing" so we're stripping out all spaces in both input and table to make this easier and more foolproof --->
	<cffunction name="GetChartAccounts" access="public" output="false" returntype="any">
		<cfargument name="acctNum" type="string" required="false" />
		<cfargument name="AcctPre" type="string" required="false" />
		<cftry>
		<cfquery name="local.rsData" datasource="#dsn.name#">
			SELECT  acct_num
			FROM  Datamart.dbo.v_UCISchart_accounts
			WHERE (1=1)
			<cfif StructKeyExists(arguments,"acctNum") AND len(trim(arguments.acctNum))>
			 	AND (acct_num = <cfqueryparam value="#arguments.acctNum#" cfsqltype="cf_sql_varchar">)
			</cfif>
			<cfif StructKeyExists(arguments,"acctPre") AND len(trim(arguments.acctPre))>
			 	AND (acct_num like <cfqueryparam value="#arguments.acctPre#%" cfsqltype="cf_sql_varchar">)
			</cfif>
		</cfquery>
		<cfreturn local.rsData />
			<cfcatch type="database">
				<cfdump var=#cfcatch# abort=true />
			</cfcatch>
		</cftry>
	</cffunction>
	<!--- /get current char of accounts --->
	
	<!--- get home budget string value  --->
	<cffunction name="GetFOHomeAreaName" access="public" output="false" returntype="any">
		<cfargument name="CODE_BUDG_ADMN_AREA_HOME" type="string" required="true" />
		<cftry>
		<cfquery name="local.rsData" datasource="#dsn.name#">	
			SELECT  Admin_Area_Name
			FROM  Datamart.dbo.v_cfoaausr_curr
			WHERE  (CODE_BUDG_ADMN_AREA_HOME = <cfqueryparam value="#arguments.CODE_BUDG_ADMN_AREA_HOME#" cfsqltype="cf_sql_varchar">)
		</cfquery>
		<cfreturn local.rsData />
			<cfcatch type="database">
				<cfdump var=#cfcatch# abort=true />
			</cfcatch>
		</cftry>
	</cffunction>
	<!--- /get home budget string value  --->
	
	 <!--- get FO Account info  --->
	<cffunction name="GetFOAccountInfo" access="public" output="false" returntype="any">
		<cfargument name="code_budg_numb_home" type="string" required="true" /> 
		<cfargument name="code_budg_loc_home" type="string" required="true" /> 
		<cfquery name="local.rsData" datasource="#dsn.name#">	
			SELECT FOA.CODE_BUDG_ADMN_AREA_HOME, FOA.CODE_BUDG_NUMB_HOME, FOA.CODE_BUDG_LOC_HOME, AA.Admin_Area_Name
			FROM  datamart.dbo.v_UCIS_FOAccount AS FOA LEFT OUTER JOIN
            		datamart.dbo.v_cfoaausr_curr AS AA ON FOA.CODE_BUDG_ADMN_AREA_HOME = AA.CODE_BUDG_ADMN_AREA_HOME
			WHERE (FOA.CODE_BUDG_NUMB_HOME = <cfqueryparam value="#arguments.code_budg_numb_home#" cfsqltype="cf_sql_varchar">)
			 AND (FOA.CODE_BUDG_LOC_HOME = <cfqueryparam value="#arguments.code_budg_loc_home#" cfsqltype="cf_sql_varchar">)
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /get FO Account info  --->
	
	<!--- get ALl FOReps --->
	<cffunction name="GetAllFOReps" access="Public" returnType="any" output="false">
		<cfquery name="local.rsData" datasource="#dsn.name#">
			SELECT     distinct  ltrim(rtrim(fo_accessid)) AS FOUID
			FROM   datamart.dbo.v_cfoaausr_curr
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /get All FOReps --->


	<!--- get financial role employees --->
	<cffunction name="GetAllFORoledEmployees" access="Public" returnType="any" output="false">
		<cfquery name="local.rsData" datasource="#dsn.name#">
			SELECT    DISTINCT Numb_Empl_ID, Role_Assignee_Name, Role_Name, CODE_PERS_ACCESS_ACCT_ID
			FROM    Dynasty.dbo.v_Financial_Role_Employees
		</cfquery>
		<cfreturn local.rsData />
	</cffunction>
	<!--- /get financial role employees --->
	
</cfcomponent>