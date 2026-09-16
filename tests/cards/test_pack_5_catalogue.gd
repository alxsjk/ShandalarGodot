extends GutTest
## Complete-set gate: dormant trusted rules, never metadata-only playable stubs.

func test_alliances_is_opt_in_and_has_144_executable_identities() -> void:
	CardPacks.set_enabled("pack-5", true)
	CardRegistry.ensure_loaded()
	assert_true(CardRegistry.has_card("Force of Will"))
	assert_eq(CardRegistry.names_in_set("all").size(), 144)
	for name in CardRegistry.names_in_set("all"):
		var card := CardRegistry.get_card(name)
		assert_false(card.cast_condition.is_valid() and card.cast_condition.get_method() == "_pending", name)
	CardPacks.set_enabled("pack-5", false)
	assert_false(CardRegistry.has_card("Force of Will"))

func test_natures_blessing_gives_first_strike_and_has_none_of_its_own() -> void:
	# "{G}{W}, Discard a card: Put a +1/+1 counter on target creature or
	# that creature gains banding, first strike, or trample." The keyword
	# is handed out; the enchantment has no keyword line of its own, and
	# the Deck Builder's @ABILITY filter reads printed keywords as native.
	CardPacks.set_enabled("pack-5", true)
	CardRegistry.ensure_loaded()
	DeckAbilities.clear_cache()
	var card := CardRegistry.get_card("Nature's Blessing")
	assert_true(card.keywords.is_empty(), "no printed keyword on the enchantment")
	var strike := 1 << DeckAbilities.Ability.FIRST_STRIKE
	assert_eq(DeckAbilities.native(card) & strike, 0, "it does not have first strike")
	assert_eq(DeckAbilities.gives(card) & strike, strike, "it gives first strike")
	CardPacks.set_enabled("pack-5", false)
