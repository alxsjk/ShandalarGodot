extends "res://tools/duel_soak.gd"
## Same real DuelScreen and human clicker as the base soak; only decks and
## in-memory pack selection differ. Requires the real local ZIP and the
## isolated shandalar_test profile. No player settings or Elo writes.

const SPECS := [
	["Island", ["Giant Oyster", "Sea Sprite", "Memory Lapse", "Reveka, Wizard Savant", "Coral Reef", "Wall of Kelp", "Chain Stasis", "Merchant Scroll", "Serrated Arrows"]],
	["Mountain", ["Anaba Shaman", "Anaba Bodyguard", "Anaba Spirit Crafter", "Didgeridoo", "Lightning Bolt", "Retribution", "Ambush Party", "Dwarven Trader", "Roterothopter"]],
	["Plains", ["Hazduhr the Abbot", "White Knight", "Serra Paladin", "Abbey Matron", "Ambush", "Aysen Bureaucrats", "Clockwork Steed", "Serra Bestiary", "Serrated Arrows"]],
	["Forest", ["Faerie Noble", "Willow Priestess", "Willow Faerie", "Rysorian Badger", "Spectral Bears", "Autumn Willow", "Giant Growth", "Carapace", "An-Havva Inn"]],
]

func _configure_decks(config: DuelConfig, _first: String, _second: String) -> void:
	if not OS.has_feature("shandalar_test"):
		push_error("Pack 4 UI soak requires the isolated shandalar_test profile")
		quit(3)
		return
	Settings.set_value("enabled_card_packs", ["pack-4"], false)
	root.get_node("CardPacks")._configure_registry()
	CardRegistry.ensure_loaded()
	if not CardRegistry.has_card("Giant Oyster"):
		push_error("Pack 4 UI soak requires the real local Pack-4-Homelands.zip")
		quit(3)
		return
	config.decks = []
	config.player_names = []
	for seat in 2:
		var spec: Array = SPECS[(_index + seat) % SPECS.size()]
		var deck: Array[String] = []
		for _n in 24: deck.append(spec[0])
		for name in spec[1]:
			for _n in 4: deck.append(name)
		config.decks.append(deck)
		config.player_names.append("Homelands " + spec[0])
