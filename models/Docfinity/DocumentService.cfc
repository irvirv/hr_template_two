component output="false" singleton {
	
	// services
	property name="SecurityService" inject="id:Docfinity.SecurityService";
	property name="DocfinityGateway" inject="id:Docfinity.DocfinityGateway";
	property name="LoggingService" inject="logbox:logger:{this}";
    // settings
    //property name="urlDocfinity" default="https://dms-test.ais.psu.edu/ohrweb/webservices/rest";
	property name="arrJSONSecurityStrings" inject="coldbox:setting:arrJSONSecurityStrings"; // common json security prefixes - coldfusion will handle // by itself
	property name="mimetypes" inject="Coldbox:Setting:mimetypes";
	property name="validFileExt" inject="Coldbox:Setting:validFileExt";

	/**
	* init
	**/
	public function init(){
		urlDocfinity = "https://dms-test.ais.psu.edu/ohrweb/webservices/rest";
		urlDocfinityServLet = "https://dms-test.ais.psu.edu/ohrweb/servlet/";
		return this;
	}
	
	/**
	* get document files types accepted by Docfinity
	**/
	public function ListDocumentFileTypes(){
		return DocfinityGateway.ListDocumentFileTypes();
	}

	/**
	* get document types accepted by Docfinity fro our user
	**/
	public function ListDocumentTypes(){
		return DocfinityGateway.ListDocumentTypes();
	}

	/**
	* get document type metadata fields
	**/
	public function ListDocumentMetaData(required string documentTypeID){
		return DocfinityGateway.ListDocumentMetaData(documentTypeID);
	}


	/**
	* upload a user document to Docfinity
	**/
	public function UploadDocument( 
		required string userID, 
		required string filename, 
		required string docType, 
		required string jobOrderNumber,
		required string IPAddress,
		required string destination, 
		required string uploadFilePath, 
		required string nameConflict,
		required string jobTitle,
		required numeric bidID,
		required numeric candidateID ){
		var rtnStruct = {};
		// upload the file onto our file system
		var strUploadResult = UploadFile(
			filename = arguments.filename,
			destination = arguments.destination,
			uploadFilePath = arguments.uploadFilePath,
			nameConflict = arguments.nameConflict
		);
		if( StructKeyExists(strUploadResult,"errorMsg") ){
			// return error message and quit
			return strUploadResult;
		}else if (NOT strUploadResult.FileWasSaved OR NOT ListFindNoCase(validFileExt, strUploadResult.serverFileExt)){
			// file couldn't be saved for some reason
			try {
				fileDelete(strUploadResult.serverdirectory & "\" & strUploadResult.serverfile);
			}
			catch (any e) {
				// do nothing 
			}
			rtnStruct.errorMsg = "The file you tried to upload is not recognized as a valid document type.  Perhaps you are missing 
				the file extension on the end of the file.  The only way the server can tell that you are sending a proper document is if the 
				extension is one of '" & lcase(validFileExt) & "'.  Click your BACK button to return to the upload form.";
			// return as non uploaded with error message 
			return rtnStruct;
		}
		// upload to Docfnity itself.  It returns a Document ID
		var resDocfinityID = DocfinityGateway.UploadDocument( fileLocation = strUploadResult.serverdirectory & "\" & strUploadResult.serverfile );
		// if the upload to docfinity was successful remove the upload doc from its temp location 
		if ( !len(resDocfinityID) ){
			rtnStruct.errorMsg = "There was an error in saving your uploaded document.  Please try again.";
			return rtnStruct;
		}
		else {
			// was ok so delete temp file that was uploaded to server 
			try {
				FileDelete (strUploadResult.serverdirectory & "\" & strUploadResult.serverfile);
			}
			catch (any e) {
				// do nothing 
			}
		}
		// index document in Docfinity 
		var strIndexResult = DocfinityGateway.IndexDocument(
			documentTypeID = "cfc25889d81bcf3d0jtyg5mcf0000000", 
			jobOrderNumber = arguments.jobOrderNumber,
			clientFileName = strUploadResult.clientFileName,
			clientFileExt = strUploadResult.clientFileExt,
			contentType = strUploadResult.contentType,
			contentSubType = strUploadResult.contentSubType,
			candidateID = arguments.candidateID,
			docType = arguments.docType,
			IPAddress = arguments.IPAddress,
			documentID = local.resDocfinityID,
			bidID = arguments.bidID,
			jobTitle = arguments.jobTitle,
			nameFirst = "",
			nameLast = "" );

		if ( !StructKeyExists(strIndexResult,"metadataLoaded") OR strIndexResult.metadataLoaded neq 'yes' ){
			rtnStruct.errorMsg = "There was an error in indexing your uploaded document.  Please try again.";
			return rtnStruct;
		}
	}


	/**
	*  Get docs loaded for our candidate for a specific job
	*  In our test instance all we have now to look up with is jobID but does show method
	*  You have to have a categoryID or a documentTypeID - just using broader category for now - most apps migth use docType.
	**/
	public function GetDocsInfo(required numeric candidateID, required numeric jobOrderNumber){
		//writedump(arguments); abort;
		var searchID = "cfc25889d81bcf3d0jtygc9er0000000"; // this gets defined by Docfinity admin.
		var categoryID = "cfc25889d81bcf3d0jtyg4l2d0000000"; // category docTypes fall under - structure is category1/docType1, category1/docType2,....
		var strMetaValues = {
			"metadataId" = "cfc25889d81bcf3d0jtygc9io0000000", /// this is metaID for job ID
      		"numericValue" = 1, // everything in demo hard wired to job ID 1
      		"metadataType" = "INTEGER"
		};
		var strSearchResults =  DocfinityGateway.ExecuteSearch(
			searchID = searchID,
			categoryID = categoryID,
			strMetaValues = strMetaValues
		);
		//writedump(strSearchResults); abort;


	}

	
	/*************************   private functions   ****************************/
	
	/**
	* upload file onto our file system
	**/
	private function UploadFile( required string filename, required string destination, required string uploadFilePath, required string nameConflict ){
		setting requestTimeOut="180";
		try {
    		lock name=hash(arguments.filename), timeout="180", type="Exclusive", throwOnTimeout="true" {
    			var strUploadResult = fileUpload(arguments.destination, arguments.uploadFilePath, variables.mimetypes, arguments.nameConflict);
			}
		
		}
		catch (any e) {
			try {
				LoggingService.error(e);
				LoggingService.error(arguments.destination);
				LoggingService.error(arguments.filename);
				LoggingService.error(variables.mimetypes);
				LoggingService.error(arguments.nameConflict);
				}
				catch (any e) {
					// do nothing 
				}
			rtnStruct.errorMsg = "There was a problem uploading your file. Please check file type.";
			return rtnStruct;
		}
		return strUploadResult;
	}
	
	
}