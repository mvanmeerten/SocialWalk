module data
	entity User {
		name : String
		pacer_id : String
		access_token : String
		refresh_token : String
		time_to_refresh : DateTime
		email : Email (validate((from User as u where u.email = ~this.email and u <> ~this).length == 0, "There is already an account for this email"))
		password : Secret
		groups : {Group} (inverse=Group.users)
		adminGroups : {Group} (inverse=Group.adminUsers)
		activities : {DailyActivity}
		
		function dailyStepsSince(date: Date): List<DailyActivity> {
			var activityList := List<DailyActivity>();
			for (activity in activities where activity.date.after(date) || activity.date == date) {
				activityList.add(activity);
			}
			return activityList;
		}
		
		function stepsSince(date: Date): Int {
			var steps := 0;
			for (activity in activities) {
				if (activity.date == date || activity.date.after(date)) {
					steps := steps + activity.steps;
				}
			}
			log(steps);
			return steps;
		}
		
		function averageStepsSince(date: Date): Int {
			var steps := 0;
			var counter := 0;
			for (activity in activities) {
				if (activity.date == date || activity.date.after(date) && (activity.date != today())) {
					steps := steps + activity.steps;
					counter := counter + 1;
				}
			}
			if (counter > 0) {
				return steps / counter;	
			}
			return 0;
		}
	}
	
	entity Group {
		// name : String (searchable(analyzer=autocomplete_untokenized), validate(name.length() > 4, "Name should have 5 characters or more"))
		name : String (searchable, validate(name.length() > 4, "Name should have 5 characters or more"))
		users : {User}
		adminUsers : {User}
		dateToTrackFrom : Date (searchable, validate(dateToTrackFrom != null, "Not a valid date"))
		
		function totalSteps(): Int {
			var totalSteps := 0;
			for (user in users) {
				totalSteps := totalSteps + user.stepsSince(dateToTrackFrom);
			}
			return totalSteps;
		}
	}
	
	entity DailyActivity {
		date : Date
		steps : Int
		walking_running_distance : Int (default=0)
		cycling_distance : Int (default=0)
	    swimming_distance : Int (default=0)
	    total_distance : Int (default=0)
	    calories : Int (default=0)
	    active_time : Int (default=0)
	    user : User
	}
	
	analyzer autocomplete_untokenized {
	    tokenizer = KeywordTokenizer
	    token filter = LowerCaseFilter
  	}