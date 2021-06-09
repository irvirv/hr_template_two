component extends="coldbox.system.EventHandler"{

	// settings
	property name="config" inject="coldbox:configSettings";
	// services
	property name="SecurityService" inject="id:usermodels.SecurityService";


	/**
	prehandler
	**/
	public function prehandler(){
		event.paramValue("accessID", "christian");
		prc.xe_OHRSite = 'https://hr.psu.edu/';	
	}

	
	
	/** 
	* Default Action
	**/
	public function index(event,rc,prc){
		var strAccessResult = SecurityService.CheckAccess(
			accessID= rc.accessID
		);
		if( strAccessResult.authorized ){
			prc.loggedInUser = strAccessResult.authorizedUser;
			event.setLayout("worklayout");
			event.setView("main/index");
		}else{
			relocate(event="main.unauthorized", queryString="accessID=#strAccessResult.authorizedUser#" );
		}
	}

	/** 
	* Default Action
	**/
	public function index_wrong(event,rc,prc){
		if( listFindNoCase("Doug,Christian,John", rc.accessID) ){
			prc.loggedInUser = rc.accessID;
			event.setLayout("worklayout");
			event.setView("main/index");
		}else{
			log.error(rc.accessID & " attempted login but no employee or non-employee record found. Login failed.");
			relocate(event="main.unauthorized", queryString="accessID=#rc.accessID#" );
		}
	}


	/** 
	* sample table
	**/
	public function table(event,rc,prc){
		var strAccessResult = SecurityService.CheckAccess(
			accessID=rc.accessID
		);
		if( strAccessResult.authorized ){
			prc.loggedInUser = strAccessResult.authorizedUser;
			prc.ActiveLink = "main.table";
		}else{
			relocate(event="main.unauthorized", queryString="accessID=#strAccessResult.authorizedUser#" );
		}
	}


	/** 
	* sample form
	**/
	public function form(event,rc,prc){
		var strAccessResult = SecurityService.CheckAccess(
			accessID=rc.accessID
		);
		if( strAccessResult.authorized ){
			prc.loggedInUser = strAccessResult.authorizedUser;
			prc.ActiveLink = "main.form";
		}else{
			relocate(event="main.unauthorized", queryString="accessID=#strAccessResult.authorizedUser#" );
		}
	}

	/** 
	* sample list
	**/
	public function list(event,rc,prc){
		var strAccessResult = SecurityService.CheckAccess(
			accessID=rc.accessID
		);
		if( strAccessResult.authorized ){
			prc.loggedInUser = strAccessResult.authorizedUser;
			prc.ActiveLink = "main.list";
		}else{
			relocate(event="main.unauthorized", queryString="accessID=#strAccessResult.authorizedUser#" );
		}
	}

	
	/** 	
	* cached event example.  A cached event does not execute if in cache but interceptors still do
	* cache can be cleared with  - cachebox.getCache("template").clearAllEvents();
	**/
	public function somecachedevent(event,rc,prc) cache="true" cacheTimeout="30" cacheLastAccessTimeout="15" {
		prc.ActiveLink = "main.somecachedevent";
		prc.loggedInUser = wirebox.getInstance("usermodels.User").getAccessID(); // note this will not display proper user to visitor #2
		prc.xe_logout = "main.logout";
		event.setLayout("worklayout");
		event.setView("main/cachedevent");
	}

	/** 	
	* not an authorized user
	**/
	public function unauthorized(event,rc,prc){
		prc.ActiveLink = "main.unauthorized";
		prc.loggedInUser = rc.accessID;
		prc.xe_logout = "main.logout";
		event.setLayout("worklayout");
		event.setView("main/unauthorized");
	}

	/**
	* logout
	**/
	public function logout(event,rc,prc){
		SecurityService.logout();
		location("https://webaccess.psu.edu/cgi-bin/logout", "false");
		abort;
	}

	/**
	* coldbox page not found
	**/
	function pageNotFound(event,rc,prc){
		// Do a quick page not found and 404 error
		event.renderData( data="<h1>Page Not Found</h1>", statusCode=404 );
		// Set a page for rendering and a 404 header
		event.setView( view="main/pageNotFound", noLayout=true ).setHTTPHeader( "404", "Page Not Found" );
	}

	/**
	* some other .cfm file outside coldbox but within our app root not found.
	**/
	function missingTemplate(event,rc,prc){
		// Log a warning
		log.warn( "Missing page detected: #rc.missingTemplate#");
		// Do a quick page not found and 404 error
		event.renderData( data="<h1>Page Not Found</h1>", statusCode=404 );
		// Set a page for rendering and a 404 header
		event.setView( "main/pageNotFound" ).setHTTPHeader( "404", "Page Not Found" );
	}

	/**
	*  main failed page
	*  is a display page only.  Error handling/logging happened before we got here.
	**/
	function showfail(event,rc,prc){
		// show generic failed page
		event.setView(view="main/failed", noLayout=true);
	}



	/************************************** IMPLICIT ACTIONS *********************************************/


	function onAppInit(event,rc,prc){

	}

	function onRequestStart(event,rc,prc){

	}

	function onRequestEnd(event,rc,prc){

	}

	function onSessionStart(event,rc,prc){

	}

	function onSessionEnd(event,rc,prc){
		var sessionScope = event.getValue("sessionReference");
		var applicationScope = event.getValue("applicationReference");
	}

	function onException(event,rc,prc){
		log.error( prc.exception.getMessage() & prc.exception.getDetail(), prc.exception.getMemento() );
		if( config.Environment != 'DEVELOPMENT' ){
			flash.put("exceptionURL", event.getCurrentRoutedURL() );
			relocate("main.showfail");
		}

	}

}