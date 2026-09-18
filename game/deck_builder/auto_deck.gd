class_name AutoDeck
extends RefCounted
## [QoL] THE AI DECK BUILDER'S HEAD: a card pool and a handful of wishes
## in, a playable deck out. The 1997 program had nothing like it — its
## computer opponents played decks a designer had typed in — and the
## deck-lotus tool the owner pointed at (2026-09-18) turns out to have
## no automatic builder either, only a list parser and a stats view, so
## the method here is our own and it is written down so it can be argued
## with:
##
## 1. SCORE every card in the pool on its own ([method score]): a creature
##    by its body per mana — power before toughness — with the duel AI's
##    own keyword prices ([constant Evaluator.KEYWORD_VALUE]) and a
##    little for each ability, less its drawbacks and less again when its
##    mana value is one a game rarely reaches; a spell by the roles the duel AI reads off it
##    ([method AiDeckStudy.classify] — removal, burn, counters, card draw
##    and the rest), cheaper being better and the lean weighing the roles
##    ([constant LEAN_ROLE_SCALE]: a deck of creatures wants its pump and
##    not a sweeper); a narrow answer (colour hate, a Circle of
##    Protection) is marked down, since the deck is built blind to its
##    opponent. The SPEED then prices the mana value ([method worth],
##    [constant TEMPO]): a fast deck prizes what it can cast on the first
##    turn and discounts what it cannot cast before the fourth, a slow
##    deck the other way round.
## 2. CHOOSE THE COLOURS ([method _choose_colors]): every colour set the
##    wishes allow is rated by the sum of its best castable cards, a few
##    per cent off for every extra colour, and the best one wins; the
##    colours asked for are always in it.
## 3. FILL THE SPELLS ([method _fill_spells]) greedily, one card at a
##    time: the best worth after two firm nudges — towards the speed's
##    mana curve ([constant CURVES]: a fast deck is three parts in ten
##    first-turn castables, a slow deck one part in twenty-five) and
##    towards the creature share asked for — and a growing reluctance to
##    take a third and fourth copy of the same card. The four-of rule is
##    [method DeckModel.duplicates_allowed]'s, restricted cards are one
##    copy and banned cards never come under tournament rules.
## 4. LAY THE LANDS ([method _lay_lands]): the count the speed asks for,
##    dual lands of the deck's colours first, then basic lands in the
##    proportion of the coloured pips. Basic lands are never scarce.
##
## Nothing here consults an opponent or a game: the same pool, wishes
## and [member seed] build the same deck, which is what makes it a
## thing a test can hold still.

## The two deck sizes on offer — the 1997 floor and the tournament norm.
const SIZES: Array[int] = [40, 60]
## The creature share of the non-land cards, by the lean asked for.
const LEAN_CREATURES := "creatures"
const LEAN_BALANCED := "balanced"
const LEAN_SPELLS := "spells"
const LEANS: Array[String] = [LEAN_CREATURES, LEAN_BALANCED, LEAN_SPELLS]
const CREATURE_SHARE := {LEAN_CREATURES: 0.70, LEAN_BALANCED: 0.55, LEAN_SPELLS: 0.38}
## The speeds, and what each means in lands and in the curve.
const SPEED_FAST := "fast"
const SPEED_MEDIUM := "medium"
const SPEED_SLOW := "slow"
const SPEEDS: Array[String] = [SPEED_FAST, SPEED_MEDIUM, SPEED_SLOW]
## Lands by size and speed. The shipped decks run 34-37% land; a fast
## deck of one-drops wants a little less, a deck of six-drops a little
## more.
const LANDS := {
	40: {SPEED_FAST: 15, SPEED_MEDIUM: 16, SPEED_SLOW: 17},
	60: {SPEED_FAST: 22, SPEED_MEDIUM: 24, SPEED_SLOW: 25},
}
## The share of the spells at each mana value — 1 (and 0), 2, 3, 4 and 5
## or more — the fill holds to, by speed. The first bucket is the
## first-turn castables: a fast deck is three parts in ten of them and
## averages about 2.3 mana a spell, a slow deck one part in twenty-five
## and averages about 3.6.
const CURVES := {
	SPEED_FAST: [0.30, 0.34, 0.22, 0.10, 0.04],
	SPEED_MEDIUM: [0.12, 0.28, 0.28, 0.18, 0.14],
	SPEED_SLOW: [0.04, 0.18, 0.28, 0.26, 0.24],
}
## What the speed makes of a mana value: a factor on the score by curve
## bucket ([method worth]). A fast deck prizes its one-drops a fifth
## over and takes a five-drop at seven tenths; a slow deck the other
## way round, less sharply, since it still wants a two-drop or two;
## medium takes every card at its score.
const TEMPO := {
	SPEED_FAST: [1.2, 1.1, 1.0, 0.85, 0.7],
	SPEED_MEDIUM: [1.0, 1.0, 1.0, 1.0, 1.0],
	SPEED_SLOW: [0.8, 0.9, 1.0, 1.1, 1.15],
}
## The firm nudges of the fill: a bucket of the curve, or the creature
## share, a whole share over or under the wish moves a card's value by
## [constant NUDGE], capped at [constant NUDGE_CAP] — about what a good
## card scores, so what was asked for is met unless the pool has only
## junk left where it wants more.
const NUDGE := 3.0
const NUDGE_CAP := 2.5
## The rarity ceilings: anything, no rares (and no legends), commons only.
const RARITY_ANY := ""
const RARITY_CAPS: Array[String] = [RARITY_ANY, "uncommon", "common"]
const RARITY_RANK := {"common": 0, "uncommon": 1, "rare": 2, "legendary": 3}
## The five basic lands and the colour each makes.
const BASICS := {"Plains": Mtg.ManaColor.W, "Island": Mtg.ManaColor.U,
	"Swamp": Mtg.ManaColor.B, "Mountain": Mtg.ManaColor.R, "Forest": Mtg.ManaColor.G}
## Copies of one non-basic land, and the share of the lands they may be.
const DUAL_CAP := 4
const NONBASIC_SHARE := 0.34
## A legend is one in play at a time; two in the deck is plenty.
const LEGEND_CAP := 2
## The reluctance to take another copy of the same card: nothing for the
## first, and more each time. A fast deck wants its best cards every
## game, so it minds less.
const COPY_PENALTY := [0.0, 0.2, 0.5, 0.9]
const FAST_COPY_SCALE := 0.7
## How much of a creature's worth its mana value lets through: a
## five-drop is cast most games, an eight-drop is a dead card in half of
## them. Mana values under five pass whole.
const CAST_EASE := {5: 0.9, 6: 0.8, 7: 0.65}
const CAST_EASE_FLOOR := 0.5
## A card whose mana ability makes none of the deck's colours — a Green
## Mana Battery in a blue-black deck — is a rock, whatever its score.
const OFF_COLOR_MANA := 1.0
## Prices for the keywords the duel AI does not price, in the same
## stat-point unit as [constant Evaluator.KEYWORD_VALUE].
const MORE_KEYWORDS := {Mtg.Keyword.HASTE: 0.7, Mtg.Keyword.UNBLOCKABLE: 1.5,
	Mtg.Keyword.FEAR: 1.0}
## What a spell's role is worth — the roles are [method
## AiDeckStudy.classify]'s. A card's value is its best role plus a little
## for each further one.
const ROLE_WORTH := {
	"removal": 2.4, "burn": 2.2, "sweeper": 1.9, "draw": 1.9, "counter": 1.8,
	"tokens": 1.5, "bounce": 1.3, "discard": 1.3, "acceleration": 1.0,
	"reanimation": 1.2, "recursion": 0.9, "pump": 0.9, "land_denial": 0.8,
	"tap_payoff": 0.8, "untap": 0.6, "mill": 0.6, "life_mana": 0.6,
	"x_damage": 0.3, "sacrifice_outlet": 0.3,
}
## What the lean makes of a role, a factor on [constant ROLE_WORTH]: a
## deck of creatures wants its pump and its tokens and not a sweeper
## that kills its own; a deck of spells wants the sweeper, the counters
## and the card draw the more, and has little to pump.
const LEAN_ROLE_SCALE := {
	LEAN_CREATURES: {"pump": 1.6, "tokens": 1.2, "sweeper": 0.5},
	LEAN_BALANCED: {},
	LEAN_SPELLS: {"sweeper": 1.3, "counter": 1.2, "draw": 1.2, "pump": 0.6},
}
## The answer keys ([method AiSideboard.answers]) that make a card BROAD
## — it answers creatures, which every deck has.
const BROAD_ANSWERS: Array[String] = ["creature", "flying"]

## The pool: `name -> copies on offer`, never a basic land (they are
## always free) and never a name the registry does not know.
var pool: Dictionary = {}
## Where the pool came from, for the report — "Fourth Edition and The
## Dark", "the dealt cards", "pool.txt".
var pool_label := "the library"
## The wishes.
var size := 60
## The colours asked for, a [enum Mtg.ManaColor] mask; 0 lets the builder
## choose them all.
var colors := 0
## How many colours the deck may have, 1 to 3.
var max_colors := 2
var lean := LEAN_BALANCED
var speed := SPEED_MEDIUM
var rarity_cap := RARITY_ANY
## Tournament rules: no banned card (the nine ante cards among them),
## restricted cards one copy.
var tournament := true
## The deck to build AROUND — its non-land cards go in first and its
## colours are the deck's. Null builds from nothing.
var keep: DeckModel = null
## The roll; 0 asks for a fresh one, and [member roll] then holds it.
var seed := 0
var roll := 0

## What the last [method build] chose, for the window and the notes.
var chosen_colors := 0
var report: Array[String] = []
## Basic lands laid because the pool ran out of spells.
var short_by := 0

var _rng := RandomNumberGenerator.new()
var _scores: Dictionary = {}


# ------------------------------------------------------------- the pools --

## A pool of [param copies] of every name in [param names] — a whole set,
## or a whole library. Basics and unknown names are left out.
static func pool_from_names(names: Array, copies := 4) -> Dictionary:
	var out := {}
	for name in names:
		var card_name := String(name)
		if not CardRegistry.has_card(card_name) or BASICS.has(card_name):
			continue
		out[card_name] = copies
	return out


## Every card the registry puts in any of [param set_codes], with the
## Extras window's two switches honoured the way the Inventory honours
## them ([method CardRegistry.card_in_set]).
static func pool_from_sets(set_codes: Array, completion_on := true,
		original_on := true, copies := 4) -> Dictionary:
	CardRegistry.ensure_loaded()
	var names: Array = []
	for name in CardRegistry.all_names():
		for code in set_codes:
			if CardRegistry.card_in_set(String(name), String(code), completion_on, original_on):
				names.append(name)
				break
	return pool_from_names(names, copies)


## A pool from counted names — a dealt [member SealedPool.counts], or a
## deck's own [member DeckModel.counts]. Basics and unknown names are
## left out, so a pool never holds what the builder cannot play.
static func pool_from_counts(counts: Dictionary) -> Dictionary:
	var out := {}
	for name in counts:
		var card_name := String(name)
		if not CardRegistry.has_card(card_name) or BASICS.has(card_name):
			continue
		if int(counts[name]) > 0:
			out[card_name] = int(out.get(card_name, 0)) + int(counts[name])
	return out


## A pool from a decklist's text — the same lines a `.deck` file holds
## (`4 Lightning Bolt`, `SB:` lines count too, `#` comments skipped),
## read leniently by [method DeckList.parse]. Names the game does not
## have are listed in [param out_report] and left out; a line that is not
## a card line at all is an error and the pool is empty.
static func pool_from_text(text: String, out_report: Array) -> Dictionary:
	var list := DeckList.new()
	list.parse(text, "pool", false, false)
	if not list.errors.is_empty():
		out_report.append_array(list.errors)
		return {}
	var counts := {}
	for name in list.cards:
		counts[name] = int(counts.get(name, 0)) + 1
	for name in list.sideboard:
		counts[name] = int(counts.get(name, 0)) + 1
	if not list.proxies.is_empty():
		out_report.append("%d name%s the game does not have: %s" % [
			list.proxies.size(), "" if list.proxies.size() == 1 else "s",
			", ".join(list.proxies)])
	return pool_from_counts(counts)


## Copies on offer, all names together.
static func pool_total(counts: Dictionary) -> int:
	var n := 0
	for name in counts:
		n += int(counts[name])
	return n


## The pool as a [SealedPool], for the Inventory to offer under the pool
## medallion: the pool's own copies, and [param basics] of each basic
## land, since the builder treats those as free.
func to_sealed_pool(basics := 0) -> SealedPool:
	var out := SealedPool.new()
	out.counts = pool.duplicate()
	for land in BASICS:
		out.counts[land] = maxi(basics, size)
	out.packs.append({"title": "AI deck builder", "cards": out.names()})
	return out


# ------------------------------------------------------------- the build --

## Build the deck. Never null: an empty pool builds a deck of basic
## lands and says so in [member report].
func build() -> DeckModel:
	CardRegistry.ensure_loaded()
	_scores.clear()
	report.clear()
	short_by = 0
	roll = seed if seed != 0 else randi_range(1, 999_999)
	_rng.seed = roll
	if not SIZES.has(size):
		size = 60
	max_colors = clampi(max_colors, 1, 3)
	var out := DeckModel.new()
	var limit := DeckModel.duplicates_allowed(size)
	if limit <= 0:
		limit = 4
	# The kept cards first: they are the deck's, whatever the pool holds.
	var required := colors
	var kept := 0
	if keep != null:
		for name in keep.names():
			var card_name := String(name)
			var data := DeckModel._card(card_name)
			if data == null or data.is_land():
				continue
			required |= data.color_mask() & ~Mtg.ManaColor.C
			for i in int(keep.counts[card_name]):
				out.add(card_name)
				kept += 1
	var candidates := _candidates(limit)
	chosen_colors = _choose_colors(candidates, required)
	var land_total := int(LANDS[size][speed])
	_fill_spells(out, candidates, size - land_total)
	_lay_lands(out, candidates, land_total)
	out.deck_name = deck_name()
	_write_report(out, kept)
	out.notes = "\n".join(report)
	return out


## The deck's name from what was built: "Red-Green Beatdown".
func deck_name() -> String:
	var archetype: Dictionary = {
		LEAN_CREATURES: {SPEED_FAST: "Rush", SPEED_MEDIUM: "Beatdown", SPEED_SLOW: "Stompy"},
		LEAN_BALANCED: {SPEED_FAST: "Aggro", SPEED_MEDIUM: "Midrange", SPEED_SLOW: "Big"},
		LEAN_SPELLS: {SPEED_FAST: "Tempo", SPEED_MEDIUM: "Spells", SPEED_SLOW: "Control"},
	}
	return "%s %s" % [color_phrase(chosen_colors), String(archetype[lean][speed])]


## "Mono-White", "Blue-Black", "White-Blue-Black" — in WUBRG order.
static func color_phrase(mask: int) -> String:
	var names: PackedStringArray = []
	for color in Mtg.WUBRG:
		if mask & color:
			names.append(String(Mtg.COLOR_NAMES[color]))
	if names.is_empty():
		return "Colourless"
	if names.size() == 1:
		return "Mono-%s" % names[0]
	return "-".join(names)


## The pool's playable cards as `[CardData, copies allowed]`, the copies
## the smaller of the pool's and the rules', sorted by name so a seed
## means the same deck whatever order the pool came in.
func _candidates(limit: int) -> Array:
	var out: Array = []
	var names: Array = pool.keys()
	names.sort()
	for name in names:
		var card_name := String(name)
		var data := DeckModel._card(card_name)
		if data == null:
			continue
		if rarity_cap != RARITY_ANY:
			var tier := DeckStats.rarity_tier(data)
			if int(RARITY_RANK.get(tier, 0)) > int(RARITY_RANK[rarity_cap]):
				continue
		var cap := mini(int(pool[card_name]), limit)
		if tournament:
			if DeckFormat.BANNED.has(card_name):
				continue
			if DeckFormat.RESTRICTED.has(card_name):
				cap = mini(cap, 1)
		if (data.supertypes & Mtg.Supertype.LEGENDARY) != 0:
			cap = mini(cap, LEGEND_CAP)
		if cap > 0:
			out.append([data, cap])
	return out


## Every colour set the wishes allow, rated by the sum of its best
## castable spells' scores (each copy after the first worth less, as the
## fill will find), with a few per cent off for every extra colour so a
## deep pool does not always end three colours. The colours asked for
## are in every set; asking for more than [member max_colors] widens it.
func _choose_colors(candidates: Array, required: int) -> int:
	var must := required & ~Mtg.ManaColor.C
	var most := maxi(max_colors, _count_colors(must))
	var best_mask := must
	var best_worth := -1.0
	var spells := int(size - int(LANDS[size][speed]))
	for mask in range(1, 32):
		if (mask & must) != must or _count_colors(mask) > most:
			continue
		var worth := _mask_worth(candidates, mask, spells)
		worth *= 1.0 - 0.06 * (_count_colors(mask) - 1)
		if worth > best_worth:
			best_worth = worth
			best_mask = mask
	return best_mask


static func _count_colors(mask: int) -> int:
	var n := 0
	for color in Mtg.WUBRG:
		if mask & color:
			n += 1
	return n


## The sum of the top [param slots] castable spell scores under
## [param mask], copies after the first discounted as the fill discounts
## them.
func _mask_worth(candidates: Array, mask: int, slots: int) -> float:
	var values: Array[float] = []
	for entry in candidates:
		var data: CardData = entry[0]
		if data.is_land() or not castable(data, mask):
			continue
		var value := worth(data)
		for n in int(entry[1]):
			values.append(value - COPY_PENALTY[mini(n, COPY_PENALTY.size() - 1)])
	values.sort()
	values.reverse()
	var worth := 0.0
	for i in mini(slots, values.size()):
		worth += values[i]
	return worth


## Whether every coloured pip of [param data] is in [param mask].
static func castable(data: CardData, mask: int) -> bool:
	return (data.color_mask() & ~Mtg.ManaColor.C & ~mask) == 0


## The greedy fill: [param slots] non-land cards, each the best worth
## after the nudges. Nothing castable left stops it short, and the lands
## make up the difference ([method _lay_lands]).
func _fill_spells(out: DeckModel, candidates: Array, slots: int) -> void:
	var curve: Array = CURVES[speed]
	var wanted: Array[float] = []
	for share in curve:
		wanted.append(float(share) * slots)
	var creatures_wanted := float(CREATURE_SHARE[lean]) * slots
	var spells_wanted := slots - creatures_wanted
	var have: Array[int] = [0, 0, 0, 0, 0]
	var creatures_have := 0
	var placed := 0
	# What the kept cards already take up.
	for name in out.names():
		var data := DeckModel._card(String(name))
		if data == null or data.is_land():
			continue
		var copies := int(out.counts[name])
		have[_bucket(data)] += copies
		if data.is_creature():
			creatures_have += copies
		placed += copies
	# The castable candidates priced once — `[data, copies, value,
	# bucket]` — since the colours are chosen and the strains do not move
	# while the deck fills; the loop below adds only the nudges. (Priced
	# in the loop, a 60-card build from the whole library scored every
	# card forty times over.)
	var picks: Array = []
	for entry in candidates:
		var data: CardData = entry[0]
		if data.is_land() or not castable(data, chosen_colors):
			continue
		picks.append([data, int(entry[1]),
			worth(data) - _pip_strain(data) - _off_color_mana(data), _bucket(data)])
	var copy_scale := FAST_COPY_SCALE if speed == SPEED_FAST else 1.0
	while placed < slots:
		var best: CardData = null
		var best_value := -INF
		for pick in picks:
			var data: CardData = pick[0]
			var n := out.count_of(data.card_name)
			if n >= int(pick[1]):
				continue
			var bucket := int(pick[3])
			var value: float = pick[2]
			# The curve and the lean are both firm nudges ([constant
			# NUDGE]). A soft curve — 0.9 a share, floored at -1.5 — let
			# the score walk over it: a slow deck kept six one-drops and
			# a fast deck ran its two-drops a third under the wish; a 0.8
			# lean left a "more spells" deck at the balanced share, the
			# library's creatures being that much deeper than its spells.
			value += clampf(NUDGE * (wanted[bucket] - have[bucket]) / maxf(wanted[bucket], 1.0),
				-NUDGE_CAP, NUDGE_CAP)
			if data.is_creature():
				value += clampf(NUDGE * (creatures_wanted - creatures_have) / maxf(creatures_wanted, 1.0),
					-NUDGE_CAP, NUDGE_CAP)
			else:
				value += clampf(NUDGE * (spells_wanted - (placed - creatures_have)) / maxf(spells_wanted, 1.0),
					-NUDGE_CAP, NUDGE_CAP)
			value -= COPY_PENALTY[mini(n, COPY_PENALTY.size() - 1)] * copy_scale
			# A hair of chance, so two builds from one pool are not one deck.
			value += _rng.randf() * 0.05
			if value > best_value:
				best_value = value
				best = data
		if best == null:
			break
		out.add(best.card_name)
		have[_bucket(best)] += 1
		if best.is_creature():
			creatures_have += 1
		placed += 1
	short_by = slots - placed


## The curve bucket of a spell: 0 for mana value 0 and 1, then 2, 3, 4,
## and 5 or more.
static func _bucket(data: CardData) -> int:
	return clampi(data.cost.mana_value() - 1, 0, 4)


## The rock: a mana ability that makes only colours the deck is not.
func _off_color_mana(data: CardData) -> float:
	var made := produces(data)
	if made == 0 or (made & Mtg.ManaColor.C) != 0:
		return 0.0
	return 0.0 if (made & chosen_colors) != 0 else OFF_COLOR_MANA


## Double and triple pips of one colour are harder to have in a deck of
## two or three colours; a mono-coloured deck does not mind.
func _pip_strain(data: CardData) -> float:
	if _count_colors(chosen_colors) <= 1:
		return 0.0
	var strain := 0.0
	for color in data.cost.colored:
		var pips := int(data.cost.colored[color])
		if pips > 1:
			strain += 0.15 * (pips - 1)
	return strain


## The lands: non-basic lands of the deck's colours first, dual lands
## before single ones and at most [constant NONBASIC_SHARE] of the total,
## then basics in the proportion of the coloured pips, every colour with
## a pip getting at least two. A deck the pool could not fill takes the
## difference in basics as well.
func _lay_lands(out: DeckModel, candidates: Array, land_total: int) -> void:
	var total := land_total + short_by
	var nonbasic_room := int(floor(NONBASIC_SHARE * land_total))
	var duals: Array = []
	for entry in candidates:
		var data: CardData = entry[0]
		if not data.is_land():
			continue
		var made := produces(data) & ~Mtg.ManaColor.C
		if made == 0 or (made & ~chosen_colors) != 0:
			continue
		duals.append([data, mini(int(entry[1]), DUAL_CAP), _count_colors(made)])
	duals.sort_custom(func(a: Array, b: Array) -> bool:
		if a[2] != b[2]:
			return a[2] > b[2]
		return (a[0] as CardData).card_name < (b[0] as CardData).card_name)
	var laid := 0
	for row in duals:
		for i in int(row[1]):
			if laid >= nonbasic_room:
				break
			out.add((row[0] as CardData).card_name)
			laid += 1
	# The basics, by the pips.
	var pips := {}
	var pip_total := 0
	for name in out.names():
		var data := DeckModel._card(String(name))
		if data == null or data.is_land():
			continue
		for color in data.cost.colored:
			if chosen_colors & int(color):
				pips[color] = int(pips.get(color, 0)) + int(data.cost.colored[color]) * int(out.counts[name])
				pip_total += int(data.cost.colored[color]) * int(out.counts[name])
	var basics_left := total - laid
	var shares := {}
	var colors_used: Array = []
	for color in Mtg.WUBRG:
		if chosen_colors & color:
			colors_used.append(color)
	if pip_total == 0:
		# Nothing coloured to cast: the colours asked for, evenly.
		for color in colors_used:
			pips[color] = 1
			pip_total += 1
	var given := 0
	for color in colors_used:
		var pip := int(pips.get(color, 0))
		if pip == 0:
			continue
		var share := maxi(2, int(floor(float(basics_left) * pip / pip_total)))
		shares[color] = share
		given += share
	# Largest remainder for what floor left over, and a trim when the
	# floors of two already exceed the room.
	var order: Array = shares.keys()
	order.sort_custom(func(a: int, b: int) -> bool:
		var ra := float(basics_left) * int(pips[a]) / pip_total - int(shares[a])
		var rb := float(basics_left) * int(pips[b]) / pip_total - int(shares[b])
		return ra > rb)
	var i := 0
	while given < basics_left and not order.is_empty():
		shares[order[i % order.size()]] += 1
		given += 1
		i += 1
	while given > basics_left and not order.is_empty():
		var most: int = order[0]
		for color in order:
			if int(shares[color]) > int(shares[most]):
				most = color
		if int(shares[most]) <= 0:
			break
		shares[most] -= 1
		given -= 1
	for color in colors_used:
		var land := _basic_for(int(color))
		for n in int(shares.get(color, 0)):
			out.add(land)


static func _basic_for(color: int) -> String:
	for land in BASICS:
		if int(BASICS[land]) == color:
			return String(land)
	return "Plains"


## The colours a card's mana abilities make, as a mask.
static func produces(data: CardData) -> int:
	var mask := 0
	for ability in data.mana_abilities:
		for pair in ability.produces:
			mask |= int(pair[0])
	return mask


# ------------------------------------------------------------- the score --

## How good a card is on its own, in the pool's own terms — see the class
## doc. Cached by name for the build.
func score(data: CardData) -> float:
	if _scores.has(data.card_name):
		return float(_scores[data.card_name])
	var value := _creature_score(data) if data.is_creature() else _spell_score(data)
	_scores[data.card_name] = value
	return value


## The score priced for the speed: [method score] times the speed's
## [constant TEMPO] for the card's mana value. This is what the colour
## choice and the fill go by, so a fast deck is drawn to the colours
## with the best one-drops and a slow deck to the colours with the best
## big spells.
func worth(data: CardData) -> float:
	return score(data) * float(TEMPO[speed][_bucket(data)])


## Power counts for more than toughness — the deck is built to win —
## and a creature that cannot hurt anyone (no power, or a defender) is
## worth half its body, its abilities apart. The body's worth is then
## measured against par — twice the mana value — so a 2/2 for two and a
## 4/4 for four score the same, a 2/1 for one scores better than either,
## and a fat thing for eight is not worth what its stats say ([constant
## CAST_EASE]). Where on the curve the deck's creatures land is the
## fill's business, not the score's ([method _fill_spells]).
func _creature_score(data: CardData) -> float:
	var worth := 1.2 * data.power + 0.8 * data.toughness
	for keyword in data.keywords:
		worth += float(Evaluator.KEYWORD_VALUE.get(keyword, 0.0))
		worth += float(MORE_KEYWORDS.get(keyword, 0.0))
	if not data.landwalk.is_empty():
		worth += 0.8
	if data.protection_from != 0:
		worth += 0.6
	if data.rampage > 0:
		worth += 0.3
	if data.power <= 0 or data.keywords.has(Mtg.Keyword.DEFENDER):
		worth *= 0.5
	if not data.mana_abilities.is_empty():
		worth += 1.2
	for ability in data.activated_abilities:
		var regenerates := false
		for effect in ability.effects:
			if effect is RegenerateEffect:
				regenerates = true
		worth += 0.6 if regenerates else 0.5
	if not data.triggered_abilities.is_empty():
		worth += 0.3
	if not data.static_abilities.is_empty():
		worth += 0.4
	worth -= _drawbacks(data)
	var mana := maxi(data.cost.mana_value(), 1)
	var ease := 1.0 if mana < 5 else float(CAST_EASE.get(mana, CAST_EASE_FLOOR))
	# Par is a body of twice the mana value — a 2/2 for two, a 4/4 for
	# four — and par scores about 2.5, where a fair spell scores too.
	return maxf(worth / (2.0 * mana + 1.0) * 3.0 * ease, 0.0)


## The upkeep clauses and the like, read off the oracle text the way the
## duel AI reads roles off it.
static func _drawbacks(data: CardData) -> float:
	var line := data.oracle_text.to_lower()
	var cost := 0.0
	if "cumulative upkeep" in line:
		cost += 1.5
	elif "upkeep" in line and ("sacrifice" in line or "pay" in line
			or "damage to you" in line or "lose" in line):
		cost += 0.8
	if "can't block" in line:
		cost += 0.5
	if "doesn't untap" in line or "does not untap" in line:
		cost += 1.0
	if "can't attack" in line:
		cost += 0.8
	if "sacrifice" in line and ("end of turn" in line or "end step" in line):
		cost += 0.8
	return cost


func _spell_score(data: CardData) -> float:
	var roles := AiDeckStudy.classify(data)
	var answers := AiSideboard.answers(data)
	var best := 0.0
	var others := 0
	var scale: Dictionary = LEAN_ROLE_SCALE[lean]
	for role in roles:
		var worth := float(ROLE_WORTH.get(role, 0.0)) * float(scale.get(role, 1.0))
		if role == "removal" and answers.is_empty():
			# Removal the sideboard reads no answer off is removal of
			# something no deck need have — a Wall (Tunnel), a land
			# (Stone Rain), an Aura on a land (Pyramids). Not a slot.
			continue
		if role == "burn":
			# Burn by its damage: Lightning Bolt's three is the unit,
			# Psychic Purge's one is a third of a card, and an X spell
			# is whatever the mana is.
			var intent := EffectIntent.read(_spell_effects(data), data.card_name)
			if not intent.damage_uses_x:
				worth *= clampf(intent.damage / 3.0, 0.3, 1.3)
		if worth > best:
			if best > 0.0:
				others += 1
			best = worth
		elif worth > 0.0:
			others += 1
	if data.aura_steals:
		# Control Magic: the duel AI reads no role off a steal, and it
		# is removal and a creature in one.
		best = maxf(best, float(ROLE_WORTH["removal"]))
	var value := 0.5 + best + 0.25 * mini(others, 2)
	if best == 0.0:
		# A card the duel AI reads no role off: an enchantment or an
		# artifact that does something quieter. Worth a look, not a slot.
		value = 1.1 if not data.static_abilities.is_empty() else 0.8
	if data.is_aura():
		value -= 0.2
	if speed == SPEED_SLOW and roles.has("artifact_mana"):
		value += 0.4
	elif speed == SPEED_FAST and roles.has("artifact_mana"):
		value -= 0.3
	value *= clampf(1.8 / (data.cost.mana_value() + 1.0) + 0.5, 0.7, 1.2)
	value -= _narrowness(data)
	return maxf(value, 0.0)


## A card's effects, its own and its activated abilities', the way
## [method AiDeckStudy.classify] gathers them.
static func _spell_effects(data: CardData) -> Array:
	var effects: Array = data.spell_effects.duplicate()
	for ability in data.activated_abilities:
		effects.append_array(ability.effects)
	return effects


## How narrow an answer the card is: a colour's or a land type's hate is
## dead against most decks, an artifact's or an enchantment's is dead
## against some; a creature's is never.
static func _narrowness(data: CardData) -> float:
	var keys := AiSideboard.answers(data)
	if keys.is_empty():
		return 0.0
	for key in keys:
		if BROAD_ANSWERS.has(key):
			return 0.0
	for key in keys:
		if key.begins_with("color:") or key.begins_with("damage:") or key.begins_with("land:"):
			return 1.8
	return 1.0


# ------------------------------------------------------------ the report --

## The notes the deck carries: what was asked, what was chosen and why
## the numbers are what they are.
func _write_report(out: DeckModel, kept: int) -> void:
	var lean_words := {LEAN_CREATURES: "mostly creatures",
		LEAN_BALANCED: "creatures and spells in balance", LEAN_SPELLS: "mostly spells"}
	report.append("Built by the AI deck builder: %d cards, %s, %s speed, %s." % [
		out.total(), color_phrase(chosen_colors), speed, String(lean_words[lean])])
	report.append("Card pool: %s (%d cards on offer)." % [pool_label, pool_total(pool)])
	var lands: Array[String] = []
	var land_count := 0
	var pips := {}
	var curve := [0, 0, 0, 0, 0]
	var creatures := 0
	var spells := 0
	var mana := 0
	for name in out.names():
		var data := DeckModel._card(String(name))
		var copies := int(out.counts[name])
		if data == null:
			continue
		if data.is_land():
			lands.append("%d %s" % [copies, name])
			land_count += copies
			continue
		curve[_bucket(data)] += copies
		spells += copies
		mana += data.cost.mana_value() * copies
		if data.is_creature():
			creatures += copies
		for color in data.cost.colored:
			pips[color] = int(pips.get(color, 0)) + int(data.cost.colored[color]) * copies
	var pip_words: PackedStringArray = []
	for color in Mtg.WUBRG:
		if pips.has(color):
			pip_words.append("%s %d" % [String(Mtg.COLOR_NAMES[color]).to_lower(), int(pips[color])])
	report.append("%d lands: %s%s." % [land_count, ", ".join(lands),
		"" if pip_words.is_empty() else " — pips " + ", ".join(pip_words)])
	report.append("%d spells: %d creatures, %d others; mana values 1: %d, 2: %d, 3: %d, 4: %d, 5+: %d; average %.1f." % [
		spells, creatures, spells - creatures, curve[0], curve[1], curve[2], curve[3], curve[4],
		float(mana) / maxi(spells, 1)])
	if kept > 0:
		report.append("Built around the %d card%s already on the surface." % [kept, "" if kept == 1 else "s"])
	if short_by > 0:
		report.append("The pool ran out after %d spells; %d extra basic land%s fill the deck." % [
			spells, short_by, "" if short_by == 1 else "s"])
	if not tournament:
		report.append("Built without the tournament rules: banned and restricted cards were allowed.")
	report.append("Seed %d: the same pool and wishes build this deck again." % roll)
