<cfoutput>
<!--- Sidebar  --->
<nav id="sidebar">
	<div id="navscroll" class="leftnavscroll" ><!--- allows for scrolling on longer menus.  Can be removed for shorter ones. --->
	<!--- psu logo --->
	<div class="sidebar-header">
		<a href="#prc.xe_OHRSite#"><img src="includes/img/ps_human_resources.png" class="img-fluid" alt="Penn State mark"/></a>
	</div>
	<!--- first nav group --->
	<ul class="list-unstyled components">
		<li class="sidebar_section_header sidebar_header_margins">Some Application</li>
		<cfif NOT StructKeyExists(prc,"ActiveLink") OR NOT len(prc.ActiveLink)>
			<li class="active">
				<a class="active" href="#Event.buildLink( prc.xe_homepage )#">
					Home <span class="sr-only">(current)</span>
				</a>
			</li>
		<cfelse>
			<li>
				<a href="#Event.buildLink( prc.xe_homepage )#">
					Home
				</a>
			</li>
		</cfif> 
	</ul>
	<!---- second nav group --->
	<ul class="list-unstyled components">
		<!--- demo table --->
		<cfif StructKeyExists(prc,"ActiveLink") AND prc.ActiveLink EQ "main.table">
			<li class="active">
				<a class="active" href="#event.buildLink( "main.table" )#">
				table
				</a>
			</li>
		<cfelse>
				<li>
				<a href="#event.buildLink( "main.table" )#">
				table
				</a>
			</li>
		</cfif>
		<!--- demo form --->
		<cfif StructKeyExists(prc,"ActiveLink") AND prc.ActiveLink EQ "main.form">
			<li class="active">
				<a class="active" href="#event.buildLink( "main.form" )#">
				form
				</a>
			</li>
		<cfelse>
			<li>
				<a href="#event.buildLink( "main.form" )#">
				form
				</a>
			</li>
		</cfif>
		<!--- demo list --->
		<cfif StructKeyExists(prc,"ActiveLink") AND prc.ActiveLink EQ "main.list">
			<li class="active">
				<a class="active" href="#event.buildLink( "main.list" )#">
				list 
				</a>
			</li>
		<cfelse>
			<li>
				<a href="#event.buildLink( "main.list" )#">
				list 
				</a>
			</li>
		</cfif>
		<!--- demo user rights --->
		<!---
		<cfif StructKeyExists(prc,"ActiveLink") AND prc.ActiveLink EQ "main.userrights">
			<li class="active">
				<a class="active" href="#event.buildLink( "main.userrights" )#">
				user rights
				</a>
			</li>
		<cfelse>
			<li>
				<a href="#event.buildLink( "main.userrights" )#">
				user rights
				</a>
			</li>
		</cfif>
		--->
		<!--- cached event --->
		<cfif StructKeyExists(prc,"ActiveLink") AND prc.ActiveLink EQ "main.somecachedevent">
			<li class="active">
				<a class="active" href="#event.buildLink( "main.somecachedevent" )#">
				cached event
				</a>
			</li>
		<cfelse>
			<li>
				<a href="#event.buildLink( "main.somecachedevent" )#">
				cached event
				</a>
			</li>
		</cfif>
	</ul>
	</div><!--- /. id="navscroll" --->
</nav>
</cfoutput>