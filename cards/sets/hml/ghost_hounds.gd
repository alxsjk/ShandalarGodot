extends CardScript
## Ghost Hounds — {1}{B} — Creature — Dog Spirit (uncommon, hml).
## Oracle: Vigilance
##         Whenever this creature blocks or becomes blocked by a white creature, this creature gains first strike until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Ghost Hounds", "{1}{B}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["dog","spirit"])
	c.with_keywords([Mtg.Keyword.VIGILANCE])
	c.oracle("Vigilance\nWhenever this creature blocks or becomes blocked by a white creature, this creature gains first strike until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
