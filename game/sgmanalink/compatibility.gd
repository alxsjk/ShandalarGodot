class_name SgCompatibility
extends RefCounted
## Portable compatibility stamp, not authentication or cheat detection.
## Bump RULES_REVISION whenever engine/card behavior changes without a release
## version change. The catalogue digest additionally pins printed definitions.

const RULES_REVISION := "sgmanalink-packs-2026-09-16-3"
static var _fingerprint := ""
static var _cache_key := ""

static func fingerprint() -> String:
	CardRegistry.ensure_loaded()
	var cache_key := str([CardRegistry.revision, SgProtocol.VERSION, RULES_REVISION,
		ProjectSettings.get_setting("application/config/version", "")])
	if _cache_key == cache_key and not _fingerprint.is_empty(): return _fingerprint
	var names: Array = CardRegistry._cards.keys()
	names.sort()
	var catalogue: Array = []
	for name in names:
		var card := CardRegistry.get_card(name)
		catalogue.append([name, str(card.cost), card.oracle_text, card.types, card.power, card.toughness])
	_fingerprint = JSON.stringify([SgProtocol.VERSION, RULES_REVISION,
		ProjectSettings.get_setting("application/config/version", ""), catalogue]).sha256_text()
	_cache_key = cache_key
	return _fingerprint
