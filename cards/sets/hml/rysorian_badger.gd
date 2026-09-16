extends CardScript
## Rysorian Badger — {2}{G} — Creature — Badger (rare, hml).
## Oracle: Whenever this creature attacks and isn't blocked, you may exile up to two target creature cards from defending player's graveyard. If you do, you gain 1 life for each card exiled this way and this creature assigns no combat damage this turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Rysorian Badger", "{2}{G}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_subtypes(["badger"])
	c.oracle("Whenever this creature attacks and isn't blocked, you may exile up to two target creature cards from defending player's graveyard. If you do, you gain 1 life for each card exiled this way and this creature assigns no combat damage this turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
