<!-- Page Content  -->
<cfoutput>
    <div class="card" id="box-list">
		<h5 class="card-header">User rights for #args.oUser.getNameFull()# (#args.oUser.getAccessID()#)</h5>
		<div class="card-body">
            <dl>
                <dt>Name</dt>
                <dd>#args.oUser.getNameFirst()# #args.oUser.getNameLast()#</dd>
                <dt>AccessID</dt>
                <dd>#args.oUser.getAccessID()#</dd>
                <dt>Using Emulation?</dt>
                <dd>#yesnoformat(args.oUser.getUsingEmulation())#</dd>
                <cfif args.oUser.getUsingEmulation() >
                    <dt>Actual User (user doing emulating)</dt>
                    <dd>#args.oUser.getEmulatingUser()#</dd>
                </cfif>
                <dt>PositionID</dt>
                <dd>#args.oUser.getPosition_ID()#</dd>
                <dt>Position Title</dt>
                <dd>#args.oUser.getPositionTitle()#</dd>
                <dt>Email</dt>
                <dd>#args.oUser.getEmail()#</dd>
                <dt>Employee Status</dt>
                <dd>#args.oUser.getCode_empl_Status()#</dd>
                <dt>Notes</dt>
                <dd>#args.oUser.getNotes()#</dd>
                <dt>Permissions List</dt>
                <dd>#args.oUser.getLstPermissions()#</dd>
                <dt>Permissions Array</dt>
                <dd>
                    <cfif ArrayLen(args.oUser.getArrPermissions())>
                        <table class="table table-striped">
                            <thead class="thead-dark">
                                <tr>
                                    <th scope="col">Permission Name</th>
                                    <th scope="col">FO Admin Area List</th>
                                    <th scope="col">Sup_Org List</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfloop index="pItem" array="#args.oUser.getArrPermissions()#"> 
                                    <tr>
                                        <td>#pItem.permissionName#</td>
                                        <td>#pItem.FOadminAreaList#</td>
                                        <td>#pItem.supOrgList#</td>
                                    </tr>
                                </cfloop>
                            </tbody>
                        </table>
                    <cfelse>
                        none
                    </cfif>
                </dd>
                <dt>Roles Array</dt>
                <dd>
                    <cfif ArrayLen(args.oUser.getArrRoles())>
                        <table class="table table-striped">
                            <thead class="thead-dark">
                                <tr>
                                    <th scope="col">Role Name</th>
                                    <th scope="col">Source</th>
                                    <th scope="col">Value</th>
                                    <th scope="col">Primary</th>
                                    <th scope="col">Constrained</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfloop index="rItem" array="#args.oUser.getArrRoles()#"> 
                                    <tr>
                                        <td>#rItem.friendlyName#</td>
                                        <td>#rItem.source#</td>
                                        <td>#rItem.value#</td>
                                        <td>#rItem.primary#</td>
                                        <td>#rItem.constrained#</td>
                                    </tr>
                                </cfloop>
                            </tbody>
                        </table>
                    <cfelse>
                        none
                    </cfif>
                </dd>
            </dl>
        </div><!---/ .card-body --->
	</div><!---/ .box-list --->
</cfoutput>
