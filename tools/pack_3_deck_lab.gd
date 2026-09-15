extends "res://DeckLab/simulate.gd"
## Isolated Ice Age entry point to the existing Deck Lab, including its
## candidate/null/control sweeps. Never writes the player's pack settings
## or the tracked Elo ledger. Uses in-process threads (--jobs); the stock
## Lab's child-process entry point does not configure optional packs.

func _initialize() -> void:
	_pack_main.call_deferred()

func _pack_main() -> void:
	var args := OS.get_cmdline_user_args()
	if args.has("--version") or args.has("-V"):
		print("pack_3_deck_lab.gd ", ProjectSettings.get_setting("application/config/version", "unknown"))
		quit(0)
		return
	if args.has("--help") or args.has("-h"):
		print("Pack 3 Deck Lab: isolated Ice Age enabled in memory; always --no-elo --procs 1.")
		print(HELP)
		quit(0)
		return
	if not OS.has_feature("shandalar_test"):
		printerr("Use GODOT_EDITOR_CUSTOM_FEATURES=shandalar_test for the Pack 3 Deck Lab")
		quit(2)
		return
	Settings.set_value("enabled_card_packs", ["pack-3"], false)
	root.get_node("CardPacks")._configure_registry()
	CardRegistry.ensure_loaded()
	if not CardRegistry.has_card("Snow-Covered Island"):
		printerr("Pack 3 is missing; set SHANDALAR_PACK_3 to your locally built ZIP")
		quit(2)
		return
	if args.has("--procs"):
		var at := args.find("--procs")
		if at + 1 >= args.size() or args[at + 1] != "1":
			printerr("Pack 3 Deck Lab uses --procs 1; use --jobs for parallel threads")
			quit(2)
			return
	else: args.append_array(["--procs", "1"])
	if not args.has("--no-elo"): args.append("--no-elo")
	quit(exit_code_of(_main(args)))
