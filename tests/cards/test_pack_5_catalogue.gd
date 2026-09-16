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
