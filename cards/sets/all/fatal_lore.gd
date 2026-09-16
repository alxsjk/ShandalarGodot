extends CardScript
## Fatal Lore — {2}{B}{B} — Sorcery (rare, all).
## Oracle: An opponent chooses one —
##         • You draw three cards.
##         • You destroy up to two target creatures that player controls. They can't be regenerated. That player draws up to three cards.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.
## SIMPLIFIED: the opponent chooses the mode, and the caster chooses any
## creature targets, on resolution rather than announcement. See
## docs/simplified-cards.md; the shared handler also exposes this in-game.

func build() -> CardData:
	var c := CardData.new("Fatal Lore", "{2}{B}{B}", Mtg.CardType.SORCERY)
	c.oracle("An opponent chooses one —\n• You draw three cards.\n• You destroy up to two target creatures that player controls. They can't be regenerated. That player draws up to three cards.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
