extends RefCounted
## Public semantic descriptions of custom payloads; no decisions live here.
## Ordinary typed damage, pumps, counters, tokens and removal need no name map.
static func annotate(c: CardData) -> void:
	var roles := {
		"Giant Oyster": [["sustained_lock"]],
		"Clockwork Steed": [["recharge", {"kind": "+1/+0", "maximum": 4}]],
		"Clockwork Swarm": [["recharge", {"kind": "+1/+0", "maximum": 4}]],
		"Didgeridoo": [["deploy_tribe", {"subtype": "minotaur"}]],
		"Willow Priestess": [["deploy_tribe", {"subtype": "faerie"}], ["protection", {"color": Mtg.ManaColor.B}]],
		"Aether Storm": [["remove_creature_ban"]],
		"Autumn Willow": [["permit_shroud"]],
		"Carapace": [["regenerate_host"]],
		"Torture": [["counter_host", {"kind": "-1/-1"}]],
		"Black Carriage": [["untap_self"]],
		"Marjhan": [["untap_self"]],
		"Joven's Tools": [["evasion", {"walls_only": true}]],
		"Dwarven Pony": [["evasion", {"landwalk": "mountain"}]],
		"Veldrane of Sengir": [["evasion", {"landwalk": "forest", "power": -3}]],
		"Dark Maze": [["attack_once"]],
		"Faerie Noble": [["tribal_pump", {"subtype": "faerie", "power": 1}]],
		"Apocalypse Chime": [["set_sweep", {"set": "hml"}]],
		"Coral Reef": [["replenish_counter", {"kind": "polyp", "count": 2}]],
		"Dwarven Sea Clan": [["delayed_damage", {"amount": 2}]],
		"Timmerian Fiends": [["ownership_offer"]],
	}
	var entries: Array = roles.get(c.card_name, [])
	for index in mini(entries.size(), c.activated_abilities.size()):
		var entry: Array = entries[index]
		c.activated_abilities[index].effects[0].with_ai_role(StringName(entry[0]), entry[1] if entry.size() > 1 else {})
	var spells := {
		"Ambush": "blocking_first_strike", "An-Havva Inn": "green_life",
		"Baki's Curse": "aura_damage", "Forget": "discard_redraw", "Leeches": "remove_poison",
		"Headstone": "graveyard_exile_cantrip", "Prophecy": "opponent_cantrip", "Jinx": "land_type_cantrip",
		"Winter Sky": "coin_sweep_draw", "Truce": "mutual_draw_life", "Broken Visage": "attacker_destroy_token",
		"Chain Stasis": "chain_tap_untap", "Retribution": "sacrifice_pair",
	}
	if spells.has(c.card_name): c.spell_effects[0].with_ai_role(StringName(spells[c.card_name]))
	for ability in c.activated_abilities:
		for effect in ability.effects:
			if effect is CounterMarkerEffect: effect.with_ai_role(&"stat_counter")
			elif effect is PumpEffect and effect.toughness < 0 and effect.target_spec != null: effect.with_ai_role(&"stat_debuff")
