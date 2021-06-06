component extends="coldbox.system.EventHandler"{
	
	
	property name="NavService" inject="id:navigation.NavService";
	
	
	
	/**
	* main menu
	**/
	public function mainmenu(event,rc,prc){
		prc.xe_homepage = "main.index";
		prc.xe_logout = "main.logout";
		prc.xe_listApps = "OHRApps.list";
		prc.xe_listRoles = "OHRRoles.list";
		prc.xe_listPositions = "OHRPositions.list";
		prc.arr_Links = NavService.GetNavInfo();
		return renderView(view="nav/mainleft") ;
	}	
	
	
}