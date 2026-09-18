class_name ManaAnalysis
extends RefCounted
## `[QoL]` Whether the mana base can actually cast the deck.
##
## [DeckStats] answers *what is in here* with probability attached — how
## many lands in the opening seven, whether a colour shows up at all.
## This answers the harder question a mana base is built to answer: **is
## every card in this deck castable on its own turn, and if not, which
## colour is short and by how many sources.**
##
## **WHOSE NUMBERS THESE ARE.** Frank Karsten's tables are what every
## modern deck tool quotes for "sources needed to cast on curve", and the
## tool this page was measured against (edhcheck.com's mana analysis)
## re-derives them from the hypergeometric against the deck's real size
## rather than interpolating a published sixty-card table. This does the
## same, and for the same reason: a deck here can be forty cards or sixty
## or two hundred and fifty, and one scaled table would be wrong for all
## three.
##
## THE MODEL, stated so the numbers can be argued with: a seven-card
## opening hand, on the play, one card a turn, **no mulligan**, and 90%
## confidence. For sixty cards it reproduces the widely published turn-four
## figures exactly — 12 sources for a single pip, 20 for a double, 26 for
## a triple — and asks one or two more than Karsten does on turns one and
## two, because his simulation is allowed to throw back a hand with no
## source and this is not. So read every requirement here as a FLOOR: a
## deck that meets it does not need the mulligan to cast its spells.
##
## Exact, never simulated, like everything else in this window — two
## builds differing by one Forest differ in the second decimal because the
## deck differs, not because the dice did. Pure and static: the page is a
## view and `tests/ui/test_mana_analysis.gd` reads the numbers.

## The confidence every "sources needed" figure is solved for. Karsten's
## own threshold, and the one the whole literature quotes.
const CONFIDENCE := 0.90

## Past this the recursion in [method color_available] would rather
## approximate than think: it is the number of DISTINCT mana-production
## patterns a single card's colours can split the deck into, and a 1997
## card asks for at most three colours, so twelve is unreachable with a
## real pool. The guard exists so a proxy-stuffed deck cannot hang the
## window.
const MAX_CATEGORIES := 12


# -------------------------------------------------- sources, on curve --

## The fewest sources of one colour that make [param pips] of it available
## by [param turn] with [param confidence] — Karsten's question, solved
## for a deck of [param deck_size] rather than looked up in a table.
##
## Monotone in the source count, so the first count that clears the bar is
## the answer. Cached because the page asks for the same handful of
## (size, pips, turn) triples on every open.
static func sources_needed(deck_size: int, pips: int, turn: int,
		confidence := CONFIDENCE, on_play := true) -> int:
	if pips <= 0 or deck_size <= 0:
		return 0
	var key := "%d/%d/%d/%.4f/%s" % [deck_size, pips, turn, confidence, on_play]
	if _need_cache.has(key):
		return int(_need_cache[key])
	var seen := cards_seen(deck_size, turn, on_play)
	var answer := deck_size
	for sources in range(pips, deck_size + 1):
		if DeckStats.at_least(deck_size, sources, seen, pips) >= confidence:
			answer = sources
			break
	_need_cache[key] = answer
	return answer


## Ints only — never a [CardData] — so this may be a `static var`
## (CONTRIBUTING.md's rule about the static card table).
static var _need_cache: Dictionary = {}


## How many cards have been seen by [param turn]: the opening seven plus
## one a turn, one fewer on the play. The one place that arithmetic lives.
static func cards_seen(deck_size: int, turn: int, on_play := true) -> int:
	return mini(DeckStats.HAND + maxi(turn, 1) - (1 if on_play else 0), deck_size)


# ------------------------------------------- the colours of one spell --

## P(every colour requirement in [param need] is available by
## [param turn]) — `{Mtg.ManaColor.W: 2}` for `{1}{W}{W}`.
##
## EXACT, INCLUDING THE OVERLAPS, which is the whole difficulty. A deck's
## mana sources are not disjoint sets: a dual land is two colours at once
## and Birds of Paradise is five, so multiplying the per-colour chances
## together is wrong in both directions — it under-counts the dual that
## serves either half and over-counts two basics competing for the same
## seven cards. Instead the deck is cut into the disjoint groups that
## produce each COMBINATION of the wanted colours, the draw is a
## multivariate hypergeometric over those groups (written as a chain of
## ordinary ones, so nothing overflows), and a hand counts as castable
## when the sources it holds can be matched one-to-one against the pips.
##
## That matching is Hall's condition, checked over every subset of the
## wanted colours: `{W}{W}{U}` needs two W sources, one U source, and
## three sources between them — the third clause is the one a per-colour
## check misses, and it is exactly the clause that fails in a two-colour
## deck holding a single dual.
static func color_available(deck: DeckModel, need: Dictionary, turn: int,
		on_play := true) -> float:
	var pop := deck.total()
	if pop <= 0:
		return 0.0
	var cols: Array[int] = []
	var want: Array[int] = []
	for color in Mtg.WUBRG:      # canonical order, so the masks are stable
		var pips := int(need.get(color, 0))
		if pips > 0:
			cols.append(int(color))
			want.append(pips)
	if cols.is_empty():
		return 1.0
	var seen := cards_seen(pop, turn, on_play)
	var sources := deck.mana_sources()
	if cols.size() == 1:         # no overlap to reason about
		return DeckStats.at_least(pop, int(sources.get(cols[0], 0)), seen, want[0])

	var groups := {}             # production mask over `cols` -> copies
	for card_name in deck.counts:
		var d := DeckModel._card(card_name)
		if d == null:
			continue
		var mask := 0
		for produced in MiniCard.mana_colors(d):
			var i := cols.find(int(produced))
			if i >= 0:
				mask |= 1 << i
		if mask != 0:
			groups[mask] = int(groups.get(mask, 0)) + int(deck.counts[card_name])
	var masks: Array[int] = []
	for mask in groups:
		masks.append(int(mask))
	masks.sort()
	if masks.size() > MAX_CATEGORIES:
		return _independent_bound(deck, cols, want, seen)
	var pools: Array[int] = []
	for mask in masks:
		pools.append(int(groups[mask]))
	var drawn: Array[int] = []
	drawn.resize(masks.size())
	drawn.fill(0)
	return _scan(masks, pools, drawn, want, 0, pop, seen)


## One level of the multivariate hypergeometric: how many of group
## [param i] were drawn, times the chance of the rest.
##
## Both prunes are what keeps it quick. Once the sources already drawn can
## pay the cost, nothing later can unpay it, so the whole subtree is 1.0;
## once even taking every remaining source cannot pay it, the subtree is
## 0.0. In practice that settles a two-colour card in a few dozen nodes.
static func _scan(masks: Array[int], pools: Array[int], drawn: Array[int],
		want: Array[int], i: int, pop_left: int, draws_left: int) -> float:
	if _hall_ok(masks, drawn, want):
		return 1.0
	if i >= masks.size() or draws_left <= 0:
		return 0.0
	if _hall_hopeless(masks, pools, drawn, want, i, draws_left):
		return 0.0
	var total := 0.0
	for d in range(mini(pools[i], draws_left) + 1):
		var chance := DeckStats.hypergeometric(pop_left, pools[i], draws_left, d)
		if chance <= 0.0:
			continue
		drawn[i] = d
		total += chance * _scan(masks, pools, drawn, want, i + 1,
			pop_left - pools[i], draws_left - d)
	drawn[i] = 0                 # the caller's levels must see zeroes above them
	return total


## Hall's condition: for every subset of the wanted colours, the sources
## that can produce at least one colour in it must cover all of its pips.
## Necessary AND sufficient for a one-to-one matching of sources to pips,
## which is what "can pay this cost" means once the land drops are made.
static func _hall_ok(masks: Array[int], drawn: Array[int],
		want: Array[int]) -> bool:
	for subset in range(1, 1 << want.size()):
		var owed := 0
		for j in want.size():
			if subset & (1 << j):
				owed += want[j]
		var held := 0
		for k in masks.size():
			if masks[k] & subset:
				held += drawn[k]
		if held < owed:
			return false
	return true


## True when no arrangement of the groups still to come can satisfy
## [method _hall_ok] — the upper bound on what subset `subset` can still
## be given is whichever is smaller, the cards left to draw or the sources
## left that serve it.
static func _hall_hopeless(masks: Array[int], pools: Array[int],
		drawn: Array[int], want: Array[int], i: int, draws_left: int) -> bool:
	for subset in range(1, 1 << want.size()):
		var owed := 0
		for j in want.size():
			if subset & (1 << j):
				owed += want[j]
		var held := 0
		var reachable := 0
		for k in masks.size():
			if not (masks[k] & subset):
				continue
			held += drawn[k]
			if k >= i:
				reachable += pools[k]
		if held + mini(reachable, draws_left) < owed:
			return true
	return false


## The fallback for a deck whose sources split into more patterns than
## [constant MAX_CATEGORIES] — the per-colour chances multiplied, which is
## an approximation and is labelled one here rather than pretended
## otherwise. Unreachable with the 1997 pool; see the constant.
static func _independent_bound(deck: DeckModel, cols: Array[int],
		want: Array[int], seen: int) -> float:
	var sources := deck.mana_sources()
	var product := 1.0
	for j in cols.size():
		product *= DeckStats.at_least(deck.total(),
			int(sources.get(cols[j], 0)), seen, want[j])
	return product


# ------------------------------------------------- the deck, by colour --

## One row per colour the deck touches: what it asks for, what it has, the
## hardest single ask it makes, and whether the sources cover it.
##
## THE HARDEST ASK IS THE ONE THAT MATTERS. A deck can hold forty black
## pips and still be fine on twelve Swamps if every one of them is a
## single `{B}` on turn four; the same twelve are a disaster behind one
## `{B}{B}{B}` on turn three. So the requirement reported per colour is
## the largest [method sources_needed] any single card in the deck
## produces, and the card that produces it is named — a builder can then
## cut that card or add the lands, which are the only two moves available.
##
## Keys: `color`, `pips`, `sources`, `need`, `need_pips`, `need_turn`,
## `card`, `odds` (the chance that ask is met), `short` (0 when covered).
static func color_requirements(deck: DeckModel) -> Array:
	var pop := deck.total()
	var pips := DeckStats.color_pips(deck)
	var sources := deck.mana_sources()
	var out := []
	for color in Mtg.WUBRG:
		var pip_count := int(pips.get(color, 0))
		var source_count := int(sources.get(color, 0))
		if pip_count == 0 and source_count == 0:
			continue
		var need := 0
		var need_pips := 0
		var need_turn := 0
		var worst_card := ""
		for card_name in deck.counts:
			var d := DeckModel._card(card_name)
			if d == null or d.cost == null:
				continue
			var k := int(d.cost.colored.get(color, 0))
			if k <= 0:
				continue
			# Its own turn: the mana value, or the pip count when {X}
			# hides the rest of the cost (Braingeyser is {U}{U} on two).
			var turn := maxi(d.cost.mana_value(), k)
			var asks := sources_needed(pop, k, turn)
			if asks > need or (asks == need and k > need_pips):
				need = asks
				need_pips = k
				need_turn = turn
				worst_card = card_name
		var odds := 1.0
		if need_pips > 0:
			odds = DeckStats.at_least(pop, source_count,
				cards_seen(pop, need_turn), need_pips)
		out.append({"color": int(color), "pips": pip_count,
			"sources": source_count, "need": need, "need_pips": need_pips,
			"need_turn": need_turn, "card": worst_card, "odds": odds,
			"short": maxi(0, need - source_count)})
	return out


# ------------------------------------------------ the deck, card by card --

## Every non-land card with the chance its COLOURS are in hand on its own
## turn — mana value 3 means turn 3 — sorted worst first.
##
## Colours only, deliberately. Whether the land drops were made is the
## Draws page's question and is asked there for the whole deck at once;
## asking it again per card would multiply two things a player would then
## have to un-multiply to see which half is the problem. A card with no
## coloured pips is 1.0 and sorts to the back, which is honest: a Mox is
## never stuck on colour.
##
## Keys: `card`, `count`, `turn`, `odds`.
static func castability(deck: DeckModel, on_play := true) -> Array:
	var out := []
	for card_name in deck.counts:
		var d := DeckModel._card(card_name)
		if d == null or d.is_land() or d.cost == null:
			continue
		var need := {}
		for color in d.cost.colored:
			# {C} wants colorless mana specifically, not "any source" —
			# no 1997 card prints it, and treating it as a colour would
			# make every Wasteland a black source. Counted as generic by
			# [method mana_demand] instead.
			if int(color) != Mtg.ManaColor.C:
				need[int(color)] = int(d.cost.colored[color])
		var turn := maxi(d.cost.mana_value(), 1)
		out.append({"card": card_name, "count": int(deck.counts[card_name]),
			"turn": turn, "odds": color_available(deck, need, turn, on_play)})
	out.sort_custom(func(a, b):
		var pa := float(a["odds"])
		var pb := float(b["odds"])
		if pa != pb:
			return pa < pb
		return String(a["card"]) < String(b["card"]))
	return out


## The [param limit] worst of [method castability]'s [param rows] that are
## actually worth naming — anything already above [param ceiling] is not a
## problem a builder needs to read about. Takes the rows rather than the
## deck so the page can sort the deck once and ask twice.
static func worst_casts(rows: Array, limit := 4, ceiling := 0.95) -> Array:
	var out := []
	for row in rows:
		if float(row["odds"]) >= ceiling or out.size() >= limit:
			break
		out.append(row)
	return out


## The deck's cast rate: the mean of [method castability] weighted by
## COPIES, because four of a card that is stuck on colour is four times
## the problem one of it is.
static func average_castability(rows: Array) -> float:
	var weighted := 0.0
	var cards := 0
	for row in rows:
		var have := int(row["count"])
		weighted += float(row["odds"]) * float(have)
		cards += have
	return 0.0 if cards == 0 else weighted / float(cards)


# ---------------------------------------------------------- land count --

## How many lands the curve wants, and how many are in there.
##
## Karsten's published regression for sixty-card constructed —
## `19.59 + 1.90 * average mana value - 0.28 * cheap accelerants`
## ("How Many Lands Do You Need in Your Deck? An Updated Analysis",
## TCGplayer, 2022) — scaled by `deck size / 60`, which is the only
## honest way to carry it to the forty-card decks this game is mostly
## played with. The scaling is not a fudge: at the typical average cost of
## 3 the formula gives 25.3 lands in sixty and 16.9 in forty, and 17 is
## exactly the limited default that number is supposed to reproduce.
##
## Keys: `lands`, `want`, `average_cost`, `accelerants`, `size`.
static func land_advice(deck: DeckModel) -> Dictionary:
	var size := deck.total()
	var average := deck.average_cost()
	var accelerants := cheap_acceleration(deck)
	var want := 19.59 + 1.90 * average - 0.28 * float(accelerants)
	return {"lands": deck.land_count(),
		"want": maxf(0.0, want * float(size) / 60.0),
		"average_cost": average, "accelerants": accelerants, "size": size}


## Cheap acceleration: non-land cards of mana value two or less that MAKE
## MANA — the Moxen, Sol Ring, Birds of Paradise, Llanowar Elves, Dark
## Ritual — counted with copies.
##
## Karsten's term is "cheap card draw or mana ramp" and this counts only
## the ramp half, on purpose. The era's cheap draw is symmetrical
## (Howling Mine), conditional (Sindbad) or restricted (Ancestral Recall),
## and a text detector that reaches for the word "draw" also catches
## Fasting and Nafs Asp, which accelerate nobody. Counting only mana
## recommends slightly MORE land, which is the safe direction to be wrong
## in.
##
## Read from the card's own [member CardData.mana_abilities] where it has
## one, and from the oracle text otherwise, because a ritual adds mana
## through a spell effect rather than an ability and Dark Ritual is the
## most-played accelerant in the pool.
static func cheap_acceleration(deck: DeckModel) -> int:
	var total := 0
	for card_name in deck.counts:
		var d := DeckModel._card(card_name)
		if d == null or d.is_land() or d.cost == null:
			continue
		if d.cost.mana_value() > 2 or d.cost.has_x:
			continue
		if d.mana_abilities.is_empty() and not _adds_mana(d.oracle_text):
			continue
		total += int(deck.counts[card_name])
	return total


## "Add {B}{B}{B}", "Add three mana of any one color", "Add an amount of
## {B}" — every way the pool writes a spell that makes mana, and nothing
## else: the word is only ever used for mana on these cards, where a
## counter is "put" and a creature is "created".
static var _adds_mana_re: RegEx = null

static func _adds_mana(text: String) -> bool:
	if _adds_mana_re == null:
		_adds_mana_re = RegEx.new()
		_adds_mana_re.compile("(?i)\\badd\\b[^.]*(\\{|\\bmana\\b)")
	return _adds_mana_re.search(text) != null


# ------------------------------------------------- generic vs coloured --

## How much of what the deck asks for is COLOURLESS — generic symbols and
## `{C}` — against how much is coloured, with copies.
##
## The number a splash lives or dies on. A deck of `{4}{G}` costs is nearly
## colourless and can afford almost any mana base; the same mana value
## written `{1}{G}{G}{G}` is a different deck, and the Stats window has
## until now shown a curve that cannot tell them apart.
##
## Keys: `colored`, `generic`, `total`, `share` (the generic fraction).
static func mana_demand(deck: DeckModel) -> Dictionary:
	var colored := 0
	var generic := 0
	for card_name in deck.counts:
		var d := DeckModel._card(card_name)
		if d == null or d.is_land() or d.cost == null:
			continue
		var have := int(deck.counts[card_name])
		generic += d.cost.generic * have
		for color in d.cost.colored:
			if int(color) == Mtg.ManaColor.C:
				generic += int(d.cost.colored[color]) * have
			else:
				colored += int(d.cost.colored[color]) * have
	var total := colored + generic
	return {"colored": colored, "generic": generic, "total": total,
		"share": 0.0 if total == 0 else float(generic) / float(total)}
