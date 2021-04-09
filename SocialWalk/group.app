module group

	page group(group: Group) {
		main {
			gridRow{
				div[class="col mr-auto"] {
					<h2>output(group.name)</h2>
				}
				div[class="col-auto ml-auto"] {
					submitlink action{
						group.users.remove(securityContext.principal);
						if (securityContext.principal in group.adminUsers) {
							group.adminUsers.remove(securityContext.principal);
						}
						group.save();
						return root();
					}{"Leave"}
				}
				if (isAdmin(group)) {
					div[class="col-auto ml-auto pl-0"] {
						navigate groupEdit(group)[class="btn btn-secondary justify-content-end "]{"Edit"}
					}					
				}
			}
			gridRow[class="mt-2"] {
				gridCol {
					ranking(group)						
				}
				gridCol {
					rankingToday(group)					
				}
			}
		}
	}
	
	template ranking(group: Group) {
		var rankedUsers := [u | u in group.users order by u.stepsSince(group.dateToTrackFrom) desc]
		card("Steps since " + group.dateToTrackFrom) {
			<table class="table" style="margin-bottom: 0;">
				<thead>
					tr {
						<th scope="col">"#"</th>
						<th scope="col">"Name"</th>
						<th scope="col">"Steps"</th>
						<th scope="col">"Average"</th>
					}
				</thead>
				<tbody>
					for( i: Int from 0 to rankedUsers.length ) {
						tr {
							<td>output(i+1)</td>
							<td>output(rankedUsers[i].name)</td>
							<td>output(rankedUsers[i].stepsSince(group.dateToTrackFrom))</td>
							<td>output(rankedUsers[i].averageStepsSince(group.dateToTrackFrom))</td>
						}
					}
				</tbody>
			</table>
		}
	}
	
	template rankingToday(group: Group) {
		var rankedUsers := [u | u in group.users order by u.stepsSince(today()) desc]
		card("Steps Today") {
			<table class="table" style="margin-bottom: 0;">
				<thead>
					<tr>
						<th scope="col">"#"</th>
						<th scope="col">"Name"</th>
						<th scope="col">"Steps"</th>
					</tr>
				</thead>
				<tbody>
					for( i: Int from 0 to rankedUsers.length ) {
						<tr>
							<td>output(i+1)</td>
							<td>output(rankedUsers[i].name)</td>
							<td>output(rankedUsers[i].stepsSince(today()))</td>
						</tr>
					}
				</tbody>
			</table>
		}
	}
