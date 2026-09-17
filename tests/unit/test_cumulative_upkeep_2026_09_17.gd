extends GameTest
## CUMULATIVE UPKEEP AND THE SEAT THAT WILL NOT NAME A BODY — CR 702.24a,
## 2026-09-17.
##
## "At the beginning of your upkeep, put an age counter on this permanent,
## then sacrifice it unless you pay its upkeep cost for each age counter on
## it." Two outcomes, and no third: the whole cost is paid, or the permanent
## dies. [CumulativeUpkeep] had a third — a seat that agreed to pay and then
## declined the SACRIFICE pick (`answer_card` returning null, which the base
## agent's contract allows) fell out of the resolution with the age counter
## added, nothing paid and the permanent still on the table.
##
## The rest of the engine has already settled what a never-optional card ask
## does with a declined or stale answer: MtgGame._ask_cost_card takes the
## first candidate (CR 601.2h — the cost was agreed to, the body is the
## engine's to pick). This pins the same answer here, plus the four refusals
## that were always right, on a SYNTHETIC permanent so nothing below depends
## on how Polar Kraken or Glacial Chasm happen to be written.


## A seat that says yes to every upkeep offer and then names nothing.
class Refuser extends DecisionAgent:
	var picks := 0
	func answer_yes_no(_g: MtgGame, _pid: int, _prompt: String, _hint: bool) -> bool:
		return true
	func answer_card(_g: MtgGame, _pid: int, _candidates: Array[CardInstance],
			_prompt: String) -> CardInstance:
		picks += 1
		return null


## A seat that refuses the offer outright.
class Decliner extends DecisionAgent:
	func answer_yes_no(_g: MtgGame, _pid: int, _prompt: String, _hint: bool) -> bool:
		return false


static func _leviathan(cost := "", life := 0, sacrifice_type := "") -> CardData:
	var card := CardData.new("Test Leviathan", "{8}{U}", Mtg.CardType.CREATURE)
	card.pt(11, 11)
	return CumulativeUpkeep.attach(card, cost, life, sacrifice_type)


func _upkeep(pid: int) -> void:
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": pid})
	resolve_stack()


# ------------------------------------------- the declined sacrifice pick --

func test_a_declined_sacrifice_pick_still_pays_the_upkeep() -> void:
	var refuser := Refuser.new()
	g.set_agent(0, refuser)
	var kraken := put_synthetic(0, _leviathan("", 0, "land"))
	var forest := put_battlefield(0, "Forest")
	_upkeep(0)
	assert_eq(refuser.picks, 1, "the seat was asked for a body")
	assert_eq(int(kraken.counters.get("age", 0)), 1, "and the age counter went on")
	assert_eq(forest.zone, Mtg.Zone.GRAVEYARD,
		"a declined pick eats the first land, not nothing (CR 601.2h)")
	assert_eq(kraken.zone, Mtg.Zone.BATTLEFIELD, "the upkeep was paid, so it lives")


func test_a_declined_pick_on_the_second_age_counter_eats_two_lands() -> void:
	var refuser := Refuser.new()
	g.set_agent(0, refuser)
	var kraken := put_synthetic(0, _leviathan("", 0, "land"))
	for _i in 3:
		put_battlefield(0, "Forest")
	_upkeep(0)
	_upkeep(0)
	assert_eq(int(kraken.counters.get("age", 0)), 2)
	assert_eq(g.players[0].battlefield.size(), 1,
		"one land for the first upkeep, two for the second — only the Kraken left")
	assert_eq(kraken.zone, Mtg.Zone.BATTLEFIELD)


# --------------------------------------------------- the four refusals --

func test_a_refused_offer_sacrifices_the_permanent() -> void:
	g.set_agent(0, Decliner.new())
	var kraken := put_synthetic(0, _leviathan("", 0, "land"))
	var forest := put_battlefield(0, "Forest")
	_upkeep(0)
	assert_eq(kraken.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(forest.zone, Mtg.Zone.BATTLEFIELD, "and nothing was paid")


func test_no_land_to_eat_sacrifices_the_permanent() -> void:
	var refuser := Refuser.new()
	g.set_agent(0, refuser)
	var kraken := put_synthetic(0, _leviathan("", 0, "land"))
	_upkeep(0)
	assert_eq(kraken.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(refuser.picks, 0, "an unpayable cost is never offered a body")


func test_too_little_life_sacrifices_the_permanent() -> void:
	g.set_agent(0, Refuser.new())
	var chasm := put_synthetic(0, _leviathan("", 2))
	g.players[0].life = 1
	_upkeep(0)
	assert_eq(chasm.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.players[0].life, 1, "and no life was paid")


func test_no_mana_sacrifices_the_permanent() -> void:
	g.set_agent(0, Refuser.new())
	var wall := put_synthetic(0, _leviathan("{2}"))
	_upkeep(0)
	assert_eq(wall.zone, Mtg.Zone.GRAVEYARD)
