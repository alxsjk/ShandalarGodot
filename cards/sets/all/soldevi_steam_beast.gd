extends CardScript
## Soldevi Steam Beast — {5} — Artifact Creature — Beast (common, all).
## Oracle: Whenever this creature becomes tapped, target opponent gains 2 life.
##         {2}: Regenerate this creature.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Soldevi Steam Beast", "{5}", Mtg.CardType.CREATURE | Mtg.CardType.ARTIFACT)
	c.pt(4, 2)
	c.with_subtypes(["beast"])
	c.oracle("Whenever this creature becomes tapped, target opponent gains 2 life.\n{2}: Regenerate this creature.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
