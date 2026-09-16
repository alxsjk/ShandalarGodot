extends CardScript
## Serra Paladin — {2}{W}{W} — Creature — Human Knight (common, hml).
## Oracle: {T}: Prevent the next 1 damage that would be dealt to any target this turn.
##         {1}{W}{W}, {T}: Target creature gains vigilance until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Serra Paladin", "{2}{W}{W}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_subtypes(["human","knight"])
	c.oracle("{T}: Prevent the next 1 damage that would be dealt to any target this turn.\n{1}{W}{W}, {T}: Target creature gains vigilance until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
