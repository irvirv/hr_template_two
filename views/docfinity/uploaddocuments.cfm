<h1>Docfinity Documents</h1>
<p>When naming files to be uploaded, please use only letters (a to z, A to Z) and/or numbers (0 to 9). Do not use any spaces or special characters.</p>
<cfoutput>
#getInstance( 'messagebox@cbmessagebox' ).renderIt()#
<div class="panel panel-primary">
	<div class="panel-heading">
		<h3 class="panel-title">title</h3>
	</div>
	<div class="panel-body">
		<cfif args.DocFinityStatus eq 1>
			<!--- upload some document type --->
		    <form class="form-horizontal" role="form" method="post" enctype="multipart/form-data" action="#Event.buildLink( '#prc.xe_UploadDoc#' )#" name="uploadother">
                <input type="hidden" id="hidden_file1" value="" name="fileName" />
                <input type="hidden" name="docType" value="Misc">
				<input type="hidden" name="jobTitle" value="some job title">
				<input type="hidden" name="bidID" value="56744">
				<input type="hidden" name="candidateID" value="123456">
                <fieldset>	
                    <legend>Upload Optional Document</legend>
                    <div class="form-group">
                        <label for="UploadFile1" class="col-sm-2 control-label">Document Path:</label>
                        <div class="col-sm-10 col-md-4">
                            <input type="file" 
                                id="UploadFile1" 
                                onchange="document.getElementById('hidden_file1').value = this.value;"
                                name="UploadFile"/>
                            <p class="help-block"><b>( File Types: .pdf, .doc, .docx, .rtf )</b></p>
                            <p class="help-block"><strong>Note:</strong> Some help text goes here.
                            </p>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-sm-offset-2 col-sm-10">
                            <input type="submit" class="btn btn-primary" value="upload document" />
                        </div>
                    </div>
                </fieldset>
            </form>
			<!---
			<cfif IsDefined("args.strOptionalDocs.jobWithOptionalDocs") AND args.strOptionalDocs.jobWithOptionalDocs eq 1>
				<!--- this job has additional optional documents allowed --->
				<!--- any already uploaded? --->
				<cfloop query="args.strOptionalDocs.rsUploadedDocs">
					<form class="form-horizontal" action="#Event.buildLink( '#prc.xe_DeleteDoc#' )#" method="post" role="form" name="deleteoptionaldoc">
						<!--- COVER LETTER DELETE PARAMETERS --->
						<input type="Hidden" name="documentID" value="#args.strOptionalDocs.rsUploadedDocs.documentID#">
						<input type="Hidden" name="candidateID" value="#args.strOptionalDocs.rsUploadedDocs.candidate_number#">
						<input type="Hidden" name="jobOrderNumber" value="#args.rsJobData.jobOrderNumber#">
						<input type="Hidden" name="docType" value="Misc">
						<input type="Hidden" name="used" value="N">
						<input type="hidden" name="OptionalDocID" value="#args.strOptionalDocs.rsUploadedDocs.OptionalDocID#">
						<fieldset>	
						<legend>Existing Uploaded Optional Document</legend>
						<div class="form-group">
							<label for="filename" class="col-sm-2 control-label">File Name:</label>
							<div class="col-sm-10 col-md-4 col-lg-3">
								<input name="filename" 
								class="form-control" 
								type="text" 
								id="filename" 
								value="#args.strOptionalDocs.rsUploadedDocs.filename#" 
								disabled />
							</div>
						</div>
						<div class="form-group">
							<label for="ScanDate" class="col-sm-2 control-label">Upload Date:</label>
							<div class="col-sm-10 col-md-4 col-lg-3">
								<input name="ScanDate" 
								class="form-control" 
								type="text" 
								id="ScanDate" 
								value="#args.strOptionalDocs.rsUploadedDocs.ScanDate#" 
								disabled />
							</div>
						</div>
						<div class="form-group">
							<div class="col-sm-offset-2 col-sm-10">
								<input type="submit" class="btn btn-danger" value="Delete">
								<a href="/docdownload/processdownload.cfm?documentID=#args.strOptionalDocs.rsUploadedDocs.documentID#" class="btn btn-default">Download</a>
							</div>
						</div>
						</fieldset>
					</form>
				</cfloop>
				<!--- any open spots left they can upload into? --->
				<cfif args.strOptionalDocs.numOptionalLeft>
					<form class="form-horizontal" role="form" method="post" enctype="multipart/form-data" action="#Event.buildLink( '#prc.xe_UploadDoc#' )#" name="uploadother">
						<input type="hidden" id="hidden_file1" value="" name="fileName" />
						<input type="hidden" name="docType" value="Misc">
						<input type="hidden" name="jobOrderNumber" value="#args.rsJobData.jobOrderNumber#">
						<fieldset>	
						<legend>Upload Optional Document (#args.strOptionalDocs.numOptionalLeft# upload spots available)</legend>
						<div class="form-group">
							<label for="UploadFile1" class="col-sm-2 control-label">Document Path:</label>
							<div class="col-sm-10 col-md-4">
								<input type="file" 
								id="UploadFile1" 
								onchange="document.getElementById('hidden_file1').value = this.value;"
								name="UploadFile"/>
								<p class="help-block"><b>( File Types: .pdf, .doc, .docx, .rtf )</b></p>
								<p class="help-block"><strong>Note:</strong> This upload is for any additional documents that may be 
								requested in the job posting. Please review the job posting to determine if any additional documents 
								are requested. Thank you.
								</p>
							</div>
						</div>
						<div class="form-group">
							<div class="col-sm-offset-2 col-sm-10">
								<input type="submit" class="btn btn-default" value="upload document" />
							</div>
						</div>
						</fieldset>
					</form>
				</cfif>
				<!--- /any open spots left they can upload into? --->
			</cfif>
			<!--- /Optional docs --->
			--->
			<div class="alert alert-info" role="alert"><strong>When uploading documents</strong> you may leave this section by clicking "My Account" in the upper right 
				and return back here at a later time to edit your documents by clicking "Upload Documents" next to this job listing in the My Account section.
			</div>
		</cfif>
	</div>
</div>
</cfoutput>