class_name DraftStore
extends RefCounted
## [QoL] Unique draft files and atomic, exact-deck recovery checkpoints.

var deck_path := ""
var pool_path := ""
var receipt: Dictionary = {}
var _last_text := ""


func prepare(folder: String, pool: SealedPool, options: Dictionary) -> String:
	var refusal := GamePaths.draft_folder_refusal(folder)
	if refusal != "": return refusal
	folder = ProjectSettings.globalize_path(GamePaths.expand(folder.strip_edges())).simplify_path()
	var error := DirAccess.make_dir_recursive_absolute(folder)
	if error != OK: return "Cannot create the save folder: " + error_string(error)
	var bytes := Crypto.new().generate_random_bytes(12)
	if bytes.size() != 12: return "Randomness is unavailable. No draft was started."
	var stamp := Time.get_datetime_string_from_system().replace(":", "-")
	var stem := "draft-%s-%s" % [stamp, bytes.hex_encode().left(12)]
	deck_path = folder.path_join(stem + ".deck")
	pool_path = folder.path_join(stem + ".pool.json")
	for path in [deck_path, pool_path, deck_path + ".pending", pool_path + ".pending"]:
		if FileAccess.file_exists(path) or DirAccess.dir_exists_absolute(path):
			return "The new draft filename is already in use. Try launching again."
	receipt = {"schema": 1, "created": Time.get_datetime_string_from_system(true),
		"version": ProjectSettings.get_setting("application/config/version", ""),
		"collation": "printed-rarity-v1", "pack_shapes": {"booster": SealedPool.BOOSTER, "starter": SealedPool.STARTER},
		"options": options.duplicate(), "counts": pool.counts.duplicate(),
		"packs": pool.packs.duplicate(true), "state": "building"}
	return _write(pool_path, JSON.stringify(receipt, "\t") + "\n")


func checkpoint(deck: DeckModel, reason := "building") -> String:
	if deck_path.is_empty(): return "No draft output was prepared."
	# Last-line defence against any future builder command bypassing the pool.
	for card_name in deck.names() + deck.side_names():
		if deck.copies_of(card_name) > int(receipt.counts.get(card_name, 0)):
			return "The deck contains cards outside the dealt pool; it has not been saved."
	var text := deck.to_text()
	if text != _last_text or reason != "building" or not FileAccess.file_exists(deck_path):
		var refusal := _write(deck_path, text)
		if refusal != "": return refusal
		_last_text = text
	if reason != String(receipt.state):
		receipt.state = reason
		receipt["main_cards"] = deck.total()
		receipt["sideboard_cards"] = deck.side_total()
		receipt["finished"] = Time.get_datetime_string_from_system(true)
		var refusal := _write(pool_path, JSON.stringify(receipt, "\t") + "\n")
		if refusal != "":
			receipt.state = "building"
			return refusal
	return ""


static func _write(path: String, text: String) -> String:
	var pending := path + ".pending"
	var file := FileAccess.open(pending, FileAccess.WRITE)
	if file == null: return "Cannot save the draft: " + error_string(FileAccess.get_open_error())
	file.store_string(text)
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK: return "Cannot finish writing the draft: " + error_string(error)
	error = DirAccess.rename_absolute(pending, path)
	if error != OK:
		return "Cannot replace the draft file (%s). The recovery copy is at %s." % [error_string(error), pending]
	return ""
