class_name GSFriendRequest
extends RefCounted

## One pending friend request, as [code]GET friends/requests[/code] returns it.
##
## [member id] is an integer because the site's [code]UserFriendship.id[/code] is one, and
## [code]POST friends/respond[/code] sends it back as [code]requestId[/code]. A string id
## sent to a route whose schema says number is refused — so it is kept as the type the site
## gave, not as whatever would be convenient here.
##
## [member user_id] is the OTHER person: the sender of an incoming request, the addressee of
## an outgoing one. That is how the site shapes both lists.

var id: int = 0
var user_id: String = ""
var display_name: String = ""

## Unix seconds.
var created_at: int = 0

## True when this player sent it.
var outgoing: bool = false


static func from_dict(d: Dictionary, p_outgoing: bool = false) -> GSResult:
	var r := GSFriendRequest.new()
	r.id = GSPresence._int(d.get("id"))
	r.user_id = GSPresence._str(d.get("userId"))
	if r.id <= 0 or r.user_id == "":
		return GSResult.fail(GSError.CODE_PARSE, "a friend request with no id or no person", str(d))
	r.display_name = GSPresence._str(d.get("displayName"))
	r.created_at = GSPresence.parse_time(d.get("createdAt"))
	r.outgoing = p_outgoing
	return GSResult.success(r)


## Reads [code]{incoming: [...], outgoing: [...]}[/code] into
## [code]{"incoming": Array[GSFriendRequest], "outgoing": Array[GSFriendRequest]}[/code].
static func lists_from(v: Variant) -> GSResult:
	if not (v is Dictionary):
		return GSResult.fail(GSError.CODE_PARSE, "The friend requests are not an object.")
	var d: Dictionary = v
	var incoming: Array[GSFriendRequest] = []
	var outgoing_list: Array[GSFriendRequest] = []
	for pair in [["incoming", false], ["outgoing", true]]:
		var rows: Variant = d.get(pair[0])
		if not (rows is Array):
			continue
		for row in (rows as Array):
			if not (row is Dictionary):
				continue
			var parsed := GSFriendRequest.from_dict(row as Dictionary, bool(pair[1]))
			if not parsed.ok:
				continue
			if pair[1]:
				outgoing_list.append(parsed.value)
			else:
				incoming.append(parsed.value)
	return GSResult.success({"incoming": incoming, "outgoing": outgoing_list})


func to_dict() -> Dictionary:
	return {
		"id": id,
		"userId": user_id,
		"displayName": display_name,
		"createdAt": GSPresence.format_time(created_at),
	}


func describe() -> String:
	return "#%d %s %s (%s)" % [id, "to" if outgoing else "from", display_name, user_id]
