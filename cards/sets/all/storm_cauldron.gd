extends CardScript
## Storm Cauldron — {5} — Artifact (rare, all).
## Oracle: Each player may play an additional land during each of their turns.
##         Whenever a land is tapped for mana, return it to its owner's hand.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Storm Cauldron", "{5}", Mtg.CardType.ARTIFACT)
	c.oracle("Each player may play an additional land during each of their turns.\nWhenever a land is tapped for mana, return it to its owner's hand.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
