class_name SgIdentity
extends RefCounted
## [QoL] A local display-name preference, NOT a cryptographic account.
## Saving never stores invitations, private keys or seat-resumption tokens.

const KEY := "sgmanalink_nickname"
const ADJECTIVES := ["Amber", "Ancient", "Azure", "Bright", "Copper", "Emerald", "Silver", "Wild"]
const NOUNS := ["Drake", "Falcon", "Fox", "Mage", "Owl", "Raven", "Wisp", "Wolf"]


static func remembered_name() -> String:
	var value: Variant = Settings.get_value(KEY, "")
	return value if SgProtocol.nickname(value) else ""


static func generate_name() -> String:
	# This is presentation randomness, independent of every duel's rules RNG.
	var bytes := Crypto.new().generate_random_bytes(4)
	if bytes.size() != 4:
		return "Wandering Mage"
	return "%s %s %03d" % [ADJECTIVES[bytes[0] % ADJECTIVES.size()],
		NOUNS[bytes[1] % NOUNS.size()], (int(bytes[2]) * 256 + int(bytes[3])) % 1000]


static func save_name(value: String, remember: bool) -> String:
	var nickname := value.strip_edges()
	if not SgProtocol.nickname(nickname):
		return "Use up to 20 letters, numbers, spaces, - or _."
	if remember and not nickname.is_empty():
		Settings.set_value(KEY, nickname)
	else:
		Settings.clear_value(KEY)
	return "Could not save the name preference. Please try again." if Settings.is_dirty() else ""
