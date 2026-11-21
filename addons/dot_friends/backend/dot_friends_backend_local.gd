class_name GSFriendsBackendLocal
extends GSFriendsBackend

## One person's view of a [GSFriendsLocalHub]. Get one with [method GSFriendsLocalHub.as_user].
##
## Carries the app this person is playing, because on the site that comes from the token
## rather than from the post — a client cannot claim to be in a game it is not.

var hub: GSFriendsLocalHub = null
var user_id: String = ""
var app_id: int = 0
var app_name: String = ""


func _init(p_hub: GSFriendsLocalHub = null, p_user_id: String = "", p_app_id: int = 0, p_app_name: String = "") -> void:
	hub = p_hub
	user_id = p_user_id
	app_id = p_app_id
	app_name = p_app_name


func friends() -> GSResult:
	return hub.friends_of(user_id)


func requests() -> GSResult:
	return hub.requests_of(user_id)


func send_request(target: String) -> GSResult:
	return hub.send_request(user_id, target)


func respond(request_id: int, accept: bool) -> GSResult:
	return hub.respond(user_id, request_id, accept)


func cancel_request(request_id: int) -> GSResult:
	return hub.cancel_request(user_id, request_id)


func remove_friend(target: String) -> GSResult:
	return hub.remove_friend(user_id, target)


func post_presence(body: Dictionary) -> GSResult:
	return hub.post_presence(user_id, body, app_id, app_name)


func fetch_presence(user_ids: PackedStringArray) -> GSResult:
	return hub.presence_for(user_id, user_ids)


func describe() -> String:
	return "local friends hub, as %s" % user_id
