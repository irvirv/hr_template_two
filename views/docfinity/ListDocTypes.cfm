
<cfset qryDocTypes = queryNew("categoryId,categoryName,ID,name,description,fulltext") />
<cfloop index="docItem" array="#args.arrDoctypes#"> 
    <cfset strAddedItem = {
        categoryId = docItem.categoryId,
        categoryName = docItem.categoryName,
        ID = docItem.ID,
        name = docItem.name,
        description = docItem.description,
        fulltext = docItem.fulltext
    } />
    <cfset qryDocTypes.addrow(strAddedItem) />
</cfloop>

<cfoutput>
<cfloop query="qryDocTypes" group="categoryId">
	&nbsp;
    <div class="card" id="box-functions">
		<h5 class="card-header">#qryDocTypes.categoryName#</h5>
		<div class="card-body">
			<div class="table-responsive-sm">
				<table class="table table-striped">
					<thead class="thead-dark">
						<tr>
							<th scope="col">Document Type Name</th>
                            <th scope="col">Document Type ID</th>
                            <th scope="col">Description</th>
                            <th scope="col">FullText</th>
						</tr>
					</thead>
					<tbody>
						<cfloop> 
							<tr>
								<th scope="row"><a href="#event.buildLink( prc.xe_listMetadata )#?documentTypeID=#qryDocTypes.ID#">#qryDocTypes.name#</a></th>
								<td><a href="#event.buildLink( prc.xe_listMetadata )#?documentTypeID=#qryDocTypes.ID#">#qryDocTypes.ID#</a></td>
                                <td>#qryDocTypes.description#</td>
                                <td>#qryDocTypes.fulltext#</td>
							</tr>
						</cfloop>
					</tbody>
				</table>
			</div>
		</div><!---/ .card-body --->
	</div><!---/ .card box-functions --->
</cfloop>
</cfoutput>