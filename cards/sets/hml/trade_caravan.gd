extends CardScript
## Trade Caravan — {W} — Creature — Human Nomad (common, hml).
## Oracle: At the beginning of your upkeep, put a currency counter on this creature.
##         Remove two currency counters from this creature: Untap target basic land. Activate only during an opponent's upkeep.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Trade Caravan", "{W}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["human","nomad"])
	c.oracle("At the beginning of your upkeep, put a currency counter on this creature.\nRemove two currency counters from this creature: Untap target basic land. Activate only during an opponent's upkeep.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
