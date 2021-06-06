component output="false" singleton {
	
	// services

    // settings
	property name="urlDocfinity" inject="coldbox:setting:urlDocfinityRest";
	property name="docfinityUserSalt" inject="coldbox:setting:docfinityUserSalt";
	
	/**
	* init
	**/
	public function init(){
		//urlDocfinity = "https://dms.ais.psu.edu/ohrweb/webservices/rest";
		return this;
	}


	/**
	* get bearer token
	**/
	public function GetBearerToken(){
		// get our latest creds
		var rsCreds = GetCreds();
		// make the call to docfinity
		try{
			cfhttp(	method="GET", 
				url=urlDocfinity & "user/apikey?userId=" & rsCreds.Secure_ID, 
				result="local.httpResultStruct",
				timeout="60",
				throwonerror = true
			){
				cfhttpparam(name="Authorization", type="header", value="Bearer #rsCreds.Previous_Bearer_Token#");
			}
		} 
		catch(any e){
			writedump(e); abort;
		}
		//writedump(local.httpResultStruct); abort;
		// Remove quotes around the token key within the FILECONTENT returned
		var authKey = replace(local.httpResultStruct["filecontent"],'"','','all');
		//Save the token key to be used for the next REST call
		var resSaveKey = UpdateCreds(
			UX = "test_user",
			newBearerToken = authKey
		);
		return authKey;
    }


	/**
	* get docfinity credentials
	**/
	public function GetCreds(){
		return queryExecute(
            "SELECT UX, PX, Secure_ID, Previous_Bearer_Token, encrypted_user, encrypted_pass
            FROM tbl_Docfinity_User
            WHERE ux = :ux ", 
            {ux: "test_user"}, 
            {datasource = "cf_HRTEST"} 
        );
    }

	/**
	* update docfinity credentials
	* @newBearerToken latest bearer token
	**/
	public function UpdateCreds(newBearerToken, ux){
		queryExecute(
            "UPDATE tbl_Docfinity_User
			SET Previous_Bearer_Token = :newBearerToken
            WHERE ux = :ux ", 
            {ux: arguments.ux, newBearerToken: arguments.newBearerToken}, 
            {datasource = "cf_HRTEST"} 
        );
    }

	/**
	* generate a useable value for xsrfToken / hashing UUID I think works well
	**/
	public function GenerateXSRFToken(){
		return hash(CreateUUID());
	}

	/**
	* get user pass for our Docfinity user
	**/
	public function GetDocfinityUser(){
		var rsUser = GetCreds();
		var rtnStruct.user = decrypt(rsUser.encrypted_user, docfinityUserSalt, "AES", "Base64");
		rtnStruct.pass = decrypt(rsUser.encrypted_pass, docfinityUserSalt, "AES", "Base64");
		return rtnStruct;
	}

	


	
	
}