
/*
		Hello! Welcome to my custom GameJolt API for GMS 2.3!
		*** THIS ONLY WORKS FOR GMS 2.3+ *** It uses a lot of the new features in the 2.3 update nonexistant pre2.3

		To get started change the GJInit() Game ID and Private Key
		
		This system is built from the ground up to work with any object, however it NEEDS a control object to function!
		Before calling anything else make sure you have one instance of a oGJControl (or any other control object) always existing
		call the GJInit() function, AND call the GJNetworking() in their Async - HTTP event.
		
		---SIDENOTE with the onAttempt functions, they can be set to -1 if you do not want to use any function.
		
		IMPORTANT-- Some functions use ds_maps to give information back to you after they are loaded.
		These maps are not deleted automatically, and when you're done using them you need to delete the map yourself.
		I will mark all of the functions that return a map with a comment "MAP DATA" (or "LIST DATA") in the GameJoltAPI script.
		Be sure to delete these maps when calling these functions to prevent memory leaks. (Example, see GJOnFetchUserAttempt())
		
		As your game gets more advanced you're obviously going to need to expand on what is here, but I hope this serves well as a basis.
		Check out the functions in this create event to make simple events occur when async actions happen such as GJLoginAttempt()
		
		Nobody is perfect, if you spot any bugs, or question my awful programming methods.
		Please do let me know! I am always up to improve this API.
		
		Created by DustBunneGames. <3
		GMS2 Custom API Version 1.1.3, GameJolt API Version 1.2
*/


/// @function GJInit();
//This is the function that should init your gamejolt controller. It should be called ONCE by one object (oGJControl)
/// @param GameID The game ID of your gamejolt game
/// @param PrivateKey The private key of your gamejolt game
/// @param DebugMode Weither or not to enable debug mode. This just makes the system log every response from GameJolt. It can usually be left off
function GJInit(GJID, GJPK, DebugMode) {
	__GjGameID = GJID
	__GjPrivateKey = GJPK
	__GjVersion = "v1_2" //Version of Game Jolt this API was last updated to use. Changing this will cause issues unless you plan on updating it yourself.
	__GjCallList = ds_list_create();
	__GjUsername = ""
	__GjGameToken = ""
	__GjTempUsername = ""
	__DebugMode = DebugMode
	global.__GjControlObject = object_index;
}

/// @function GJLogin();
/// @param Username The username of the user attempting to login
/// @param GameToken The game token of the user attempting to login
/// @param onAttemptFunction This is the function that will be called once the request is completed. This can be set to -1 if you do not want to call any function. Parameters: Success, ErrorMessage, RetryNumber
//onAttemptFunction - Success: Weither the request was successful or not.
//onAttemptFunction - ErrorMessage: error message, only supplied on failure.
//onAttemptFunction - RetryNumber: the current retry number, this number decreases till it reaches 0 from the supplied autoRetry amount. You can use this to display a "failed after [num] of retries" message. If autoRetry is set to -1, it will return the number of trys so far+1 * -1. So for example, if it was the 4th retry, it would return -5
/// @param autoRetry The number of times to automatically repeat the request if it fails. This can be set to 0 to never repeat, or -1 to repeat until successful.
function GJLogin(Username, GameToken, onAttemptFunction, autoRetry) {
	var owner = id
	with(global.__GjControlObject) {
		__GjTempUsername = Username
		__GjGameToken = GameToken
		var url="https://api.gamejolt.com/api/game/"+__GjVersion+"/users/auth/?game_id="+__GjGameID+"&username="+Username+"&user_token="+GameToken;
		url+="&signature="+md5_string_utf8(url+__GjPrivateKey)
		var http=http_get(url);
		var Construct = {
			type:"Login",
			id:http,
			host:owner,
			toCall:onAttemptFunction,
			retry:autoRetry,
			uName:Username,
			gToken:GameToken
		}
		ds_list_add(__GjCallList,Construct)
		return http;
	}
}

/// @function GJGetLoginStatus( Returns the player's username if logged in "" if not );
//Requres that the control object exists, but so does everything else!
function GJGetLoginStatus() {
	with(global.__GjControlObject) {
		return(__GjUsername)
	}
}

/// @function GJUserFetch();
// ---------------MAP DATA--------------
//This function will return a ds_map with all of the user data (assuming it is successful)
//See https://gamejolt.com/game-api/doc/users/fetch for the key names.
//EX: ds_map_find_value(DataMap,"avatar_url") will return the user's avatar URL (just make sure you're doing this in the GJOnFetchUserAttempt() function)
//This function is supposed to support multiuser fetching, but I can't get it to work so this version doesn't..
/// @param Type The type of information being used for the fetch, this can be "ID" (user ID) or "Name" (username) these are not cap sensitive.
/// @param User The data to attempt a fetch with (either a Username or a UserID dependent on what you supplied for the Type)
/// @param onAttemptFunction This is the function that will be called once the request is completed. Parameters: Success, DataMap, ErrorMessage, RetryNumber
//onAttemptFunction - Success: Weither the request was successful or not.
//onAttemptFunction - MapData: ds_map_id containing all of the user data, only supplied if successful.
//onAttemptFunction - ErrorMessage: error message, only supplied on failure.
//onAttemptFunction - RetryNumber: the current retry number, this number decreases till it reaches 0 from the supplied autoRetry amount. You can use this to display a "failed after [num] of retries" message. If autoRetry is set to -1, it will return the number of trys so far+1 * -1. So for example, if it was the 4th retry, it would return -5
/// @param autoRetry The number of times to automatically repeat the request if it fails. This can be set to 0 to never repeat, or -1 to repeat until successful.
function GJUserFetch(Type, User, onAttemptFunction, autoRetry) {
	var owner = id
	with(global.__GjControlObject) {
		Type = string_lower(Type)
		var edata = ""; //Extra data (what we will later supply to the URL)
		switch(Type) {
			case"id":
				edata = "&user_id="+string(User)
			break;
			case"name":
				edata = "&username="+string(User)
			break;
			default:
				show_debug_message("GJAPI ERROR= attempted to fetch a nonexistant user type. The type should be \"id\" or \"user\", you supplied \""+string(Type)+"\"")
				exit;
			break;
		}
		var url="https://api.gamejolt.com/api/game/"+__GjVersion+"/users/?game_id="+__GjGameID+edata;
		url+="&signature="+md5_string_utf8(url+__GjPrivateKey)
		var http=http_get(url);
		var Construct = {
			type:"FetchUser",
			id:http,
			host:owner,
			toCall:onAttemptFunction,
			retry:autoRetry,
			iType:Type,
			user:User
		}
		ds_list_add(__GjCallList,Construct)
		return http;
	}
}

/// @function GJOpenSession();
//Will attempt to open/close/check/ping a game session of your game for the logged in user.
//For more info on what each type will do, look at https://gamejolt.com/game-api/doc/sessions
/// @param Type The type of information being used for the session, this can be open, close, check, or ping these are not cap sensitive.
/// @param Status What to set the status to (only when calling a ping type) a status can either be idle or active.
/// @param onAttemptFunction This is the function that will be called once the request is completed. Parameters: Success, ErrorMessage, RetryNumber
//onAttemptFunction - Success: Weither the request was successful or not.
//onAttemptFunction - ErrorMessage: error message, only supplied on failure.
//onAttemptFunction - RetryNumber: the current retry number, this number decreases till it reaches 0 from the supplied autoRetry amount. You can use this to display a "failed after [num] of retries" message. If autoRetry is set to -1, it will return the number of trys so far+1 * -1. So for example, if it was the 4th retry, it would return -5
//Worth noting that this function will not tell you what type of update you made in the onAttemptFunction, you should make seperate functions for each type.
/// @param autoRetry The number of times to automatically repeat the request if it fails. This can be set to 0 to never repeat, or -1 to repeat until successful.
function GJSessionUpdate(Type, Status, onAttemptFunction, autoRetry) {
	var owner = id
	with(global.__GjControlObject) {
		if(__GjUsername != "") { //Not usable unless logged in.
			Type = string_lower(Type)
			var url="https://api.gamejolt.com/api/game/"+__GjVersion+"/sessions/"+Type+"/?game_id="+__GjGameID+"&username="+__GjUsername+"&user_token="+__GjGameToken;
			if(Type = "ping" && Status != undefined) {
				Status = string_lower(Status)
				url += "&status="+Status	
			}
			url+="&signature="+md5_string_utf8(url+__GjPrivateKey)
			var http=http_get(url);
			var Construct = {
				type:"Session",
				subtype:Type,
				id:http,
				host:owner,
				toCall:onAttemptFunction,
				retry:autoRetry,
				status:Status
			}
			ds_list_add(__GjCallList,Construct)
			return http;
		} else {
			show_debug_message("GJAPI ERROR= Failed to update session, user is not logged in!")		
		}
	}
}

/// @function GJScoreAdd();
//Will attempt to add a score to a scoreboard as the logged in user, or as a guest if requested.
/// @param Scoreboard The table id of the scoreboard to add the value to, this can be set to "" to supply the default.
/// @param Sort This is a number associated with the score. All sorting will be based on this number. Example: 500
/// @param DisplayName This is a name associated with the score. This is what the users will see when looking at the scoreboard. Example: 500 Points
/// @param ExtraData This is any extra data to store privately along with the score. Mostly intended to see if scores are legit or not. "" to leave unused
/// @param GuestName This is the name of the player if they're a guest. If you do not want to submit the score as a guest, set this to "".
/// @param onAttemptFunction This is the function that will be called once the request is completed. Parameters: Success, ErrorMessage, RetryNumber
//onAttemptFunction - Success: Weither the request was successful or not.
//onAttemptFunction - ErrorMessage: error message, only supplied on failure.
//onAttemptFunction - RetryNumber: the current retry number, this number decreases till it reaches 0 from the supplied autoRetry amount. You can use this to display a "failed after [num] of retries" message. If autoRetry is set to -1, it will return the number of trys so far+1 * -1. So for example, if it was the 4th retry, it would return -5
/// @param autoRetry The number of times to automatically repeat the request if it fails. This can be set to 0 to never repeat, or -1 to repeat until successful.
function GJScoreAdd(Scoreboard, Sort, DisplayName, ExtraData, GuestName, onAttemptFunction, autoRetry) {
	var owner = id
	with(global.__GjControlObject) {
		if(__GjUsername != "" || GuestName != "") { //Not usable unless logged in. (or guest)
			var url="https://api.gamejolt.com/api/game/"+__GjVersion+"/scores/add/?game_id="+__GjGameID+"&sort="+string(Sort)+"&score="+string(DisplayName);
			if(__GjUsername != "" && GuestName = "") {
				url += "&username="+__GjUsername+"&user_token="+__GjGameToken;
			}
			if(string(Scoreboard) != "") {
				url += "&table_id="+string(Scoreboard)	
			}
			if(GuestName != "") {
				url += "&guest="+GuestName
			}
			if(ExtraData != "") {
				url += "&extra_data="+ExtraData
			}
			url+="&signature="+md5_string_utf8(url+__GjPrivateKey)
			var http=http_get(url);
			var Construct = {
				type:"Score",
				subtype:"Add",
				id:http,
				host:owner,
				retry:autoRetry,
				toCall:onAttemptFunction,
				sb:Scoreboard,
				sort:Sort,
				displayName:DisplayName,
				eData:ExtraData,
				gName:GuestName
			}
			ds_list_add(__GjCallList,Construct)
			return http;
		} else {
			show_debug_message("GJAPI ERROR= Failed to add score, user is not logged in or guest name was not set!")		
		}
	}
}

/// @function GJScoreFetch();
// ---------------LIST DATA--------------
//This function will return a ds_LIST with all of the scores inside, each of the scores are all ds_MAPS (assuming it is successful)
//See https://gamejolt.com/game-api/doc/scores/fetch for the key names.
//for example, ds_map_find_value(ds_list_find_value(DataList,0),"user") will return the user who achieved the first score in the returned list.
//Because the maps are nested within a list, they do not need to be deleted. It will be done automatically, but the main list MUST still be deleted!
//Will attempt to get the scoreboard information of the provided id
/// @param Scoreboard The table id of the scoreboard to add the value to, this can be set to "" to supply the default.
/// @param Limit This is the max number of scores to be returned.
/// @param BetterThan Set this value to anything other than "" to tell gj to only retreve scores better than the set value. "" to disable
/// @param WorseThan Set this value to anything other than "" to tell gj to only retreve scores worse than the set value. "" to disable
/// @param GuestName This is the name of the player if they're a guest. Required if the player is not logged in.
/// @param onAttemptFunction This is the function that will be called once the request is completed. Parameters: Success, DataList, ErrorMessage, RetryNumber
//onAttemptFunction - Success: Weither the request was successful or not.
//onAttemptFunction - DataList: ds_list containing all of the requested information, only supplied on success.
//onAttemptFunction - ErrorMessage: error message, only supplied on failure.
//onAttemptFunction - RetryNumber: the current retry number, this number decreases till it reaches 0 from the supplied autoRetry amount. You can use this to display a "failed after [num] of retries" message. If autoRetry is set to -1, it will return the number of trys so far+1 * -1. So for example, if it was the 4th retry, it would return -5
/// @param autoRetry The number of times to automatically repeat the request if it fails. This can be set to 0 to never repeat, or -1 to repeat until successful.
function GJScoreFetch(Scoreboard, Limit, BetterThan, WorseThan, GuestName, onAttemptFunction, autoRetry) {
	var owner = id
	with(global.__GjControlObject) {
		if(__GjUsername != "" || GuestName != "") { //Not usable unless logged in. (or guest)
			var url="https://api.gamejolt.com/api/game/"+__GjVersion+"/scores/?game_id="+__GjGameID+"&limit="+string(Limit);
			if(__GjUsername != "" && GuestName = "") {
				url += "&username="+__GjUsername+"&user_token="+__GjGameToken;
			}
			if(string(Scoreboard) != "") {
				url += "&table_id="+string(Scoreboard)	
			}
			if(GuestName != "") {
				url += "&guest="+GuestName
			}
			if(BetterThan != "") {
				url += "&better_than="+string(BetterThan)
			}
			if(WorseThan != "") {
				url += "&worse_than="+string(WorseThan)
			}
			url+="&signature="+md5_string_utf8(url+__GjPrivateKey)
			var http=http_get(url);
			var Construct = {
				type:"Score",
				subtype:"Fetch",
				id:http,
				host:owner,
				toCall:onAttemptFunction,
				retry:autoRetry,
				sb:Scoreboard,
				limit:Limit,
				bThan:BetterThan,
				wThan:WorseThan,
				gName:GuestName
			}
			ds_list_add(__GjCallList,Construct)
			return http;
		} else {
			show_debug_message("GJAPI ERROR= Failed to fetch scores, user is not logged in, or guest name was not set!")
		}
	}
}

/// @function GJScoreTables();
// ---------------LIST DATA--------------
//This function will return a ds_LIST with all of the scoreboards for your game inside, each of the scores are ds_MAPS (assuming it is successful)
//NOTE - This does not retreve the actual scores on the scoreboards, just the boards themselves. For that see GJScoreFetch().
//See https://gamejolt.com/game-api/doc/scores/tables for the key names.
//for example, ds_map_find_value(ds_list_find_value(DataList,0),"description") will return the description of the first scoreboard in the returned list.
//Because the maps are nested within a list, they do not need to be deleted because it will be done automatically, but the main list MUST still be deleted!
/// @param onAttemptFunction This is the function that will be called once the request is completed. Parameters: Success, DataList, ErrorMessage, RetryNumber
//onAttemptFunction - Success: Weither the request was successful or not.
//onAttemptFunction - DataList: ds_list containing all of the requested information, only supplied on success.
//onAttemptFunction - ErrorMessage: error message, only supplied on failure.
//onAttemptFunction - RetryNumber: the current retry number, this number decreases till it reaches 0 from the supplied autoRetry amount. You can use this to display a "failed after [num] of retries" message. If autoRetry is set to -1, it will return the number of trys so far+1 * -1. So for example, if it was the 4th retry, it would return -5
/// @param autoRetry The number of times to automatically repeat the request if it fails. This can be set to 0 to never repeat, or -1 to repeat until successful.
function GJScoreTables(onAttemptFunction, autoRetry) {
	var owner = id
	with(global.__GjControlObject) {
		var url="https://api.gamejolt.com/api/game/"+__GjVersion+"/scores/tables/?game_id="+__GjGameID;
		url+="&signature="+md5_string_utf8(url+__GjPrivateKey)
		var http=http_get(url);
		var Construct = {
			type:"Score",
			subtype:"Tables",
			id:http,
			host:owner,
			toCall:onAttemptFunction,
			retry:autoRetry
		}
		ds_list_add(__GjCallList,Construct)
		return http;
	}
}

/// @function GJScoreRank();
//This function will return the inputed sort value's position on the scoreboard.
//NOTE - This does not retreve the actual scores on the scoreboards, just their rank position. For that see GJScoreFetch().
/// @param Scoreboard The table id of the scoreboard to add the value to, this can be set to "" to supply the default.
/// @param Sort This is a number associated with the score. All sorting will be based on this number. Example: 500
/// @param onAttemptFunction This is the function that will be called once the request is completed. Parameters: Success, Rank, ErrorMessage, RetryNumber
//onAttemptFunction - Success: Weither the request was successful or not.
//onAttemptFunction - Rank: rank of the inputed sort value, only supplied on success.
//onAttemptFunction - ErrorMessage: error message, only supplied on failure.
//onAttemptFunction - RetryNumber: the current retry number, this number decreases till it reaches 0 from the supplied autoRetry amount. You can use this to display a "failed after [num] of retries" message. If autoRetry is set to -1, it will return the number of trys so far+1 * -1. So for example, if it was the 4th retry, it would return -5
/// @param autoRetry The number of times to automatically repeat the request if it fails. This can be set to 0 to never repeat, or -1 to repeat until successful.
function GJScoreRank(Scoreboard, Sort, onAttemptFunction, autoRetry) {
	var owner = id
	with(global.__GjControlObject) {
		var url="https://api.gamejolt.com/api/game/"+__GjVersion+"/scores/get-rank/?game_id="+__GjGameID+"&sort="+string(Sort);
		if(string(Scoreboard) != "") {
			url += "&table_id="+string(Scoreboard)	
		}
		url+="&signature="+md5_string_utf8(url+__GjPrivateKey)
		var http=http_get(url);
		var Construct = {
			type:"Score",
			subtype:"Rank",
			id:http,
			host:owner,
			toCall:onAttemptFunction,
			retry:autoRetry,
			sb:Scoreboard,
			sort:Sort
		}
		ds_list_add(__GjCallList,Construct)
		return http;
	}
}

/// @function GJTrophyFetch();
// ---------------LIST DATA--------------
//This function will return a ds_LIST populated with ds_MAPS for each trophy, or just one depending on the parameters passed in.
//See https://gamejolt.com/game-api/doc/trophies/fetch for the key names.
//for example, ds_map_find_value(ds_list_find_value(DataList,0),"achieved") will return the date that the first achievement in the list was unlocked, or "false" if it's not unlocked yet.
//Because the maps are nested within a list, they do not need to be deleted because it will be done automatically, but the main list MUST still be deleted!
/// @param TrophyID The id of the trophy you're trying to get information on. If you want multiple trophies in one call, set this to ""
/// @param Achieved This tells gamejolt to only get achieved trophies if true, or only locked trophies if false. This is NOT how you unlock an achievement. See GJTrophyUpdate() for that.
/// @param onAttemptFunction This is the function that will be called once the request is completed. Parameters: Success, DataList, ErrorMessage, RetryNumber
//onAttemptFunction - Success: Weither the request was successful or not.
//onAttemptFunction - DataList: ds_list containing all of the requested information, only supplied on success.
//onAttemptFunction - ErrorMessage: error message, only supplied on failure.
//onAttemptFunction - RetryNumber: the current retry number, this number decreases till it reaches 0 from the supplied autoRetry amount. You can use this to display a "failed after [num] of retries" message. If autoRetry is set to -1, it will return the number of trys so far+1 * -1. So for example, if it was the 4th retry, it would return -5
/// @param autoRetry The number of times to automatically repeat the request if it fails. This can be set to 0 to never repeat, or -1 to repeat until successful.
function GJTrophyFetch(TrophyID, Achieved, onAttemptFunction, autoRetry) {
	var owner = id
	with(global.__GjControlObject) {
		if(__GjUsername != "") { //Only useable if logged in.
			var url="https://api.gamejolt.com/api/game/"+__GjVersion+"/trophies/?game_id="+__GjGameID+"&username="+__GjUsername+"&user_token="+__GjGameToken;
			if(string(TrophyID) != "") {
				url += "&trophy_id="+string(Scoreboard)	
			}
			if(string(Achieved) != "") {
				url += "&achieved="+string(Scoreboard)	
			}
			url+="&signature="+md5_string_utf8(url+__GjPrivateKey)
			var http=http_get(url);
			var Construct = {
				type:"Trophy",
				subtype:"Fetch",
				id:http,
				host:owner,
				toCall:onAttemptFunction,
				retry:autoRetry,
				tID:TrophyID,
				achieved:Achieved
			}
			ds_list_add(__GjCallList,Construct)
			return http;
		} else {
			show_debug_message("GJAPI ERROR= Failed to fetch trophy, user is not logged in!")		
		}
	}
}

/// @function GJTrophyUpdate();
//This function will give/remove the desired trophy from the logged in user.
/// @param TrophyID The id of the trophy you're trying to get information on. If you want multiple trophies in one call, set this to ""
/// @param Achieved Set this value to true to add the trophy or false to remove it.
/// @param onAttemptFunction This is the function that will be called once the request is completed. Parameters: Success, ErrorMessage, RetryNumber
//onAttemptFunction - Success: Weither the request was successful or not.
//onAttemptFunction - ErrorMessage: error message, only supplied on failure.
//onAttemptFunction - RetryNumber: the current retry number, this number decreases till it reaches 0 from the supplied autoRetry amount. You can use this to display a "failed after [num] of retries" message. If autoRetry is set to -1, it will return the number of trys so far+1 * -1. So for example, if it was the 4th retry, it would return -5
//Worth noting that this function will not tell you what type of update you made in the onAttemptFunction, you should make seperate functions for each type.
/// @param autoRetry The number of times to automatically repeat the request if it fails. This can be set to 0 to never repeat, or -1 to repeat until successful.
function GJTrophyUpdate(TrophyID, Achieved, onAttemptFunction, autoRetry) {
	var owner = id
	with(global.__GjControlObject) {
		if(__GjUsername != "") { //Only useable if logged in.
			var AchieveType = "add";
			if(Achieved = 0) { AchieveType = "remove" } //false, remove achievement
			var url="https://api.gamejolt.com/api/game/"+__GjVersion+"/trophies/"+AchieveType+"-achieved/?game_id="+__GjGameID+"&username="+__GjUsername+"&user_token="+__GjGameToken+"&trophy_id="+string(TrophyID);
			url+="&signature="+md5_string_utf8(url+__GjPrivateKey)
			var http=http_get(url);
			var Construct = {
				type:"Trophy",
				subtype:AchieveType,
				id:http,
				host:owner,
				toCall:onAttemptFunction,
				retry:autoRetry,
				tID:TrophyID,
				achieved:Achieved
			}
			ds_list_add(__GjCallList,Construct)
			return http;
		} else {
			show_debug_message("GJAPI ERROR= Failed to update trophy, user is not logged in!")		
		}
	}
}

/// @function GJDataFetch();
//This function will return the data stored in a global or user key. All data stored is converted into a string, so when fetching data be sure to reconvert to a real if needed.
/// @param Key The key of the data to fetch
/// @param User Weither or not to fetch from the user data or not (fetch global data). This should be true or false.
/// @param onAttemptFunction This is the function that will be called once the request is completed. Parameters: Success, Data, ErrorMessage, RetryNumber
//onAttemptFunction - Success: Weither the request was successful or not.
//onAttemptFunction - Data: data stored in the requested key. Only supplied on success.
//onAttemptFunction - ErrorMessage: error message, only supplied on failure.
//onAttemptFunction - RetryNumber: the current retry number, this number decreases till it reaches 0 from the supplied autoRetry amount. You can use this to display a "failed after [num] of retries" message. If autoRetry is set to -1, it will return the number of trys so far+1 * -1. So for example, if it was the 4th retry, it would return -5
/// @param autoRetry The number of times to automatically repeat the request if it fails. This can be set to 0 to never repeat, or -1 to repeat until successful.
function GJDataFetch(Key, User, onAttemptFunction, autoRetry) {
	var owner = id
	with(global.__GjControlObject) {
		var url="https://api.gamejolt.com/api/game/"+__GjVersion+"/data-store/?game_id="+__GjGameID+"&key="+string(Key);
		if(User && __GjUsername != "") {
			url += "&username="+__GjUsername+"&user_token="+__GjGameToken
		} else {
			if(__GjUsername = "" && User) {
				show_debug_message("GJAPI ERROR= Failed to set user data, user is not logged in!")	
				exit;
			}
		}
		url+="&signature="+md5_string_utf8(url+__GjPrivateKey)
		var http=http_get(url);
		var Construct = {
			type:"Data",
			subtype:"Fetch",
			id:http,
			host:owner,
			toCall:onAttemptFunction,
			retry:autoRetry,
			key:Key,
			user:User
		}
		ds_list_add(__GjCallList,Construct)
		return http;
	}
}

/// @function GJDataSet();
//This function will set the data stored in a global or user key. All data stored is converted into a string, so when fetching data be sure to reconvert to a real if needed.
/// @param Key The key of the data to set
/// @param Data to store in the key. Again, reguardless of type, it will be converted into a string, so be sure to convert it into a real after fetching if need be.
/// @param User Weither or not to set the user data or global data. This should be true or false. True for User, False for Global.
/// @param onAttemptFunction This is the function that will be called once the request is completed. Parameters: Success, ErrorMessage, RetryNumber
//onAttemptFunction - Success: Weither the request was successful or not.
//onAttemptFunction - ErrorMessage: error message, only supplied on failure.
//onAttemptFunction - RetryNumber: the current retry number, this number decreases till it reaches 0 from the supplied autoRetry amount. You can use this to display a "failed after [num] of retries" message. If autoRetry is set to -1, it will return the number of trys so far+1 * -1. So for example, if it was the 4th retry, it would return -5
/// @param autoRetry The number of times to automatically repeat the request if it fails. This can be set to 0 to never repeat, or -1 to repeat until successful.
function GJDataSet(Key, Data, User, onAttemptFunction, autoRetry) {
	var owner = id
	with(global.__GjControlObject) {
		var url="https://api.gamejolt.com/api/game/"+__GjVersion+"/data-store/set/?game_id="+__GjGameID+"&key="+string(Key)+"&data="+string(Data);
		if(User && __GjUsername != "") {
			url += "&username="+__GjUsername+"&user_token="+__GjGameToken
		} else {
			if(__GjUsername = "" && User) {
				show_debug_message("GJAPI ERROR= Failed to set user data, user is not logged in!")	
				exit;
			}
		}
		url+="&signature="+md5_string_utf8(url+__GjPrivateKey)
		var http=http_get(url);
		var Construct = {
			type:"Data",
			subtype:"Set",
			id:http,
			host:owner,
			toCall:onAttemptFunction,
			retry:autoRetry,
			key:Key,
			data:Data,
			user:User
		}
		ds_list_add(__GjCallList,Construct)
		return http;
	}
}

/// @function GJDataRemove();
//This function will delete the global or user key.
/// @param Key The key to remove
/// @param User Weither or not to remove from user data or global data. This should be true or false. True for User, False for Global.
/// @param onAttemptFunction This is the function that will be called once the request is completed. Parameters: Success, ErrorMessage, RetryNumber
//onAttemptFunction - Success: Weither the request was successful or not.
//onAttemptFunction - ErrorMessage: error message, only supplied on failure.
//onAttemptFunction - RetryNumber: the current retry number, this number decreases till it reaches 0 from the supplied autoRetry amount. You can use this to display a "failed after [num] of retries" message. If autoRetry is set to -1, it will return the number of trys so far+1 * -1. So for example, if it was the 4th retry, it would return -5
/// @param autoRetry The number of times to automatically repeat the request if it fails. This can be set to 0 to never repeat, or -1 to repeat until successful.
function GJDataRemove(Key, User, onAttemptFunction, autoRetry) {
	var owner = id
	with(global.__GjControlObject) {
		var url="https://api.gamejolt.com/api/game/"+__GjVersion+"/data-store/remove/?game_id="+__GjGameID+"&key="+string(Key);
		if(User && __GjUsername != "") {
			url += "&username="+__GjUsername+"&user_token="+__GjGameToken
		} else {
			if(__GjUsername = "" && User) {
				show_debug_message("GJAPI ERROR= Failed to remove user data, user is not logged in!")	
				exit;
			}
		}
		url+="&signature="+md5_string_utf8(url+__GjPrivateKey)
		var http=http_get(url);
		var Construct = {
			type:"Data",
			subtype:"Remove",
			id:http,
			host:owner,
			toCall:onAttemptFunction,
			retry:autoRetry,
			key:Key,
			user:User
		}
		ds_list_add(__GjCallList,Construct)
		return http;
	}
}

/// @function GJDataUpdate();
//This function will update the data in a global or user key. For more information check https://gamejolt.com/game-api/doc/data-store/update
/// @param Key The key to update
/// @param Opperation The type of opperation to perform, this can be append, prepend, add, subtract, multiply, or divide.
/// @param Value The value of the opperation. For example if opperation was "add" and value was 2, then this would add 2 to the given key
/// @param User Weither or not to opperate on user data or global data. This should be true or false. True for User, False for Global.
/// @param onAttemptFunction This is the function that will be called once the request is completed. Parameters: Success, ErrorMessage, RetryNumber
//onAttemptFunction - Success: Weither the request was successful or not.
//onAttemptFunction - ErrorMessage: error message, only supplied on failure.
//onAttemptFunction - RetryNumber: the current retry number, this number decreases till it reaches 0 from the supplied autoRetry amount. You can use this to display a "failed after [num] of retries" message. If autoRetry is set to -1, it will return the number of trys so far+1 * -1. So for example, if it was the 4th retry, it would return -5
/// @param autoRetry The number of times to automatically repeat the request if it fails. This can be set to 0 to never repeat, or -1 to repeat until successful.
function GJDataUpdate(Key, Opperation, Value, User, onAttemptFunction, autoRetry) {
	var owner = id
	with(global.__GjControlObject) {
		var url="https://api.gamejolt.com/api/game/"+__GjVersion+"/data-store/update/?game_id="+__GjGameID+"&key="+string(Key)+"&operation="+string(Opperation)+"&value="+string(Value);
		if(User && __GjUsername != "") {
			url += "&username="+__GjUsername+"&user_token="+__GjGameToken
		} else {
			if(__GjUsername = "" && User) {
				show_debug_message("GJAPI ERROR= Failed to remove user data, user is not logged in!")	
				exit;
			}
		}
		url+="&signature="+md5_string_utf8(url+__GjPrivateKey)
		var http=http_get(url);
		var Construct = {
			type:"Data",
			subtype:"Update",
			id:http,
			host:owner,
			toCall:onAttemptFunction,
			retry:autoRetry,
			key:Key,
			op:Opperation,
			val:Value,
			user:User
		}
		ds_list_add(__GjCallList,Construct)
		return http;
	}
}


/// @function GJDataGetKeys();
// ---------------LIST DATA--------------
//This function will return a ds_LIST with all of the keys in a global or user scope, with an optional Pattern if desired.
/// @param Pattern The pattern to apply to the key names in the data store. Set as "" to exclude patterns. For more information check https://gamejolt.com/game-api/doc/data-store/get-keys
/// @param User Weither or not to get the keys of user data or global data. This should be true or false. True for User, False for Global.
/// @param onAttemptFunction This is the function that will be called once the request is completed. Parameters: Success, DataList, ErrorMessage, RetryNumber
//onAttemptFunction - Success: Weither the request was successful or not.
//onAttemptFunction - DataList: ds_list containing all of the requested information, only supplied on success.
//onAttemptFunction - ErrorMessage: error message, only supplied on failure.
//onAttemptFunction - RetryNumber: the current retry number, this number decreases till it reaches 0 from the supplied autoRetry amount. You can use this to display a "failed after [num] of retries" message. If autoRetry is set to -1, it will return the number of trys so far+1 * -1. So for example, if it was the 4th retry, it would return -5
/// @param autoRetry The number of times to automatically repeat the request if it fails. This can be set to 0 to never repeat, or -1 to repeat until successful.
function GJDataGetKeys(Pattern, User, onAttemptFunction, autoRetry) {
	var owner = id
	with(global.__GjControlObject) {
		var url="https://api.gamejolt.com/api/game/"+__GjVersion+"/data-store/get-keys/?game_id="+__GjGameID;
		if(User && __GjUsername != "") {
			url += "&username="+__GjUsername+"&user_token="+__GjGameToken
		} else {
			if(__GjUsername = "" && User) {
				show_debug_message("GJAPI ERROR= Failed to remove user data, user is not logged in!")	
				exit;
			}
		}
		if(Pattern != "") {
			url += "&pattern="+string(Pattern);	
		}
		url+="&signature="+md5_string_utf8(url+__GjPrivateKey)
		var http=http_get(url);
		var Construct = {
			type:"Data",
			subtype:"GetKeys",
			id:http,
			host:owner,
			toCall:onAttemptFunction,
			retry:autoRetry,
			pattern:Pattern,
			user:User
		}
		ds_list_add(__GjCallList,Construct)
		return http;
	}
}

/// @function GJFriends();
// ---------------LIST DATA--------------
//This function will return a ds_LIST with all of the user ID's of the logged in user's friends
//(user needs to be logged in)
/// @param onAttemptFunction This is the function that will be called once the request is completed. Parameters: Success, DataList, ErrorMessage, RetryNumber
//onAttemptFunction - Success: Weither the request was successful or not.
//onAttemptFunction - DataList: ds_list containing all of the requested information, only supplied on success.
//onAttemptFunction - ErrorMessage: error message, only supplied on failure.
//onAttemptFunction - RetryNumber: the current retry number, this number decreases till it reaches 0 from the supplied autoRetry amount. You can use this to display a "failed after [num] of retries" message. If autoRetry is set to -1, it will return the number of trys so far+1 * -1. So for example, if it was the 4th retry, it would return -5
/// @param autoRetry The number of times to automatically repeat the request if it fails. This can be set to 0 to never repeat, or -1 to repeat until successful.
function GJFriends(onAttemptFunction, autoRetry) {
	var owner = id
	with(global.__GjControlObject) {
		if(__GjUsername != "") {
			var url="https://api.gamejolt.com/api/game/"+__GjVersion+"/friends/?game_id="+__GjGameID+"&username="+__GjUsername+"&user_token="+__GjGameToken;
			url+="&signature="+md5_string_utf8(url+__GjPrivateKey)
			var http=http_get(url);
			var Construct = {
				type:"Friends",
				id:http,
				host:owner,
				toCall:onAttemptFunction,
				retry:autoRetry
			}
			ds_list_add(__GjCallList,Construct)
			return http;
		} else {
			show_debug_message("GJAPI ERROR= Failed to list friends, user is not logged in!")		
		}
	}
}


///@function GJNetworking();
//This function doesn't require perameters, it should be used in the control object ONLY, call it in the Async - HTTP event, it controls all of the networking for GJ so make sure it's being called or all of your requests will not be handled properly.
function GJNetworking() {
	for(var i=0; i<ds_list_size(__GjCallList); i++) {
		var Construct = ds_list_find_value(__GjCallList,i)
		var CID = Construct.id
		if(ds_map_find_value(async_load, "status") <= 0 && ds_map_find_value(async_load, "id") = CID) {
				if(__DebugMode) {
					show_debug_message(ds_map_find_value(async_load, "result"))
				}
				if(ds_map_find_value(async_load, "status") = 0) {
					var ResultMap = json_decode(ds_map_find_value(async_load, "result"));
					var response = ds_map_find_value(ResultMap,"response")
					var success = ds_map_find_value(response,"success")
					var errorMessage = "";
					switch(success) {
						case"true":
						success = 1
						break;
						case"false":
						success = 0
						errorMessage = ds_map_find_value(response,"message")
						break;
					}
				} else {
					var success = 0
					var errorMessage = "Non-GameJolt related error: "+string(ds_map_find_value(async_load, "status"))+" ["+Construct.type+"]"
				}
				
				ds_list_delete(__GjCallList,i)
				switch(Construct.type) {
					case"Login":
						if(success) {
							__GjUsername = __GjTempUsername
							__GjTempUsername = ""
						} else {
							if(Construct.retry != 0 && errorMessage != "No such user with the credentials passed in could be found.") {
								Construct.retry --
								with(Construct.host) {
									GJLogin(Construct.uName,Construct.gToken,Construct.toCall,Construct.retry)
								}
							}
						}
						with(Construct.host) {
							if(Construct.toCall != -1)  { Construct.toCall(success, errorMessage,Construct.retry) }
						}
					break;
					case"FetchUser":
						var users = -1;
						if(success) {
							var users = ds_map_create()
							ds_map_copy(users,ds_list_find_value(ds_map_find_value(response,"users"),0))
						} else {
							if(Construct.retry != 0) {
								Construct.retry --
								with(Construct.host) {
									GJUserFetch(Construct.iType,Construct.user,Construct.toCall,Construct.retry)
								}
							}
						}
						with(Construct.host) {
							if(Construct.toCall != -1)  { Construct.toCall( success, users, errorMessage,Construct.retry) }
						}
					break;
					case"Session":
						if(!success) {
							if(Construct.retry != 0) {
								Construct.retry --
								with(Construct.host) {
									GJSessionUpdate(Construct.subtype,Construct.status,Construct.toCall,Construct.retry)
								}
							}
						}
						with(Construct.host) {
							if(Construct.toCall != -1) { Construct.toCall(success,errorMessage,Construct.retry); }
						}
					break;
					case"Score":
						var scoreType = Construct.subtype;
						switch(scoreType) {
							case"Add":
							if(!success) {
								if(Construct.retry != 0) {
									Construct.retry --
									with(Construct.host) {
										GJScoreAdd(Construct.sb,Construct.sort,Construct.displayName,Construct.eData,Construct.gName,Construct.toCall,Construct.retry)
									}
								}
							}
							with(Construct.host) {
								if(Construct.toCall != -1) { Construct.toCall(success,errorMessage,Construct.retry); }
							}
							break;
							case"Rank":
							var rank = -1;
							if(success) {
								rank = ds_map_find_value(response,"rank")
							} else {
								if(Construct.retry != 0) {
									Construct.retry --
									with(Construct.host) {
										GJScoreRank(Construct.sb,Construct.sort,Construct.toCall,Construct.retry)
									}
								}
							}
							with(Construct.host) {
								if(Construct.toCall != -1)  { Construct.toCall(success,rank,errorMessage,Construct.retry) }
							}
							break;
							default: //Default resort (for fetch and table command since they generally do the same thing)
							var scores = -1;
							if(success) { 
								//Duplicating the scores to a new list so it will not be effected by the map deletion later.
								var type = "scores"
								if(scoreType = "Tables") { type = "tables" }
								scores = ds_map_find_value(response,type)
								var NewScores = ds_list_create()
								if(scores != "") {
									for(var i=0; i<ds_list_size(scores); i+=1) {
										var this = ds_list_find_value(scores,i)	
										var newmap =ds_map_create()
										ds_map_copy(newmap,this)
										ds_list_add(NewScores,newmap)
										ds_list_mark_as_map(NewScores,ds_list_size(NewScores)-1)
									}
								}
								scores = NewScores
							} else {
								if(Construct.retry != 0) {
									Construct.retry --
									if(Construct.subtype = "Fetch") {
										with(Construct.host) {
											GJScoreFetch(Construct.sb,Construct.limit,Construct.bThan,Construct.wThan,Construct.gName,Construct.toCall,Construct.retry)
										}
									} else {
										with(Construct.host) {
											GJScoreTables(Construct.toCall,Construct.retry)
										}
									}
								}
							}	
							with(Construct.host) {
								if(Construct.toCall != -1) { Construct.toCall(success,scores,errorMessage,Construct.retry); }
							}
							break;
						}
					break;
					case"Trophy":
						switch(Construct.subtype) {
							case"Fetch":
								var trophies = -1;
								if(success) { 
									//Duplicating the trophies to a new list so it will not be effected by the map deletion later.
									trophies = ds_map_find_value(response,"trophies")
									var newTrophies = ds_list_create()
									if(trophies != "") {
										for(var i=0; i<ds_list_size(trophies); i+=1) {
											var this = ds_list_find_value(trophies,i)	
											var newmap =ds_map_create()
											ds_map_copy(newmap,this)
											ds_list_add(newTrophies,newmap)
											ds_list_mark_as_map(newTrophies,ds_list_size(newTrophies)-1)
										}
									}
									trophies = newTrophies
								} else {
									if(Construct.retry != 0) {
										Construct.retry --
										with(Construct.host) {
											GJTrophyFetch(Construct.tID,Construct.achieved,Construct.toCall,Construct.retry)
										}
									}
								}
								with(Construct.host) {
									if(Construct.toCall != -1) { Construct.toCall(success,trophies,errorMessage,Construct.retry); }
								}
							break;
							default: //Add or remove
								if(!success) {
									if(Construct.retry != 0) {
										Construct.retry --
										with(Construct.host) {
											GJTrophyUpdate(Construct.tID,Construct.achieved,Construct.toCall,Construct.retry)
										}
									}
								}
								with(Construct.host) {
									if(Construct.toCall != -1) { Construct.toCall(Construct.subtype,success,errorMessage,Construct.retry); }
								}
							break;
						}
					break;
					case"Data":
						switch(Construct.subtype) {
							case"Fetch":
								var data = ""
								if(success) {
									data = 	ds_map_find_value(response,"data")
								} else {
									if(Construct.retry != 0) {
										Construct.retry --
										with(Construct.host) {
											GJDataFetch(Construct.key,Construct.user,Construct.toCall,Construct.retry)
										}
									}	
								}
								with(Construct.host) {
									if(Construct.toCall != -1) { Construct.toCall(success,data,errorMessage,Construct.retry) }
								}
							break;
							default:
								if(!success) {
									if(Construct.retry != 0) {
										Construct.retry --
										with(Construct.host) {
											switch(Construct.subtype) {
												case"Set":
													with(Construct.host) {
														GJDataSet(Construct.key,Construct.data,Construct.user,Construct.toCall,Construct.retry)
													}
												break;
												case"Remove":
													with(Construct.host) {
														GJDataRemove(Construct.key,Construct.user,Construct.toCall,Construct.retry)
													}
												break;
												case"Update":
													with(Construct.host) {
														GJDataUpdate(Construct.key,Construct.op,Construct.val,Construct.user,Construct.toCall,Construct.retry)
													}
												break;
											}
										}
									}	
								}
								with(Construct.host) {
									if(Construct.toCall != -1) { Construct.toCall(success,errorMessage,Construct.retry) }
								}
							break;
							case"GetKeys":
								var dataList = -1;
								if(success) {
									dataList = ds_list_create()
									var keys = ds_map_find_value(response,"keys")
									if(keys != "") {
										for(var i=0; i<ds_list_size(keys); i+=1) { //Add all of the key names to a list if successful
											ds_list_add(dataList,ds_map_find_value(ds_list_find_value(keys,i),"key"))
										}
									}
								} else {
									if(Construct.retry != 0) {
										Construct.retry --
										with(Construct.host) {
											GJDataGetKeys(Construct.pattern,Construct.user,Construct.toCall,Construct.retry)
										}
									}
								}
								with(Construct.host) {
									if(Construct.toCall != -1) { Construct.toCall(success,dataList,errorMessage,Construct.retry) }
								}
							break;
						}
					break;
					case"Friends":
						var dataList = -1;
						if(success) {
							dataList = ds_list_create()
							var friends = ds_map_find_value(response,"friends")
							if(friends != "") {
								for(var i=0; i<ds_list_size(friends); i+=1) { //Add all of the key names to a list if successful
									ds_list_add(dataList,ds_map_find_value(ds_list_find_value(friends,i),"friend_id"))
								}
							}
						} else {
							if(Construct.retry != 0) {
								Construct.retry --
								with(Construct.host) {
									GJFriends(Construct.toCall,Construct.retry)
								}
							}
						}
						with(Construct.host) {
							if(Construct.toCall != -1) { Construct.toCall(success,dataList,errorMessage,Construct.retry) }
						}
					break;
				}
			
			if(success) {
				ds_map_destroy(ResultMap)
			}
			delete Construct;
			break;
	   }
	}
}