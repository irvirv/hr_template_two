component extends="coldbox.system.EventHandler"{
	
	
	
	/**
	* main menu
	**/
	public function mainmenu(event,rc,prc){
		prc.xe_homepage = "main.index";
		prc.xe_logout = "main.logout";
		prc.xe_listApps = "OHRApps.list";
		prc.xe_listRoles = "OHRRoles.list";
		prc.xe_listPositions = "OHRPositions.list";
		return renderView(view="nav/mainleft") ;
	}	
	
	
}