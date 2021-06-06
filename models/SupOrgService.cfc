component output="false" singleton {
	
	
	property name="SupOrgData" inject="id:modeldata.SupOrgDataManager";
	
	/**
	* init
	**/
	public function init(){
		return this;
	}
	
	
	/**
	* get all Sup orgs
	**/
	public function ListAllSupOrgs(){
		return SupOrgData.GetSupOrgData();
	}
	
	/**
	* get data on specific sup org 
	**/
	public function GetSupOrgData(Assigned_Sup_Org){
		return SupOrgData.GetSupOrgData(
			Assigned_Sup_Org = arguments.Assigned_Sup_Org
		);	
	}
	
	
	/**
	* get SupOrgs
	**/
	public function GetSupOrgs( supOrgList="" ){
		if( len(arguments.supOrgList) ){
			var rsSupOrgData =  SupOrgData.GetSupOrgs(
				supOrgList = arguments.supOrgList
			);
		}else{
			var rsSupOrgData =  SupOrgData.getSupOrgs();
		}
		for (var i=1; i lte rsSupOrgData.recordcount; i=i+1 ){
			if( len(rsSupOrgData["Assigned_Sup_Org_Name"][i]) ){
				rsSupOrgData["Assigned_Sup_Org_Name"][i] = CreateFriendlyName( rsSupOrgData["Assigned_Sup_Org_Name"][i] );
			}
		}
		return rsSupOrgData;
	}
	

	/**
	* get SupOrgs
	**/
	public function GetStrategicPartner( Assigned_Sup_Org="", SPAccessID="" ){
		if( len(arguments.Assigned_Sup_Org) ){
			var rsSupOrgData =  SupOrgData.GetSupOrgData(
				Assigned_Sup_Org = arguments.Assigned_Sup_Org
			);
		}else if( len(arguments.SPAccessID) ){
			var rsSupOrgData =  SupOrgData.GetSupOrgData(
				SPAccessID = arguments.SPAccessID
			);
		}else{
			var rsSupOrgData =  SupOrgData.GetSupOrgData();
		}
		for (var i=1; i lte rsSupOrgData.recordcount; i=i+1 ){
			if( len(rsSupOrgData["Sup_Org_Name"][i]) ){
				rsSupOrgData["Sup_Org_Name"][i] = CreateFriendlyName( rsSupOrgData["Sup_Org_Name"][i] );
			}
		}
		return rsSupOrgData;
	}
	
	
	
	/**
	* get persons with a permission based on suporg and role assignment
	**/
	public function ListPersonPermissionSupOrg(permissionName, supOrg){
		// first get roles based on our permission
		var lstPermissions = "";
		var rsRoles = GetSupOrgRoleMembers(
			permissionName = arguments.permissionName
		);
		for ( var R IN rsRoles ){
			if( R.Constrained ){
				lstPermissions = listappend(lstPermissions,R.UserRole);
			}
		}
		return ListSupOrgRoleMatch(
			workdayRoles = lstPermissions,
			supOrg = arguments.supOrg
		);
		
	}
	
	
	/**
	* get persons with a permission based on suporg and role assignment
	**/
	public function ListUnconstrainedPersonSupOrg(permissionName){
		// first get roles based on our permission
		var lstPermissions = "";
		var rsRoles = GetSupOrgRoleMembers(
			permissionName = arguments.permissionName
		);
		for ( var R IN rsRoles ){
			if( !R.Constrained ){
				lstPermissions = listappend(lstPermissions,R.UserRole);
			}
		}
		if( len(lstPermissions) ){
			return SupOrgData.ListUnconstrainedRoleMatch(
				workdayRoles = lstPermissions
			);
		}else{
			return "";
		}
	}
	
	/**
	* list people by role and sup_org assigned in
	**/
	public function ListSupOrgRoleMatch( workdayRoles, supOrg ){
		return SupOrgData.ListSupOrgRoleMatch(
			workdayRoles = arguments.workdayRoles,
			supOrg = arguments.supOrg
		);
	}
	
	/**
	* get rep area / sup_org match
	**/
	public function GetSupOrgByRepArea( HRRepArea ){
		return SupOrgData.GetSupOrgByRepArea(
			HRRepArea = arguments.HRRepArea	
		);
	}
	
	
	
	/**
	*  get roles that are based on supOrg
	**/
	public function GetSupOrgRoleMembers( permissionName ){
		return SupOrgData.GetSupOrgRoleMembers(
			permissionName = arguments.permissionName
		);
	}
	
	
	/**
	*  shorten up the sup org name
	*  sup_org name is a 3 to 5 part concatinated string (by "-") and we only want primary part
	*  also remove anything in parentheses as that has people's names which are sometimes hyphenated and messes up our breakdown below
	**/
	public function CreateFriendlyName( required supOrgName ){
		var orgName = ReReplaceNoCase(arguments.supOrgName,"\(.*?\)","","all");
		var arrOrgBreakDown = ListToArray(orgName,"-");
		switch ( ArrayLen(arrOrgBreakDown) ){
			
			case 3:
				return trim(arrOrgBreakDown[1]) & " - " & trim(arrOrgBreakDown[2]);
				break;
						
			case 4:
				if( trim(arrOrgBreakDown[2]) eq "General and Acad Officers" OR trim(arrOrgBreakDown[2]) eq "General and Academic Officers" ){
					return trim(arrOrgBreakDown[3]);
				}else{
					return trim(arrOrgBreakDown[2]) & " - " & trim(arrOrgBreakDown[3]);	
				}
				break;
						
			case 5:
				return trim(arrOrgBreakDown[4]);
				break;
						
			default:
				return trim(orgName);
		
		}
	}
	
}


