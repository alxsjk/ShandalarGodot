extends SceneTree
## Deterministic complete Wizard-v-Wizard Ice Age duels in both rulesets.
## Run under the repository's isolated shandalar_test profile, never the
## player's profile. The pack must already be locally built and installed.

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.has("--version") or args.has("-V"):
		print("pack_3_duel_audit.gd ", ProjectSettings.get_setting("application/config/version", "unknown"))
		quit(0)
		return
	if args.has("--help") or args.has("-h"):
		print("Pack 3 Ice Age audit — ten complete Wizard duels, modern and Fifth Edition.")
		print("Use tools/runtime.sh: shandalar_find_godot; shandalar_find_timeout; shandalar_test_profile.")
		print("Set SHANDALAR_PACK_3 to your locally built Pack-3-Ice_Age.zip; run with --script res://tools/pack_3_duel_audit.gd.")
		quit(0)
		return
	if not args.is_empty():
		printerr("Unknown audit arguments; use --help")
		quit(3)
		return
	if not OS.has_feature("shandalar_test"):
		printerr("PACK 3 AI AUDIT: requires GODOT_EDITOR_CUSTOM_FEATURES=shandalar_test")
		quit(2)
		return
	Settings.set_value("enabled_card_packs", ["pack-3"], false)
	root.get_node("CardPacks")._configure_registry()
	CardRegistry.ensure_loaded()
	if CardRegistry.size() != 1243:
		printerr("PACK 3 AI AUDIT: install the real local Pack-3-Ice_Age.zip first")
		quit(2)
		return
	var specs := [
		["Snow-Covered Forest", ["Fyndhorn Elves", "Balduvian Bears", "Aurochs", "Woolly Spider", "Lhurgoyf", "Nature's Lore", "Giant Growth", "Dire Wolves"]],
		["Snow-Covered Swamp", ["Knight of Stromgald", "Legions of Lim-Dûl", "Krovikan Vampire", "Ashen Ghoul", "Soul Burn", "Dark Ritual", "Foul Familiar", "Necropotence"]],
		["Snow-Covered Mountain", ["Orcish Conscripts", "Orcish Cannoneers", "Balduvian Barbarians", "Incinerate", "Meteor Shower", "Melee", "Errantry", "Sabretooth Tiger"]],
		["Snow-Covered Plains", ["Order of the White Shield", "Seraph", "Kjeldoran Knight", "Kjeldoran Skyknight", "General Jarkeld", "Sacred Boon", "Hipparion", "Swords to Plowshares"]],
		["Snow-Covered Island", ["Brainstorm", "Counterspell", "Illusionary Wall", "Illusionary Forces", "Snowfall", "Zuran Spellcaster", "Ray of Command", "Binding Grasp"]],
	]
	var decks: Array = []
	for spec in specs:
		var deck: Array[String] = []
		for _i in 24: deck.append(spec[0])
		for name in spec[1]:
			if not CardRegistry.has_card(name):
				printerr("PACK 3 AI AUDIT: missing " + name)
				quit(2)
				return
			for _i in 4: deck.append(name)
		for name in ["Barbed Sextant", "Urza's Bauble", "Ashnod's Transmogrant", "Wall of Shields"]: deck.append(name)
		decks.append(deck)
	var completed := 0
	for edition in ["modern", "fifth"]:
		for i in decks.size():
			var game := MtgGame.new()
			var duel_seed := 43000 + i + (100 if edition == "fifth" else 0)
			game.setup(decks[i], decks[(i + 1) % decks.size()], specs[i][0], specs[(i + 1) % specs.size()][0], 20, 20, duel_seed)
			game.rules.set_edition(edition)
			var a := AiPlayer.new(0, AiProfile.wizard())
			var b := AiPlayer.new(1, AiProfile.wizard())
			game.set_agent(0, a)
			game.set_agent(1, b)
			game.start()
			if not AiPlayer.play_out(game, a, b):
				printerr("PACK 3 AI AUDIT FAILED: ", edition, " seed ", duel_seed, " turn ", game.turn_number)
				quit(2)
				return
			completed += 1
			print("PACK 3 AI DUEL OK: ", edition, " seed ", duel_seed, " turns ", game.turn_number, " winner ", game.winner)
	print("PACK 3 AI AUDIT OK: ", completed, " completed full duels")
	quit(0)
