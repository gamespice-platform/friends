class_name GSFriend
extends RefCounted

## One accepted friend, and where they are, as [code]GET friends[/code] returns them.
##
## [member user_id] is the backbone's user id — the same string GameSpice Party's members carry
## and the one a GameSpice Server session sees as [code]backbone:<user_id>[/code]. Friends are
## matched by it and never by name, because a display name is the one field a stranger
## can copy.

var user_id: String = ""
var display_name: String = ""

## Empty when the site has none for them.
var avatar_url: String = ""

var presence: GSPresence = GSPresence.new()


static func of(p_user_id: String, p_name: String, p_presence: GSPresence = null) -> GSFriend:
	var f := GSFriend.new()
	f.user_id = p_user_id
	f.display_name = p_name
	f.presence = p_presence if p_presence != null else GSPresence.offline()
	return f


## Reads one row of [code]GET friends[/code]. A row with no user id is refused rather than
## kept: it could never be matched against a presence, a request or a party member.
static func from_dict(d: Dictionary) -> GSResult:
	var f := GSFriend.new()
	f.user_id = GSPresence._str(d.get("userId"))
	if f.user_id == "":
		return GSResult.fail(GSError.CODE_PARSE, "a friend with no user id", str(d))
	f.display_name = GSPresence._str(d.get("displayName"))
	f.avatar_url = GSPresence._str(d.get("avatarUrl"))
	f.presence = GSPresence.from_dict(d.get("presence"))
	return GSResult.success(f)


## Reads the whole [code]GET friends[/code] array. One bad row is skipped rather than
## failing the list: a friends list missing one person is still a friends list, and one
## that fails outright shows nobody.
static func list_from(v: Variant) -> GSResult:
	if not (v is Array):
		return GSResult.fail(GSError.CODE_PARSE, "The friends list is not a list.")
	var out: Array[GSFriend] = []
	for row in (v as Array):
		if not (row is Dictionary):
			continue
		var parsed := GSFriend.from_dict(row as Dictionary)
		if parsed.ok:
			out.append(parsed.value)
	return GSResult.success(out)


func to_dict() -> Dictionary:
	return {
		"userId": user_id,
		"displayName": display_name,
		"avatarUrl": avatar_url if avatar_url != "" else null,
		"presence": presence.to_dict(),
	}


func copy() -> GSFriend:
	return GSFriend.from_dict(to_dict()).value


func is_online() -> bool:
	return presence.is_online()


func describe() -> String:
	return "%s (%s): %s" % [display_name, user_id, presence.describe()]
