extends GameTest

const Sphinx = preload("res://cards/sets/leg/petra_sphinx.gd")
const Neb = preload("res://cards/sets/leg/nebuchadnezzar.gd")


func test_sphinx_ranks_registered_copies_minus_known_cards_without_a_library_scan() -> void:
	g.players[0].deck_names.assign(["Forest", "Island", "Island"])
	var before := Sphinx.RiddleEffect.nameable(g, 0)
	for card in g.players[0].library: card.data = CardRegistry.get_card("Island")
	assert_eq(Sphinx.RiddleEffect.nameable(g, 0), before)
	assert_eq(before[0], "Island")
	give_hand(0, "Island")
	assert_eq(Sphinx.RiddleEffect.nameable(g, 0)[0], "Forest",
		"the chooser knows its own hand; ties are alphabetical")


func test_opponent_face_down_identity_cannot_change_the_naming_hint() -> void:
	g.players[1].deck_names.assign(["Air Elemental", "Air Elemental",
		"Hill Giant", "Hill Giant"])
	var hidden := give_hand(1, "Air Elemental")
	g.put_from_hand_face_down(hidden, 1)
	var before := Neb.NameEffect.nameable(g, 1)
	hidden.data = CardRegistry.get_card("Hill Giant")
	g.recalculate()
	assert_eq(Neb.NameEffect.nameable(g, 1), before)
	assert_eq(before[0], "Air Elemental")


func test_public_copies_still_improve_the_naming_hint() -> void:
	g.players[1].deck_names.assign(["Air Elemental", "Air Elemental",
		"Hill Giant", "Hill Giant"])
	put_battlefield(1, "Air Elemental")
	assert_eq(Neb.NameEffect.nameable(g, 1)[0], "Hill Giant")
