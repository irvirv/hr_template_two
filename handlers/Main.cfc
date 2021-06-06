component extends="coldbox.system.EventHandler"{

	// settings
	property name="config" inject="coldbox:configSettings";
	// services
	property name="SecurityService" inject="id:usermodels.SecurityService";
	
	/** 
	* Default Action
	**/
	public function index(event,rc,prc){
		if( SecurityService.CheckAccess() ){
			prc.loggedInUser = wirebox.getInstance("usermodels.User").getAccessID();
			prc.xe_OHRSite = 'https://hr.psu.edu/';
			event.setLayout("worklayout");
			event.setView("main/index");
		}else{
			relocate(event="main.unauthorized", SSL=true);
		}
	}

	/** 
	* view Action
	**/
	public function view(event,rc,prc){
		if( SecurityService.CheckAccess("view") ){
			var viewData.oUser = wirebox.getInstance("usermodels.User");
			prc.xe_OHRSite = 'https://hr.psu.edu/';
			prc.ActiveLink = "main.view";
			event.setLayout("worklayout");
			event.setView("main/view");
		}else{
			relocate(event="main.unauthorized", SSL=true);
		}
	}


	/** 
	* sample table
	**/
	public function table(event,rc,prc){
		var viewData.oUser = wirebox.getInstance("usermodels.User");
		prc.xe_OHRSite = 'https://hr.psu.edu/';
		prc.ActiveLink = "main.table";
		prc.loggedInUser = wirebox.getInstance("usermodels.User").getAccessID();
		event.setLayout("worklayout");
		event.setView("main/table");
	}

	/** 
	* sample form
	**/
	public function form(event,rc,prc){
		var viewData.oUser = wirebox.getInstance("usermodels.User");
		prc.xe_OHRSite = 'https://hr.psu.edu/';
		prc.ActiveLink = "main.form";
		prc.loggedInUser = wirebox.getInstance("usermodels.User").getAccessID();
		event.setLayout("worklayout");
		event.setView("main/form");
	}

	/** 
	* sample list
	**/
	public function list(event,rc,prc){
		var viewData.oUser = wirebox.getInstance("usermodels.User");
		prc.xe_OHRSite = 'https://hr.psu.edu/';
		prc.ActiveLink = "main.list";
		prc.loggedInUser = wirebox.getInstance("usermodels.User").getAccessID();
		event.setLayout("worklayout");
		event.setView("main/list");
	}

	/** 
	* user rights
	**/
	public function userrights(event,rc,prc){	
		if( SecurityService.CheckAccess() ){
			var viewData.oUser = wirebox.getInstance("usermodels.User");
			prc.xe_OHRSite = 'https://hr.psu.edu/';
			prc.ActiveLink = "main.userrights";
			prc.loggedInUser = wirebox.getInstance("usermodels.User").getAccessID();
			event.setLayout("worklayout");
			event.setView(view="main/userrights", args=viewData);
		}else{
			relocate(event="main.unauthorized", SSL=true);
		}
	}

	
	/** 	
	* cached event example.  A cached event does not execute if in cache but interceptors still do
	* cache can be cleared with  - cachebox.getCache("template").clearAllEvents();
	**/
	public function somecachedevent(event,rc,prc) cache="true" cacheTimeout="30" cacheLastAccessTimeout="15" {
		prc.xe_OHRSite = 'https://hr.psu.edu/';
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
		prc.xe_OHRSite = 'https://hr.psu.edu/';
		prc.ActiveLink = "main.unauthorized";
		prc.loggedInUser = wirebox.getInstance("usermodels.User").getAccessID();
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