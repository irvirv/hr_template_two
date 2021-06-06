component output="false" singleton {
	
	// services
	property name="SecurityService" inject="id:Docfinity.SecurityService";
	property name="LoggingService" inject="logbox:logger:{this}";
    // settings
    property name="urlDocfinityRest" inject="coldbox:setting:urlDocfinityRest";
	property name="urlDocfinityServlet" inject="coldbox:setting:urlDocfinityServlet";
	property name="arrJSONSecurityStrings" inject="coldbox:setting:arrJSONSecurityStrings"; // common json security prefixes - coldfusion will handle // by itself
	
	/**
	* init
	**/
	public function init(){
		return this;
	}
	
	/**
	* get document files types accepted by Docfinity
	**/
	public function ListDocumentFileTypes(){
		//writedump(urlDocfinityRest); abort;
		var xsrfToken = SecurityService.GenerateXSRFToken();
		var bearerToken = SecurityService.GetBearerToken();
		var strDocfinityUser = SecurityService.GetDocfinityUser();
		try{
			cfhttp(	method="GET", 
				url=urlDocfinityRest & "document/filetypes", 
				result="local.httpResultStruct",
				timeout="60"
			){
				cfhttpparam(name="XSRF-TOKEN", type="cookie", value="#xsrfToken#");
				cfhttpparam(name="Authorization", type="header", value="Bearer #bearerToken#");
				cfhttpparam(name="X-XSRF-TOKEN", type="header", value="#xsrfToken#");
				cfhttpparam(name="X-AUDITUSER", type="header", value="#strDocfinityUser.user#");
			}
		} 
		catch(any e){
			// hard failure
			LoggingService.error(" hard failure of Docfinity api caught by try/catch block: " & e.message & e.detail, e.tagcontext );
			return {};
		}
		// why not this? - if( StructKeyExists(httpResultStruct,"statusCode") ){
		if( StructKeyExists(httpResultStruct,"ResponseHeader") && StructKeyExists(httpResultStruct.ResponseHeader,"status_code") ){
			switch ( httpResultStruct.ResponseHeader.status_code ){
				// normal success
				case "200":
					// pull out filecontent to work with
					var JSONString = httpResultStruct.filecontent;
					// strip security prefix (if any) - Coldfusion will do by itself for its own string (//) but not others commonly used
					for( var i IN arrJSONSecurityStrings ){
						if( left(JSONString,len(i)) == i ){
							JSONString = right(JSONString, len(JSONString) - len(i));
							break;
						}
					}
					if( isJSON(JSONString) ){
						return DeserializeJSON(JSONString);
					}else{
						// bad json data came back
						LoggingService.error(" Docfinity call failed.  Bad JSON returned ", httpResultStruct);
						return {};
					}
					break;

				// unauthorized
				case "401":
					LoggingService.error(" Docfinity call failed with authorization error.  Please check credentials. ", httpResultStruct);
					return {};
					break;

				// not found
				case "404":
					LoggingService.warn("Docfinity data not found - 404.", httpResultStruct);
					return {};
					break;

				// default (some other error)
				default:
					// log error and return empty struct. 
					try{
						LoggingService.error("Docfinity call failed with " & httpResultStruct.ResponseHeader.status_code, httpResultStruct);
					} catch (any e){
						LoggingService.error(e.message, e.detail);
					}
					return {};
					break;
			}
		}else{
			// hard failure
			LoggingService.error(" hard failure of Docfinity api ", httpResultStruct);
			return {};
		}
	}


	/**
	* get document types accepted by Docfinity for our user
	* https://dms-test.ais.psu.edu/ohrweb/webservices/rest/documentType/user
	**/
	public function ListDocumentTypes(){
		var xsrfToken = SecurityService.GenerateXSRFToken();
		var bearerToken = SecurityService.GetBearerToken();
		var strDocfinityUser = SecurityService.GetDocfinityUser();
		try{
			cfhttp(	method="GET", 
				url=urlDocfinityRest & "documentType/user", 
				result="local.httpResultStruct",
				timeout="60"
			){
				cfhttpparam(name="XSRF-TOKEN", type="cookie", value="#xsrfToken#");
				cfhttpparam(name="Authorization", type="header", value="Bearer #bearerToken#");
				cfhttpparam(name="X-XSRF-TOKEN", type="header", value="#xsrfToken#");
				cfhttpparam(name="X-AUDITUSER", type="header", value="#strDocfinityUser.user#");
			}
		} 
		catch(any e){
			// hard failure
			LoggingService.error(" hard failure of Docfinity api caught by try/catch block: " & e.message & e.detail, e.tagcontext );
			return {};
		}
		// why not this? - if( StructKeyExists(httpResultStruct,"statusCode") ){
		if( StructKeyExists(httpResultStruct,"ResponseHeader") && StructKeyExists(httpResultStruct.ResponseHeader,"status_code") ){
			switch ( httpResultStruct.ResponseHeader.status_code ){
				// normal success
				case "200":
					// pull out filecontent to work with
					var JSONString = httpResultStruct.filecontent;
					// strip security prefix (if any) - Coldfusion will do by itself for its own string (//) but not others commonly used
					for( var i IN arrJSONSecurityStrings ){
						if( left(JSONString,len(i)) == i ){
							JSONString = right(JSONString, len(JSONString) - len(i));
							break;
						}
					}
					if( isJSON(JSONString) ){
						return DeserializeJSON(JSONString);
					}else{
						// bad json data came back
						LoggingService.error(" Docfinity call failed.  Bad JSON returned ", httpResultStruct);
						return {};
					}
					break;

				// unauthorized
				case "401":
					LoggingService.error(" Docfinity call failed with authorization error.  Please check credentials. ", httpResultStruct);
					return {};
					break;

				// not found
				case "404":
					LoggingService.warn("Docfinity data not found - 404.", httpResultStruct);
					return {};
					break;

				// default (some other error)
				default:
					// log error and return empty struct. 
					try{
						LoggingService.error("Docfinity call failed with " & httpResultStruct.ResponseHeader.status_code, httpResultStruct);
					} catch (any e){
						LoggingService.error(e.message, e.detail);
					}
					return {};
					break;
			}
		}else{
			// hard failure
			LoggingService.error(" hard failure of Docfinity api ", httpResultStruct);
			return {};
		}
	}


	/**
	* get document types accepted by Docfinity for our user
	* https://dms-test.ais.psu.edu/ohrweb/webservices/rest/documentType/metadata?id=cfc25889d81bcf3d0jtyg5mcf0000000
	**/
	public function ListDocumentMetaData(required string documentTypeID){
		var xsrfToken = SecurityService.GenerateXSRFToken();
		var bearerToken = SecurityService.GetBearerToken();
		var strDocfinityUser = SecurityService.GetDocfinityUser();
		try{
			cfhttp(	method="GET", 
				url=urlDocfinityRest & "documentType/metadata?id=" & arguments.documentTypeID, 
				result="local.httpResultStruct",
				timeout="60"
			){
				cfhttpparam(name="XSRF-TOKEN", type="cookie", value="#xsrfToken#");
				cfhttpparam(name="Authorization", type="header", value="Bearer #bearerToken#");
				cfhttpparam(name="X-XSRF-TOKEN", type="header", value="#xsrfToken#");
				cfhttpparam(name="X-AUDITUSER", type="header", value="#strDocfinityUser.user#");
			}
		}
		catch(any e){
			// hard failure
			LoggingService.error(" hard failure of Docfinity api caught by try/catch block: " & e.message & e.detail, e.tagcontext );
			return {};
		}
		// why not this? - if( StructKeyExists(httpResultStruct,"statusCode") ){
		if( StructKeyExists(httpResultStruct,"ResponseHeader") && StructKeyExists(httpResultStruct.ResponseHeader,"status_code") ){
			switch ( httpResultStruct.ResponseHeader.status_code ){
				// normal success
				case "200":
					// pull out filecontent to work with
					var JSONString = httpResultStruct.filecontent;
					// strip security prefix (if any) - Coldfusion will do by itself for its own string (//) but not others commonly used
					for( var i IN arrJSONSecurityStrings ){
						if( left(JSONString,len(i)) == i ){
							JSONString = right(JSONString, len(JSONString) - len(i));
							break;
						}
					}
					if( isJSON(JSONString) ){
						return DeserializeJSON(JSONString);
					}else{
						// bad json data came back
						LoggingService.error(" Docfinity call failed.  Bad JSON returned ", httpResultStruct);
						return {};
					}
					break;

				// unauthorized
				case "401":
					LoggingService.error(" Docfinity call failed with authorization error.  Please check credentials. ", httpResultStruct);
					return {};
					break;

				// not found
				case "404":
					LoggingService.warn("Docfinity data not found - 404.", httpResultStruct);
					return {};
					break;

				// default (some other error)
				default:
					// log error and return empty struct. 
					try{
						LoggingService.error("Docfinity call failed with " & httpResultStruct.ResponseHeader.status_code, httpResultStruct);
					} catch (any e){
						LoggingService.error(e.message, e.detail);
					}
					return {};
					break;
			}
		}else{
			// hard failure
			LoggingService.error(" hard failure of Docfinity api ", httpResultStruct);
			return {};
		}
	}



	/**
	* upload a document on our file system to Docfinity
	**/
	public function UploadDocument( required string fileLocation ){
		var xsrfToken = SecurityService.GenerateXSRFToken();
		var strDocfinityUser = SecurityService.GetDocfinityUser();
		var docfinityPath = urlDocfinityservlet & "upload/?j_username=" & strDocfinityUser.user & "&j_password=" & strDocfinityUser.pass;
		try{
			cfhttp(	method="POST", 
				url=docfinityPath, 
				result="local.httpResultStruct",
				multipart="true",
				timeout="60"
			){
				cfhttpparam(name="file", type="file", file="#arguments.fileLocation#");
				cfhttpparam(name="XSRF-TOKEN", type="cookie", value="#xsrfToken#");
				cfhttpparam(name="X-XSRF-TOKEN", type="header", value="#xsrfToken#");
				cfhttpparam(name="X-AUDITUSER", type="header", value="#strDocfinityUser.user#");
			}
		} 
		catch(any e){
			// hard failure
			LoggingService.error("hard failure of Docfinity api call caught by try/catch block: " & e.message & e.detail, e.tagcontext );
			return "";
		}
		if( StructKeyExists(httpResultStruct,"ResponseHeader") && StructKeyExists(httpResultStruct.ResponseHeader,"status_code") ){
			switch ( httpResultStruct.ResponseHeader.status_code ){
				// normal success
				case "200":
					// filecontent is document ID $$$$ need to test for this somehow in case get something else
					// $$$$ maybe log this success as well?
					return httpResultStruct.filecontent;
					break;

				// unauthorized (bad authentication)
				case "401":
					LoggingService.error("Docfinity call failed with authentication error.  Please check credentials. ", httpResultStruct);
					return "";
					break;
				
				// forbidden
				case "403":
					LoggingService.error("Docfinity call failed with error of forbidden.  Please check credentials and access at remote server. ", httpResultStruct);
					return "";
					break;

				// not found
				case "404":
					LoggingService.warn("Docfinity data not found - 404. ", httpResultStruct);
					return "";
					break;

				// default (some other error)
				default:
					// log error and return empty struct. 
					try{
						LoggingService.error("Docfinity call failed with " & httpResultStruct.ResponseHeader.status_code, httpResultStruct);
					} catch (any e){
						LoggingService.error(e.message, e.detail);
					}
					return "";
					break;
			}
		}else{
			// hard failure
			LoggingService.error(" hard failure of Docfinity api ", httpResultStruct);
			return "";
		}
	}


	/**
	* index our document
	*  Most of these arguments aren't used in this demo but they exist in the current job site for resumes, etc. so including as arguments.
	*  Would need added to Docfinity in order to use.  Only a handful presently there for dev purposes.
	*  $$$$ need to validate both inputs and metadata values.  For instance a string could come in as a numeric value which would then serialize 
	*  as numeric while docfinity is expecting a value enclosed in quotes. 
	**/
	public function IndexDocument( 
		required string documentID,
		required string documentTypeID,
		required numeric jobOrderNumber,
		required numeric bidID,
		required string jobTitle,
		required numeric candidateID,
		nameFirst,
		nameLast,
		PSUID,
		clientFileName,
		clientFullFileName,
		clientFileExt,
		docType,
		IPAddress,
		contentType,
		contentSubType,
		mimeType ){
		
		var xsrfToken = SecurityService.GenerateXSRFToken();
		var bearerToken = SecurityService.GetBearerToken();
		var strDocfinityUser = SecurityService.GetDocfinityUser();
		
		// Get our metadata options for this document type (I think we can just set these once in application var and then renew on restart of app).
		// are hard-wired here
		var postValues = [{
			"documentId"=arguments.documentID,
			"documentTypeId"=arguments.documentTypeID,
			"documentIndexingMetadataDtos" = [{
				// Job ID
				"metadataId":"cfc25889d81bcf3d0jtyfy17t0000000",
				"metadataName":"Job Id",
				"documentTypeId":arguments.documentTypeID,
				"type":"INTEGER",
				"value":arguments.jobOrderNumber
			},
			{
				// Candidate ID
				"metadataId":"cfc25889d81bcf3d0jtyfwn330000000",
				"metadataName":"Candidate Id",
				"documentTypeId":arguments.documentTypeID,
				"type":"INTEGER",
				"value":arguments.candidateID
			},
			{
				// Bid ID
				"metadataId":"cfc25889d81bcf3d0jtyg0nuj0000000",
				"metadataName":"Bid Id",
				"documentTypeId":arguments.documentTypeID,
				"type":"INTEGER",
				"value":arguments.bidID
			},
			{
				// Job Title
				"metadataId":"8b78487d44574b9b0j7rwdmlg0000000",
				"metadataName":"Job Title",
				"documentTypeId":arguments.documentTypeID,
				"type":"STRING_VARIABLE",
				"value":left(arguments.jobTitle,50)
			}
			]
		}];

		var JSONString = serializeJSON(postValues);

		for( var i IN arrJSONSecurityStrings ){
			if( left(JSONString,len(i)) == i ){
				JSONString = right(JSONString, len(JSONString) - len(i));
				break;
			}
		}


		//var fullURL = urlDocfinity & "/documentType/metadata?id=" & arguments.documentTypeID;
		try{
			cfhttp(	method="POST", 
				url=urlDocfinityRest & "indexing/index/commit", 
				result="local.httpResultStruct",
				timeout="60"
			){
				cfhttpparam(name="XSRF-TOKEN", type="cookie", value="#xsrfToken#");
				cfhttpparam(name="X-XSRF-TOKEN", type="header", value="#xsrfToken#");
				cfhttpparam(name="Authorization", type="header", value="Bearer #bearerToken#");
				cfhttpparam(name="X-AUDITUSER", type="header", value="#strDocfinityUser.user#");
				cfhttpparam(name="Content-Type", type="header", value="application/JSON");
				cfhttpparam(name="body", type="body", value="#JSONString#");
			}
		}
		catch(any e){
			// hard failure
			LoggingService.error(" hard failure of Docfinity api caught by try/catch block: " & e.message & e.detail, e.tagcontext );
			return {};
		}
		// why not this? - if( StructKeyExists(httpResultStruct,"statusCode") ){
		if( StructKeyExists(httpResultStruct,"ResponseHeader") && StructKeyExists(httpResultStruct.ResponseHeader,"status_code") ){
			switch ( httpResultStruct.ResponseHeader.status_code ){
				// normal success
				case "200":
					// pull out filecontent to work with
					var JSONString = httpResultStruct.filecontent;
					// strip security prefix (if any) - Coldfusion will do by itself for its own string (//) but not others commonly used
					for( var i IN arrJSONSecurityStrings ){
						if( left(JSONString,len(i)) == i ){
							JSONString = right(JSONString, len(JSONString) - len(i));
							break;
						}
					}
					if( isJSON(JSONString) ){
						return DeserializeJSON(JSONString);
					}else{
						// bad json data came back
						LoggingService.error(" Docfinity call failed.  Bad JSON returned ", httpResultStruct);
						return {};
					}
					break;

				// unauthorized
				case "401":
					LoggingService.error(" Docfinity call failed with authorization error.  Please check credentials. ", httpResultStruct);
					return {};
					break;

				// not found
				case "404":
					LoggingService.warn("Docfinity data not found - 404.", httpResultStruct);
					return {};
					break;

				// default (some other error)
				default:
					// log error and return empty struct. 
					try{
						LoggingService.error("Docfinity call failed with " & httpResultStruct.ResponseHeader.status_code, httpResultStruct);
					} catch (any e){
						LoggingService.error(e.message, e.detail);
					}
					return {};
					break;
			}
		}else{
			// hard failure
			LoggingService.error(" hard failure of Docfinity api ", httpResultStruct);
			return {};
		}
	}


	/**
	* execute a defined search
	**/
	public function ExecuteSearch(required string searchID,required string categoryID, required struct strMetaValues  ){
		var xsrfToken = SecurityService.GenerateXSRFToken();
		var bearerToken = SecurityService.GetBearerToken();
		var strDocfinityUser = SecurityService.GetDocfinityUser();

		var postValues = {
			"searchId": arguments.searchID,
			"startIndex": 0,
			"maxNum": 0,
			"criteria": [
				{
				"metadataId": arguments.strMetaValues.metadataId,
				"numericValue": arguments.strMetaValues.numericValue,
				"metadataType": arguments.strMetaValues.metadataType
				}
			],
			"categoryId": arguments.categoryID
		};


		var JSONString = serializeJSON(postValues);

		for( var i IN arrJSONSecurityStrings ){
			if( left(JSONString,len(i)) == i ){
				JSONString = right(JSONString, len(JSONString) - len(i));
				break;
			}
		}


		try{
			cfhttp(	method="POST", 
				url=urlDocfinityRest & "document/search/category/execute", 
				result="local.httpResultStruct",
				timeout="60"
			){
				cfhttpparam(name="XSRF-TOKEN", type="cookie", value="#xsrfToken#");
				cfhttpparam(name="X-XSRF-TOKEN", type="header", value="#xsrfToken#");
				cfhttpparam(name="Authorization", type="header", value="Bearer #bearerToken#");
				cfhttpparam(name="X-AUDITUSER", type="header", value="#strDocfinityUser.user#");
				cfhttpparam(name="Content-Type", type="header", value="application/JSON");
				cfhttpparam(name="body", type="body", value="#JSONString#");
			}
		}
		catch(any e){
			// hard failure
			LoggingService.error(" hard failure of Docfinity api caught by try/catch block: " & e.message & e.detail, e.tagcontext );
			return {};
		}
		// why not this? - if( StructKeyExists(httpResultStruct,"statusCode") ){
		if( StructKeyExists(httpResultStruct,"ResponseHeader") && StructKeyExists(httpResultStruct.ResponseHeader,"status_code") ){
			switch ( httpResultStruct.ResponseHeader.status_code ){
				// normal success
				case "200":
					// pull out filecontent to work with
					var JSONString = httpResultStruct.filecontent;
					// strip security prefix (if any) - Coldfusion will do by itself for its own string (//) but not others commonly used
					for( var i IN arrJSONSecurityStrings ){
						if( left(JSONString,len(i)) == i ){
							JSONString = right(JSONString, len(JSONString) - len(i));
							break;
						}
					}
					if( isJSON(JSONString) ){
						return DeserializeJSON(JSONString);
					}else{
						// bad json data came back
						LoggingService.error(" Docfinity call failed.  Bad JSON returned ", httpResultStruct);
						return {};
					}
					break;

				// unauthorized
				case "401":
					LoggingService.error(" Docfinity call failed with authorization error.  Please check credentials. ", httpResultStruct);
					return {};
					break;

				// not found
				case "404":
					LoggingService.warn("Docfinity data not found - 404.", httpResultStruct);
					return {};
					break;

				// default (some other error)
				default:
					// log error and return empty struct. 
					try{
						LoggingService.error("Docfinity call failed with " & httpResultStruct.ResponseHeader.status_code, httpResultStruct);
					} catch (any e){
						LoggingService.error(e.message, e.detail);
					}
					return {};
					break;
			}
		}else{
			// hard failure
			LoggingService.error(" hard failure of Docfinity api ", httpResultStruct);
			return {};
		}


	}
	
	
	
}

