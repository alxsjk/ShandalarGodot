extends GameTest
## "Draw N cards, then discard one of them" is a BOUNDED discard: only the
## cards just drawn are legal, which is what Krovikan Sorcerer already does
## (cards/sets/ice/_storage.gd). Pack 5's two copies of the sentence used
## the unbounded cleanup discard instead, so the rest of the hand was on
## offer — the pattern `docs/adding-cards.md` warns about under "Whose
## CHOICE is it?".

func before_each() -> void:
	CardPacks.set_enabled("pack-5", true)
	super()
	advance_to_step(Mtg.Step.MAIN1)


func after_each() -> void:
	g = null
	CardPacks.set_enabled("pack-5", false)


## Answers the bounded discard with nothing; every other question keeps the
## default answer, so the two-land sacrifice cost still pays itself.
class Silent extends DecisionAgent:
	func answer_card(game: MtgGame, pid: int, candidates: Array[CardInstance],
			prompt: String) -> CardInstance:
		if prompt.contains("just drawn"): return null
		return super(game, pid, candidates, prompt)


func test_soldevi_sage_discards_one_of_the_three_it_drew() -> void:
	var sage := put_battlefield(0, "Soldevi Sage")
	put_battlefield(0, "Forest")
	put_battlefield(0, "Forest")
	# The default agent dumps the most expensive card in hand; a card that
	# was in hand before the draw must not be on offer at all.
	var held := give_hand(0, "Shivan Dragon")
	assert_ok(g.activate_ability(0, sage, 0))
	resolve_stack()
	assert_eq(held.zone, Mtg.Zone.HAND, "the card already in hand is not one of the three drawn")
	assert_eq(g.players[0].hand.size(), 3)


func test_casting_of_bones_discards_one_of_the_three_it_drew() -> void:
	var bear := put_battlefield(0, "Grizzly Bears")
	var aura := give_hand(0, "Casting of Bones")
	add_mana(0, Mtg.ManaColor.B, 3)
	assert_ok(g.cast_spell(0, aura, [TargetRef.card(bear)]))
	resolve_stack()
	var held := give_hand(0, "Shivan Dragon")
	var terror := give_hand(0, "Terror")
	add_mana(0, Mtg.ManaColor.B, 2)
	assert_ok(g.cast_spell(0, terror, [TargetRef.card(bear)]))
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(held.zone, Mtg.Zone.HAND, "the card already in hand is not one of the three drawn")
	assert_eq(g.players[0].hand.size(), 3)


func test_a_seat_that_answers_nothing_still_discards_one_of_the_drawn_cards() -> void:
	g.set_agent(0, Silent.new())
	var sage := put_battlefield(0, "Soldevi Sage")
	put_battlefield(0, "Forest")
	put_battlefield(0, "Forest")
	var held := give_hand(0, "Shivan Dragon")
	assert_ok(g.activate_ability(0, sage, 0))
	resolve_stack()
	# Declining is not legal, so the first candidate is discarded anyway.
	assert_eq(held.zone, Mtg.Zone.HAND)
	assert_eq(g.players[0].hand.size(), 3)
