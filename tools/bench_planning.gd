extends SceneTree
## Deterministic planning latency probe; no saves, ratings or random search.
## Run with a timeout: Godot --headless --path . -s res://tools/bench_planning.gd
## Timings are diagnostic, not machine-dependent assertions in the test gate.
## Append -- --unfair to measure the separate hand-aware challenge with a
## known opposing Giant Growth. Budgets in that report are PER study; the
## challenge can run eight response studies after the baseline study.

const REPEATS := 5


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var unfair := OS.get_cmdline_user_args().has("--unfair")
	var report: Array = []
	for size in [1, 3, 6, 12, 13]:
		for trick in [false, true]:
			print("Measuring %d creatures per side; own trick: %s" % [size, trick])
			var game := _board(size, trick)
			if unfair:
				game._put_on_battlefield(_card(game, 1, "Forest"), 1)
				var response := _card(game, 1, "Giant Growth")
				response.zone = Mtg.Zone.HAND
				game.players[1].hand.append(response)
				game.recalculate()
			var pilot: AiPlayer = UnfairPlayer.new(0) if unfair else AiPlayer.new(0, AiProfile.wizard())
			game.set_agent(0, pilot)
			var candidates := pilot._attack_candidates(game, 1)
			var times: Array[float] = []
			var max_nodes := 0
			for _i in REPEATS + 1:
				var start := Time.get_ticks_usec()
				pilot._attack_choice(game, candidates, 1)
				var elapsed := float(Time.get_ticks_usec() - start) / 1000.0
				if _i > 0: times.append(elapsed)
				max_nodes = maxi(max_nodes, pilot.last_combat_nodes)
			times.sort()
			report.append({"creatures_per_side": size, "own_trick": trick,
				"unfair": unfair,
				"median_ms": times[times.size() / 2],
				"max_ms": times.back(), "max_study_leaves": max_nodes,
				"budget": pilot.profile.combat_search_nodes})
			print(JSON.stringify(report.back()))
	print(JSON.stringify({"repeats": REPEATS, "combat": report}, "  "))
	quit()


func _board(count: int, trick: bool) -> MtgGame:
	var game := MtgGame.new()
	var names: Array = []
	for _i in 40: names.append("Forest")
	game.setup(names, names, "P0", "P1", 20, 20, 91326)
	game.start(0)
	for seat in 2:
		for i in count:
			var card := _card(game, seat, "Hill Giant" if i % 3 == 0 else "Grizzly Bears")
			game._put_on_battlefield(card, seat)
			card.summoning_sick = false
	var land := _card(game, 0, "Forest")
	game._put_on_battlefield(land, 0)
	if trick:
		var pump := _card(game, 0, "Giant Growth")
		pump.zone = Mtg.Zone.HAND
		game.players[0].hand.append(pump)
	game.recalculate()
	return game


func _card(game: MtgGame, seat: int, name: String) -> CardInstance:
	var card := CardInstance.new(CardRegistry.get_card(name), game._next_instance_id, seat)
	game._next_instance_id += 1
	game._instances[card.id] = card
	return card
