extends Node
## Numbered GAMEPLAY CARD PACKS — discovery, validation and the player's
## enable/disable choice. These are not general `SkinPack` archives: Pack 1
## carries metadata and its 373 set entries' art, while the four implementations
## it unlocks ship dormant inside the trusted game build.

signal changed(id: String, enabled: bool)
signal rescanned

const ID := "pack-1"
const FILE_NAME := "Pack-1-DotP-complete.zip"
const PACK_VERSION := "1.0.0"
const MINIMUM_GAME_VERSION := "0.20.0"
const PREFIX := "card_packs/pack_1_dotp_complete/"
const MANIFEST := PREFIX + "manifest.json"
const CATALOG := PREFIX + "catalog.json"
const CARDS := PREFIX + "cards.json"
const README := PREFIX + "README.txt"
const EXPECTED_FILES := [MANIFEST, CATALOG, CARDS, README]
const EXPECTED_COUNTS := {
	"published_printings": 1305,
	"named_set_entries": 1270,
	"distinct_cards": 901,
	"pack_card_entries": 373,
	"reprint_entries": 369,
	"new_rules_identities": 4,
}
const EXPECTED_SET_COUNTS := {
	"2ed": [292, 302], "arn": [78, 78], "atq": [85, 100],
	"leg": [310, 310], "drk": [119, 119], "4ed": [368, 378],
	"past": [12, 12], "phpr": [6, 6],
}
const ADDED_NAMES := ["Chaos Orb", "Word of Command", "Shahrazad", "Falling Star"]
const CARD_SCRIPTS := [
	{"name": "Chaos Orb", "set": "2ed",
		"path": "res://cards/optional/pack_1/chaos_orb.gd"},
	{"name": "Word of Command", "set": "2ed",
		"path": "res://cards/optional/pack_1/word_of_command.gd"},
	{"name": "Shahrazad", "set": "arn",
		"path": "res://cards/optional/pack_1/shahrazad.gd"},
	{"name": "Falling Star", "set": "leg",
		"path": "res://cards/optional/pack_1/falling_star.gd"},
]

var _available: Dictionary = {}
var _rejections: Array[Dictionary] = []
var _art_cache: Dictionary = {}
var _current_deck_names: Array[String] = []


func _ready() -> void:
	discover()
	_configure_registry()


## Search the explicit test/developer path first, then the player's card
## folder, a portable game's folder, and the checkout's sibling build dir.
## The first valid exact-name ZIP wins.
func discover() -> void:
	_available.clear()
	_rejections.clear()
	_art_cache.clear()
	for path in candidate_paths() + candidate_paths(FallenEmpiresPack.ID) + candidate_paths(IceAgePack.ID):
		if not FileAccess.file_exists(path):
			continue
		var id := FallenEmpiresPack.ID if path.get_file() == FallenEmpiresPack.FILE_NAME else ID
		if path.get_file() == IceAgePack.FILE_NAME:
			id = IceAgePack.ID
		if _available.has(id):
			continue
		var report := inspect(path)
		if bool(report.get("ok", false)):
			if bool(report.get("has_art", false)) \
					and not ProjectSettings.load_resource_pack(path, false):
				var why := "its metadata is valid but its artwork could not be mounted"
				_rejections.append({"id": id, "path": path, "why": why})
				push_warning("card pack: %s refused — %s" % [path, why])
				continue
			_available[id] = report
			print("card pack: found %s" % path)
			continue
		_rejections.append({"id": id, "path": path, "why": report.get("why", "invalid")})
		push_warning("card pack: %s refused — %s" % [path, report.get("why", "invalid")])


## Re-read the configured folder immediately. An enabled id remains in
## Settings when its ZIP is absent or invalid, so repairing the file and
## pressing Rescan brings it back without making the player enable it twice.
func rescan() -> void:
	discover()
	_configure_registry()
	CardRegistry.ensure_loaded()
	rescanned.emit()


static func candidate_paths(id := ID) -> Array[String]:
	var out: Array[String] = []
	var file_name := file_name_for(id)
	var explicit := OS.get_environment("SHANDALAR_PACK_" + id.trim_prefix("pack-")).strip_edges()
	if explicit != "":
		out.append(explicit)
	var card_folder := GamePaths.cardpacks_folder().path_join(file_name)
	if not out.has(card_folder):
		out.append(card_folder)
	var beside := GamePaths.executable_dir(OS.get_executable_path(),
		OS.has_feature("macos"))
	for path in [beside.path_join(file_name),
			beside.path_join("cardpacks").path_join(file_name)]:
		if not out.has(path):
			out.append(path)
	if not OS.has_feature("standalone"):
		var checkout := ProjectSettings.globalize_path("res://").trim_suffix("/")
		var development := checkout.get_base_dir().path_join(
			"shandalar-packs").path_join(file_name)
		if not out.has(development):
			out.append(development)
	return out


## Validate the exact Pack 1 contract before trusting any catalog data. A
## metadata-only build is accepted only by the isolated test profile; a pack a
## player can enable carries the exact 754 expected image paths and still no code.
static func inspect(path: String) -> Dictionary:
	if path.get_file() == IceAgePack.FILE_NAME:
		return IceAgePack.inspect(path)
	if path.get_file() == FallenEmpiresPack.FILE_NAME:
		return FallenEmpiresPack.inspect(path)
	if path.get_file() != FILE_NAME:
		return _refusal("must be named exactly " + FILE_NAME)
	var reader := ZIPReader.new()
	if reader.open(path) != OK:
		return _refusal("not a ZIP file")
	var names := Array(reader.get_files())
	names.sort()
	for required in EXPECTED_FILES:
		if not names.has(required):
			reader.close()
			return _refusal("its file list is not the Pack 1 layout")
	for name in names:
		if (not String(name).begins_with(PREFIX) \
				and not String(name).begins_with("skin/cardart/")) \
				or String(name).contains("..") or String(name).contains("\\"):
			reader.close()
			return _refusal("unsafe ZIP entry: " + String(name))
	var manifest_bytes := reader.read_file(MANIFEST)
	var catalog_bytes := reader.read_file(CATALOG)
	var cards_bytes := reader.read_file(CARDS)
	var readme_bytes := reader.read_file(README)
	var manifest: Variant = JSON.parse_string(manifest_bytes.get_string_from_utf8())
	var catalog: Variant = JSON.parse_string(catalog_bytes.get_string_from_utf8())
	var cards: Variant = JSON.parse_string(cards_bytes.get_string_from_utf8())
	if not (manifest is Dictionary) or not (catalog is Dictionary) or not (cards is Array):
		reader.close()
		return _refusal("one of its JSON files cannot be read")
	var metadata := EXPECTED_FILES.duplicate()
	metadata.sort()
	var complete := EXPECTED_FILES.duplicate()
	complete.append_array(_expected_art_files(cards))
	complete.sort()
	if names != metadata and names != complete:
		reader.close()
		return _refusal("its file list is not the Pack 1 layout")
	if names == metadata and not OS.has_feature("shandalar_test"):
		reader.close()
		return _refusal("its 754 Pack 1 art files are missing")
	var checksums: Variant = manifest.get("checksums", {})
	var metadata_hashes := {
		"catalog.json": _sha256(catalog_bytes),
		"cards.json": _sha256(cards_bytes),
		"README.txt": _sha256(readme_bytes),
	}
	if not (checksums is Dictionary) \
			or checksums.get("algorithm", "") != "sha256" \
			or checksums.get("metadata", {}) != metadata_hashes:
		reader.close()
		return _refusal("its metadata checksum does not match")
	var artwork: Variant = checksums.get("artwork", {})
	var art_names: Array = []
	for name in names:
		if not metadata.has(name):
			art_names.append(name)
	if not (artwork is Dictionary) \
			or int(artwork.get("files", -1)) != art_names.size() \
			or String(artwork.get("sha256", "")) != _artwork_sha256(reader, art_names):
		reader.close()
		return _refusal("its artwork checksum does not match")
	var version := String(manifest.get("version", ""))
	var minimum := String(manifest.get("minimum_game_version", ""))
	var game_version := String(ProjectSettings.get_setting(
		"application/config/version", "0.0.0"))
	if not _valid_version(version) or not _valid_version(minimum):
		reader.close()
		return _refusal("its version fields are invalid")
	if _version_less(game_version, minimum):
		reader.close()
		return _refusal("requires game version %s or newer (this is %s)" % [
			minimum, game_version])
	reader.close()
	if manifest.get("pack_format", 0) != 1 or manifest.get("id", "") != ID \
			or manifest.get("file_name", "") != FILE_NAME:
		return _refusal("its manifest does not identify Pack 1")
	if manifest.get("new_rules_identities", []) != ADDED_NAMES:
		return _refusal("its four new rules identities do not match Pack 1")
	if not _counts_match(manifest.get("counts", {})) \
			or not _counts_match(catalog.get("counts", {})) \
			or catalog.get("pack_id", "") != ID:
		return _refusal("its published counts do not match Pack 1")
	var sets: Variant = catalog.get("sets", {})
	if not (sets is Dictionary):
		return _refusal("its set catalog is missing")
	var catalog_pairs := {}
	var distinct := {}
	for code in CardRegistry.SET_ORDER:
		var one: Variant = sets.get(code, {})
		if not (one is Dictionary) or not (one.get("names", null) is Array):
			return _refusal("its %s checklist is missing" % code)
		var names_in_set: Array = one["names"]
		var expected: Array = EXPECTED_SET_COUNTS[code]
		if names_in_set.size() != int(expected[0]) \
				or int(one.get("named_cards", -1)) != int(expected[0]) \
				or int(one.get("published_printings", -1)) != int(expected[1]):
			return _refusal("its %s checklist has the wrong counts" % code)
		var local := {}
		for value in names_in_set:
			var card_name := String(value)
			if card_name == "" or local.has(card_name):
				return _refusal("its %s checklist has an invalid name" % code)
			local[card_name] = true
			distinct[card_name] = true
			catalog_pairs[code + "|" + card_name] = true
	if catalog_pairs.size() != 1270 or distinct.size() != 901:
		return _refusal("its set checklists do not total Pack 1")
	if cards.size() != 373:
		return _refusal("it does not contain 373 Pack 1 card entries")
	var got_names: Array[String] = []
	var pairs := {}
	for row in cards:
		if not (row is Dictionary):
			return _refusal("one of its Pack 1 card entries is invalid")
		var card_name := String(row.get("name", ""))
		var code := String(row.get("set", ""))
		var pair := code + "|" + card_name
		if card_name == "" or not EXPECTED_SET_COUNTS.has(code) \
				or not catalog_pairs.has(pair):
			return _refusal("one of its Pack 1 card entries is outside the catalog")
		got_names.append(card_name)
		pairs[pair] = true
	if pairs.size() != 373:
		return _refusal("its Pack 1 set entries are not unique")
	for wanted in ADDED_NAMES:
		if not got_names.has(wanted):
			return _refusal("its four new rules identities do not match Pack 1")
	return {"ok": true, "why": "", "path": path, "manifest": manifest,
		"catalog": catalog, "cards": cards, "has_art": names == complete}


static func _refusal(why: String) -> Dictionary:
	return {"ok": false, "why": why}


static func _counts_match(value: Variant) -> bool:
	if not (value is Dictionary):
		return false
	for key in EXPECTED_COUNTS:
		if int(value.get(key, -1)) != int(EXPECTED_COUNTS[key]):
			return false
	return true


static func _sha256(payload: PackedByteArray) -> String:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(payload)
	return hashing.finish().hex_encode()


## Same deterministic path + per-file-digest stream as the Python builder.
static func _artwork_sha256(reader: ZIPReader, names: Array) -> String:
	var ordered := names.duplicate()
	ordered.sort()
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	for value in ordered:
		var name := String(value)
		hashing.update(name.to_utf8_buffer())
		hashing.update(PackedByteArray([0]))
		hashing.update(_sha256(reader.read_file(name)).to_utf8_buffer())
		hashing.update("\n".to_utf8_buffer())
	return hashing.finish().hex_encode()


static func _valid_version(value: String) -> bool:
	var parts := value.split(".")
	if parts.size() != 3:
		return false
	for part in parts:
		if part == "" or not part.is_valid_int() or int(part) < 0:
			return false
	return true


static func _version_less(left: String, right: String) -> bool:
	var a := left.split(".")
	var b := right.split(".")
	for i in 3:
		var av := int(a[i]) if i < a.size() and a[i].is_valid_int() else 0
		var bv := int(b[i]) if i < b.size() and b[i].is_valid_int() else 0
		if av != bv:
			return av < bv
	return false


static func _expected_art_files(cards: Array) -> Array:
	var out: Array = []
	for row in cards:
		if not (row is Dictionary):
			continue
		var name := String(row.get("name", ""))
		var code := String(row.get("set", ""))
		var stem := _snake(name)
		for suffix in [".jpg", "_card.jpg"]:
			out.append(PREFIX + "art/%s/%s%s" % [code, stem, suffix])
			if ADDED_NAMES.has(name):
				out.append("skin/cardart/%s%s" % [stem, suffix])
	return out


static func _snake(value: String) -> String:
	var out := ""
	for character in value.to_lower():
		var code := character.unicode_at(0)
		out += character if (code >= 97 and code <= 122) \
			or (code >= 48 and code <= 57) else "_"
	while out.contains("__"):
		out = out.replace("__", "_")
	return out.trim_prefix("_").trim_suffix("_")


func available_ids() -> Array[String]:
	var ids: Array[String] = []
	for id in _available:
		ids.append(String(id))
	ids.sort()
	return ids


func has_pack(id: String) -> bool:
	return _available.has(id)


func is_enabled(id: String) -> bool:
	return has_pack(id) and Settings.enabled_card_packs().has(id)


func info(id: String) -> Dictionary:
	if not _available.has(id):
		return {}
	var report: Dictionary = _available[id]
	var manifest: Dictionary = report["manifest"].duplicate(true)
	manifest["path"] = report["path"]
	manifest["enabled"] = is_enabled(id)
	return manifest


func entry_records(id: String) -> Array:
	if not _available.has(id):
		return []
	return Array(_available[id].get("cards", [])).duplicate(true)


## Status for the Options > Card Packs page, including a useful refusal
## when the exact file exists but validation rejected it.
func status(id: String) -> Dictionary:
	if has_pack(id):
		var accepted := info(id)
		accepted["available"] = true
		accepted["rejection"] = ""
		return accepted
	var rejected := {}
	for one in _rejections:
		if one.get("id", ID) == id:
			rejected = one
			break
	return {
		"id": id,
		"file_name": file_name_for(id),
		"version": PACK_VERSION,
		"minimum_game_version": MINIMUM_GAME_VERSION,
		"available": false,
		"enabled": false,
		"path": rejected.get("path", candidate_paths(id)[0]),
		"rejection": rejected.get("why", "not found"),
	}


func set_enabled(id: String, enabled: bool) -> bool:
	if not has_pack(id):
		return false
	var ids := Settings.enabled_card_packs()
	if enabled and not ids.has(id):
		ids.append(id)
	elif not enabled:
		ids.erase(id)
	Settings.set_enabled_card_packs(ids)
	_configure_registry()
	CardRegistry.ensure_loaded()
	changed.emit(id, enabled)
	return true


## The exact full path shown by the Card Packs page. Creating the folder is
## harmless and makes Open Folder useful before the first ZIP exists.
func ensure_folder() -> String:
	var full := ProjectSettings.globalize_path(GamePaths.cardpacks_folder())
	DirAccess.make_dir_recursive_absolute(full)
	return full


func open_folder() -> void:
	if not OS.has_feature("web"):
		OS.shell_open(ensure_folder())


## Pack-aware art is a Deck Builder presentation choice only. Game objects
## and saved decks remain keyed by card name; the selected set merely chooses
## which mounted crop or full-card scan represents that name on screen.
func art_path(card_name: String, set_code: String, full_card := false) -> String:
	var id := FallenEmpiresPack.ID if set_code == "fem" else ID
	if set_code == "ice":
		id = IceAgePack.ID
	if not is_enabled(id) or set_code == "":
		return ""
	var report: Dictionary = _available[id]
	if not bool(report.get("has_art", false)) \
			or not CardRegistry.card_in_set(card_name, set_code):
		return ""
	var suffix := "_card.jpg" if full_card else ".jpg"
	var prefix := FallenEmpiresPack.PREFIX if id == FallenEmpiresPack.ID else PREFIX
	if id == IceAgePack.ID:
		prefix = IceAgePack.PREFIX
	var path := "res://%sart/%s/%s%s" % [prefix, set_code,
		_snake(card_name), suffix]
	return path if FileAccess.file_exists(path) else ""


func art_texture(card_name: String, set_code: String, full_card := false) -> Texture2D:
	var path := art_path(card_name, set_code, full_card)
	if path == "":
		return null
	if _art_cache.has(path):
		return _art_cache[path]
	var bytes := FileAccess.get_file_as_bytes(path)
	var image := Image.new()
	if bytes.is_empty() or image.load_jpg_from_buffer(bytes) != OK:
		return null
	if not full_card:
		image.generate_mipmaps()
	var texture := ImageTexture.create_from_image(image)
	_art_cache[path] = texture
	return texture


func set_current_deck_names(names: Array[String]) -> void:
	_current_deck_names.clear()
	for name in names:
		if not _current_deck_names.has(name):
			_current_deck_names.append(name)


func current_deck_conflicts(id: String) -> Array[String]:
	var found: Array[String] = []
	var names: Array = FallenEmpiresPack.names() if id == FallenEmpiresPack.ID else ADDED_NAMES
	if id == IceAgePack.ID:
		names = IceAgePack.new_names()
	for name in names:
		if _current_deck_names.has(name):
			found.append(name)
	return found


func disable_warning(id: String) -> String:
	var names := current_deck_conflicts(id)
	if names.is_empty():
		return ""
	return ("The current deck requires %s because it contains %s. " \
		+ "Disabling the pack will keep the names in the deck, but they cannot " \
		+ "be played until %s is enabled again.") % [label_for(id), ", ".join(names), label_for(id)]


func packs_required_by(names: Array[String]) -> Array[String]:
	var ids: Array[String] = []
	var second := FallenEmpiresPack.names()
	var third := IceAgePack.new_names()
	for name in names:
		if ADDED_NAMES.has(name) and not ids.has(ID):
			ids.append(ID)
		if second.has(name) and not ids.has(FallenEmpiresPack.ID):
			ids.append(FallenEmpiresPack.ID)
		if third.has(name) and not ids.has(IceAgePack.ID):
			ids.append(IceAgePack.ID)
	ids.sort()
	return ids


static func file_name_for(id: String) -> String:
	if id == IceAgePack.ID:
		return IceAgePack.FILE_NAME
	return FallenEmpiresPack.FILE_NAME if id == FallenEmpiresPack.ID else FILE_NAME


static func label_for(id: String) -> String:
	return "Pack " + id.trim_prefix("pack-")


func missing_requirements(ids: Array[String]) -> Array[String]:
	var missing: Array[String] = []
	for id in ids:
		if not is_enabled(id):
			missing.append(id)
	return missing


func _configure_registry() -> void:
	if not is_enabled(ID):
		CardRegistry.configure_optional_pack(false, {}, [], [], {})
	else:
		var report: Dictionary = _available[ID]
		var catalog: Dictionary = report["catalog"]
		CardRegistry.configure_optional_pack(true, catalog.get("sets", {}),
			CARD_SCRIPTS, report.get("cards", []), catalog.get("counts", {}))
	var sets := {}
	var scripts: Array = []
	var records: Array = []
	for contract in [FallenEmpiresPack, IceAgePack]:
		if is_enabled(contract.ID):
			var report: Dictionary = _available[contract.ID]
			sets.merge(report.catalog.sets)
			scripts.append_array(contract.scripts())
			records.append_array(report.cards)
	CardRegistry.configure_expansion_packs(sets, scripts, records)
