extends "res://tools/duel_soak.gd"
## Same real DuelScreen and human clicker as the base soak; only decks and
## in-memory pack selection differ. Requires the real local ZIP and the
## isolated shandalar_test profile. No player settings or Elo writes.

const SPECS := [
	[
		"Island",
		[
			"Storm Crow",
			"Force of Will",
			"Arcane Denial",
			"Browse",
			"Benthic Explorers",
			"Spiny Starfish",
			"Phantasmal Sphere",
			"Lat-Nam's Legacy",
			"Phyrexian War Beast"
		]
	],
	[
		"Mountain",
		[
			"Gorilla Shaman",
			"Pyrokinesis",
			"Pillage",
			"Balduvian Horde",
			"Lightning Bolt",
			"Storm Shaman",
			"Guerrilla Tactics",
			"Gorilla War Cry",
			"Phyrexian War Beast"
		]
	],
	[
		"Plains",
		[
			"Noble Steeds",
			"Reprisal",
			"Exile",
			"Carrier Pigeons",
			"Errand of Duty",
			"Soldevi Steam Beast",
			"Scars of the Veteran",
			"Kjeldoran Home Guard",
			"Phyrexian War Beast"
		]
	],
	[
		"Forest",
		[
			"Elvish Spirit Guide",
			"Elvish Ranger",
			"Kaysa",
			"Deadly Insect",
			"Giant Growth",
			"Nature's Chosen",
			"Gorilla Chieftain",
			"Bounty of the Hunt",
			"Phyrexian War Beast"
		]
	]
]

func _configure_decks(config: DuelConfig, _first: String, _second: String) -> void:
	if not OS.has_feature("shandalar_test"):
		push_error("Pack 5 UI soak requires the isolated shandalar_test profile")
		quit(3)
		return
	Settings.set_value("enabled_card_packs", ["pack-5"], false)
	root.get_node("CardPacks")._configure_registry()
	CardRegistry.ensure_loaded()
	if not CardRegistry.has_card("Force of Will"):
		push_error("Pack 5 UI soak requires the real local Pack-5-Alliances.zip")
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
		config.player_names.append("Alliances " + spec[0])
