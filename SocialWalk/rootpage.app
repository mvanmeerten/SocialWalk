module rootpage

	page root() {
		init {
			var user := User{name := "Martijn van Meerten", email := "martijnvanmeerten@hotmail.com", pacer_id := "pacerId", password := ("12345678!" as Secret).digest()};
			if ((from User as u where u.email = ~user.email and u <> ~user).length == 0) {
				user.save();
			}
			if (!loggedIn()) {
				return accessControl();
			}
			else if (!authorized()) {
				log(url(PacerAPI.authorizeURL()));
				goto url(PacerAPI.authorizeURL());
			}
		}
		main {
			<div class="row mt-2">
				<div class="col-md-6">
					groupOverview("My Groups", securityContext.principal.groups)
					gridRow[class="mt-2"] {
						gridCol {
							submitlink action {
								goto groupSearch();
							}{ "Group Search" }
						}
						gridCol {
							submitlink action {
								populateDB();
							}{"Populate DB"}
						}
					}
				</div>
				<div class="col-md-6">
					newGroup()
				</div>
			</div>
		}
	}

	template groupOverview( title: String, groups: {Group} ) {
		card(title) {
			<table class="table table-hover" style="margin-bottom: 0;">
				<thead>
					tr {
						<th scope="col">"Name"</th>
						<th scope="col">"Date to track from"</th>
					}
				</thead>
				<tbody>
					for( group in groups ) {
						tr [onclick=action {log("Test"); goto group(group);}, style="cursor: pointer;"] {
							<td>output(group.name)</td>
							<td>output(group.dateToTrackFrom)</td>
						}
					}
				</tbody>
			</table>
		}
	}
	
	htmlwrapper {
		tr tr
	}
	
	template newGroup() {
		var group := Group{}
		h3{ "Create a new group" }
		form {
			myLabel("Name"){ input(group.name) }
			myLabel("Date to track from"){ input(group.dateToTrackFrom) }
			submit action{
				group.users.add(securityContext.principal);
				group.adminUsers.add(securityContext.principal);
				group.save();
			}{ "Create" } 
		}
	}
	
	function authorized(): Bool {
		return securityContext.principal.pacer_id.length() > 0;
	}
	
	function populateDB() {
		var names : List<String> := ["Liam", "Noah", "Oliver", "William", "Elijah", "James", "Benjamin", "Lucas", "Mason", "Ethan", "Alexander", "Henry", "Jacob", "Michael", "Daniel", "Logan", "Jackson", "Sebastian", "Jack", "Aiden", "Owen", "Samuel", "Matthew", "Joseph", "Levi", "Mateo", "David", "John", "Wyatt", "Carter", "Julian", "Luke", "Grayson", "Isaac", "Jayden", "Theodore", "Gabriel", "Anthony", "Dylan", "Leo", "Lincoln", "Jaxon", "Asher", "Christopher", "Josiah", "Andrew", "Thomas", "Joshua", "Ezra", "Hudson", "Charles", "Caleb", "Isaiah", "Ryan", "Nathan", "Adrian", "Christian", "Maverick", "Colton", "Elias", "Aaron", "Eli", "Landon", "Jonathan", "Nolan", "Hunter", "Cameron", "Connor", "Santiago", "Jeremiah", "Ezekiel", "Angel", "Roman", "Easton", "Miles", "Robert", "Jameson", "Nicholas", "Greyson", "Cooper", "Ian", "Carson", "Axel", "Jaxson", "Dominic", "Leonardo", "Luca", "Austin", "Jordan", "Adam", "Xavier", "Jose", "Jace", "Everett", "Declan", "Evan", "Kayden", "Parker", "Wesley", "Kai"];
		var emails : List<String> := ["dbanarse@hotmail.com", "mwilson@yahoo.ca", "roesch@aol.com", "sumdumass@icloud.com", "munson@sbcglobal.net", "gomor@gmail.com", "gordonjcp@sbcglobal.net", "flakeg@live.com", "ilial@outlook.com", "kmself@comcast.net", "fviegas@hotmail.com", "jaesenj@aol.com", "marcs@yahoo.ca", "rmcfarla@yahoo.com", "daveewart@me.com", "ajohnson@comcast.net", "ivoibs@mac.com", "johnbob@outlook.com", "jaarnial@aol.com", "chlim@comcast.net", "notaprguy@att.net", "baveja@aol.com", "martink@yahoo.com", "vertigo@optonline.net", "tsuruta@msn.com", "sopwith@aol.com", "laird@icloud.com", "seasweb@icloud.com", "sfoskett@mac.com", "quantaman@yahoo.com", "miyop@att.net", "killmenow@me.com", "konit@msn.com", "speeves@hotmail.com", "wonderkid@msn.com", "noticias@mac.com", "enintend@outlook.com", "johndo@sbcglobal.net", "hwestiii@yahoo.com", "leviathan@msn.com", "keiji@icloud.com", "psichel@me.com", "liedra@yahoo.ca", "jschauma@yahoo.com", "debest@sbcglobal.net", "british@gmail.com", "hallo@yahoo.nl", "preneel@comcast.net", "keutzer@icloud.com", "stomv@att.net"];
		var passwords : List<Secret> := ["pB7GuUXXNH!", "nWygTM3Jjs!", "m8cKTUnAVA!", "dt5Vk8ftRF!", "geYpt9Ev8t!", "bnmNg393dV!", "sQeeXasaS8!", "xUpQ88AGxx!", "3DxDVStJK2!", "r5YpEseLNC!", "n5UHGbRKmP!", "hF6rFgw28h!", "hAGgqYJRNh!", "YyqZ5BrEj9!", "SuvgquyZDA!", "SD9SNscgNJ!", "xgv8uUfVnF!", "jyKfCzdK8Z!", "mxLUdfXZjp!", "s4n2hWNR47!", "DUaDfujAbM!", "x8bVTCyDXr!", "F92gVyT43n!", "UVaLXHDaFk!", "vzsBtCsMMR!", "WVzMy6EyK3!", "8kn54cQESL!", "uDyx8hVvjs!", "wKdYnn3q4Y!", "r5RDkZDcc8!", "RVkM7MZTP6!", "rg3C6VZMUg!", "QzvYLyNmA5!", "mwkLbZXHtP!", "XnAGebMCyU!", "R74DS4A5PZ!", "GCSHbCswUU!", "YS45cVnYQe!", "qd3YneB2rz!", "wf8zb9eSBM!", "FnP4ACVHRw!", "jNEzENADmf!", "xQFAMhHXkW!", "yvEgjpCR6e!", "HfmKXqmcFA!", "5ATYUrhrFR!", "H7uhRJY3Gm!", "gCjakkDBBH!", "UAWzRLdtaw!", "aAdSyDQpGC"];
		var groupNames : List<String> := ["Thundering Tornadoes", "Big Lightning", "Running Titans", "Strange Rattlesnakes", "Supreme Demons", "Wonderful Flash", "Black Tigers", "Big Trolls", "Weak Bullets", "Polar Eagles", "Unaccountable Jimmies", "Blue Warriors", "Glistening Generals", "Punctual Storm", "Winter Jets", "Weak Bloodhounds", "Horned Badgers", "Silver Pilots", "Prairie Privateers", "Bald Fire", "Marvelous Bengals", "Mad Bobcats", "Sugar Wave", "Powerful Wombats", "Silver Pirates", "Odd Wombats", "Festive Ladies", "Punctual Women", "Prairie Foxes", "Powerful Flash", "Golden Archers", "Graceful Heels", "Wet Yellowjackets", "Horrible Eagles", "Educated Defenders", "Prairie Racers", "Little Mavericks", "Marvelous Panthers", "Flaming Mules", "Swift Owls", "Odd Stallions", "Punctual Vulcans", "Glistening Cowboys", "Short Musketeers", "Silver Trolls", "Sassy Mules", "Old Colts", "Fanatical Llamas", "Weak Lancers"];
		for (i: Int from 0 to 50) {
			var user := User{name := names[i], email := emails[i], pacer_id := "pacerId", password := passwords[i].digest()};
			for (j: Int from 0 to (random() * 100.0).ceil()) {
				var activity := DailyActivity{user := user, date := today().addDays(j * -1), steps := (random() * 20000.0).ceil() };
				activity.save();
				user.activities.add(activity);
			}
			user.save();
		}
		var users := (from User);
		for (i: Int from 0 to groupNames.length) {
			var group := Group{name := groupNames[i], dateToTrackFrom := today().addDays(-5 - (random() * 100.0).ceil())};
			for (user in users) {
				if (random() < 0.1) {
					group.users.add(user);
					if (group.adminUsers.length == 0) {
						group.adminUsers.add(user);
					}
					else if (random() < 0.2) {
						group.adminUsers.add(user);
					}
				}
			}
			group.save();
		}
	}
