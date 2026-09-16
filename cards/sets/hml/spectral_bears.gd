extends CardScript
## Spectral Bears — {1}{G} — Creature — Bear Spirit (uncommon, hml).
## Oracle: Whenever this creature attacks, if defending player controls no black nontoken permanents, it doesn't untap during your next untap step.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Spectral Bears", "{1}{G}", Mtg.CardType.CREATURE)
	c.pt(3, 3)
	c.with_subtypes(["bear","spirit"])
	c.oracle("Whenever this creature attacks, if defending player controls no black nontoken permanents, it doesn't untap during your next untap step.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
