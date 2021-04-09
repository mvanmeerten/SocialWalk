module groupSearch

page groupSearch() {
	var nameQuery := ""
	var startQuery: Date
	var endQuery: Date
	main {
		form[class="mt-2 mb-2"] {
			gridRow[class="justify-content-sm-center"]{
				gridCol[class="col-sm-6"] {
					myLabel("Group name")[class="mb-2"]{ input(nameQuery)[onkeyup := updateSearch(nameQuery, startQuery, endQuery)] }					
				}
			}
			gridRow[class="justify-content-sm-center"]{
				gridCol[class="col-sm-6"] {
					myLabel("From date")[class="mb-2"]{ input(startQuery)[onchange := updateSearch(nameQuery, startQuery, endQuery)] }					
				}
			}
			gridRow[class="justify-content-sm-center"]{
				gridCol[class="col-sm-6"] {
					myLabel("End date")[class="mb-2"]{ input(endQuery)[onchange := updateSearch(nameQuery, startQuery, endQuery)] }					
				}
			}
		}
		placeholder groups { groupSearchTemplate(from Group) }
	}
	action updateSearch(query: String, startDateQuery: Date, endDateQuery: Date) {
		// var groupSearcher := GroupSearcher();
		var groupList := List<Group>();
		if (startDateQuery != Date("") && endDateQuery != Date("")) {
			groupList := (search Group matching dateToTrackFrom: [startDateQuery to endDateQuery]).results();
		} else if (startDateQuery != Date("") && endDateQuery == Date("")) {
			groupList := (search Group matching dateToTrackFrom: [startDateQuery to *]).results();
		} else if (startDateQuery == Date("") && endDateQuery != Date("")) {
			groupList := (search Group matching dateToTrackFrom: [* to endDateQuery]).results();
		} else {
			groupList := (from Group);
		}
		if (query.length() > 0) {
			groupList := [g | g in groupList where g in findGroupByNameLike(query)];
		}
		replace(groups, groupSearchTemplate(groupList));
		// else {
		// 	if (startDateQuery != Date("") && endDateQuery != Date("")) {
		// 		replace(groups, groupSearchTemplate((search Group matching dateToTrackFrom: [startDateQuery to endDateQuery]).results()));
		// 	} else if (startDateQuery != Date("") && endDateQuery == Date("")) {
		// 		replace(groups, groupSearchTemplate((search Group matching dateToTrackFrom: [startDateQuery to *]).results()));
		// 	} else if (startDateQuery == Date("") && endDateQuery != Date("")) {
		// 		replace(groups, groupSearchTemplate((search Group matching dateToTrackFrom: [* to endDateQuery]).results()));
		// 	} else {
		// 		replace(groups, groupSearchTemplate(from Group));
		// 	}
		// }
		// log(groupSearcher.results());
		// if (query.length() > 0) {
		// 	log(groupSearcher.results());
		// 	groupSearcher := ~groupSearcher , 
		// 	replace(groups, groupSearchTemplate(groupSearcher.results()));
		// 	// replace(groups, groupSearchTemplate(findGroupByNameLike(query)));
		// } else {
		// 	replace(groups, groupSearchTemplate(groupSearcher.results()));
		// }
		// log(startDateQuery);
		// log(endDateQuery);
		// if (startDateQuery != Date("")) {
		// 	if (endDateQuery != Date("")) {
		// 		groupSearcher := groupSearcher.field("dateToTrackFrom").rangeQuery(startDateQuery, endDateQuery);
		// 	} else {
		// 		groupSearcher := groupSearcher.field("dateToTrackFrom").rangeQuery(startDateQuery, today());
		// 	}
		// } else if (endDateQuery != Date("")) {
		// 	groupSearcher := groupSearcher.field("dateToTrackFrom").rangeQuery(endDateQuery.addYears(-100), endDateQuery);
		// }
		// else {
		// 	replace(groups, groupSearchTemplate(from Group));
		// }
		// if (query.length() == 0 && startDateQuery == Date("") && endDateQuery == Date("")) {
		// 	replace(groups, groupSearchTemplate(from Group));
		// 	return;
		// } else {
		// 	log("replacing");
		// 	replace(groups, groupSearchTemplate(groupSearcher.results()));			
		// }
	}
}

ajax template groupSearchTemplate(groups: [Group]) {
	card("Groups") {
		<table class="table" style="margin-bottom: 0;">
			<thead>
				tr {
					<th scope="col">"Name"</th>
					<th scope="col">"Date to track from"</th>
					<th scope="col"></th>
				}
			</thead>
			<tbody>
				for( group in groups ) {
					tr {
						<td>output(group.name)</td>
						<td>output(group.dateToTrackFrom)</td>
						if (group in securityContext.principal.groups) {
							<td>navigate group(group)[class="btn btn-secondary"]{"View"}</td>
						} else {
							<td>submitlink action {
								group.users.add(securityContext.principal);
								if (group.adminUsers.length == 0) {
									group.adminUsers.add(securityContext.principal);
								}
								goto group(group);
							}{"Join"}</td>
						}
					}
				}
			</tbody>
		</table>
	}
}