extends CardScript
## Misfortune — {1}{B}{R}{G} — Sorcery (rare, all).
## Oracle: An opponent chooses one —
##         • You put a +1/+1 counter on each creature you control and gain 4 life.
##         • You put a -1/-1 counter on each creature that player controls and Misfortune deals 4 damage to that player.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.
## SIMPLIFIED: the opponent chooses the mode on resolution, not announcement.
## See docs/simplified-cards.md; the shared handler also exposes this in-game.

func build() -> CardData:
	var c := CardData.new("Misfortune", "{1}{B}{R}{G}", Mtg.CardType.SORCERY)
	c.oracle("An opponent chooses one —\n• You put a +1/+1 counter on each creature you control and gain 4 life.\n• You put a -1/-1 counter on each creature that player controls and Misfortune deals 4 damage to that player.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
