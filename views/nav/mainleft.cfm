<cfoutput>
<!--- Sidebar  --->
<nav id="sidebar">
	<div id="navscroll" class="leftnavscroll" ><!--- allows for scrolling on longer menus.  Can be removed for shorter ones. --->
	<!--- psu logo --->
	<div class="sidebar-header">
		<!---<img src="#getSetting('appIncludesFolder')#/img/PS_HOR_REV_RGB_2C.png" class="img-fluid" alt="Penn State mark"/>--->
		<img src="#getSetting('appIncludesFolder')#/img/ps_human_resources.png" class="img-fluid" alt="Penn State mark"/>
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
		<cfloop from="1" to="#arrayLen(prc.arr_Links)#" index="i">
			<cfif prc.arr_Links[i].navnewgroup eq 1>
				<cfif i neq 1><!--- we don't want our top nav group to have a divider line above it --->
					</ul>
				</cfif>
				<li>
				<a href="##pageSubmenu#i#" data-toggle="collapse" aria-expanded="false" class="dropdown-toggle">#prc.arr_Links[i].navgrouptext#</a>
				<ul class="collapse list-unstyled" id="pageSubmenu#i#">
			</cfif>
			<cfif prc.arr_Links[i].navItemType eq "event">
				<!--- it's just an event name so build out the proper link --->
				<cfset builtlink = event.buildLink( prc.arr_Links[i].navitemevent ) />
				<cfif StructKeyExists(prc,"ActiveLink") AND prc.ActiveLink EQ prc.arr_Links[i].navitemevent>
					<li class="active">
						<a class="active" href="#builtlink#">#prc.arr_Links[i].navitemtext# <span class="sr-only">(current)</span></a>
						<!---<a class="active" href="##">#prc.arr_Links[i].navitemtext# <span class="sr-only">(current)</span></a>---><!--- no link for demo --->
					</li>
				<cfelse>
					<li>
						<a href="#builtlink#">#prc.arr_Links[i].navitemtext#</a>
						<!---<a href="##">#prc.arr_Links[i].navitemtext#</a>---><!--- no link for demo --->
					</li>
				</cfif>
			<cfelse>
				<li>
					<!--- it must be plain url already --->
					<a href="#prc.arr_Links[i].navitemevent#">#prc.arr_Links[i].navitemtext#</a>
				</li>
			</cfif>
		</cfloop>
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
	<!---- second nav group --->
	<ul class="list-unstyled components">
		<!--- docfinity functions --->
		<cfif StructKeyExists(prc,"ActiveLink") AND prc.ActiveLink EQ "docfinity.index">
			<li class="active">
				<a class="active" href="#event.buildLink( "docfinity.index" )#">
				Docfinity Functions
				</a>
			</li>
		<cfelse>
				<li>
				<a href="#event.buildLink( "docfinity.index" )#">
				Docfinity Functions
				</a>
			</li>
		</cfif>
	</ul>
	</div><!--- /. id="navscroll" --->
</nav>
</cfoutput>