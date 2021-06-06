<cfoutput>
	<div class="card" id="box-functions">
		<h5 class="card-header">Docfinity File Types</h5>
		<div class="card-body">
			<div class="table-responsive-sm">
				<table class="table table-striped">
					<thead class="thead-dark">
						<tr>
							<th scope="col">ID##</th>
							<th scope="col">Name</th>
							<th scope="col">Label</th>
							<th scope="col">Extensions</th>
						</tr>
					</thead>
					<tbody>
						<cfloop index="docItem" array="#args.arrFiletypes#"> 
							<tr>
								<th scope="row">#docItem.ID#</th>
								<td>#docItem.name#</td>
								<td>#docItem.label#</td>
								<td>#docItem.extensions#</td>
							</tr>
						</cfloop>
					</tbody>
				</table>
			</div>
		</div><!---/ .card-body --->
	</div><!---/ .card box-functions --->
</cfoutput>