component output="false" singleton {
	
	
	property name="workdayAPI" inject="Coldbox:setting:workdayAPI";
	strWorkdayAPI = {}; //bearer token info structure
	
	/**
	* init
	**/
	public function init(){
		return this;
	}
	
	/**
	* get employee Info
	**/
	public function GetEmployeeAPIinfo( required PSUID ){
		var rtnStruct = {};
		rtnStruct.APIResult = "";
		// get valid bearer token for api call
		var bearerToken = GetBearerToken();
		if( bearerToken eq 0 ){
			rtnStruct.APIResult = "bearer_failed";
		}else{
			cfhttp(method="GET", url="#workdayAPI.RootURL#Users/#arguments.PSUID#", result="local.resLookup", timeout="60"  ) {
    			cfhttpparam(name = "Authorization", type = "header", value = "Bearer #bearerToken#");
			}
			if( resLookup.ResponseHeader.status_code IS '200' ){
				// webservice call was successful
				rtnStruct.strEmpData = DeserializeJSON(resLookup.filecontent);
				// checking to see PSUID returned matches one sent
				if( rtnStruct.strEmpData.id IS arguments.PSUID ){
					rtnStruct.APIResult = "success";
				}else{
					// do wrong user return error
					rtnStruct.APIResult = "wrong_emp";
				}
			}else if( resLookup.ResponseHeader.status_code IS "404" ){
				rtnStruct.APIResult = "no_emp_api";
			}else{
				// do error handling for non-200/404 response
				rtnStruct.APIResult = "api_failed";
			}
		}
		return rtnStruct;
	}
	
	
	/***********************************   Private functions    *******************************/
	
	
	/**
	* get Bearer token for api call
	**/
	private function GetBearerToken(){
		var currentBearerInfo = getStrWorkdayAPI(); 
		if( StructKeyExists(currentBearerInfo,"workdayBearerToken") ){
			return currentBearerInfo.workdayBearerToken;
		}else{
			return 0;
		}
	}
	
	/**
	* get current API info
	**/
	private function GetStrWorkdayAPI(){
		if( StructKeyExists(strWorkdayAPI,"tokenDate") AND DateDiff("s", strWorkdayAPI.tokenDate, now()) LT strWorkdayAPI.expiresInSeconds ){
			//what we have is good and not expired
			return strWorkdayAPI;
		}else if( setStrWorkdayAPI() ){
			//expired so rebuild and return if successful
			return strWorkdayAPI;
		}else{
			return {};
		}			
	}
	
	/**
	* set Workday API info so as to be current (non-expired)
	**/
	private function SetStrWorkdayAPI(){
		try{
			cfhttp(method="POST", url="#workdayAPI.TokenRoot#", result="local.bToken") {
    			cfhttpparam(name = "grant_type", type = "formfield", value = "client_credentials");
    			cfhttpparam(name = "client_id", type = "formfield", value = "#workdayAPI.ClientID#");
    			cfhttpparam(name = "client_secret", type = "formfield", value = "#workdayAPI.Secret#");
			}
		} catch (any e) {
			//Writeoutput(e); abort;
			return 0;
		}
		if( bToken.ResponseHeader.status_code IS '200' ){
			try{
				var strRights = deserializeJSON(bToken.filecontent);
				//populate values
				strWorkdayAPI.tokenDate = now();
				strWorkdayAPI.workdayBearerToken = strRights.access_token;
				strWorkdayAPI.expiresInSeconds = strRights.expires_in - 60;
				return 1;
			} catch (any e){
				return 0;
			}
		}else{
			return 0;
		}
	}
}