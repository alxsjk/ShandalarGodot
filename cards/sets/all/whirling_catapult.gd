extends CardScript
## Whirling Catapult — {4} — Artifact (uncommon, all).
## Oracle: {2}, Exile the top two cards of your library: This artifact deals 1 damage to each creature with flying and each player.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Whirling Catapult", "{4}", Mtg.CardType.ARTIFACT)
	c.oracle("{2}, Exile the top two cards of your library: This artifact deals 1 damage to each creature with flying and each player.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
