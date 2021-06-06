component output="false" singleton {
	
	// services
	property name="HelperService" inject="HelperService";
	property name="UserDataManager" inject="id:usermodels.modeldata.UserDataGateway";
	property name="ProxyDataManager" inject="id:usermodels.modeldata.ProxyDataGateway";
	property name="wirebox" inject="wirebox";
	property name="populator" inject="wirebox:populator";
	// settings
	property name="systemRoles" inject="coldbox:setting:userRoles";
	property name="rightsApplicationName" inject="coldbox:setting:rightsApplicationName";
	// modules
	property name="RMSAPI" inject="RMSAPIGateway@rmsAPIService";
	

	/**
	* init
	**/
	public component function init(){
		return this;
	}
	
	
	/**
	* Get User Info and set in user object
	*	This checks for an employee and then, if found, gets rights.  If not found as employee then checks for non-employee.  What
	*	it does NOT do is get employee and then, if no rights (but employee found), continue on to non-emp rights.  
	*	Assumption is you're either an employee or non-employee. This keeps depts. from "cheating" by creating external rights 
	*	for employees outside of where they should be maintained  - i.e. within Workday.
	*
	* @accessID accessID of user we're using for rights and such
	* @usingEmulation whether or not using emulation for this session (1/0)
	* @emulatingUser accessID of the person doing the emulating if usingEmulation (above) is 1
	**/  
	public boolean function SetUserInfo( accessID, usingEmulation, emulatingUser ){
		var oUser = wirebox.getInstance("usermodels.User"); // load blank user or one already created
		// look for them as employee first
		var userFound = ProcessAsEmployee(
			accessID = arguments.accessID,
			oUser = oUser
		);
		// if not found as emp try non employee
		if( NOT userFound ){
			userFound = ProcessAsNonEmployee(
				accessID = arguments.accessID,
				oUser = oUser
			);
		}
		// if using emulation add that fact to user object as well for other processes to use in their logging
		if( arguments.usingEmulation ){
			oUser.setUsingEmulation(arguments.usingEmulation);
			oUser.setEmulatingUser(arguments.emulatingUser);
		}
		// return success/fail on user being found
		return userFound;
	}
	
	
	/**
	* get user's access limits (budgets and sup_orgs)
	**/
	public function GetUserLimits(){
		var oUser = wirebox.getInstance("usermodels.User");
		var rtnStruct.foundRoles = 0;
		// first get the logged in users roles
		var userPermissions = trim(oUser.getlstPermissions());
		if( len(userPermissions) ){
			// go thru our user types and set access limits accordingly
			// are the OHR?  If so they can look up in any sup_org or budget area
			if( len( HelperService.ListCommon(userPermissions, systemRoles.primary)) ){
				// they can see any areas
				rtnStruct.budgetList = "*";
				rtnStruct.SupOrgList = "*";
				rtnStruct.foundRoles = 1;
			}else{
				// from here on we mix and match as they might have multiple access rights
				rtnStruct.SupOrgList = GetSupOrgRights(
					userPermissions = userPermissions 
				);
				rtnStruct.budgetList = GetBudgetCodeRights(
					userPermissions = userPermissions
				);
				if( len(rtnStruct.budgetList) OR len(rtnStruct.SupOrgList) ){
					rtnStruct.foundRoles = 1;
				}
			}
		}
		return rtnStruct;
	}
	
	
	/***********************************   Private functions    *******************************/
	
	/**
	* try setting this user in app as an employee user
	* @accessID the accessID of user we're looking up
	* @oUser the user object created with all their stuff (psuid, position ID, job code email, etc.) Is likely empty here
	**/
	private boolean function ProcessAsEmployee( accessID, oUser ){
		var arrCleanedPermissions = [];
		var userFound = 0; // default not found
		// first try as an employee and get structure full of info if found
		var strEmpRights = RMSAPI.GetEmployeeUser(
			accessID = arguments.accessID,
			applicationName = variables.rightsApplicationName
		);
		// found ??
		if( StructKeyExists(strEmpRights,"type") AND strEmpRights.type eq "employee" ){
			userFound = 1;
			// populate primary user info from what we recieved to user object (oUser)
			populator.PopulateFromStruct( arguments.oUser, strEmpRights.attributes );
			// if any rights returned add them to our user
			var arrPermissions = []; // permissions are really "roles" in our app
			var arrRoles = []; // roles are Workday roles or directly assigned in RMS
			if( StructKeyExists(strEmpRights,"arrAppRights") AND ArrayLen(strEmpRights.arrAppRights) ){
				/**comes back as an array but since we passed in an app name it's only 1 item since one array item per 
				application so hardwire in first element in array. **/
				for (var ePermission in strEmpRights.arrAppRights[1].permissions) {
					// each permission has a series of attributes like role name it comes from, sup org constriants, etc.
					for( var pAttribute IN ePermission.permissionAttributes ){
						// figure out our constraints list
						if( pAttribute.constraintType eq 'unconstrained' ){
							var isConstrained = 0;
							var assignedSupOrgList = "*"; // wildcard (all sup_orgs)
							var assignedCostCenterList = "";
						}else{
							var isConstrained = 1;
							// build list of sup_orgs user is constrained to
							var assignedSupOrgList = "";
							for(var supOrgC IN pAttribute.supOrgConstraints){
								assignedSupOrgList = listAppend(assignedSupOrgList,supOrgC.assigned_sup_org);
							}
							// build list of cost centers user is constrained to
							var assignedCostCenterList = "";
							if( StructKeyExists(pAttribute,"costCenterConstraints") ){
								for(var costCenterC IN pAttribute.costCenterConstraints){
									assignedCostCenterList = listAppend(assignedCostCenterList,numberformat(costCenterC.assigned_admin_area,"009"));
								}	
							}
						}
						// set the role info as struct
						var strRoleInfo = {
							source = pAttribute.source, // e.g. WorkDay or direct assigned
							primary="Y",  // hard wired for now
							value = pAttribute.role, // e.g. PSU_ORG_ROLE_PROFESSIONAL_SERVICES_LABOR_EMPLOYEE_RELATIONS
							friendlyName = pAttribute.roleFriendly, // e.g. Professional Services - Labor &amp; Employee Relations
							constrained = isConstrained // e.g. unconstrained
						};
						// add to our array of roles this user is in
						arrayAppend(arrRoles,strRoleInfo );
						// set permissions from this role as struct
						var strPermissionInfo = {
							permission = ePermission.permissionName, // e.g. primary or HR or Finance or view, etc.
							source = pAttribute.source, // e.g. WorkDay or direct assigned
							assignedSupOrgList = assignedSupOrgList, // wildcard or specific list of sup_orgs
							assignedFOadminAreaList = assignedCostCenterList // list of admin areas for budgets (if any)
						};
						// add to our array of permissions
						arrayAppend(arrPermissions,strPermissionInfo );
					}
				}
				// did we get any roles at all?
				if( arrayLen(arrRoles) ){
					// get final values of permissions (supOrg,FO admin area) per permission type. This combines multiple permission sets into one master array
					arrCleanedPermissions = ParseWorkdayPermissions(
						arrPermissions = arrPermissions
					);
				}
			}
			// all our roles now accounted for - set to user object
			if( arrayLen(arrRoles) ){
				arguments.oUser.setarrRoles(
					arrRoles = arrRoles
				);
				if( arrayLen(arrCleanedPermissions) ){
					// we got a finished set with values so assign to user
					arguments.oUser.setarrPermissions(
						arrPermissions = arrCleanedPermissions
					);
				}
			}
		}  // end - ( StructKeyExists(strEmpRights,"type") AND strEmpRights.type eq "employee" )
		return userFound;	
	}
	
	/**
	* try setting this user in app as a non-employee user
	* @accessID the accessID of user we're looking up
	* @oUser the user object created with all their stuff (psuid, position ID, job code email, etc.) Is likely empty here
	**/
	private boolean function ProcessAsNonEmployee( accessID, oUser ){
		var userFound = 0; // default not found
		var strNonEmpRights = RMSAPI.GetNonEmployeeUser(
			accessID = arguments.accessID,
			applicationName = rightsApplicationName
		);
		if( StructKeyExists(strNonEmpRights,"accessID") AND strNonEmpRights.accessID IS arguments.accessID ){
			userFound = 1;
			//accessID returned matches what we sent
			populator.PopulateFromStruct( arguments.oUser, strNonEmpRights.attributes );
			// if any rights returned add them to our user
			if( StructKeyExists(strNonEmpRights,"arrAppRights") AND arrayLen(strNonEmpRights.arrAppRights) ){
				if( arrayLen(strNonEmpRights.arrAppRights[1].permissions) ){
					arguments.oUser.setarrPermissions(
						arrPermissions = strNonEmpRights.arrAppRights[1].permissions
					);
				}	
			}
		}
		return userFound;	
	}
	
	
	/**
	* assign roles/permissions from what we've recieved
	* @arrPermissions array of permissions we found that we're now going to clean up into master sets of permissions
	**/
	private array function ParseWorkdayPermissions(arrPermissions){
		var rtnArray = [];
		var permissionList = "";
		for ( var p in arguments.arrPermissions){
			// do we already have this permission in Array?
			if( NOT ListFindNoCase(permissionList,p.permission) ){
				permissionList = listAppend(permissionList,p.permission); // add to our list of permissions used for seeing if we've already processed this permission from different source
				arrayAppend(rtnArray,{permissionName=p.permission, supOrgList="", FOadminAreaList=""}); //add to our array of positions containing permission name and blank sup_org list
			}
			// loop thru our returning array as presently built and figure out sup_org assignment
			for( var T IN rtnArray ){
				if( T.permissionName EQ p.permission ){
					// sup orgs
					if( p.assignedSupOrgList eq "*" ){
						// we got a wildcard "all" so replace whatever is there so far with "all" (*)
						T.supOrgList = p.assignedSupOrgList;
					}else if( T.supOrgList neq "*" ){
						// if we got a list of sup_orgs and list already isn't "all" (*) then add to it otherwise leave as "all"
						T.supOrgList = listAppend(T.supOrgList,p.assignedSupOrgList);
					}
					// financial admin areas
					if( p.assignedFOadminAreaList eq "*" ){
						// we got a wildcard "all" so replace whatever is there so far with "all" (*)
						T.FOadminAreaList = p.assignedFOadminAreaList;
					}else if( T.FOadminAreaList neq "*" ){
						// if we got a list of admin areas and list already isn't "all" (*) then add to it otherwise leave as "all"
						T.FOadminAreaList = listAppend(T.FOadminAreaList,p.assignedFOadminAreaList);
					}
				}
			}
		}
		// loop thru return array one more time looking for any duplicates of sup_orgs in the above process and clean those out
		for( var X IN rtnArray ){
			X.supOrgList = ListRemoveDuplicates(X.supOrgList, ",", true);
			X.FOadminAreaList = ListRemoveDuplicates(X.FOadminAreaList, ",", true);
		}
		return rtnArray;
	}
	
	
	
	/**
	* get budget area rights (FO admin areas)
	**/
	private string function GetBudgetCodeRights( required string userPermissions ){
		var budgetAreaList = "";
		// are they an FO rep or some other user allowed to work with FO processes? 
		if( len( HelperService.ListCommon(arguments.userPermissions,systemRoles.Finance)) ){
			// get their budget areas
			var oUser = wirebox.getInstance("usermodels.User");
			// if not constrained can see all otherwise only those they have rights to
			if( isArray(oUser.getarrPermissions()) AND arrayLen(oUser.getarrPermissions()) ){
				for ( var P in oUser.getarrPermissions() ){
					if( P.permissionName eq systemRoles.finance ){
						budgetAreaList = listAppend(budgetAreaList,P.FOadminAreaList);	
					}
				}
			}	
		}
		return ListRemoveDuplicates(budgetAreaList, ",", true);
	}
	
	
	/**
	* get sup_org rights
	**/
	private function GetSupOrgRights( required string userPermissions ){
		var supOrgList = "";
		if( len( HelperService.ListCommon(arguments.userPermissions,systemRoles.HR)) ){
			// get sup orgs	
			var oUser = wirebox.getInstance("usermodels.User");
			// if not constrained can see all otherwise only those they have rights to
			if( isArray(oUser.getarrPermissions()) AND arrayLen(oUser.getarrPermissions()) ){
				for ( var P in oUser.getarrPermissions() ){
					if( P.permissionName eq systemRoles.HR ){
						supOrgList = listAppend(SupOrgList,P.supOrgList);	
					}
				}
			}	
		}
		return ListRemoveDuplicates(supOrgList, ",", true);
	}


	/**
	*get RMS direct user
	 **/
	 public function GetRMSUser( accessID ){
		 return UserDataManager.GetRMSUser(
	 		accessID = arguments.accessID
	 	);
	 }
	

}