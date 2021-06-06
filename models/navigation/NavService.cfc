component output="false" singleton {
	
	// services
	property name="SecurityService" inject="id:usermodels.SecurityService";
	property name="wirebox" inject="wirebox";
	// data
	property name="NavigationData" inject="id:navigation.modeldata.NavigationData";
	
	
	
	/**
	* init
	**/
	public function init(){
		return this;
	}
	
	
	/**
	* build our nav link structure into an array
	**/
	public function GetNavInfo(){
		// get what we have for nav info in our nav object
		var oNav = wirebox.getInstance("navigation.nav");
		var arrNav = oNav.getNavArray();
		// if is built just return it
		if( isArray(arrNav) and arrayLen(arrNav) ){
			return arrNav;
		}else{
			// not built yet so build it
			var oUser = wirebox.getInstance("Usermodels.User");
			var permissionsList = "";
			if( isArray(oUser.getArrPermissions()) ){
				for ( var x IN oUser.getArrPermissions()){
					permissionsList = listAppend(permissionsList,x.permissionName);
				}
			}
			var arrNavArray =[];
			var rsNavData = NavigationData.GetNavData( 
				permissionList = permissionsList
			);
			var currentNav = "";
			for ( var navItem IN rsNavData ){
				arrNavArray[ rsNavData.CurrentRow ] = {};
				arrNavArray[ rsNavData.CurrentRow ].NavItemText = navItem.NavItemText;
				arrNavArray[ rsNavData.CurrentRow ].NavItemEvent = navItem.NavItemEvent;
				arrNavArray[ rsNavData.CurrentRow ].NavItemType = navItem.NavItemType;
				arrNavArray[ rsNavData.CurrentRow ].NavGroupText = navItem.NavGroupText;
				arrNavArray[ rsNavData.CurrentRow ].icon = navItem.icon;
				if( navItem.NavGroupName == currentNav ){
					arrNavArray[ rsNavData.CurrentRow ].NavNewGroup = 0;
				}else{
					arrNavArray[ rsNavData.CurrentRow ].NavNewGroup = 1;
					currentNav = navItem.NavGroupName;
				}
			}
			// all done so set it so don't have to build next time and return it.
			oNav.setNavArray(arrNavArray);
			return oNav.getNavArray();
		}
	}
}


