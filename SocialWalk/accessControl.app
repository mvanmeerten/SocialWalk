module accessControl

	principal is User with credentials email, password

	access control rules
		rule page root{ true }
		rule page accessControl{ true }
		rule page signUp{ true }
		rule page authorize(*){ loggedIn() }
		rule page group( group: Group ){ loggedIn() && inGroup(group) }
		rule page groupEdit( group: Group ) { isAdmin(group) }
		rule page groupSearch{ loggedIn() }
		rule page user(user: User){ loggedIn() && user == securityContext.principal }
		rule ajaxtemplate *(*){ true }
	section
	
	function inGroup(group: Group): Bool {
		return group in securityContext.principal.groups;
	}
	
	function isAdmin(group: Group): Bool {
		return securityContext.principal in group.adminUsers;
	}

	page accessControl {
		init {
			if (loggedIn()) {
				return root();
			}
		}
		main {
			div
			authentication
		}
	}
	
	page signUp {
		var newuser := User{}
		main {
			h3{ "Registration" }
			gridRow{
				div[class="col-sm-6 mb-2"] {
					form {
						myLabel("Email"){ input(newuser.email) }
						myLabel("Password"){ input(newuser.password){
							validate(newuser.password.length() > 7, "Password should be at least 8 characters long")
							validate(/[\-_@!]+/.find(newuser.password), "Password must contain one or more of \"- _ @ !\"")
						} }
						submit action{
							newuser.password := newuser.password.digest();
							newuser.save();
						}{ "Sign up" }
					}
					navigate accessControl(){ "Log in" }
				}
			}
			
		}
	}

	override template login() {
		var username : String
		var password : Secret
		var stayLoggedIn := false
		form {
			<fieldset>
				<legend>
					output( "Login" )
				</legend>
				<table>
					<tr>labelcolumns( "Email:" ){ input( username ) }</tr>
					<tr>labelcolumns( "Password:" ){ input( password ) }</tr>
					<tr>labelcolumns( "Stay logged in:" ){ input( stayLoggedIn ) } </tr>
				</table>
				gridRow {
					gridCol [class="col-sm-2"] {
						submit signinAction() { "Login" }
					}
					gridCol [class="col-sm-2"] {
						navigate signUp(){"Sign up"}
					}
				}
			</fieldset>
		}
		action signinAction {
			getSessionManager().stayLoggedIn := stayLoggedIn;
			validate( authenticate( username, password ), "The login credentials are not valid.");
			return root();
	}
}