extends CardScript
## Lim-Dûl's Paladin — {2}{B}{R} — Creature — Human Knight (uncommon, all).
## Oracle: Trample
##         At the beginning of your upkeep, you may discard a card. If you don't, sacrifice this creature and draw a card.
##         Whenever this creature becomes blocked, it gets +6/+3 until end of turn.
##         Whenever this creature attacks and isn't blocked, it assigns no combat damage this turn and defending player loses 4 life.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Lim-Dûl's Paladin", "{2}{B}{R}", Mtg.CardType.CREATURE)
	c.pt(0, 3)
	c.with_subtypes(["human","knight"])
	c.with_keywords([Mtg.Keyword.TRAMPLE])
	c.oracle("Trample\nAt the beginning of your upkeep, you may discard a card. If you don't, sacrifice this creature and draw a card.\nWhenever this creature becomes blocked, it gets +6/+3 until end of turn.\nWhenever this creature attacks and isn't blocked, it assigns no combat damage this turn and defending player loses 4 life.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
