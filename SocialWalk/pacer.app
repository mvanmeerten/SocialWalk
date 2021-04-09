module pacer

native class pacer.PacerAPI as PacerAPI {
	static createAccessToken( String ): String
	static refreshAccessToken( String ): String
	static getUserInfo( String, String ): String
	static getDailyActivities( String, String, String, String ): String
	static authorizeURL(): String
	static getAuthorization(): String
}

page authorize(code: String, state: String, auth_result: String) {
	init {
		if (auth_result == "success") {
			var raw_token := PacerAPI.createAccessToken(code);
			log(raw_token);
			var access_token_response := JSONObject(raw_token);
			log(access_token_response);
			if (access_token_response.getBoolean("success")) {
				var data := access_token_response.getJSONObject("data");
				log(data);
				var user := securityContext.principal;
				user.pacer_id := data.getString("user_id");
				user.access_token := data.getString("access_token");
				user.refresh_token := data.getString("refresh_token");
				user.time_to_refresh := now().addSeconds(data.getString("expires_in").parseInt());
				setName(user);
				setActivities(user);
				goto root();
			}
		}
	}
}

function setName(user: User) {
	var response := PacerAPI.getUserInfo(user.pacer_id, user.access_token);
	log(response);
	var jsonResponse := JSONObject(response);
	if (jsonResponse.getBoolean("success")) {
		var data := jsonResponse.getJSONObject("data");
		log(data);
		user.name := data.getString("display_name");
	} else {
		user.name := "errorGettingName";
	}
}

function refreshAccessToken(user: User) {
	var response := PacerAPI.refreshAccessToken(user.refresh_token);
	log(response);
	var jsonResponse := JSONObject(response);
	if (jsonResponse.getBoolean("success")) {
		var data := jsonResponse.getJSONObject("data");
		log(data);
		user.access_token := data.getString("access_token");
		user.time_to_refresh := now().addSeconds(data.getString("expires_in").parseInt());
	}
}

function setActivities(user: User) {
	var response := PacerAPI.getDailyActivities(user.pacer_id, user.access_token, today().addDays(-14).format("yyyy-MM-dd"), today().format("yyyy-MM-dd"));
	log(response);
	var jsonResponse := JSONObject(response);
	if (jsonResponse.getBoolean("success")) {
		var data := jsonResponse.getJSONObject("data");
		log(data);
		var activities := data.getJSONArray("daily_activities");
		for (i:Int from 0 to activities.length()) {
			var activityData := activities.getJSONObject(i);
			var activity := DailyActivity{};
			var existingActivityForDateList := [x | x in user.activities where x.date == Date(activityData.getString("recorded_for_date"), "yyyy-MM-dd")];
			if (existingActivityForDateList.length > 0) {
				log(existingActivityForDateList);
				activity := existingActivityForDateList[0];
			}
			activity.date := Date(activityData.getString("recorded_for_date"), "yyyy-MM-dd");
			activity.steps := activityData.getInt("steps");
			activity.walking_running_distance := activityData.getInt("walking_running_distance");
			activity.cycling_distance := activityData.getInt("cycling_distance");
			activity.swimming_distance := activityData.getInt("swimming_distance");
			activity.total_distance := activityData.getInt("total_distance");
			activity.calories := activityData.getInt("calories");
			activity.active_time := activityData.getInt("active_time");
			activity.user := user;
			activity.save();
			user.activities.add(activity);
		}
	}
}

function recurringRefresh() {
	log("Refreshing data");
	for (u in (from User)) {
		if (u.access_token.length() > 0) {
			refreshAccessToken(u);
			setActivities(u);			
		}
	}
}

invoke recurringRefresh() every 1 minutes


