module user

	page user(user: User) {
		main {
			gridRow {
				gridCol {
					userEdit(user)
				}
				gridCol {
					groupMembership(user, user.groups, "Groups", true)[class="mb-2"]
					groupMembership(user, user.adminGroups, "Admin groups", false)
				}
			}
		}
	}
	
	template userEdit(user: User) {
		var newPassword: Secret := ""
		form {
			myLabel("Email"){ output(user.email) }
			myLabel("Name"){ input(user.name) }
			myLabel("Change Password"){ input(newPassword){
					validate(newPassword.length() > 7, "Password should be at least 8 characters long")
					validate(/[\-_@!]+/.find(newPassword), "Password must contain one or more of \"- _ @ !\"")
				} 
			}
			submit action {
				user.password := newPassword.digest();
			}[class="m-1"]{"Save"}
		}
		gridRow[class="ml-0"] {
			submitlink action {
				logout();
				return root();
			}[class="m-1 btn-secondary"]{"Log out"}
		}
	}
	
	template groupMembership(user: User, groups: {Group}, headerText: String, remove: Bool) {
		card[all attributes] {
			cardHeader {
				~headerText
			}
			cardBody {
				for (group in groups) {
					gridRow[class="mt-1 mb-1"] {
						gridCol {
						 	output(group.name)								
						}
						gridCol[class="col-sm-auto"] {
							membershipAction(user, group, remove)
						}
					}
				}
			}
		}
	}
	
	template membershipAction(user: User, group: Group, remove: Bool) {
		submitlink action {
	 		if (user in group.adminUsers) {
	 			user.adminGroups.remove(group);
	 		}
	 		if (remove) {
	 			user.groups.remove(group);
	 		}
	 		user.save();
	 	}[class="btn btn-danger"]{<span class="fa fa-minus-circle"></span>}
	}