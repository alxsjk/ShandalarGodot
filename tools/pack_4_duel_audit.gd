extends SceneTree
## Deterministic complete Wizard-v-Wizard Homelands duels in both rulesets.
## Run under the repository's isolated shandalar_test profile, never the
## player's profile. The pack must already be locally built and installed.

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.has("--version") or args.has("-V"):
		print("pack_4_duel_audit.gd ", ProjectSettings.get_setting("application/config/version", "unknown"))
		quit(0)
		return
	if args.has("--help") or args.has("-h"):
		print("Pack 4 Homelands audit — complete Wizard duels and actual card-use counts in both rulesets.")
		print("--rounds N (default 1, max 1000); --seed N (default 54000). Nine themed decks, 18 duels per round.")
		print("Use tools/runtime.sh: shandalar_find_godot; shandalar_find_timeout; shandalar_test_profile.")
		print("Set SHANDALAR_PACK_4 to your locally built Pack-4-Homelands.zip; run with --script res://tools/pack_4_duel_audit.gd.")
		quit(0)
		return
	var rounds := 1
	var base_seed := 54000
	var at := 0
	while at < args.size():
		if args[at] not in ["--rounds", "--seed"] or at + 1 >= args.size() or not args[at + 1].is_valid_int():
			printerr("Invalid audit arguments; use --help")
			quit(3)
			return
		if args[at] == "--rounds": rounds = int(args[at + 1])
		else: base_seed = int(args[at + 1])
		at += 2
	if rounds < 1 or rounds > 1000 or base_seed < 0:
		printerr("Rounds must be 1..1000 and seed nonnegative")
		quit(3)
		return
	if not OS.has_feature("shandalar_test"):
		printerr("PACK 4 AI AUDIT: requires GODOT_EDITOR_CUSTOM_FEATURES=shandalar_test")
		quit(2)
		return
	Settings.set_value("enabled_card_packs", ["pack-4"], false)
	root.get_node("CardPacks")._configure_registry()
	CardRegistry.ensure_loaded()
	if CardRegistry.size() != 1012:
		printerr("PACK 4 AI AUDIT: install the real local Pack-4-Homelands.zip first")
		quit(2)
		return
	var specs := [
		["Forest", ["Autumn Willow", "Rysorian Badger", "Spectral Bears", "Hungry Mist", "Carapace", "Giant Growth", "An-Havva Constable", "Leaping Lizard"]],
		["Swamp", ["Sengir Autocrat", "Drudge Spell", "Ihsan's Shade", "Grandmother Sengir", "Torture", "Dark Ritual", "Broken Visage", "Sengir Bats"]],
		["Mountain", ["Anaba Shaman", "Anaba Spirit Crafter", "Anaba Bodyguard", "Didgeridoo", "Lightning Bolt", "Retribution", "Dwarven Pony", "Dwarven Trader"]],
		["Plains", ["Hazduhr the Abbot", "White Knight", "Serra Paladin", "Abbey Matron", "Abbey Gargoyles", "Aysen Bureaucrats", "Serra Bestiary", "Swords to Plowshares"]],
		["Island", ["Giant Oyster", "Memory Lapse", "Merchant Scroll", "Reveka, Wizard Savant", "Wall of Kelp", "Reef Pirates", "Sea Sprite", "Counterspell"]],
		["Swamp", ["Koskun Falls", "Black Carriage", "Funeral March", "Drudge Spell", "Dark Ritual", "Headstone", "Sengir Autocrat", "Feast of the Unicorn"]],
		["Island", ["Giant Oyster", "Coral Reef", "Baki's Curse", "Forget", "Sea Troll", "Sea Sprite", "Chain Stasis", "Jinx"]],
		["Forest", ["Faerie Noble", "Willow Priestess", "Willow Faerie", "An-Havva Inn", "Primal Order", "Autumn Willow", "Root Spider", "Giant Growth"]],
		["Plains", ["Clockwork Steed", "Clockwork Swarm", "Mesa Falcon", "Ambush", "Aysen Crusader", "Trade Caravan", "Death Speakers", "Serra Paladin"]],
	]
	var decks: Array = []
	for spec in specs:
		var deck: Array[String] = []
		for _i in 24: deck.append(spec[0])
		for name in spec[1]:
			if not CardRegistry.has_card(name):
				printerr("PACK 4 AI AUDIT: missing " + name)
				quit(2)
				return
			for _i in 4: deck.append(name)
		for name in ["Serrated Arrows", "Joven's Tools", "Clockwork Gnomes", "Roterothopter"]: deck.append(name)
		decks.append(deck)
	var completed := 0
	var use_counts := {}
	for edition in ["modern", "fifth"]:
		for match_index in decks.size() * rounds:
			var i := match_index % decks.size()
			var round_index := match_index / decks.size()
			var opponent := (i + 1 + round_index % (decks.size() - 1)) % decks.size()
			var game := MtgGame.new()
			var duel_seed := base_seed + match_index + (100000 if edition == "fifth" else 0)
			game.setup(decks[i], decks[opponent], specs[i][0], specs[opponent][0], 20, 20, duel_seed)
			game.rules.set_edition(edition)
			var a := AiPlayer.new(0, AiProfile.wizard())
			var b := AiPlayer.new(1, AiProfile.wizard())
			game.set_agent(0, a)
			game.set_agent(1, b)
			game.start()
			if not AiPlayer.play_out(game, a, b):
				printerr("PACK 4 AI AUDIT FAILED: ", edition, " seed ", duel_seed, " turn ", game.turn_number)
				quit(2)
				return
			completed += 1
			for meta in game.log_meta:
				if meta.kind not in ["cast", "activate"] or String(meta.card).is_empty(): continue
				var key := "%s: %s" % [meta.kind, meta.card]
				use_counts[key] = int(use_counts.get(key, 0)) + 1
			print("PACK 4 AI DUEL OK: ", edition, " seed ", duel_seed, " turns ", game.turn_number, " winner ", game.winner)
	var keys: Array = use_counts.keys()
	keys.sort()
	for key in keys: print("PACK 4 ACTUAL USE: ", key, " = ", use_counts[key])
	print("PACK 4 AI AUDIT OK: ", completed, " completed full duels")
	quit(0)
