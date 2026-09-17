class_name SampleHand
extends RefCounted
## [QoL] A SAMPLE HAND from the deck on the table — seven cards off the
## top of a shuffled copy, the Paris mulligan the duel plays, and one
## card a turn after that. The "goldfish" every paper player runs before
## a deck is sleeved: not a statistic but a HAND, looked at, so a build
## whose Draws page says 2-5 lands 80% of the time can also be seen to
## do it — or seen to hold Sengir Vampire, Sengir Vampire, Sengir
## Vampire and a Swamp, which the page never showed.
##
## THE RULES ARE THE DUEL'S, not a new set: the shuffle is the engine's
## own Fisher-Yates ([method MtgGame._shuffle]), the mulligan is the one
## `MtgGame`'s opening block plays since the owner's ruling of 2026-09-08
## — any hand may be thrown back, each redraw ONE CARD FEWER, down to an
## empty hand after the seventh, no bottoming — and the no-land /
## all-land test survives here exactly as it survives there: advice
## ([method is_mulligan_hand]), never a gate. The turns are the first
## player's, who draws no card on turn one, which is the harder case and
## the one a deck is tuned for.
##
## A MODEL AND NOTHING ELSE. Names, not [CardInstance]s: this is the deck
## builder, there is no game, and a proxy has no data at all. The Stats
## window's Hand page ([method DeckBuilderScreen._stats_page_hand]) draws
## what this holds; `tests/unit/test_sample_hand.gd` pins the rules
## without a screen.


## The cards not yet drawn, TOP OF THE LIBRARY LAST so a draw is a
## `pop_back`. Every copy is its own entry — four Swamps are four names.
var library: Array[String] = []

## The hand, in the order it was drawn.
var hand: Array[String] = []

## How many hands have been thrown back since [method new_hand] — the
## engine's `mulligans_taken`, for one seat. The hand is `7 - mulligans`
## cards, or fewer when the deck is smaller than that.
var mulligans := 0

## Which turn it is. One after the deal; [method next_turn] counts it up
## and draws.
var turn := 1

## The deck as a list, one name per copy, in [method DeckModel.names]
## order — so the same seed deals the same hand from the same deck.
var _cards: Array[String] = []

## Its own dice, like [member MtgGame.rng]: a seeded sample is a
## repeatable one, which is what the tests need and what nothing else
## minds.
var _rng := RandomNumberGenerator.new()


## From [param deck]'s MAIN pile — the sideboard is not in the library
## at the opening — with a fresh seed, or [param p_seed] when a caller
## wants the same deal twice. Nothing is dealt yet: [method new_hand].
func _init(deck: DeckModel = null, p_seed := -1) -> void:
	if p_seed >= 0:
		_rng.seed = p_seed
	else:
		_rng.randomize()
	if deck == null:
		return
	for card_name in deck.names():
		for i in int(deck.counts.get(card_name, 0)):
			_cards.append(card_name)


## How many cards the sample deals from — the main deck's total.
func deck_size() -> int:
	return _cards.size()


## Shuffle everything and deal a fresh seven (fewer from a deck smaller
## than seven). Turn one, no mulligans.
func new_hand() -> void:
	mulligans = 0
	_deal(7)


## Throw the hand back and draw one card fewer — the Paris rule as the
## duel plays it. Refused, and false, only when there is no hand left to
## throw back: the seventh mulligan draws nothing, and nothing cannot be
## shuffled away again ([method MtgGame.may_mulligan]).
func mulligan() -> bool:
	if not may_mulligan():
		return false
	mulligans += 1
	_deal(7 - mulligans)
	return true


## Is there a hand to throw back? The engine's own door, minus the seat
## and the keep — a sample has neither.
func may_mulligan() -> bool:
	return not hand.is_empty()


## How many cards the NEXT mulligan would draw — what the button says.
func next_hand_size() -> int:
	return mini(7 - mulligans - 1, _cards.size()) if may_mulligan() else 0


## The next turn: count it, and draw one card if the library has one.
## The name drawn, or "" from an empty library — the sample does not
## lose the game, it only stops drawing.
func next_turn() -> String:
	turn += 1
	if library.is_empty():
		return ""
	var drawn: String = library.pop_back()
	hand.append(drawn)
	return drawn


## How many of the hand are lands, by the registry's word. A proxy has no
## data and counts as a spell — it is what the player stands it in for,
## and the sample cannot know.
func lands_in_hand() -> int:
	var lands := 0
	for card_name in hand:
		if is_land_name(card_name):
			lands += 1
	return lands


## The 1997 rule's hand — no land at all, or nothing but land — as the
## engine names it ([method MtgGame.hand_is_a_mulligan_hand]): the reason
## the announcement gives, never a gate. An empty hand is neither.
func is_mulligan_hand() -> bool:
	if hand.is_empty():
		return false
	var lands := lands_in_hand()
	return lands == 0 or lands == hand.size()


## Cards left to draw.
func library_size() -> int:
	return library.size()


## Whether [param card_name] is a land — the registry's answer, and
## `false` for a name it does not carry (a proxy).
static func is_land_name(card_name: String) -> bool:
	var data := DeckModel._card(card_name)
	return data != null and data.is_land()


## Shuffle the whole deck and draw [param count] off the top. Turn one.
func _deal(count: int) -> void:
	turn = 1
	library = _cards.duplicate()
	_shuffle(library)
	hand.clear()
	for i in mini(count, library.size()):
		hand.append(library.pop_back())


## [method MtgGame._shuffle], on names.
func _shuffle(cards: Array[String]) -> void:
	for i in range(cards.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp := cards[i]
		cards[i] = cards[j]
		cards[j] = tmp
