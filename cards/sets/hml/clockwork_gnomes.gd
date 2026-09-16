extends CardScript
## Clockwork Gnomes — {4} — Artifact Creature — Gnome (common, hml).
## Oracle: {3}, {T}: Regenerate target artifact creature.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Clockwork Gnomes", "{4}", Mtg.CardType.CREATURE | Mtg.CardType.ARTIFACT)
	c.pt(2, 2)
	c.with_subtypes(["gnome"])
	c.oracle("{3}, {T}: Regenerate target artifact creature.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
