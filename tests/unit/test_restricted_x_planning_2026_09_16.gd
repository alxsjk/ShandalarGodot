extends GameTest
## A RESTRICTED-X COST THE PLANNER COULD NOT PLAN — 2026-09-16.
##
## [member ManaCost.restricted_x_mask] is "spend only these types on this
## part of the cost": Soul Burn's *"Spend only black and/or red mana on X"*
## and, since Alliances, Primitive Justice's extra {R}-or-{G} per target
## ([member CardData.extra_target_color_mask], folded into the cost by
## [method MtgGame.spell_payment]).
##
## [ManaPool] pays any such mask. [method ManaPlanner.plan_from] enumerated
## ONLY the {B}/{R} one and returned "no plan" for every other, so a cost
## carrying the {R}/{G} mask read as unpayable to everything that asks the
## planner rather than the pool: the duel screen's auto-tap
## (`_auto_tap_for_pending`) tapped nothing, and `_pending_is_reachable`
## called the cast unreachable and dropped the player out of it — which is
## every Primitive Justice aimed at a second artifact.
##
## The planner now walks the mask in [constant ManaPool.RESTRICTED_SPEND_ORDER],
## the order the pool itself spends it in, so the colours a plan taps for
## are the colours the payment then takes.


func before_each() -> void:
	CardPacks.set_enabled("pack-3", true)
	CardPacks.set_enabled("pack-5", true)
	super()
	advance_to_step(Mtg.Step.MAIN1)


func after_each() -> void:
	g = null
	CardPacks.set_enabled("pack-3", false)
	CardPacks.set_enabled("pack-5", false)


func _payment(card: CardInstance, x_value: int, targets: int) -> Dictionary:
	return g.spell_payment(0, card.data, x_value, targets, card, 0)


func test_the_second_target_of_primitive_justice_carries_a_red_or_green_pip() -> void:
	var justice := give_hand(0, "Primitive Justice")
	var payment := _payment(justice, 0, 2)
	var cost: ManaCost = payment["cost"]
	assert_eq(cost.restricted_x_mask, Mtg.ManaColor.R | Mtg.ManaColor.G)
	assert_eq(cost.restricted_x_amount, 1, "one extra target, one extra pip")


func test_the_planner_taps_for_a_red_or_green_restricted_pip() -> void:
	var justice := give_hand(0, "Primitive Justice")
	put_battlefield(0, "Mountain")
	put_battlefield(0, "Forest")
	put_battlefield(0, "Forest")
	put_battlefield(0, "Forest")
	var payment := _payment(justice, 0, 2)
	var plan := ManaPlanner.plan(g, 0, payment["cost"], int(payment["extra"]),
		payment["usage"])
	assert_eq(plan.size(), 4, "{1}{R}, one more generic, one more {R} or {G}")


func test_the_planned_taps_really_pay_for_two_artifacts() -> void:
	var one := put_battlefield(1, "Black Lotus")
	var two := put_battlefield(1, "Mox Ruby")
	var justice := give_hand(0, "Primitive Justice")
	put_battlefield(0, "Mountain")
	put_battlefield(0, "Forest")
	put_battlefield(0, "Forest")
	put_battlefield(0, "Forest")
	var payment := _payment(justice, 0, 2)
	ManaPlanner.run_plan(g, 0, ManaPlanner.plan(g, 0, payment["cost"],
		int(payment["extra"]), payment["usage"]))
	assert_ok(g.cast_spell(0, justice,
		[TargetRef.card(one), TargetRef.card(two)]))
	resolve_stack()
	assert_eq(one.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(two.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.players[0].mana_pool.total(), 0, "nothing was left floating")


func test_a_mask_with_no_source_for_it_still_has_no_plan() -> void:
	var justice := give_hand(0, "Primitive Justice")
	put_battlefield(0, "Mountain")
	put_battlefield(0, "Plains")
	put_battlefield(0, "Plains")
	put_battlefield(0, "Plains")
	var payment := _payment(justice, 0, 2)
	assert_true(ManaPlanner.plan(g, 0, payment["cost"], int(payment["extra"]),
		payment["usage"]).is_empty(), "white cannot pay the {R}/{G} pip")


func test_soul_burn_still_plans_its_black_or_red_x() -> void:
	var burn := give_hand(0, "Soul Burn")
	for unused in 5:
		put_battlefield(0, "Swamp")
	var payment := _payment(burn, 2, 1)
	var plan := ManaPlanner.plan(g, 0, payment["cost"], int(payment["extra"]),
		payment["usage"])
	assert_eq(plan.size(), 5, "{2}{B} plus two more on X")
