class_name SgCompatibility
extends RefCounted
## Portable compatibility stamp, not authentication or cheat detection.
## Bump RULES_REVISION whenever engine/card behavior changes without a release
## version change. The catalogue digest additionally pins printed definitions.

const RULES_REVISION := "sgmanalink-2026-09-15-1"
static var _fingerprint := ""

static func fingerprint() -> String:
	if not _fingerprint.is_empty(): return _fingerprint
	CardRegistry.ensure_loaded()
	var names: Array = CardRegistry._cards.keys()
	names.sort()
	var catalogue: Array = []
	for name in names:
		var card := CardRegistry.get_card(name)
		catalogue.append([name, str(card.cost), card.oracle_text, card.types, card.power, card.toughness])
	_fingerprint = JSON.stringify([SgProtocol.VERSION, RULES_REVISION,
		ProjectSettings.get_setting("application/config/version", ""), catalogue]).sha256_text()
	return _fingerprint
