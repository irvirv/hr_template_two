component output="false" singleton {

	// services
	property name="logbox" inject="logbox:logger:{this}";

	

		
	/**
	* init
	**/
	public component function init(){
		return this;
	}
	
	/**
	* Check user access rights for this request
	*
	**/
	public struct function CheckAccess( required string accessID ){
		var rtnStruct.authenticated = false;
		rtnStruct.authorized = false;
		rtnStruct.authorizedUser ='';
		if( DoAuthentication(arguments.accessID) ){
			rtnStruct.authenticated = true;
			rtnStruct.authorized = true;
			rtnStruct.authorizedUser = arguments.accessID;
		}else{
			logbox.error(arguments.accessID & " attempted login but no employee or non-employee record found. Login failed.");
		}
		return rtnStruct;
	}
	
	

	/** 
	* logout user
	**/
	public void function Logout(){
		getPageContext().getSession().invalidate();
	}
	
	
	/***********************************   Private functions    *******************************/
	
	
	/** 
	* see if user is in our list of active users
	*
	* @remoteUser the accessID of the actual user
	**/
	private boolean function DoAuthentication(required string accessID){
		if( listFindNoCase("Doug,Christian,John", arguments.accessID) ){
			return true;
		}else{
			return false;
		}
	}


}
