extends GutTest
## Reproducible draft commitments: exact replay, metadata survival and trust bounds.

const FOLDER := "user://test_draft_recipe"
const SEED := "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"
var files: Array[String] = []


func before_each() -> void:
	CardRegistry.ensure_loaded()


func after_each() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	for path in files:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	files.clear()


func _names() -> Array[String]:
	var names: Array[String] = []
	for card_name in CardRegistry.all_names():
		if SealedPool.SLOT_ORDER.has(SealedPool.slot_of(card_name)): names.append(card_name)
	return names


func _pool(seed_hex := SEED) -> SealedPool:
	return DraftRecipe.deal(DraftPoolConfig.defaults(), _names(), seed_hex)


func _store(pool: SealedPool) -> DraftStore:
	var store := DraftStore.new()
	assert_eq(store.prepare(FOLDER, pool, pool.draft_recipe.options), "")
	files.append_array([store.deck_path, store.pool_path, store.deck_path + ".pending", store.pool_path + ".pending"])
	return store


func test_frozen_dealer_matches_an_independent_sha256_reference_vector() -> void:
	# Independently calculated using Python hashlib, little-endian uint32s,
	# rejection sampling and compact UTF-8 JSON; no Godot RNG is involved.
	var recipe := {"schema": 1, "algorithm": DraftRecipe.ALGORITHM, "seed": SEED,
		"options": {"boosters": 1, "starters": 0, "free_lands": 1, "extras": 2, "minutes": 20},
		"sheets": {"rare": ["Shivan Dragon"], "uncommon": ["Counterspell", "Serra Angel", "Sol Ring"],
			"common": ["Dark Ritual", "Disenchant", "Giant Growth", "Grizzly Bears", "Healing Salve", "Lightning Bolt", "Llanowar Elves", "Mons's Goblin Raiders", "Scryb Sprites", "Unholy Strength"],
			"land": ["Forest", "Island", "Mountain", "Plains", "Swamp"]},
		"pool_sha256": "3231e8474ee8be69f58b972d1febb6c7261f11d6f2a08b3a7ac7bec2de4ef879",
		"fingerprint": "ba56d2dcd6a70463fbfec7e3f7fdbd3848685a912f854eaf697bef54451b95da"}
	var replay := DraftRecipe.reconstruct(recipe)
	assert_true(replay.ok)
	assert_eq(DraftRecipe.fingerprint(recipe), recipe.fingerprint)
	assert_eq(replay.pool.total(), 22)
	assert_eq(replay.pool.packs[0].cards[-1], "Mountain")
	assert_eq(replay.pool.packs[-1].cards, ["Forest", "Shivan Dragon"] as Array[String])


func test_recipe_round_trips_large_seed_and_json_float_options_exactly() -> void:
	var pool := _pool("f".repeat(64))
	var json := JSON.new()
	assert_eq(json.parse(JSON.stringify(pool.draft_recipe, "\t")), OK)
	assert_eq(json.data.seed, "f".repeat(64))
	var replay := DraftRecipe.reconstruct(json.data)
	assert_true(replay.ok)
	assert_eq(replay.pool.packs, pool.packs)
	assert_eq(replay.pool.counts, pool.counts)
	assert_eq(replay.fingerprint, pool.draft_recipe.fingerprint)


func test_canonical_hash_preserves_unicode_card_names_as_utf8() -> void:
	assert_eq(DraftRecipe.pack_hash([{"title": "Random Cards", "cards": ["Juzám Djinn", "Junún Efreet"]}]),
		"94c27f68b151349894624050f868e37976631fc92bb6fba92586893646f51026")


func test_seed_and_eligible_selection_are_both_required_to_match() -> void:
	var first := _pool()
	var again := _pool()
	var different := _pool("a".repeat(64))
	assert_eq(first.packs, again.packs)
	assert_eq(first.draft_recipe.fingerprint, again.draft_recipe.fingerprint)
	assert_ne(first.draft_recipe.fingerprint, different.draft_recipe.fingerprint)
	assert_ne(first.counts, different.counts)
	var reduced := _names()
	reduced.erase("Shivan Dragon")
	var limited := DraftRecipe.deal(DraftPoolConfig.defaults(), reduced, SEED)
	assert_ne(first.draft_recipe.fingerprint, limited.draft_recipe.fingerprint)
	assert_false(limited.draft_recipe.sheets.rare.has("Shivan Dragon"))


func test_replay_uses_the_recorded_sheets_not_current_pool_settings() -> void:
	var pool := _pool()
	var saved: Variant = Settings.get_value(DraftPoolConfig.SETTING, 0) if Settings.has_value(DraftPoolConfig.SETTING) else null
	Settings.set_value(DraftPoolConfig.SETTING, ["Mountain"], false)
	var replay := DraftRecipe.reconstruct(pool.draft_recipe)
	if saved == null: Settings.clear_value(DraftPoolConfig.SETTING)
	else: Settings.set_value(DraftPoolConfig.SETTING, saved, false)
	assert_true(replay.ok)
	assert_eq(replay.pool.packs, pool.packs)


func test_versioned_dealer_preserves_rarity_shape_at_all_pack_limits() -> void:
	for value in range(16):
		var options := DraftPoolConfig.defaults()
		options.boosters = 12 if value == 15 else value % 5
		options.starters = 12 if value == 15 else 1 + value % 3
		options.free_lands = 30 if value == 15 else 2
		options.extras = 60 if value == 15 else 7
		var pool := DraftRecipe.deal(options, _names(), str(value).sha256_text())
		assert_not_null(pool)
		assert_eq(pool.total(), pool.card_total())
		for pack in pool.packs:
			var seen: Dictionary = {}
			var slots := {"rare": 0, "uncommon": 0, "common": 0, "land": 0}
			for card_name in pack.cards:
				var slot := "land" if SealedPool.LAND_NAMES.has(card_name) else DeckStats.rarity_of(card_name)
				slots[slot] += 1
				if slot != "land": assert_false(seen.has(card_name))
				seen[card_name] = true
			if pack.title.begins_with("Starter"): assert_eq(slots, SealedPool.STARTER)
			elif pack.title.begins_with("Booster"): assert_eq(slots, SealedPool.BOOSTER)
		var replay := DraftRecipe.reconstruct(pool.draft_recipe)
		assert_true(replay.ok)
		assert_eq(replay.pool.packs, pool.packs)


func test_saved_deck_embeds_recipe_before_completion_and_after_finish() -> void:
	var pool := _pool()
	var store := _store(pool)
	var receipt: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(store.pool_path))
	assert_eq(receipt.recipe.fingerprint, pool.draft_recipe.fingerprint)
	var deck := DeckModel.new()
	deck.add(pool.names()[0])
	for reason in ["building", "done"]:
		assert_eq(store.checkpoint(deck, reason), "")
		var text := FileAccess.get_file_as_string(store.deck_path)
		assert_eq(text, store.deck_text(deck), "Web and native use the same serialization")
		assert_string_contains(text, "# draft-seed: " + SEED)
		assert_string_contains(text, "# draft-packs: 3 boosters, 1 starters")
		assert_string_contains(text, "# draft-fingerprint: " + receipt.recipe.fingerprint)
		assert_true(DraftAudit.check_files(store.pool_path, store.deck_path, receipt.recipe.fingerprint).ok)
		var parser := DeckList.new()
		parser.parse(text)
		assert_eq(parser.errors, [] as Array[String])
		assert_eq(parser.cards.size(), 1)
	assert_eq(deck.draft_comments, "", "Serialization must not mutate the live model")


func test_native_load_save_copy_and_undo_keep_the_recipe() -> void:
	var store := _store(_pool())
	assert_eq(store.checkpoint(DeckModel.new(), "done"), "")
	var report: Array = []
	var loaded := DeckStore.load_deck(store.deck_path, report)
	assert_not_null(loaded)
	assert_string_contains(loaded.draft_comments, "# draft-recipe:")
	assert_eq(loaded.duplicate_model().draft_comments, loaded.draft_comments)
	var pasted := DeckStore.import_text(loaded.to_text(), "Draft", report)
	assert_eq(pasted.draft_comments, loaded.draft_comments)
	var imported := DeckStore.import_file(store.deck_path, report)
	assert_eq(imported.draft_comments, loaded.draft_comments)
	assert_true(DraftAudit.reconstruct_text(loaded.to_text()).ok)
	loaded.clear()
	assert_eq(loaded.draft_comments, "", "A new unrelated deck must not inherit a draft commitment")


func test_a_judge_can_reconstruct_every_pack_from_only_the_deck_file() -> void:
	var pool := _pool()
	var store := _store(pool)
	assert_eq(store.checkpoint(DeckModel.new(), "done"), "")
	var result := DraftAudit.reconstruct_file(store.deck_path, pool.draft_recipe.fingerprint)
	assert_true(result.ok)
	assert_string_contains(result.message, "judge's retained fingerprint")
	assert_string_contains(result.message, "Starter Pack 1 (60 cards)")
	assert_eq(result.receipt.packs, pool.packs)
	var unanchored := DraftAudit.reconstruct_file(store.deck_path)
	assert_true(unanchored.ok)
	assert_string_contains(unanchored.message, "Unanchored replay")


func test_judge_fingerprint_and_original_receipt_reject_a_substituted_valid_recipe() -> void:
	var original := _store(_pool())
	var replacement := _store(_pool("b".repeat(64)))
	var text := replacement.deck_text(DeckModel.new())
	assert_true(DraftAudit.reconstruct_text(text).ok, "Self-consistency is not authenticity")
	assert_false(DraftAudit.reconstruct_text(text, original.receipt.recipe.fingerprint).ok)
	assert_false(DraftAudit.check(original.receipt, text).ok)
	assert_false(DraftAudit.reconstruct_text(text, "not-a-hash").ok)


func test_modified_recipe_or_saved_pack_contents_cannot_pass_reconstruction() -> void:
	var pool := _pool()
	for field in ["seed", "pool_sha256", "fingerprint"]:
		var altered := pool.draft_recipe.duplicate(true)
		altered[field] = "e".repeat(64)
		assert_false(DraftRecipe.reconstruct(altered).ok)
	var changed := pool.draft_recipe.duplicate(true)
	changed.seed = "c".repeat(64)
	changed.fingerprint = DraftRecipe.fingerprint(changed)
	assert_string_contains(DraftRecipe.reconstruct(changed).message, "does not reconstruct")
	var store := _store(pool)
	var receipt := store.receipt.duplicate(true)
	receipt.packs[0].cards.reverse()
	assert_false(DraftAudit.check(receipt, store.deck_text(DeckModel.new())).ok)


func test_reconstructed_pool_still_rejects_excess_sideboard_copies() -> void:
	var pool := _pool()
	var store := _store(pool)
	var card_name := pool.names()[0]
	var text := store.deck_text(DeckModel.new()) + "%d %s\nSB: 1 %s\n" % [pool.counts[card_name], card_name, card_name]
	var result := DraftAudit.reconstruct_text(text)
	assert_false(result.ok)
	assert_string_contains(result.message, "Outside the saved pool")


func test_corrupt_or_unsupported_recipes_are_bounded_and_refused() -> void:
	var recipe := _pool().draft_recipe
	for value in [null, [], {}, {"schema": 2}]: assert_false(DraftRecipe.reconstruct(value).ok)
	for key in ["schema", "algorithm", "options", "sheets", "seed"]:
		var bad := recipe.duplicate(true)
		bad[key] = false
		assert_false(DraftRecipe.reconstruct(bad).ok)
	for count in [-1, 1.5, INF, NAN, 1000000, "3", null]:
		var bad := recipe.duplicate(true)
		bad.options.boosters = count
		assert_false(DraftRecipe.reconstruct(bad).ok)
	var duplicate := recipe.duplicate(true)
	duplicate.sheets.rare.append(duplicate.sheets.rare[0])
	assert_false(DraftRecipe.reconstruct(duplicate).ok)
	for text in ["name: Old draft", DraftRecipe.PREFIX + "{bad}", DraftRecipe.comments(recipe) + "\n" + DraftRecipe.comments(recipe), "#".repeat(DraftRecipe.MAX_BYTES + 1)]:
		assert_false(DraftAudit.reconstruct_text(text).ok)


func test_prepare_rejects_pool_or_options_that_disagree_with_recipe() -> void:
	var pool := _pool()
	var store := DraftStore.new()
	pool.counts[pool.names()[0]] += 1
	assert_string_contains(store.prepare(FOLDER, pool, DraftPoolConfig.defaults()), "does not match")
	assert_eq(store.deck_path, "")
	pool = _pool()
	var options := DraftPoolConfig.defaults()
	options.minutes += 1
	assert_string_contains(store.prepare(FOLDER, pool, options), "options do not match")
	assert_eq(store.pool_path, "")


func test_recovery_copy_retains_the_same_pre_draft_fingerprint() -> void:
	var pool := _pool()
	var first := _store(pool)
	var second := _store(pool)
	assert_ne(first.deck_path, second.deck_path)
	assert_eq(first.receipt.recipe.fingerprint, second.receipt.recipe.fingerprint)
	assert_eq(first.deck_text(DeckModel.new()), second.deck_text(DeckModel.new()))


func test_verifier_can_reconstruct_without_selecting_a_pool_file() -> void:
	var store := _store(_pool())
	assert_eq(store.checkpoint(DeckModel.new()), "")
	var verifier := DraftVerifier.new()
	add_child_autofree(verifier)
	verifier.select_file("deck", store.deck_path)
	verifier.fingerprint.text = store.receipt.recipe.fingerprint
	verifier.reconstruct()
	assert_string_contains(verifier.report.text, "Reconstructed from seed")
	assert_string_contains(verifier.report.text, "judge's retained fingerprint")
	verifier.fingerprint.text = "0".repeat(64)
	verifier.reconstruct()
	assert_string_contains(verifier.report.text, "does not match")
