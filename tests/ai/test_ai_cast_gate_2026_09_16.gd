extends GameTest
## THE GATE THE PLANNER ASKS FIRST (2026-09-16).
##
## Every "Cast this spell only ..." rider is a [Callable] on the card, and
## the AI calls it on EVERY main phase for EVERY card in hand
## ([method AiPlayer._cast_gate], and again through
## [method MtgGame.cast_refusal] inside [method AiPlayer._plan_spell_choice]).
## A rider written with the wrong number of parameters therefore does not
## fail once at cast time: it prints an engine error on every planning pass
## AND its restriction never fires at all, because the failed call returns
## null and the refusal string is empty.
##
## Fallen Empires' Tidal Influence shipped that way — `_one_influence`
## took (game, pid, card) while the engine calls (game, pid) — so a second
## copy was castable and every planning pass holding one printed
## "Invalid call to function '_one_influence (Callable)'". The sweep below
## is the general form: it pins the arity of every card-authored predicate
## the planner and the engine call, so the next one is caught by the suite
## rather than by a player's log.


func before_each() -> void:
	for id in CardPacks.available_ids(): CardPacks.set_enabled(id, true)
	super()


func after_each() -> void:
	g = null
	for id in CardPacks.available_ids(): CardPacks.set_enabled(id, false)


## Property name -> the argument count its call sites pass.
const CARD_PREDICATES := {"cast_condition": 2, "announcement_condition": 5,
	"sacrifice_condition": 2}
const ABILITY_PREDICATES := {"activator_condition": 3, "x_condition": 4,
	"sacrifice_filter": 1, "tap_permanent_filter": 1, "discard_filter": 1,
	"graveyard_exile_filter": 1}


func test_card_authored_predicates_take_the_arguments_they_are_called_with() -> void:
	CardRegistry.ensure_loaded()
	var wrong: Array = []
	var checked := 0
	for name in CardRegistry.all_names():
		var data := CardRegistry.get_card(String(name))
		if data == null:
			continue
		for property in CARD_PREDICATES:
			var predicate: Callable = data.get(property)
			if not predicate.is_valid():
				continue
			checked += 1
			if predicate.get_argument_count() != int(CARD_PREDICATES[property]):
				wrong.append("%s.%s takes %d" % [name, property,
					predicate.get_argument_count()])
		for ability in data.activated_abilities:
			for property in ABILITY_PREDICATES:
				var predicate: Callable = ability.get(property)
				if not predicate.is_valid():
					continue
				checked += 1
				if predicate.get_argument_count() != int(ABILITY_PREDICATES[property]):
					wrong.append("%s.%s takes %d" % [name, property,
						predicate.get_argument_count()])
	assert_eq(wrong, [], "card predicates must match their call sites")
	assert_gt(checked, 50, "the sweep must actually have found predicates")


func test_a_second_tidal_influence_is_refused_without_an_engine_error() -> void:
	put_battlefield(0, "Tidal Influence")
	for _i in 3: put_battlefield(0, "Island")
	var second := give_hand(0, "Tidal Influence")
	advance_to_step(Mtg.Step.MAIN1)
	var pilot := AiPlayer.new(0, AiProfile.wizard())
	g.set_agent(0, pilot)
	assert_string_contains(pilot._cast_gate(g, second), "already on the battlefield")
	assert_string_contains(g.cast_refusal(0, second), "already on the battlefield")
	assert_true(pilot._plan_spell_choice(g, second, 0).is_empty(),
		"the planner must not propose a cast the engine refuses")
