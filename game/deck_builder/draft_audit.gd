class_name DraftAudit
extends RefCounted
## [QoL] Bounded, read-only deck membership checks against a saved dealt pool.
## A local receipt is evidence to compare, not a signature or trusted referee.

const MAX_CARDS := 1110 # 12 boosters + 12 starters + 150 lands + 60 extras.
const POOL_BYTES := 1048576
const DECK_BYTES := DraftRecipe.MAX_BYTES
const TRUST_NOTE := "Checks pool membership, not deck-format legality or identity. The organiser must retain the original pool or fingerprint before building. A recipe or hash supplied afterwards can be replaced by the player."


static func check_files(pool_path: String, deck_path: String, expected_fingerprint := "") -> Dictionary:
	var pool := _read(pool_path, POOL_BYTES)
	if not pool.ok: return pool
	var deck := _read(deck_path, DECK_BYTES)
	if not deck.ok: return deck
	var json := JSON.new()
	if json.parse(pool.text) != OK: return _failure("Invalid JSON in draft pool file.")
	return check(json.data, deck.text, expected_fingerprint)


static func reconstruct_file(deck_path: String, expected_fingerprint := "") -> Dictionary:
	var deck := _read(deck_path, DECK_BYTES)
	if not deck.ok: return deck
	return reconstruct_text(deck.text, expected_fingerprint)


static func reconstruct_text(text: String, expected_fingerprint := "") -> Dictionary:
	var embedded := DraftRecipe.from_text(text)
	if not embedded.ok: return embedded
	var replay := DraftRecipe.reconstruct(embedded.recipe)
	if not replay.ok: return replay
	var receipt := {"schema": 1, "counts": replay.pool.counts, "packs": replay.pool.packs, "recipe": embedded.recipe}
	var result := check(receipt, text, expected_fingerprint)
	if not result.ok: return result
	result["receipt"] = receipt
	var options: Dictionary = embedded.recipe.options
	result.message += "\n\nReconstructed from seed: %s\n%d boosters · %d starters · %d extra lands per type · %d random extras · %d minutes\nFingerprint: %s" % [
		embedded.recipe.seed, int(options.boosters), int(options.starters), int(options.free_lands), int(options.extras), int(options.minutes), embedded.recipe.fingerprint]
	result.message += "\nMatches the judge's retained fingerprint." if expected_fingerprint != "" else "\nUnanchored replay: no pre-draft fingerprint was supplied."
	for pack in replay.pool.packs:
		result.message += "\n\n%s (%d cards)\n%s" % [pack.title, pack.cards.size(), ", ".join(pack.cards)]
	return result


static func _read(path: String, limit: int) -> Dictionary:
	if path.is_empty(): return _failure("Choose both a saved pool and a deck.")
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return _failure("Cannot read " + path.get_file() + ".")
	if file.get_length() > limit:
		file.close()
		return _failure("File is too large for a draft check: " + path.get_file())
	var text := file.get_as_text()
	var error := file.get_error()
	file.close()
	if error != OK: return _failure("Could not finish reading " + path.get_file() + ".")
	return {"ok": true, "text": text}


static func check(receipt: Variant, deck_text: String, expected_fingerprint := "") -> Dictionary:
	var refusal := pool_refusal(receipt)
	if refusal != "": return _failure(refusal)
	if deck_text.to_utf8_buffer().size() > DECK_BYTES:
		return _failure("Deck file is too large for a draft check.")
	if receipt.has("recipe"):
		var replay := DraftRecipe.reconstruct(receipt.recipe)
		if not replay.ok: return replay
		if DraftRecipe.pack_hash(receipt.packs) != receipt.recipe.pool_sha256:
			return _failure("Saved pack contents do not match the reconstructed recipe.")
		var embedded := DraftRecipe.from_text(deck_text)
		if not embedded.ok: return embedded
		if DraftRecipe.fingerprint(embedded.recipe) != receipt.recipe.fingerprint \
				or embedded.recipe.fingerprint != receipt.recipe.fingerprint:
			return _failure("Deck recipe does not match the original pool's fingerprint.")
		if expected_fingerprint != "" and (not DraftRecipe.digest(expected_fingerprint) or expected_fingerprint != receipt.recipe.fingerprint):
			return _failure("Draft fingerprint does not match the judge's retained fingerprint.")
	elif expected_fingerprint != "":
		return _failure("This older pool has no reconstruction fingerprint.")
	# Bound expanded counts BEFORE invoking the shared text-deck parser.
	var total := 0
	for raw in deck_text.split("\n"):
		var line := raw.strip_edges()
		if line.is_empty() or line.begins_with("#") or line.begins_with("//") or line.begins_with("name:"):
			continue
		if line.to_upper().begins_with("SB:"): line = line.substr(3).strip_edges()
		var space := line.find(" ")
		var token := line.substr(0, space) if space > 0 else ""
		if token.to_lower().ends_with("x"): token = token.left(-1)
		if not token.is_valid_int() or token.length() > 4 or token.to_int() < 1:
			return _failure("Invalid deck card count. Choose a native .deck or .dec text file.")
		total += token.to_int()
		if total > MAX_CARDS: return _failure("Deck and sideboard exceed the largest possible draft pool.")
	var deck := DeckList.new()
	deck.parse(deck_text)
	if not deck.errors.is_empty():
		return _failure("Invalid deck: " + deck.errors[0])
	var used: Dictionary = {}
	for card_name in deck.cards + deck.sideboard:
		used[card_name] = int(used.get(card_name, 0)) + 1
	var problems: Array[String] = []
	for card_name in used:
		var allowed := int(receipt.counts.get(card_name, 0))
		if used[card_name] > allowed:
			problems.append("%s: %d in deck + sideboard; %d in pool." % [card_name, used[card_name], allowed])
	if not problems.is_empty(): return _failure("Outside the saved pool:\n" + "\n".join(problems))
	return {"ok": true, "message": "Pool membership matches: %d main-deck cards and %d sideboard cards.\nEvery card and copy is accounted for." % [deck.cards.size(), deck.sideboard.size()]}


static func pool_refusal(receipt: Variant) -> String:
	if not receipt is Dictionary or not _whole(receipt.get("schema"), 1) or receipt.schema != 1:
		return "Invalid or unsupported draft pool file."
	var counts: Variant = receipt.get("counts")
	var packs: Variant = receipt.get("packs")
	if not counts is Dictionary or counts.is_empty() or counts.size() > MAX_CARDS \
			or not packs is Array or packs.is_empty() or packs.size() > 26:
		return "Invalid pool counts or pack list."
	CardRegistry.ensure_loaded()
	var expected: Dictionary = {}
	var total := 0
	for card_name in counts:
		if not card_name is String or not CardRegistry.has_card(card_name) or not _whole(counts[card_name], MAX_CARDS):
			return "Pool contains an unknown card or an invalid quantity."
		expected[card_name] = int(counts[card_name])
		total += int(counts[card_name])
	if total > MAX_CARDS: return "Pool exceeds the largest supported draft."
	var actual: Dictionary = {}
	var dealt := 0
	for pack in packs:
		if not pack is Dictionary or not pack.get("title") is String or not pack.get("cards") is Array:
			return "Invalid pack contents in pool file."
		dealt += pack.cards.size()
		if dealt > MAX_CARDS: return "Pack contents exceed the largest supported draft."
		for card_name in pack.cards:
			if not card_name is String or not expected.has(card_name): return "Pack contents do not match pool counts."
			actual[card_name] = int(actual.get(card_name, 0)) + 1
	if actual != expected: return "Pack contents do not match pool counts."
	return ""


static func _whole(value: Variant, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) \
		and float(value) == floor(float(value)) and value >= 1 and value <= maximum


static func _failure(message: String) -> Dictionary:
	return {"ok": false, "message": message}
