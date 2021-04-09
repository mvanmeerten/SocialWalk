module services

service loginUser() {
	if (getHttpMethod() == "POST") {
        // Make object with the specified data
        var requestData := JSONObject(readRequestBody());
        
        var newUser := User{name := "Martijn van Meerten", email := "martijnvanmeerten@hotmail.com", pacer_id := "pacerId", password := ("12345678!" as Secret).digest()};
		if ((from User as u where u.email = ~newUser.email and u <> ~newUser).length == 0) {
			newUser.save();
		}
        // Will contain the response
        var response := JSONObject();
        var email := requestData.getString("email");
        var password := requestData.getString("password");
        log(email);
        log(password);
        log(authenticate(email, password));
        
        // Try to log-in the user and add response if this succeeded or not.
        if (authenticate(requestData.getString("email"), requestData.getString("password"))) {
        	var user := securityContext.principal;
        	log(user.name);
            response.put("message", "user successfully logged in!");
            response.put("id", user.id);
            response.put("name", user.name);
            response.put("email", user.email);
        } else {
        	log("failed");
            response.put("response", "The login credentials are not valid.");
        }
        
        // Give back response whether log-in succeeded
        return response;
    }
}

service logoutUser() {
	if (getHttpMethod() == "POST") {
        var response := JSONObject();
        logout();
        return response;
    }
}

service signUpUser() {
	if (getHttpMethod() == "POST") {
        // Make object with the specified data
        var requestData := JSONObject(readRequestBody());
        
        // Will contain the response
        var response := JSONObject();
        
        var user := User{};
        user.email := requestData.getString("email");
        user.name := requestData.getString("name");
        user.password := (requestData.getString("password") as Secret).digest();
        user.save();
        
        return response;
    }
}

service editUser() {
	if (getHttpMethod() == "POST") {
		var response := JSONObject();
		var requestData := JSONObject(readRequestBody());
		
		var name := requestData.getString("name");
        var password := (requestData.getString("password") as Secret).digest();
        
        securityContext.principal.password := password;
        securityContext.principal.name := name;
        securityContext.principal.save();
        
        return response;
	}
}

service deleteUser() {
	if (getHttpMethod() == "POST") {
		var response := JSONObject();
		securityContext.principal.adminGroups.clear();
		securityContext.principal.activities.clear();
		securityContext.principal.groups.clear();
        securityContext.principal.delete();
        return response;
	}
}

service createGroup() {
	if (getHttpMethod() == "POST") {
        var requestData := JSONObject(readRequestBody());
        
        var response := JSONObject();
        
        var groupName := requestData.getString("groupName");
        var dateToTrackFrom := requestData.getString("dateToTrackFrom");
        
        log(groupName);
        log(dateToTrackFrom);
        
        var group := Group{};
        group.name := groupName;
        group.dateToTrackFrom := Date(dateToTrackFrom, "yyyy-MM-dd");
        group.users.add(securityContext.principal);
        group.adminUsers.add(securityContext.principal);
        group.save();
        
        response.put("id", group.id);
        
        return response;
	}
}

service editGroup(group: Group) {
	if (getHttpMethod() == "POST") {
		var response := JSONObject();
		var requestData := JSONObject(readRequestBody());
		
		var groupName := requestData.getString("groupName");
        var dateToTrackFrom := requestData.getString("dateToTrackFrom");
        
        group.name := groupName;
        group.dateToTrackFrom := Date(dateToTrackFrom, "yyyy-MM-dd");

        group.save();
        
        response.put("id", group.id);
        
        return response;
	}
}

service deleteGroup(group: Group) {
	if (getHttpMethod() == "POST") {
		group.users.clear();
		group.adminUsers.clear();
		group.delete();
        return JSONObject();
	}
}

service getGroupsOfUser() {
	if (getHttpMethod() == "GET") {
		var response := JSONArray();
		
		for (group in securityContext.principal.groups) {
			var o := JSONObject();
			o.put("id", group.id);
			o.put("name", group.name);
			o.put("date", group.dateToTrackFrom.format("yyyy-MM-dd"));
			response.put(o);
		}
		log(response);
		return response;
	}
}

service getGroup(group: Group) {
	if (getHttpMethod() == "GET") {
		var response := JSONObject();
		response.put("name", group.name);
		response.put("date", group.dateToTrackFrom.format("yyyy-MM-dd"));
		response.put("isAdmin", securityContext.principal in group.adminUsers);
		
		var users := JSONArray();		
		var rankedUsers := [u | u in group.users order by u.stepsSince(group.dateToTrackFrom) desc];
		
		for (user in rankedUsers) {
			var userObject := JSONObject();
			userObject.put("id", user.id);
			userObject.put("name", user.name);
			userObject.put("steps", user.stepsSince(group.dateToTrackFrom));
			userObject.put("average", user.averageStepsSince(group.dateToTrackFrom));
			userObject.put("today", user.stepsSince(today()));
			var activitiesArray := JSONArray();
			var activities := [a | a in user.activities where a.date == group.dateToTrackFrom || a.date.after(group.dateToTrackFrom) order by a.date ];
			log(activities);
			var steps := 0;
			for (activity in activities) {
				var activityObject := JSONObject();
				activityObject.put("date", activity.date.format("yyyy-MM-dd"));
				steps := steps + activity.steps;
				activityObject.put("steps", steps);
				activitiesArray.put(activityObject);
			}
			userObject.put("activities", activitiesArray);
			users.put(userObject);
		}
		response.put("users", users);
		
		return response;
	}
}

service groups() {
	if (getHttpMethod() == "GET") {
		var response := JSONArray();
		var groups := [g | g in (from Group) where !(g in securityContext.principal.groups)];
		for (group in groups) {
			var groupObject := JSONObject();
			groupObject.put("id", group.id);
			groupObject.put("name", group.name);
			groupObject.put("date", group.dateToTrackFrom.format("yyyy-MM-dd"));
			groupObject.put("participants", group.users.length);
			groupObject.put("totalSteps", group.totalSteps());
			response.put(groupObject);
		}
		log(response);
		return response;
	}
}

service joinGroup(group: Group) {
	if (getHttpMethod() == "POST") {
		var response := JSONObject();
		group.users.add(securityContext.principal);
		if (group.adminUsers.length == 0) {
			group.adminUsers.add(securityContext.principal);
		}
		group.save();
		return response;
	}
}

service leaveGroup(group: Group) {
	if (getHttpMethod() == "POST") {
		var response := JSONObject();
		group.users.remove(securityContext.principal);
		if (securityContext.principal in group.adminUsers) {
			group.adminUsers.remove(securityContext.principal);
		}
		group.save();
		return response;
	}
}

service populateDB() {
	if (getHttpMethod() == "POST") {
		var response := JSONObject();
		populateDB();
		return response;
	}
}

service stepsSince(date: String) {
	if (getHttpMethod() == "GET") {
		var response := JSONArray();
		var activityList := securityContext.principal.dailyStepsSince(Date(date, "yyyy-MM-dd"));
		for (activity in activityList) {
			var activityObject := JSONObject();
			activityObject.put("date", activity.date.format("yyyy-MM-dd"));
			activityObject.put("steps", activity.steps);
			response.put(activityObject);
		}
		return response;
	}
}

service loggedIn() {
	if (getHttpMethod() == "GET") {
		var response := JSONObject();
		if (loggedIn()) {
			response.put("response", true);
		} else {
			response.put("response", false);
		}
		return response;
	}
}

access control rules

	rule page loginUser() { true }
	rule page logoutUser() { true }
	rule page signUpUser() { true }
	rule page loggedIn() { true }
	rule page populateDB() { true }
	rule page editUser() { loggedIn() }
	rule page deleteUser() { loggedIn() }
	rule page createGroup() { loggedIn() }
	rule page editGroup(group: Group) { loggedIn() && isAdmin(group) }
	rule page deleteGroup(group: Group) { loggedIn() && isAdmin(group) }
	rule page getGroupsOfUser() { loggedIn() }
	rule page getGroup(group: Group) { loggedIn() && inGroup(group) }
	rule page groups() { loggedIn() }
	rule page joinGroup(group: Group) { loggedIn() }
	rule page leaveGroup(group: Group) { loggedIn() && inGroup(group) }
	rule page stepsSince(date: String) { loggedIn() }
	