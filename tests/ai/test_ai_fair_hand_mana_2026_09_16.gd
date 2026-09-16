extends GameTest
## RULE 8 AND MANA IN THE HAND (2026-09-16). Elvish Spirit Guide's "exile
## this card from your hand: add {G}" made the hand a mana zone, and
## [method ManaPlanner.sources] began reading it — for EVERY seat it was
## asked about. The engine may (the defender really can exile the Guide to
## pay Hipparion's blocking tax); the computer opponent may not, and yet
## its read of the other seat's blocks, taxes and open mana all went
## through the same planner. These are the hidden-state substitution
## tests rule 8 asks for, with a public-change control (a revealed Guide
## is public and counts) beside each.
##
## Hipparion is Ice Age (Pack 3) and the Guide is Alliances (Pack 5), so
## both packs are on for the script and off again after it.


func before_each() -> void:
	CardPacks.set_enabled(IceAgePack.ID, true)
	CardPacks.set_enabled("pack-5", true)
	super()


func after_each() -> void:
	g = null
	CardPacks.set_enabled("pack-5", false)
	CardPacks.set_enabled(IceAgePack.ID, false)


## Hill Giant (3/3) across from a Hipparion that owes {1} to block it, on
## a table where seat 1 has nothing untapped: the tax cannot be paid.
func _giant_and_hipparion() -> Array:
	return [put_battlefield(0, "Hill Giant"), put_battlefield(1, "Hipparion")]


func test_the_ais_read_of_their_blocks_does_not_change_with_a_hidden_guide() -> void:
	var pair := _giant_and_hipparion()
	var giant: CardInstance = pair[0]
	var hipparion: CardInstance = pair[1]
	var before := CombatState.block_illegality(g, hipparion, giant, 1, true, 0)
	assert_eq(before, "can't afford the blocking cost")
	var hidden := give_hand(1, "Elvish Spirit Guide")
	assert_eq(CombatState.block_illegality(g, hipparion, giant, 1, true, 0), before,
		"seat 0 asking about seat 1's block must not see the Guide in seat 1's hand")
	# Public-change control: a revealed Guide is information seat 0 may use.
	hidden.revealed_in_hand = true
	assert_eq(CombatState.block_illegality(g, hipparion, giant, 1, true, 0), "",
		"a revealed Guide is public, and it pays the tax")


func test_the_engines_own_check_still_lets_the_defender_exile_the_guide() -> void:
	var pair := _giant_and_hipparion()
	var giant: CardInstance = pair[0]
	var hipparion: CardInstance = pair[1]
	assert_eq(CombatState.block_illegality(g, hipparion, giant, 1), "can't afford the blocking cost")
	give_hand(1, "Elvish Spirit Guide")
	assert_eq(CombatState.block_illegality(g, hipparion, giant, 1), "",
		"the rules-exact check (no viewer) counts the defender's own hand")
	assert_eq(CombatState.block_illegality(g, hipparion, giant, 1, true, 1), "",
		"and so does the defender asking about its own block")


## Seat 0's AI on a fresh table: Grizzly Bears under Awesome Presence
## ("can't be blocked unless defending player pays {3} for each creature
## blocking it") into a Hill Giant with two Forests open — one mana short
## of the tax — and [param hidden] in seat 1's hand. How many attackers
## it declares.
func _declared_attackers(hidden: String) -> int:
	before_each()   # a fresh game; the packs are already on
	var ai := AiPlayer.new(0, AiProfile.wizard())
	var bears := put_battlefield(0, "Grizzly Bears")
	put_battlefield(1, "Hill Giant")
	put_battlefield(1, "Forest")
	put_battlefield(1, "Forest")
	give_hand(1, hidden)
	advance_to_step(Mtg.Step.MAIN1)
	var presence := give_hand(0, "Awesome Presence")
	add_mana(0, Mtg.ManaColor.U, 2)
	assert_ok(g.cast_spell(0, presence, [TargetRef.card(bears)]))
	resolve_stack()
	assert_eq(presence.attached_to, bears.id)
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	ai.act(g)
	assert_false(g.awaiting_attackers, "the AI left the attack step open")
	return g.combat.attackers.size()


func test_the_attack_decision_is_the_same_with_and_without_the_hidden_guide() -> void:
	# The whole AI, not just the predicate. Two Forests cannot pay the
	# Presence's {3}, so the Bears are free damage and swing. A Guide
	# hidden in seat 1's hand would (through the engine's view) let the
	# Giant block and eat them — a fair seat cannot know that, so the
	# two tables, identical in public, get the same declaration.
	var with_guide := _declared_attackers("Elvish Spirit Guide")
	var with_bears := _declared_attackers("Grizzly Bears")
	assert_eq(with_guide, with_bears, "the declaration must not depend on what seat 1 hides in hand")
	assert_eq(with_bears, 1, "two Forests cannot pay the tax, so the Bears swing")


func test_their_open_mana_counts_no_hidden_guide_but_does_count_a_revealed_one() -> void:
	var ai := AiPlayer.new(0, AiProfile.wizard())
	put_battlefield(1, "Forest")
	put_battlefield(1, "Forest")
	assert_eq(ai._their_open_mana(g, 1), 2)
	var hidden := give_hand(1, "Elvish Spirit Guide")
	assert_eq(ai._their_open_mana(g, 1), 2, "a hidden Guide is not open mana seat 0 may know about")
	hidden.revealed_in_hand = true
	assert_eq(ai._their_open_mana(g, 1), 3, "a revealed one is")


func test_the_planner_and_the_affordability_check_take_a_viewer() -> void:
	give_hand(1, "Elvish Spirit Guide")
	var green := ManaCost.parse("{G}")
	assert_false(ManaPlanner.plan(g, 1, green, 0).is_empty(), "the seat's own plan exiles the Guide")
	assert_false(ManaPlanner.plan(g, 1, green, 0, [], {}, 1).is_empty(), "asking about itself, likewise")
	assert_true(ManaPlanner.plan(g, 1, green, 0, [], {}, 0).is_empty(), "seat 0 asking sees no source")
	assert_true(g.can_afford_cost(1, green), "the engine pays for its player with the Guide")
	assert_false(g.can_afford_cost(1, green, [], 0), "seat 0's read of the same cost is hand-blind")
	assert_true(ManaPlanner.sources(g, 1, {}, true, 0).is_empty())
	assert_eq(ManaPlanner.sources(g, 1, {}, true, 1).size(), 1)
