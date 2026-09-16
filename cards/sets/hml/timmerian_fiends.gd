extends CardScript
## Timmerian Fiends — {1}{B}{B} — Creature — Horror (rare, hml).
## Oracle: Remove this card from your deck before playing if you're not playing for ante.
##         {B}{B}{B}, Sacrifice this creature: The owner of target artifact may ante the top card of their library. If that player doesn't, exchange ownership of that artifact and Timmerian Fiends. Put the artifact card into your graveyard and Timmerian Fiends from anywhere into that player's graveyard. This change in ownership is permanent.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.
## SIMPLIFIED: only nontoken cards participate in ownership exchanges.
## See docs/simplified-cards.md; the adaptation is shown in the rules text.

func build() -> CardData:
	var c := CardData.new("Timmerian Fiends", "{1}{B}{B}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["horror"])
	c.oracle("Remove this card from your deck before playing if you're not playing for ante.\n{B}{B}{B}, Sacrifice this creature: The owner of target artifact may ante the top card of their library. If that player doesn't, exchange ownership of that artifact and Timmerian Fiends. Put the artifact card into your graveyard and Timmerian Fiends from anywhere into that player's graveyard. This change in ownership is permanent.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
