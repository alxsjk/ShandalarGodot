extends RefCounted
## Semantic metadata only. Policy uses these shapes, never card names.
static func annotate(c: CardData) -> void:
	if c.card_name == "Ivory Gargoyle":
		for trigger in c.triggered_abilities:
			if trigger.event_type == Mtg.EventType.DIES: trigger.returns_source_after_death = true
	var roles := {
		"Browse": [["library_selection", {"consume": 5, "value": 6.0}]],
		"Phyrexian Portal": [["library_selection", {"consume": 10, "value": 6.0}]],
		"Soldevi Sage": [["library_selection", {"consume": 3, "value": 11.0}]],
		"Soldevi Digger": [["grave_bottom"]],
		"Thawing Glaciers": [["land_search"]],
		"Soldevi Excavations": [["scry"]],
		"Gorilla Shaman": [["exact_mv_removal"]],
		"Floodwater Dam": [["tap_x_lands"]],
		"Helm of Obedience": [["mill_until_creature"]],
		"Phyrexian Devourer": [["blind_counter_growth"]],
		"Balduvian Dead": [["hasty_token"]],
		"Gargantuan Gorilla": [["fight"]],
		"Whip Vine": [["sustained_lock"]],
		"Viscerid Armor": [["self_bounce"]],
		"Kjeldoran Pride": [["move_buff_aura"]],
		"Enslaved Scout": [["evasion", {"landwalk": "mountain"}]],
		"Varchild's Crusader": [["suicide_evasion"]],
		"Sworn Defender": [["match_combat_stats"]],
		"Nature's Chosen": [["untap_host"], ["untap_object"]],
		"Nature's Blessing": [["stat_counter"], ["permanent_keyword", {"keyword": Mtg.Keyword.BANDING}], ["permanent_keyword", {"keyword": Mtg.Keyword.FIRST_STRIKE}], ["permanent_keyword", {"keyword": Mtg.Keyword.TRAMPLE}]],
		"Phelddagrif": [["self_keyword_gift", {"keyword": Mtg.Keyword.TRAMPLE}], ["self_keyword_gift", {"keyword": Mtg.Keyword.FLYING}], ["self_bounce_gift"]],
		"Gustha's Scepter": [["hide_hand"], ["recover_hidden"]],
		"Tidal Control": [["counter_spell"], ["counter_spell"]],
		"Soldevi Sentry": [["regenerate_gift"]],
		"Scarab of the Unseen": [["remove_auras"]],
		"Storm Elemental": [["tap_flyer"], ["blind_snow_pump"]],
		"Chaos Harlequin": [["blind_risky_pump"]],
		"Urza's Engine": [["self_keyword", {"keyword": Mtg.Keyword.BANDING}], ["band_trample"]],
		"Mishra's Groundbreaker": [["permanent_animation"]],
	}
	var entries: Array = roles.get(c.card_name, [])
	for index in mini(entries.size(), c.activated_abilities.size()):
		var entry: Array = entries[index]
		c.activated_abilities[index].effects[0].with_ai_role(StringName(entry[0]), entry[1] if entry.size() > 1 else {})
	var spells := {"Exile": "attacker_exile_life", "Ritual of the Machine": "steal_creature", "Hail Storm": "asymmetric_combat_sweep", "Stench of Decay": "nonartifact_debuff_sweep", "Energy Arc": "untap_fog", "Gorilla War Cry": "army_menace", "Surge of Strength": "mana_value_pump", "Martyrdom": "grant_redirect", "Fatal Lore": "opponent_choice_value", "Library of Lat-Nam": "opponent_choice_value", "Misfortune": "opponent_choice_value", "Lat-Nam's Legacy": "hand_filter_slow_draw", "Foresight": "library_thin_slow_draw", "Diminishing Returns": "reset_hands", "Omen of Fire": "island_white_sweep"}
	if spells.has(c.card_name): c.spell_effects[0].with_ai_role(StringName(spells[c.card_name]))
	for a in c.activated_abilities:
		for e in a.effects:
			if e is CounterMarkerEffect and e.ai_role == &"": e.with_ai_role(&"stat_counter")
