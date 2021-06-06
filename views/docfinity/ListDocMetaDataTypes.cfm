<cfset docTypeName = "" />
<cfloop index="i" array="#args.arrMetaDataTypes#"> 
    <cfif StructKeyExists(i,"documentTypeName")>
        <cfset docTypeName = i.documentTypeName />
    </cfif>
    <cfbreak />
</cfloop>
<cfoutput>
	<div class="card" id="box-functions">
		<h5 class="card-header">Docfinity MetaData Types for Document Type &ndash; #docTypeName#</h5>
		<div class="card-body">
			<div class="table-responsive-sm">
				<table class="table table-striped">
					<thead class="thead-dark">
						<tr>
							<th scope="col">ID##</th>
							<th scope="col">metadataName</th>
							<th scope="col">metadataType</th>
                            <th scope="col">minLength</th>
							<th scope="col">maxLength</th>
                            <th scope="col">ordinal</th>
						</tr>
					</thead>
					<tbody>
						<cfloop index="i" array="#args.arrMetaDataTypes#"> 
                            <tr>
								<th scope="row">#i.ID#</th>
								<td><cfif StructKeyExists(i,"metadataName")>#i.metadataName#</cfif></td>
								<td><cfif StructKeyExists(i,"metadataType")>#i.metadataType#</cfif></td>
                                <td><cfif StructKeyExists(i,"minLength")>#i.minLength#</cfif></td>
								<td><cfif StructKeyExists(i,"maxLength")>#i.maxLength#</cfif></td>
                                <td><cfif StructKeyExists(i,"ordinal")>#i.ordinal#</cfif></td>
							</tr>
						</cfloop>
					</tbody>
				</table>
			</div>
		</div><!---/ .card-body --->
	</div><!---/ .card box-functions --->
</cfoutput>