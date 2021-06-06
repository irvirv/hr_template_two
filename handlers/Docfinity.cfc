component extends="coldbox.system.EventHandler"{

	// services
    property name="SecurityService" inject="id:usermodels.SecurityService";
    property name="DocumentService" inject="id:Docfinity.DocumentService";
	// settings
	property name="docfinityStatus" inject="Coldbox:Setting:docfinityStatus";
	property name="tempDocsDestination" inject="Coldbox:Setting:tempDocsDestination";
	
	
	
	/** 
	* list document file types
	**/
	public function index(event,rc,prc){
        if( SecurityService.CheckAccess() ){
            prc.loggedInUser = wirebox.getInstance("usermodels.User").getAccessID();
			prc.xe_OHRSite = 'https://hr.psu.edu/';
			prc.ActiveLink = "docfinity.index";
			event.setLayout("worklayout");
			event.setView("docfinity/index");
		}else{
			relocate(event="main.unauthorized", SSL=true);
		}
	}
	
	
	
	/** 
	* list document file types
	**/
	public function ListDocumentFileTypes(event,rc,prc){
        if( SecurityService.CheckAccess() ){
			var viewData.arrFiletypes = DocumentService.ListDocumentFileTypes();
			prc.loggedInUser = wirebox.getInstance("usermodels.User").getAccessID();
			prc.xe_OHRSite = 'https://hr.psu.edu/';
			prc.ActiveLink = "docfinity.index";
			event.setLayout("worklayout");
			event.setView(view="docfinity/ListFileTypes", args=viewData);
		}else{
			relocate(event="main.unauthorized", SSL=true);
		}
	}


	/** 
	* list document types accepted for our user
	**/
	public function ListDocumentTypes(event,rc,prc){
        if( SecurityService.CheckAccess() ){
			var viewData.arrDoctypes = DocumentService.ListDocumentTypes();
			prc.loggedInUser = wirebox.getInstance("usermodels.User").getAccessID();
			prc.xe_OHRSite = 'https://hr.psu.edu/';
			prc.ActiveLink = "docfinity.index";
			prc.xe_listMetadata = "docfinity.ListDocumentMetaData";
			event.setLayout("worklayout");
			event.setView(view="docfinity/ListDocTypes", args=viewData);
		}else{
			relocate(event="main.unauthorized", SSL=true);
		}
	}


	/** 
	* list metadata vars for a document type
	**/
	public function ListDocumentMetaData(event,rc,prc){
        if( SecurityService.CheckAccess() ){
			var viewData.arrMetaDataTypes = DocumentService.ListDocumentMetaData(rc.documentTypeID);
			prc.loggedInUser = wirebox.getInstance("usermodels.User").getAccessID();
			prc.xe_OHRSite = 'https://hr.psu.edu/';
			prc.ActiveLink = "docfinity.index";
			prc.xe_listMetadata = "docfinity.ListDocumentMetaData";
			event.setLayout("worklayout");
			event.setView(view="docfinity/ListDocMetaDataTypes", args=viewData);
		}else{
			relocate(event="main.unauthorized", SSL=true);
		}
	}


	/** 
	* upload document
	**/
	public function UploadDocument(event,rc,prc){
        if( SecurityService.CheckAccess() ){
			var viewData = {};
			event.paramValue("jobOrderNumber",1);
			event.paramValue("candidateID",123456);
			// Docfinity status - up?  down? 
			viewData.docfinityStatus = docfinityStatus;
			if (docfinityStatus){
				// get any optional documents  
				viewData.strDocInfo = DocumentService.GetDocsInfo(
					candidateID = rc.candidateID,
					jobOrderNumber = VAL(rc.jobordernumber) );
			} 
			else {
				var arrErrors = [];
				arrayAppend(arrErrors, "The 'Upload Documents' capability is down for maintenance. We are working diligently to restore this feature and we appreciate your patience. Please check back in 24 hours. Thank you.");
				getInstance( 'messagebox@cbmessagebox' ).error( messageArray=arrErrors );
			}
			//var viewData.arrFiletypes = DocumentService.UploadDocument();
			prc.loggedInUser = wirebox.getInstance("usermodels.User").getAccessID();
			prc.xe_OHRSite = 'https://hr.psu.edu/';
			prc.ActiveLink = "docfinity.index";
			prc.xe_UploadDoc = "docfinity.uploaddocumentaction";
			prc.xe_ChoosePriorDoc = "employmentapplication.choosepriordocaction";
			prc.xe_DeleteDoc = "employmentapplication.deletedocumentaction";
			event.setLayout("worklayout");
			event.setView( view="docfinity/uploaddocuments", args=viewData );
		}else{
			relocate(event="main.unauthorized", SSL=true);
		}
	}


	/**
	*action for uploading a doc 
	**/
	public function uploaddocumentaction(event,rc,prc){
		var oUser = wirebox.getInstance("usermodels.User");
		var item = "";
		for (item in rc){
			if (isSimpleValue(rc[item])){
				rc[item] = trim(htmlEditFormat(rc[item]));
			}
		}
		var arrErrors = [];
		var hasError = 0;
		if (NOT StructKeyExists(rc,"fileName") OR NOT len(rc.fileName)){
			// no file chosen 
			arrayAppend(arrErrors, "No file seems to be chosen for upload.");
		}
		else {
			var strippedFileName = "";
			strippedFileName = ReReplace(rc.fileName, "[[:space:]]","_","All");
			strippedFileName = ReReplace(strippedFileName,"[^a-zA-Z0-9\.\_\:\-\\]", "*", "All");
			if (FindNoCase("*",strippedFileName)){
			//<cfif REFind("[{}()^$&%##!@=<>;,~`'*?]",rc.fileName)> 
				// bad filename 
				arrayAppend(arrErrors, "The file you tried to upload has some characters in the filename that Windows 
					doesn't recognize.  Please remove any characters like $,%,* and use only letters, numbers or underscores 
					in your filename.");
			}
		}
		event.paramValue("jobOrderNumber",1);
		if (NOT IsValid("integer",rc.jobOrderNumber) OR NOT rc.jobOrderNumber){
			arrayAppend(arrErrors, "This upload appears to be for an invalid job number");
		}
		if (arrayLen(arrErrors)){
			// some sort of error - send back 
			getInstance( 'messagebox@cbmessagebox' ).error( messageArray=arrErrors );
			setNextEvent(event="docfinity.uploaddocument", querystring="jobordernumber=#rc.jobOrderNumber#", SSL=true);
		}
		else {
			// seems good - try to upload
			var strUploadDoc = DocumentService.UploadDocument(
				userID = oUser.getAccessID(),
				jobOrderNumber = rc.jobOrderNumber,
				filename = rc.filename,
				uploadFilePath = "uploadFile",
				destination = tempDocsDestination,
        		nameConflict = "MakeUnique",
				docType = rc.docType,
				IPAddress = cgi.remote_addr,
				jobTitle = rc.jobTitle,
				bidID = rc.bidID,
				candidateID = rc.candidateID );
				
			if (StructKeyExists(strUploadDoc,"errorMsg")){
				arrErrors = [];
				arrayAppend(arrErrors,strUploadDoc.errorMsg);
				if (arrayLen(arrErrors)){
					getInstance( 'messagebox@cbmessagebox' ).error( messageArray=arrErrors );
					setNextEvent(event="employmentapplication.uploaddocuments", querystring="jobordernumber=#rc.jobOrderNumber#", SSL=true);
				}
			}
		}
		setNextEvent(event="docfinity.uploaddocument", querystring="jobordernumber=#rc.jobOrderNumber#", SSL=true);
	}

	

}