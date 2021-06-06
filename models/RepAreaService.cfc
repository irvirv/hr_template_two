component output="false" singleton {
	
	
	property name="HRRepAreaData" inject="id:modeldata.HRRepAreaData";
	property name="SupOrgData" inject="id:modeldata.SupOrgDataManager";
	property name="SupOrgService" inject;
	
	/**
	* init
	**/
	public function init(){
		return this;
	}
	
	/**
	* get all hr rep areas
	**/
	public function ListAllRepAreas(){
		return HRRepAreaData.GetRepByArea();
	}
	
	/**
	* get potential rep areas by sup org
	**/
	public function GetRepAreasBySupOrgs( supOrgs ){
		return SupOrgData.GetRepAreasBySupOrgs(
			supOrgs = arguments.supOrgs
		);
	}
	
	
	/**
	* get rep area info
	**/
	public function GetRepByArea( HRRepArea ){
		return HRRepAreaData.GetRepByArea(
			HRRepArea = arguments.HRRepArea	
		);
	}
	
	
	/**
	* get persons with a permission based on suporg and role assignment
	**/
	public function ListPersonPermissionRepArea(permissionName, HRRepArea){
		// first get our matching suporg
		var rsSupOrg = SupOrgService.GetSupOrgByRepArea(
			HRRepArea = arguments.HRRepArea
		);
		// now go find people matching a permission and our resultant sup_org
		return SupOrgService.ListPersonPermissionSupOrg(
			permissionName = arguments.permissionName,
			supOrg = rsSupOrg.sup_org
		);
	}
	
}


