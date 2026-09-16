extends CardScript
## Serrated Arrows — {4} — Artifact (common, hml).
## Oracle: This artifact enters with three arrowhead counters on it.
##         At the beginning of your upkeep, if there are no arrowhead counters on this artifact, sacrifice it.
##         {T}, Remove an arrowhead counter from this artifact: Put a -1/-1 counter on target creature.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Serrated Arrows", "{4}", Mtg.CardType.ARTIFACT)
	c.pt(0, 0)
	c.oracle("This artifact enters with three arrowhead counters on it.\nAt the beginning of your upkeep, if there are no arrowhead counters on this artifact, sacrifice it.\n{T}, Remove an arrowhead counter from this artifact: Put a -1/-1 counter on target creature.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
