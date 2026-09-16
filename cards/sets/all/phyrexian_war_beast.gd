extends CardScript
## Phyrexian War Beast — {3} — Artifact Creature — Phyrexian Beast (common, all).
## Oracle: When this creature leaves the battlefield, sacrifice a land and this creature deals 1 damage to you.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Phyrexian War Beast", "{3}", Mtg.CardType.CREATURE | Mtg.CardType.ARTIFACT)
	c.pt(3, 4)
	c.with_subtypes(["phyrexian","beast"])
	c.oracle("When this creature leaves the battlefield, sacrifice a land and this creature deals 1 damage to you.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
