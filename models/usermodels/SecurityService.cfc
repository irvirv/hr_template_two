component output="false" singleton {

	// wirebox 
	property name="wirebox" inject="wirebox";
	// services
	property name="UserService" inject="id:usermodels.UserService";
	property name="logbox" inject="logbox:logger:{this}";
	// settings
	property name="allowGeneralUser" inject="coldbox:setting:allowGeneralUser";
	property name="adminUserRole" inject="coldbox:setting:adminUserRole";
	property name="idleTimeout" inject="coldbox:setting:idleTimeout";
	// modules
	property name="EmulationService" inject="EmulationService@rmsUserEmulation";
	

		
	/**
	* init
	**/
	public component function init(){
		return this;
	}
	
	/**
	* Check user access rights
	*
	* if not currently set with appropriate user rights (perhaps first page viewed in app?) then 
	* check remote_user for a value (all apps are behind web_access), log user in and re-check.
	* if still no rights return failed access
	*
	* @authorizedRoles the list of role names the user must belong to for successful access (match any one of passed in names not all of them)
	**/
	public boolean function CheckAccess(string authorizedRoles="any"){
		// already logged in (either as self or emulated user) and authorized for page?
		if( UserInRoleList(arguments.authorizedRoles) ){
			return 1;
		// not logged in so check for remote_user (should be there 100% of time) and try authentication process
		}else if( StructKeyExists(cgi,"remote_user") AND len(trim(cgi.remote_user)) ){
			// not logged in to app (first page viewed this session) or not authorized so log in and refresh roles list for one more try
			if( DoAuthentication(cgi.remote_user) AND UserInRoleList(arguments.authorizedRoles) ){
				// logged in and in list so authorized
				return 1;
			}else{
				//2nd try failed so not authorized
				return 0;
			}
		}else{
			// this app is behind webAccess (ThumbPrint) so if cgi.remote_user is not available auto-fail all app access
			return 0;
		}	
	}
	
	
	/** 
	* just check if a prmary user
	**/
	public boolean function CheckIfAdminUser(){
		return UserInRoleList(adminUserRole);
	}


	/** 
	* logout user
	**/
	public void function Logout(){
		getPageContext().getSession().invalidate();
		//StructClear(Session);
	}
	
	
	/***********************************   Private functions    *******************************/
	
	
	/** 
	* Try to create logged in user values and authenticate as having proper rights
	*
	* @remoteUser the accessID of the actual user (not yet checked for emulation)
	**/
	private boolean function DoAuthentication(required string remoteUser){
		// get the user accessID we're working with (might be an emulated user)
      	var strGetLoginInfo = GetWorkingUserAccessID(
      		remoteUser = arguments.remoteUser
      	);
		// got a working user value string?
      	if( len(strGetLoginInfo.workingAccessID) ){
			// go set our user object using the userservice.  This will set all the user's info like Workday roles, PSUID, name, directly assigned roles, etc.
			var resSetUserInfo = UserService.SetUserInfo(
				accessID = strGetLoginInfo.workingAccessID,
				usingEmulation = strGetLoginInfo.usingEmulation,
				emulatingUser = strGetLoginInfo.emulatingUser
			);
			// did we find our user?
			if( resSetUserInfo ){
				// set roles based on permissions we found
				var lstUserRoles = ParsePermissions();
				if( variables.allowGeneralUser && StructKeyExists(variables,"generalUserRole") && len(variables.generalUserRole) ){
					// if allowing general user (one with no specific roles) then add general user role
					lstUserRoles = listappend(lstUserRoles,variables.generalUserRole);
				}
				// try direct admin RMS roles - this is outside of emulation - HR direct assignment to system
				// user info based on direct rms user access (uses actual user coming in rather than emulation)
				var rmsDirectUser = UserService.GetRMSUser(
					accessID = arguments.remoteUser
				);
				if( rmsDirectUser.recordcount ){
					for (var accessRecord in rmsDirectUser) {
						lstUserRoles = listappend(lstUserRoles,accessRecord.accessType);
					}
				}
				if( len(lstUserRoles) ){
					// if got any roles at all, including general role, then just add "any" as a role for easy string search
					lstUserRoles = listappend(lstUserRoles,"any");
				}
				lstUserRoles = ListRemoveDuplicates(lstUserRoles, ",", true);
				if( len(lstUserRoles) ){
					// set our user object roles
					if( strGetLoginInfo.usingEmulation ){
						logbox.info(strGetLoginInfo.emulatingUser & " logging in as " & strGetLoginInfo.workingAccessID & " with roles " & lstUserRoles);
					}else{
						logbox.info(strGetLoginInfo.workingAccessID & " logging in with roles " & lstUserRoles);
					}
					var oUser = wirebox.getInstance("usermodels.User");
					oUser.setlstPermissions(lstUserRoles);
					return 1; // return success
				}else{
					logbox.warn(strGetLoginInfo.workingAccessID & " attempted login but no valid roles. Login failed.");
					return 0;
				}
			}else{
      			logbox.error(strGetLoginInfo.workingAccessID & " attempted login but no employee or non-employee found. Login failed.");
      			return 0;
      		}
      	}else{
      		// didn't get a user string
      		// log this failure
      		logbox.error(arguments.remoteUser & " failed in getting a valid accessID. Login failed.");
      		return 0; // return failure
      	}
	}


	/**
	* get user value we're to use - using one coming in or one emulating if emulation is on and user emulating someone
	*
	* * @remoteUser the accessID of the actual user (not yet checked for emulation)
	**/
	private struct function GetWorkingUserAccessID(required string remoteUser){
		var rtnStruct.usingEmulation = 0;  // are we using emulation for this particualr session?  default to "no".
		rtnStruct.emulatingUser = ''; // user potentially doing the emulating of someone else (default to blank)
		rtnStruct.workingAccessID = arguments.remoteUser; // default to who we really are
		/* 	This is our emulation module which will check for user emulation.
			Drop rmsEmulation module into module_app folder and check readme for simple setup
		*/
		var emulatedUser = EmulationService.GetEmulatedUserAPI(arguments.remoteUser);
		if( len( emulatedUser ) ){
			//assign our emulated user if found
			rtnStruct.usingEmulation = 1; // yes, we're emulating someone
			rtnStruct.workingAccessID = emulatedUser; // person we're pretending to be
			rtnStruct.emulatingUser = arguments.remoteUser;  // person we really are
		}
		return rtnStruct;
	}
	
	
	/**
	* assign permissions from what we've recieved
	**/
	private string function ParsePermissions(){
		var lstPermissions=""; // default to no permissions
		var oUser = wirebox.getInstance("usermodels.User");
		var arrPermissions = oUser.getarrPermissions();
		if( isArray(arrPermissions) AND arrayLen(arrPermissions) ){
			// create simple list of permission types to return
			for (var ePermission IN arrPermissions){
				lstPermissions = listappend(lstPermissions, ePermission.permissionName);
			}
		}
		return lstPermissions;
	}
	
	
	/**
	* is user in any of list of roles 
	* @roleList list of roles to check and see if user is a member of at least one
	**/
	private boolean function UserInRoleList(roleList){
		var oUser = wirebox.getInstance("usermodels.User");
		if( len(oUser.getlstPermissions()) ){
			var arrCheckedRoles = ListToArray(arguments.roleList); // roles we requiring put in array
			var arrUserRoles = ListToArray(oUser.getlstPermissions()); // roles user has put in array
			// if any one of our required exists in the ones user has then success otherwise no rights
			arrCheckedRoles.retainAll(arrUserRoles); // reduces arrCheckedRoles to those also found in arrUserRoles
			if( ArrayLen( arrCheckedRoles ) ){
				return true;
			}else{
				return false;
			}
		}else{
			return  false;
		}
	}

}
