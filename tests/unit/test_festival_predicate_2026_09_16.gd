extends GameTest
## Festival's ban is a game-level flag ([member MtgGame.no_attacks_this_turn])
## that [method MtgGame.declare_attackers] refused as a whole — but the
## per-creature predicate [method CombatState.attack_illegality] did not
## know it, and every seat that only asks the predicate (the SGManalink
## client's "attackable" lane, the duel screen's combat lane) offered
## attackers a Festival turn could never declare. Since 2026-09-16 the
## predicate answers the ban itself.


## Seat 1 casts Festival at seat 0's upkeep (its printed window), and it
## resolves. Priority is seat 0's at the upkeep; one pass hands it over.
func _festival_at_their_upkeep() -> void:
	put_battlefield(1, "Plains")
	var festival := give_hand(1, "Festival")
	advance_to_step(Mtg.Step.UPKEEP)
	assert_ok(g.pass_priority(0))
	add_mana(1, Mtg.ManaColor.W)
	assert_ok(g.cast_spell(1, festival))
	resolve_stack()
	assert_eq(festival.zone, Mtg.Zone.GRAVEYARD)


func test_a_creature_cannot_attack_on_a_festival_turn_and_the_predicate_says_so() -> void:
	var angel := put_battlefield(0, "Serra Angel")
	_festival_at_their_upkeep()
	assert_true(g.no_attacks_this_turn)
	assert_eq(CombatState.attack_illegality(g, angel, 1), "creatures can't attack this turn")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_refused(g.declare_attackers(0, [angel.id]), "can't attack this turn")
	assert_ok(g.declare_attackers(0, []))


func test_the_ban_lifts_with_the_turn() -> void:
	var angel := put_battlefield(0, "Serra Angel")
	_festival_at_their_upkeep()
	assert_eq(CombatState.attack_illegality(g, angel, 1), "creatures can't attack this turn")
	advance_to_next_turn()
	advance_to_next_turn()
	assert_false(g.no_attacks_this_turn)
	assert_eq(CombatState.attack_illegality(g, angel, 1), "")
