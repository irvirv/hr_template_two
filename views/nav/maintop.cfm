<cfoutput>
	<nav class="navbar navbar-expand-lg navbar-light bg-light">
		<div class="container-fluid">
			<button aria-label="Toggle sidebar" type="button" id="sidebarCollapse" class="btn btn-primary">
			<i class="fas fa-align-left"></i>
			<span>Toggle Sidebar</span>
			</button>
			<button class="btn btn-dark d-inline-block d-lg-none ml-auto" type="button" data-toggle="collapse" data-target="##navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
			<i class="fas fa-align-justify"></i>
			</button>
			<div class="collapse navbar-collapse" id="navbarSupportedContent">
				<ul class="nav navbar-nav ml-auto">
					<li class="nav-item active">
						<div class="btn-group dropleft">
							<cfif structKeyExists(prc, 'loggedInUser')>
								<button class="btn btn-secondary dropdown-toggle" type="button" style="margin-top:3px;"  id="dropdownSignoutButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
									log out #prc.loggedInUser#
								</button>
							</cfif>
							<div class="dropdown-menu" aria-labelledby="dropdownSignoutButton">
								<a class="dropdown-item" href="#event.buildlink( prc.xe_logout )#">Log Out</a>
							</div>
						</div>
					</li>
				</ul>
			</div>
		</div>
	</nav>
</cfoutput>