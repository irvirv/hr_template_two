component output="false" singleton {

	// Dependencies 
	property name="BidData" inject="id:data.BidGateway";
	property name="EnvironmentData" inject="id:data.EnvironmentGateway";
	property name="CandidateService" inject="id:CandidateService";
	property name="JobService" inject="id:JobService";
	property name="DocfinityGateway" inject="id:data.DocfinityGateway";
	property name="mimetypes" inject="Coldbox:Setting:mimetypes";
	property name="validFileExt" inject="Coldbox:Setting:validFileExt";
	property name="maxPriorResumesForSelection" inject="Coldbox:Setting:maxPriorResumesForSelection";
	property name="log" inject='logbox:logger:{this}';

	// init 
	public function init(){
		return this;
	}
    
    
    
    //****************************************** 
	//************** get documents ************* 
	//****************************************** 
	
	
	// get cover letters 
	public function GetCoverLetters(required numeric candidateID, required numeric jobOrderNumber){

		var rtnStruct = {};
		rtnStruct.rsCoverLetter = BidData.GetCoverLetter(
			candidateID = arguments.candidateID,
			jobOrderNumber = arguments.jobOrderNumber );
		if (rtnStruct.rsCoverLetter.recordcount){
			// has a cover letter so go get it 
			// let's try the database first then go directly to docfinity if not found 
			var rsCoverLetter = GetCoverLetterData(
				candidateID = arguments.candidateID,
				jobOrderNumber = arguments.jobOrderNumber
			);
			if (rsCoverLetter.recordcount){
				// found so build struct like docfinity format 
				rtnStruct.strDocMetaData = {};
				rtnStruct.strDocMetaData.documentID = rsCoverLetter.DocumentID;
				rtnStruct.strDocMetaData.thisFileName = rsCoverLetter.filename;
				rtnStruct.strDocMetaData.thisScanDate = rsCoverLetter.scanDate;
				rtnStruct.strDocMetaData.CoverResDocID = rsCoverLetter.CoverResDocID;
			}
			/*
			else {
				// $$$$$ this uses the docfinity getSearchPrompts 
				// not found so get straight from docfinity 
				var searchArray = arrayNew(1);
				searchArray[1] = arguments.jobOrderNumber;
				searchArray[2] = arguments.candidateID;
				searchArray[3] = "C";
				rtnStruct.strDocMetaData = DocfinityGateway.SearchForDocument(
					arrSearchValues = searchArray,
					searchName = "webservices_jobs_general",
					searchPromptsList = "Job##,CTS##,Record Type" );
			}
			*/
		}
		return rtnStruct;
	}
	// /get cover letters 
	
	
	// get cover letter info from datatbase 
	public function GetCoverLetterData(required numeric candidateID, required numeric jobOrderNumber){

		return BidData.GetCoverResumeDocs(
			candidateID = arguments.candidateID,
			jobOrderNumber = arguments.jobOrderNumber,
			docType = 'C'
		);
	}
	// /get cover letter info from datatbase 
	
	// get resume 
	public function GetResumeKey(required numeric candidateID, required numeric jobOrderNumber){

		var rtnStruct = {};
		rtnStruct.rsResumes = BidData.GetResumeKey(
			candidateID = arguments.candidateID,
			jobOrderNumber = arguments.jobOrderNumber );
		if (rtnStruct.rsResumes.recordcount){
			// has a resume so go get it 
			// let's try the database first then go directly to docfinity if not found 
			var rsResume = GetResumeData(
				candidateID = arguments.candidateID,
				jobOrderNumber = arguments.jobOrderNumber
			);
			if (rsResume.recordcount){
				// found so build struct like docfinity format 
				rtnStruct.strDocMetaData = {};
				rtnStruct.strDocMetaData.documentID = rsResume.DocumentID;
				rtnStruct.strDocMetaData.thisFileName = rsResume.filename;
				rtnStruct.strDocMetaData.thisScanDate = rsResume.scanDate;
				rtnStruct.strDocMetaData.CoverResDocID = rsResume.CoverResDocID;
			}
			/*
			else {
				// $$$$ this uses the getsearchprompts 
				// not found so get straight from docfinity 
				var searchArray = arrayNew(1);
				searchArray[1] = arguments.jobOrderNumber;
				searchArray[2] = arguments.candidateID;
				searchArray[3] = "R";
				rtnStruct.strDocMetaData = DocfinityGateway.SearchForDocument(
					arrSearchValues = searchArray,
					searchName = "webservices_jobs_general",
					searchPromptsList = "Job##,CTS##,Record Type",
					documentType = "R" );
				if (NOT IsStruct(rtnStruct.strDocMetaData) 
					OR StructIsEmpty(rtnStruct.strDocMetaData)){
					// search for prior documents (resumes) 
					var priorDocsSearchArray = arrayNew(1);
					priorDocsSearchArray[1] = arguments.candidateID;
					priorDocsSearchArray[2] = "R";
					rtnStruct.arrPriorDocs = DocfinityGateway.SearchForPriorDocuments(
						arrSearchValues = priorDocsSearchArray,
						searchName = "webservices_jobs_used_resumes",
						searchPromptsList = "CTS##,Record Type",
						maxNumberReturned = maxPriorResumesForSelection );
				}
			}
			*/
		}
		/*
		else {
			// $$$$ this uses the getsearchprompts 
			// doesn't have one for this job so go get any prior uploaded from any other jobs applied for (last 5) 
			// search for prior documents (resumes) 
			var priorDocsSearchArray = arrayNew(1);
			priorDocsSearchArray[1] = arguments.candidateID;
			priorDocsSearchArray[2] = "R";
			rtnStruct.arrPriorDocs = DocfinityGateway.SearchForPriorDocuments(
				arrSearchValues = priorDocsSearchArray,
				searchName = "webservices_jobs_used_resumes",
				searchPromptsList = "CTS##,Record Type",
				maxNumberReturned = maxPriorResumesForSelection );
		}
		*/
		return rtnStruct;
	}
	// /get resume 
	
	// get resume info from datatbase 
	public function GetResumeData(required numeric candidateID, required numeric jobOrderNumber){

		return BidData.GetCoverResumeDocs(
			candidateID = arguments.candidateID,
			jobOrderNumber = arguments.jobOrderNumber,
			docType = 'R'
		);
	}
	// /get resume info from datatbase 
	
	// get optional docs info for this bid 
	public function GetOptionalDocsInfo(required numeric candidateID, required numeric jobOrderNumber){

		var rtnStruct = {};
		rtnStruct.funcRes = 0;
		// job info 
		var rsJobInfo = JobService.GetJobDetail(
			jobOrderNumber = arguments.jobOrderNumber,
			overRideCurrent = 1 );
		//- not finding the job is an error 
		if (NOT rsJobInfo.recordcount){
			return rtnStruct;
		}
		if (rsJobInfo.NumOptionalDocs){
			// mark this as a job bid with potential extra docs 
			rtnStruct.jobWithOptionalDocs = 1;
			// there are optional docs allowed so see if they've uploaded any yet 
			rtnStruct.rsUploadedDocs = GetUploadedOptionalDocs(
				candidateID = arguments.candidateID,
				jobOrderNumber = arguments.jobOrderNumber );
			if (rtnStruct.rsUploadedDocs.recordcount){
				// if there are some get the info on them (filename and date uploaded) 
				rtnStruct.arrUploadedOptionalDocs = [];			
				cfloop(query="rtnStruct.rsUploadedDocs"){
					if (NOT len(rtnStruct.rsUploadedDocs.filename)){
						// if is an older upload where we weren't capturing filename in database go get the file info 
						var strInfo = DocfinityGateway.GetDocumentFileName(
							documentID = rtnStruct.rsUploadedDocs.documentID );
						rtnStruct.rsUploadedDocs[ "FileName" ][ rtnStruct.rsUploadedDocs.currentRow ] = javaCast("string", strInfo.FileName & "." & strInfo.FileExtension);
						rtnStruct.rsUploadedDocs[ "ScanDate" ][ rtnStruct.rsUploadedDocs.currentRow ] = javaCast("string", strInfo.ScanDate );
					}
					else {
						// if from database then format scandate in docifinity display style 
						rtnStruct.rsUploadedDocs[ "ScanDate" ][ rtnStruct.rsUploadedDocs.currentRow ] = dateformat(rtnStruct.rsUploadedDocs.scanDate,"mmm-dd-yyyy");
					}
				}
			}
			rtnStruct.numOptionalLeft = rsJobInfo.NumOptionalDocs - rtnStruct.rsUploadedDocs.recordcount;
			if (rtnStruct.numOptionalLeft LT 0){
				rtnStruct.numOptionalLeft = 0;
			}
		}
		else {
			// mark this as a job bid with no optional docs allowed 
			rtnStruct.jobWithOptionalDocs = 0;
		}
		rtnStruct.funcRes = 1;
		return rtnStruct;
	}
	// /get optional docs info for this bid 
	
	// get any optional docs uploaded for this bid 
    public function GetUploadedOptionalDocs(required numeric jobOrderNumber, required numeric candidateID){

		return BidData.GetUploadedOptionalDocs(
			jobOrderNumber = arguments.jobOrderNumber,
			candidateID = arguments.candidateID );
	}
	// /get any optional docs uploaded for this bid 
	
	
	//****************************************** 
	//*********** copy/upload documents ******** 
	//****************************************** 
	
	// upload a document for this bid 
	public function UploadDocument(required string userID, required numeric candidateID, required numeric jobOrderNumber, 
		required string filename, required string uploadFile, required string docType, 
		required string IPAddress, required string destination, required string nameConflict){

		var rtnStruct = {};
		rtnStruct.uploadRes = 0;
		rsCandidateInfo = CandidateService.GetCandidateInfo(
			candidateID = arguments.candidateID );
		// upload the file we're working with 
		setting requestTimeOut="180";
		try {
    		lock name=hash(arguments.filename), timeout="180", type="Exclusive", throwOnTimeout="true" {
    			var uploadResult = fileUpload (arguments.destination, arguments.uploadFile, variables.mimetypes, arguments.nameConflict);
			}
		
		}
		catch (any e) {
			try {
				//writedump(e); abort;
				log.error("#e#");
				log.error(arguments.destination);
				log.error(arguments.filename);
				log.error(variables.mimetypes);
				log.error(arguments.nameConflict);
				}
				catch (any e) {
					// do nothing 
				}
			rtnStruct.errorMsg = "There was a problem uploading your file. Please check file type.";
			return rtnStruct;
		}
		if (NOT uploadResult.FileWasSaved OR NOT ListFindNoCase(validFileExt, uploadResult.serverFileExt)){
			try {
				fileDelete (uploadResult.serverdirectory & "\" & uploadResult.serverfile);
				}
				catch (any e) {
					// do nothing 
				}
			rtnStruct.errorMsg = "The file you tried to upload is not recognized as a valid document type.  Perhaps you are missing 
				the file extension on the end of the file.  The only way the server can tell that you are sending a proper document is if the 
				extension is one of '" & lcase(validFileExt) & "'.  Click your BACK button to return to the upload form.";
			// log this error 
			EnvironmentData.AddAuditLogEntry(
				userID = arguments.userID,
				loggedAction = "BadFile",
				loggedActionValue = arguments.jobOrderNumber );
			// return as non uploaded with error message 
			return rtnStruct;
		}
		// all seems good so send to docfinity 
		var resDocfinityID = DocfinityGateway.UploadDocument(
			fileLocation = uploadResult.serverdirectory & "\" & uploadResult.serverfile );
		// if the upload to docfinity was successful remove the upload doc from its temp location 
		if (resDocfinityID IS 0){
			// returned error - log this error 
			EnvironmentData.AddAuditLogEntry(
				userID = arguments.userID,
				loggedAction = "DUFailed",
				loggedActionValue = arguments.jobOrderNumber );
			rtnStruct.errorMsg = "There was an error in saving your uploaded document.  Please try again.";
			return rtnStruct;
		}
		else {
			// was ok so delete temp file that was uploaded to server 
			try {
				FileDelete (uploadResult.serverdirectory & "\" & uploadResult.serverfile);
				}
				catch (any e) {
					// do nothing 
				}
		}
		// index document in docfinity 
		var resIndex = DocfinityGateway.IndexDocument(
			criteriaName = "Jobs", 
			jobOrderNumber = arguments.jobOrderNumber,
			nameFirst = rsCandidateInfo.First_Name,
			nameLast = rsCandidateInfo.Last_Name,
			candidateID =  arguments.candidateID,
			PSUID = rsCandidateInfo.numb_empl_id,
			clientFileName = uploadResult.clientFileName,
			clientFileExt = uploadResult.clientFileExt,
			contentType = uploadResult.contentType,
			contentSubType = uploadResult.contentSubType,
			docType = arguments.docType,
			IPAddress = arguments.IPAddress,
			documentID = local.resDocfinityID );
		if (NOT resIndex){
			rtnStruct.errorMsg = "There was an error in indexing your uploaded document.  Please try again.";
			return rtnStruct;
		}
		// update any document specific tables 
		InsertDocumentData(
			candidateID = arguments.candidateID,
			jobOrderNumber = arguments.jobOrderNumber,
			fileName = uploadResult.clientFileName & "." & uploadResult.clientFileExt,
			documentID = local.resDocfinityID,
			docType = arguments.docType );
		// update bid to show doc has been uploaded 
		var resUpdateKey = UpdateDocumentKey(
			candidateID = arguments.candidateID,
			jobOrderNumber = arguments.jobOrderNumber,
			keyValue = 'F',
			docType = arguments.docType );
		if (resUpdateKey){
			rtnStruct.uploadRes = 1;
		}
		return rtnStruct;
	}
	// /upload a document for this bid 
	
	// insert document data 
	public function InsertDocumentData(required candidateID, required numeric jobOrderNumber, 
		required string docType, string documentID = "", string fileName = ""){

		switch (arguments.docType){
			case "R":
				// resume 
				// update table with doc info 
				return BidData.InsertCoverResumeDocs(
					candidateID = arguments.candidateID,
					jobOrderNumber = arguments.jobOrderNumber,
					docType = arguments.docType,
					fileName = arguments.fileName,
					documentID = arguments.documentID );
				break;
			case "C":
				// cover letter 
				// update table with doc info 
				return BidData.InsertCoverResumeDocs(
					candidateID = arguments.candidateID,
					jobOrderNumber = arguments.jobOrderNumber,
					docType = arguments.docType,
					fileName = arguments.fileName,
					documentID = arguments.documentID );
				break;
			case "Misc":
				// optional docs 
				return BidData.AddUploadedOptionalDocs(
					candidateID = arguments.candidateID,
					jobOrderNumber = arguments.jobOrderNumber,
					fileName = arguments.fileName,
					documentID = arguments.documentID );
				break;
			default:
				return 0;
			
		}
	}
	// /update document key for bid 
	
	// update document key for bid 
	public function UpdateDocumentKey(required candidateID, required numeric jobOrderNumber, 
		required string keyValue, required string docType){

		switch (arguments.docType){
			case "R":
				// resume 
				// update bid record 
				return BidData.UpdateResumeKey(
					candidateID = arguments.candidateID,
					jobOrderNumber = arguments.jobOrderNumber,
					keyValue = arguments.keyValue );
				break;
			case "C":
				// cover letter 
				// update bid record 
				return BidData.UpdateCoverLetterKey(
					candidateID = arguments.candidateID,
					jobOrderNumber = arguments.jobOrderNumber,
					keyValue = arguments.keyValue );
				break;
			case "Misc":
				// optional docs 
				return 1;// nothing done to bid table for these 
				break;
			default:
				return 0;
			
		}
	}
	// /update document key for bid 

	// copy a document for this bid from a prior used doc 
	public function CopyPriorDocumentToJob(required string userID, required numeric candidateID, required numeric jobOrderNumber, 
		required string priorDocID, required string docType, required string IPAddress, required string destination){

		var rtnStruct = {};
		var rsCandidateInfo = CandidateService.GetCandidateInfo(
			candidateID = arguments.candidateID );
		var strDocument = DocfinityGateway.GetDocument(
			documentID = arguments.priorDocID );
		// write it out 
		var fileUploadPath = "#arguments.destination#\#trim(strDocument.strFileInfo.thisFileName)#";
		try {
			fileWrite (fileUploadPath, "#strDocument.repoFile.fileContent.toByteArray()#");
		}
		catch (any e){
			rtnStruct.errorMsg = "There was an error in saving your prior uploaded document.  Please try again.";
			return rtnStruct;
		}
		// UPLOAD A DOCUMENT 
		// all seems good so send to docfinity 
		var resDocfinityID = DocfinityGateway.UploadDocument(
			fileLocation = local.fileUploadPath );
		if (resDocfinityID IS 0){
			// returned error - log this error 
			EnvironmentData.AddAuditLogEntry(
				userID = arguments.userID,
				loggedAction = "DUFailed",
				loggedActionValue = arguments.jobOrderNumber );
			rtnStruct.errorMsg = "There was an error in saving your uploaded document.  Please try again.";
			return rtnStruct;
		}
		else {
			// was ok so delete temp file that was uploaded to server 
			try {
				fileDelete (fileUploadPath);
			}
			catch (any e) {
					//do nothing
			}
		}
		// index document in docfinity 
		var resIndex = DocfinityGateway.IndexDocument(
			criteriaName = "jobs", 
			jobOrderNumber = arguments.jobOrderNumber,
			nameFirst = rsCandidateInfo.First_Name,
			nameLast = rsCandidateInfo.Last_Name,
			candidateID =  arguments.candidateID,
			PSUID = rsCandidateInfo.numb_empl_id,
			clientFullFileName = left(trim(strDocument.strFileInfo.thisFileName),50),
			clientFileExt = left(trim(strDocument.strFileInfo.thisFileExtension),5),
			mimeType = left(trim(strDocument.strFileInfo.thisMIMEType),50),
			docType = arguments.docType,
			IPAddress = arguments.IPAddress,
			documentID = arguments.priorDocID );
		if (NOT resIndex){
			EnvironmentData.AddAuditLogEntry(
				userID = arguments.userID,
				loggedAction = "IDXFailed",
				loggedActionValue = arguments.jobOrderNumber 
			);
			rtnStruct.errorMsg = "There was an error in indexing your uploaded document.  Please try again.";
			return rtnStruct;
		}
		// update any document specific tables 
		InsertDocumentData(
			candidateID = arguments.candidateID,
			jobOrderNumber = arguments.jobOrderNumber,
			fileName = trim(strDocument.strFileInfo.thisFileName),
			documentID = resDocfinityID,
			docType = arguments.docType );
		// update bid to show doc has been uploaded 
		var resUpdateKey = UpdateDocumentKey(
			candidateID = arguments.candidateID,
			jobOrderNumber = arguments.jobOrderNumber,
			keyValue = 'F',
			docType = arguments.docType );
		if (resUpdateKey){
			rtnStruct.uploadRes = 1;
		}
		return rtnStruct;
	}
	// /copy a document for this bid from a prior used doc 
	
	
	//****************************************** 
	//************* delete documents *********** 
	//****************************************** 
	
	
	// delete a document from this bid 
	public function DeleteDocument(required string userID, required numeric candidateID, required numeric jobOrderNumber, 
		required string documentID, required numeric optionaldocID, required numeric coverResDocID, 
		required string used, required string docType){

		if (arguments.used is "N"){
			//- document not used any more - remove from docfinity 
			var resDeleteDocfinity = DocfinityGateway.DeleteDocument(
				documentID = arguments.documentID );
			if (NOT resDeleteDocfinity){
				return 0;
			}
		}
		switch (arguments.docType){
			case "Misc":
				// misc docs get removed from optional doc table 
				return BidData.DeleteOptionalDoc (
					optionalDocID = arguments.optionalDocID,
					candidateID = arguments.candidateID );
			break;
			case "C":
				// Cover Letter 
				BidData.DeleteCoverResumeDoc(
					candidateID = arguments.candidateID,
					jobOrderNumber = arguments.jobOrderNumber,
					coverResDocID = arguments.coverResDocID
				);
				return UpdateDocumentKey(
					candidateID = arguments.candidateID,
					jobOrderNumber = arguments.jobOrderNumber,
					keyValue = "",
					docType = "C" );
				break;
			case "R":
				// Resume 
				BidData.DeleteCoverResumeDoc(
					candidateID = arguments.candidateID,
					jobOrderNumber = arguments.jobOrderNumber,
					coverResDocID = arguments.coverResDocID
				);
				return UpdateDocumentKey(
					candidateID = arguments.candidateID,
					jobOrderNumber = arguments.jobOrderNumber,
					keyValue = "",
					docType = "R" );
				break;
			default:
				return 1;// $$$$$$ just success for now 
			
		}
	}
	// /delete a document from this bid 
	
}