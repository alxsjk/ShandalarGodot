extends CardScript
## Phyrexian Devourer — {6} — Artifact Creature — Phyrexian Construct (rare, all).
## Oracle: When this creature's power is 7 or greater, sacrifice it.
##         Exile the top card of your library: Put X +1/+1 counters on this creature, where X is the exiled card's mana value.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Phyrexian Devourer", "{6}", Mtg.CardType.CREATURE | Mtg.CardType.ARTIFACT)
	c.pt(1, 1)
	c.with_subtypes(["phyrexian","construct"])
	c.oracle("When this creature's power is 7 or greater, sacrifice it.\nExile the top card of your library: Put X +1/+1 counters on this creature, where X is the exiled card's mana value.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
