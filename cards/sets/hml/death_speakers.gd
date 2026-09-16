extends CardScript
## Death Speakers — {W} — Creature — Human Cleric (uncommon, hml).
## Oracle: Protection from black
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Death Speakers", "{W}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["human","cleric"])
	c.with_protection_from(Mtg.ManaColor.B)
	c.oracle("Protection from black")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
