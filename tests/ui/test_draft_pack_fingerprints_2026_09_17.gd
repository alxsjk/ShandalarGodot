extends GutTest
## The draft's pre-build commitment over every combination of card packs:
## base set alone, each numbered pack on its own, and all five together.
## The recipe carries its own sheets, so a replay must not depend on which
## packs a machine has switched on — and a refusal must say which pack it
## wants rather than calling a good pool corrupt.

const FOLDER := "user://test_draft_pack_fingerprints"
const SEED := "3132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f50"
## Base set, each pack alone, then the whole shelf.
const COMBINATIONS := [[], ["pack-1"], ["pack-2"], ["pack-3"], ["pack-4"], ["pack-5"],
	["pack-1", "pack-2", "pack-3", "pack-4", "pack-5"]]

var saved: Dictionary = {}
var files: Array[String] = []


func before_each() -> void:
	for key in [DraftPoolConfig.SETTING, DraftPoolConfig.OPTIONS, GamePaths.KEY_DRAFTS]:
		saved[key] = Settings.get_value(key, 0) if Settings.has_value(key) else null
		Settings.clear_value(key)
	_enable([])
	CardRegistry.ensure_loaded()


func after_each() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_enable([])
	for key in saved:
		if saved[key] == null: Settings.clear_value(key)
		else: Settings.set_value(key, saved[key], false)
	for path in files:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	files.clear()


func _enable(ids: Array) -> void:
	for id in CardPacks.available_ids():
		CardPacks.set_enabled(id, ids.has(id))


func _store(pool: SealedPool, options: Dictionary) -> DraftStore:
	var store := DraftStore.new()
	assert_eq(store.prepare(FOLDER, pool, options), "")
	files.append_array([store.deck_path, store.pool_path,
		store.deck_path + ".pending", store.pool_path + ".pending"])
	return store


## The pack-only names this build actually implements, in sheet order.
func _pack_only(count: int) -> Array[String]:
	var out: Array[String] = []
	for name in IceAgePack.new_names() + AlliancesPack.new_names():
		if CardRegistry.has_card(name) and SealedPool.SLOT_ORDER.has(SealedPool.slot_of(name)):
			out.append(String(name))
		if out.size() >= count: break
	return out


func test_every_pack_combination_deals_and_replays_its_own_fingerprint() -> void:
	var fingerprints: Dictionary = {}
	for combination in COMBINATIONS:
		_enable(combination)
		var label := "base set" if combination.is_empty() else ", ".join(PackedStringArray(combination))
		var names := DraftPoolConfig.selected()
		assert_eq(DraftPoolConfig.validate(DraftPoolConfig.defaults(), names), "", label)
		var pool := DraftRecipe.deal(DraftPoolConfig.defaults(), names, SEED)
		assert_not_null(pool, label)
		if pool == null: continue
		assert_eq(pool.total(), 105, label)
		var recipe: Dictionary = pool.draft_recipe
		assert_eq(DraftRecipe.fingerprint(recipe), String(recipe.fingerprint), label)
		var replay := DraftRecipe.reconstruct(recipe)
		assert_true(replay.ok, label + ": " + String(replay.get("message", "")))
		if not replay.ok: continue
		assert_eq(replay.pool.packs, pool.packs, label)
		assert_eq(replay.pool.counts, pool.counts, label)
		# Every dealt name is one the enabled packs actually offer.
		for card_name in pool.names(): assert_has(names, card_name, label)
		assert_false(fingerprints.has(recipe.fingerprint),
			"a different eligible pool must not reuse a fingerprint (%s)" % label)
		fingerprints[recipe.fingerprint] = label
	assert_eq(fingerprints.size(), COMBINATIONS.size())


func test_the_widest_pool_stays_inside_the_recipe_and_deck_file_bounds() -> void:
	_enable(["pack-1", "pack-2", "pack-3", "pack-4", "pack-5"])
	var names := DraftPoolConfig.selected()
	assert_gt(names.size(), 1500, "all five packs widen the eligible pool")
	assert_lt(names.size(), DraftRecipe.MAX_ELIGIBLE)
	var options := DraftPoolConfig.defaults()
	options.boosters = 12
	options.starters = 12
	options.free_lands = 30
	options.extras = 60
	var pool := DraftRecipe.deal(options, names, SEED)
	assert_not_null(pool)
	if pool == null: return
	assert_eq(pool.total(), DraftAudit.MAX_CARDS)
	var store := _store(pool, options)
	assert_eq(store.checkpoint(DeckModel.new(), "done"), "")
	var text := FileAccess.get_file_as_string(store.deck_path)
	assert_lt(text.to_utf8_buffer().size(), DraftAudit.DECK_BYTES,
		"the embedded recipe must still fit a deck file")
	assert_lt(FileAccess.get_file_as_string(store.pool_path).to_utf8_buffer().size(),
		DraftAudit.POOL_BYTES, "the widest receipt must still fit a pool file")
	assert_true(DraftAudit.check_files(store.pool_path, store.deck_path,
		String(pool.draft_recipe.fingerprint)).ok)
	assert_true(DraftAudit.reconstruct_file(store.deck_path,
		String(pool.draft_recipe.fingerprint)).ok)


func test_a_fingerprint_does_not_depend_on_the_order_the_packs_were_enabled() -> void:
	var forward: Array = ["pack-1", "pack-2", "pack-3", "pack-4", "pack-5"]
	_enable(forward)
	var first := DraftRecipe.deal(DraftPoolConfig.defaults(), DraftPoolConfig.selected(), SEED)
	assert_not_null(first)
	_enable([])
	var backward := forward.duplicate()
	backward.reverse()
	for id in backward:
		if CardPacks.has_pack(id): CardPacks.set_enabled(id, true)
	var again := DraftRecipe.deal(DraftPoolConfig.defaults(), DraftPoolConfig.selected(), SEED)
	assert_not_null(again)
	if first == null or again == null: return
	assert_eq(String(again.draft_recipe.fingerprint), String(first.draft_recipe.fingerprint),
		"the same shelf in the other order is the same eligible pool")
	assert_eq(again.packs, first.packs)
	# A restart: the registry is dropped and rebuilt, the recipe is not.
	CardRegistry.unload()
	CardRegistry.ensure_loaded()
	var after_restart := DraftRecipe.reconstruct(first.draft_recipe)
	assert_true(after_restart.ok)
	if after_restart.ok: assert_eq(after_restart.pool.packs, first.packs)


func test_a_pool_of_pack_only_cards_saves_loads_and_audits_with_the_packs_on() -> void:
	_enable(["pack-3", "pack-5"])
	var names: Array[String] = SealedPool.LAND_NAMES.duplicate()
	names.append_array(_pack_only(6))
	names.sort()
	assert_eq(names.size(), 11, "five basics and six pack-only cards")
	var options := {"boosters": 0, "starters": 0, "free_lands": 1, "extras": 6, "minutes": 20}
	var pool := DraftRecipe.deal(options, names, SEED)
	assert_not_null(pool)
	if pool == null: return
	assert_false(CardPacks.packs_required_by(pool.names()).is_empty(),
		"the dealt pool holds cards only a pack offers")
	var store := _store(pool, options)
	var deck := DeckModel.new()
	var dealt := pool.names()
	deck.add(dealt[0])
	deck.add_side(dealt[-1])
	assert_eq(store.checkpoint(deck, "done"), "")
	assert_true(DraftAudit.check_files(store.pool_path, store.deck_path,
		String(pool.draft_recipe.fingerprint)).ok)
	var reconstructed := DraftAudit.reconstruct_file(store.deck_path,
		String(pool.draft_recipe.fingerprint))
	assert_true(reconstructed.ok, String(reconstructed.message))
	var report: Array = []
	var loaded := DeckStore.load_deck(store.deck_path, report)
	assert_not_null(loaded)
	if loaded == null: return
	assert_true(DraftAudit.reconstruct_text(loaded.to_text()).ok,
		"a pack pool survives the deck loader's round trip")
	assert_eq(DeckStore.import_text(loaded.to_text(), "Draft", report).draft_comments,
		loaded.draft_comments)


func test_a_live_session_builds_and_saves_a_deck_from_a_pack_only_pool() -> void:
	_enable(["pack-3", "pack-5"])
	var names: Array[String] = SealedPool.LAND_NAMES.duplicate()
	names.append_array(_pack_only(6))
	names.sort()
	var options := {"boosters": 0, "starters": 0, "free_lands": 2, "extras": 6, "minutes": 20}
	var pool := DraftRecipe.deal(options, names, SEED)
	assert_not_null(pool)
	if pool == null: return
	var store := _store(pool, options)
	var session := DraftSession.new()
	session.pool = pool
	session.store = store
	session.seconds = 60
	add_child_autofree(session)
	session.start_building()
	await get_tree().process_frame
	var pack_card := ""
	for card_name in pool.names():
		var one: Array[String] = [card_name]
		if not CardPacks.packs_required_by(one).is_empty():
			pack_card = card_name
			break
	assert_ne(pack_card, "", "the deal put a pack-only card in the pool")
	var offered: Array[String] = []
	for data in session.builder._sealed_library(): offered.append(String(data.card_name))
	assert_has(offered, pack_card, "the dealt pack card is on the inventory shelf")
	session.builder._add_one(pack_card)
	assert_eq(session.builder.deck.count_of(pack_card), pool.copies_of(pack_card))
	session.finish("done")
	assert_true(session.finished)
	var text := FileAccess.get_file_as_string(store.deck_path)
	assert_string_contains(text, pack_card)
	assert_true(DraftAudit.check_files(store.pool_path, store.deck_path,
		String(pool.draft_recipe.fingerprint)).ok)
	assert_true(DraftAudit.reconstruct_file(store.deck_path).ok)


## Switching a pack off under a live dealt pool used to push one
## `CardRegistry: unknown card` into the player's log per dealt pack card:
## the Inventory refresh asked the loud fetch for names the registry had
## just dropped. The cards leave the shelf; the log stays quiet.
func test_disabling_a_pack_under_a_dealt_pool_drops_its_cards_quietly() -> void:
	_enable(["pack-3", "pack-5"])
	var names: Array[String] = SealedPool.LAND_NAMES.duplicate()
	names.append_array(_pack_only(4))
	names.sort()
	var options := {"boosters": 0, "starters": 0, "free_lands": 0, "extras": names.size(), "minutes": 20}
	var pool := DraftRecipe.deal(options, names, SEED)
	assert_not_null(pool)
	if pool == null: return
	var session := DraftSession.new()
	session.pool = pool
	session.store = _store(pool, options)
	session.seconds = 60
	add_child_autofree(session)
	session.start_building()
	await get_tree().process_frame
	assert_eq(session.builder._sealed_library().size(), names.size())
	_enable([])
	assert_eq(session.builder._sealed_library().size(), SealedPool.LAND_NAMES.size(),
		"only the basics are left on the shelf while the packs are off")
	# The pack window's own tally walks the same names through slot_of.
	assert_string_contains(pool.summary(), "%d cards" % pool.total())
	session.finish("done")


func test_a_pack_pool_checked_without_its_pack_names_the_pack_it_wants() -> void:
	_enable(["pack-3"])
	var names: Array[String] = SealedPool.LAND_NAMES.duplicate()
	names.append_array(_pack_only(4))
	names.sort()
	var options := {"boosters": 0, "starters": 0, "free_lands": 0, "extras": names.size(), "minutes": 20}
	var pool := DraftRecipe.deal(options, names, SEED)
	assert_not_null(pool)
	if pool == null: return
	var store := _store(pool, options)
	assert_eq(store.checkpoint(DeckModel.new(), "done"), "")
	var fingerprint := String(pool.draft_recipe.fingerprint)
	_enable([])
	# The frozen recipe replays perfectly; only the playable pool is gone.
	assert_true(DraftRecipe.reconstruct(pool.draft_recipe).ok)
	for result in [DraftAudit.check_files(store.pool_path, store.deck_path, fingerprint),
			DraftAudit.reconstruct_file(store.deck_path, fingerprint)]:
		assert_false(result.ok)
		assert_string_contains(String(result.message), "Pack 3")
		assert_string_contains(String(result.message), "Card Packs")
		assert_false(String(result.message).contains("unknown card"),
			"a pool dealt from a switched-off pack is not a corrupt pool")


func test_a_genuinely_unknown_pool_card_is_still_called_unknown() -> void:
	var receipt := {"schema": 1, "counts": {"Imaginary Card": 1},
		"packs": [{"title": "Test pack", "cards": ["Imaginary Card"]}]}
	assert_string_contains(DraftAudit.pool_refusal(receipt), "unknown card")


## FEM, ICE, HML and ALL each printed their own rarity structure. The draft
## deals from one sheet per printed rarity, so a pack rarity the sheets do
## not know would drop those cards out of the eligible pool in silence.
func test_every_implemented_pack_card_sits_on_exactly_one_rarity_sheet() -> void:
	_enable(["pack-1", "pack-2", "pack-3", "pack-4", "pack-5"])
	var names := DraftPoolConfig.selected()
	var sheets := SealedPool.sheets(DraftPoolConfig.library(names))
	var unplaced: Array[String] = []
	var counted := 0
	for shelf in [CardPacks.ADDED_NAMES, FallenEmpiresPack.names(), IceAgePack.new_names(),
			HomelandsPack.new_names(), AlliancesPack.new_names()]:
		for value in shelf:
			var card_name := String(value)
			if not CardRegistry.has_card(card_name): continue
			counted += 1
			var on := 0
			for slot in SealedPool.SLOT_ORDER:
				on += int(sheets[slot].has(card_name))
			if on != 1 or not SealedPool.SLOT_ORDER.has(SealedPool.slot_of(card_name)) \
					or not names.has(card_name):
				unplaced.append(card_name)
	assert_eq(unplaced, [] as Array[String], "every pack card the build implements is draftable")
	assert_gt(counted, 700, "all five packs together add over seven hundred identities")


func test_the_saved_pool_receipt_names_the_packs_the_deal_needed() -> void:
	_enable(["pack-3"])
	var names: Array[String] = SealedPool.LAND_NAMES.duplicate()
	names.append_array(_pack_only(4))
	names.sort()
	var options := {"boosters": 0, "starters": 0, "free_lands": 0, "extras": names.size(), "minutes": 20}
	var pool := DraftRecipe.deal(options, names, SEED)
	assert_not_null(pool)
	if pool == null: return
	var store := _store(pool, options)
	var receipt: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(store.pool_path))
	assert_eq(receipt.required_packs, ["pack-3"], "the receipt says which shelf dealt this pool")
	assert_eq(DraftAudit.pool_refusal(receipt), "", "the extra field is still a valid receipt")
