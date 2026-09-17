extends GameTest
## Demonic Consultation names from the DECKLIST — the owner's 2026-09-07
## ruling ("only display selection of cards from ... deck"), which Petra
## Sphinx and Nebuchadnezzar already follow. Until 2026-09-17 the prompt
## listed every name in the card pool and used the decklist only to pick
## a default.


## Says a name if it is on offer, else the first — and remembers the list.
class Namer extends DecisionAgent:
	var says := ""
	var offered: Array[String] = []

	func answer_option(_game: MtgGame, _pid: int, _prompt: String,
			options: Array[String], _hint: int) -> int:
		offered = options.duplicate()
		var i := options.find(says)
		return i if i >= 0 else 0


func before_each() -> void:
	CardPacks.set_enabled(IceAgePack.ID, true)
	super()
	advance_to_step(Mtg.Step.MAIN1)


func after_each() -> void:
	g = null
	CardPacks.set_enabled(IceAgePack.ID, false)


## The library is thirty Forests; a Dark Ritual is slid in as the eighth
## card from the top, one past the six the spell exiles blind.
func _bury_ritual() -> CardInstance:
	var ritual := _make_instance(0, "Dark Ritual")
	ritual.zone = Mtg.Zone.LIBRARY
	var library: Array = g.players[0].library
	library.insert(library.size() - 7, ritual)
	g.players[0].deck_names.append("Dark Ritual")
	return ritual


func _consult(namer: Namer) -> void:
	var spell := give_hand(0, "Demonic Consultation")
	add_mana(0, Mtg.ManaColor.B)
	g.set_agent(0, namer)
	assert_ok(g.cast_spell(0, spell))
	resolve_stack()


func test_offers_the_decklist_and_nothing_else() -> void:
	var ritual := _bury_ritual()
	put_battlefield(0, "Grizzly Bears")    # on the table, never in the deck
	var namer := Namer.new()
	namer.says = "Dark Ritual"
	_consult(namer)
	assert_eq(namer.offered, ["Forest", "Dark Ritual"] as Array[String],
		"the deck's names, most copies unaccounted for first — not the pool")
	assert_false(namer.offered.has("Grizzly Bears"), "a name the deck never had cannot be said")
	assert_false(namer.offered.has("Black Lotus"), "nor a name from the wider pool")
	assert_eq(ritual.zone, Mtg.Zone.HAND, "found after the blind six and one more")
	assert_eq(g.players[0].exile.size(), 7, "six blind, one revealed on the way")
	assert_eq(g.players[0].library.size(), 23, "thirty-one less eight")


func test_the_default_name_is_the_likeliest_card() -> void:
	# A silent chooser (the computer) takes the first name on offer: the
	# one with most copies still unaccounted for.
	_bury_ritual()
	var namer := Namer.new()          # says nothing on the list → index 0
	namer.says = "Black Lotus"
	_consult(namer)
	assert_eq(namer.offered[0], "Forest")
	assert_eq(g.players[0].hand.size(), 1, "a Forest came to hand")
	assert_eq(g.players[0].hand[0].data.card_name, "Forest")
	assert_eq(g.players[0].exile.size(), 6, "the seventh card was the named one")


func test_naming_a_card_the_library_lacks_exiles_it_all() -> void:
	# A name the deck brought but whose only copy is in hand is still on
	# offer (the player may say it); the search then runs the library dry,
	# as the card reads.
	g.players[0].deck_names.append("Hill Giant")
	give_hand(0, "Hill Giant")
	var namer := Namer.new()
	namer.says = "Hill Giant"
	_consult(namer)
	assert_true(namer.offered.has("Hill Giant"))
	assert_true(g.players[0].library.is_empty(), "every card revealed and exiled")
	assert_eq(g.players[0].exile.size(), 30)
	assert_eq(g.players[0].hand.size(), 1, "only the Hill Giant that was already there")
