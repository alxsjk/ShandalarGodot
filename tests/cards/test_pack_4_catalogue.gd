extends GameTest
## Homelands remains optional, independently filterable and name-based.
## Executable-rule coverage is audited separately from catalogue presence.

func before_each() -> void:
	for id in CardPacks.available_ids(): CardPacks.set_enabled(id, false)
	CardPacks.set_enabled("pack-4", true)
	super()

func after_each() -> void:
	g = null
	for id in CardPacks.available_ids(): CardPacks.set_enabled(id, false)

func test_pack_is_available_and_only_adds_the_complete_homelands_checklist() -> void:
	assert_true(CardPacks.has_pack("pack-4"))
	assert_eq(CardRegistry.size(), 1012)
	assert_eq(CardRegistry.names_in_set("hml").size(), 115)
	assert_eq(CardRegistry.named_set_entry_count(), 1012)
	assert_eq(CardPacks.packs_required_by(["Merchant Scroll", "Forest"]), ["pack-4"])
	CardPacks.set_enabled("pack-4", false)
	assert_eq(CardRegistry.size(), 897)
	assert_false(CardRegistry.has_card("Merchant Scroll"))

func test_homelands_only_filters_live_without_changing_the_original_strip() -> void:
	var filter := DeckFilter.new()
	filter.original_cards_on = false
	filter.completion_pack_on = false
	var pool: Array[CardData] = []
	for name in CardRegistry.all_names(): pool.append(CardRegistry.get_card(name))
	var cards := filter.apply(pool)
	assert_eq(cards.size(), 115)
	for card in cards: assert_eq(filter.preferred_printing(card), "hml")
	assert_eq(CardRegistry.SET_ORDER.size(), 8)
	filter.toggle_set("hml")
	assert_eq(filter.apply(pool).size(), 0)

func test_combined_packs_count_entries_and_identities_separately() -> void:
	for id in ["pack-1", "pack-2", "pack-3", "pack-4"]: CardPacks.set_enabled(id, true)
	assert_eq(CardRegistry.size(), 1464)
	assert_eq(CardRegistry.named_set_entry_count(), 1860)

func test_every_homelands_name_has_reviewed_rules_not_a_development_guard() -> void:
	for name in CardRegistry.names_in_set("hml"):
		var card := CardRegistry.get_card(name)
		assert_false(card.cast_condition.is_valid(), "%s is not held behind an unimplemented-rules guard" % name)
