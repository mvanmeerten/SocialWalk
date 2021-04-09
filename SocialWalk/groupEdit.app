module groupEdit

	page groupEdit(group: Group) {
		main {
			groupHeader(group)
			gridRow {
				gridCol {
					groupInfo(group)
				}
				gridCol {
					groupParticipants(group)
				}
			}
		}
	}
	
	template groupHeader(group: Group) {
		gridRow {
			div[class="col-sm-1"] {
				submitlink action {
					goto group(group);
				}{<span class="fa fa-chevron-left"></span>}
			}
			div[class="col-sm-5"] {
				<h2>"Group Edit"</h2>
			}
			div[class="col-sm-6"] {
				<h2>"Participants"</h2>
			}
		}
	}
	
	template groupInfo(group: Group) {
		form {
			myLabel("Group name"){ input(group.name) }
			myLabel("Date"){ input(group.dateToTrackFrom) }
			submit action {
				return group(group);
			}[class="m-1"]{"Save"}
			submit action {
				group.adminUsers.clear();
				group.users.clear();
				group.delete();
				return root();
			}[class="m-1 btn-danger"]{"delete"}
		}
	}
	
	template groupParticipants(group: Group) {
		<table class="table table-bordered" style="margin-bottom: 0;">
			<thead>
				tr {
					<th scope="col">"Name"</th>
					<th scope="col">"Admin"</th>
					<th scope="col">"Remove"</th>
				}
			</thead>
			<tbody>
				for( user in group.users ) {
					tr {
						<td>output(user.name)</td>
						<td>if (user in group.adminUsers) {
							submitlink action {
								log("help1");
								group.adminUsers.remove(user);
								group.save();
							}[class="btn"]{<span class="fa fa-minus-circle"></span>}
						} else {
							submitlink action {
								log("help2");
								group.adminUsers.add(user);
								group.save();
							}{<span class="fa fa-plus-circle"></span>}
						}</td>
						<td>submitlink action {
							if (user in group.adminUsers) {
								group.adminUsers.remove(user);
							}
							group.users.remove(user);
							group.save();
						}[class="btn-danger"]{ "Remove" }</td>
					}
				}
			</tbody>
		</table>
	}