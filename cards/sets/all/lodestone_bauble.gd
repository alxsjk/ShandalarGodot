extends CardScript
## Lodestone Bauble — {0} — Artifact (rare, all).
## Oracle: {1}, {T}, Sacrifice this artifact: Put up to four target basic land cards from a player's graveyard on top of their library in any order. That player draws a card at the beginning of the next turn's upkeep.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Lodestone Bauble", "{0}", Mtg.CardType.ARTIFACT)
	c.oracle("{1}, {T}, Sacrifice this artifact: Put up to four target basic land cards from a player's graveyard on top of their library in any order. That player draws a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
