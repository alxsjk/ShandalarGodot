extends GameTest
## RULE 8 ON THE WIRE. Melee hands the ATTACKER the blocking declaration, so
## the host builds the "blockable" matrix for a seat that does not own the
## creatures in it. Hipparion's blocking tax is a mana question, and mana can
## live in a hand (Elvish Spirit Guide) — the 2026-09-16 engine fix gave every
## such read a viewer; this lane never passed one.
##
## Hipparion and Melee are Ice Age (Pack 3), the Guide is Alliances (Pack 5).

var referee: SgPracticeMatch


func before_each() -> void:
	CardPacks.set_enabled("pack-3", true)
	CardPacks.set_enabled("pack-5", true)
	super()
	referee = SgPracticeMatch.new(42)
	referee.game = g
	g.interactive_choices = true
	g.set_agent(0, HumanAgent.new())
	g.set_agent(1, HumanAgent.new())


func after_each() -> void:
	referee = null
	g = null
	CardPacks.set_enabled("pack-5", false)
	CardPacks.set_enabled("pack-3", false)


## Seat 0 attacks with a Hill Giant into seat 1's Hipparion, which owes {1}
## to block anything with power 3 or greater and has nothing untapped.
func _giant_into_hipparion() -> Array:
	var giant := put_battlefield(0, "Hill Giant")
	var hipparion := put_battlefield(1, "Hipparion")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_eq(g.declare_attackers(0, [giant.id]), "")
	return [giant, hipparion]


func _melee(pid: int) -> void:
	var melee := give_hand(pid, "Melee")
	add_mana(pid, Mtg.ManaColor.R, 5)
	assert_eq(g.cast_spell(pid, melee), "")
	resolve_stack()
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)


## What seat [param pid]'s snapshot says [param blocker] may block.
func _blockable(pid: int, blocker: CardInstance) -> Array:
	for row in referee.view(pid).presentation.blockable:
		if row[0] == referee._handle(pid, blocker): return row[1]
	return []


func test_the_melee_attacker_is_not_told_about_a_guide_in_the_defenders_hand() -> void:
	var pair := _giant_into_hipparion()
	var hipparion: CardInstance = pair[1]
	_melee(0)
	assert_eq(g.block_chooser(), 0, "Melee gives the attacker the declaration")
	assert_eq(_blockable(0, hipparion), [], "the unpaid tax keeps the Hipparion out of the matrix")
	var guide := give_hand(1, "Elvish Spirit Guide")
	assert_eq(_blockable(0, hipparion), [],
		"a Guide hidden in seat 1's hand must not open seat 0's blocking matrix")
	# Public-change control: a revealed Guide is information seat 0 may use.
	guide.revealed_in_hand = true
	assert_eq(_blockable(0, hipparion), [referee._handle(0, pair[0])],
		"a revealed Guide is public and pays the tax")


func test_the_defender_still_sees_its_own_hand_mana_open_the_block() -> void:
	var pair := _giant_into_hipparion()
	var hipparion: CardInstance = pair[1]
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_eq(g.block_chooser(), 1, "without Melee the defender declares")
	assert_eq(_blockable(1, hipparion), [], "nothing untapped, nothing in hand")
	give_hand(1, "Elvish Spirit Guide")
	assert_eq(_blockable(1, hipparion), [referee._handle(1, pair[0])],
		"the defender may exile its own Guide to pay the tax")
