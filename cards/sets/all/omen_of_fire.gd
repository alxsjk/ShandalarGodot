extends CardScript
## Omen of Fire — {3}{R}{R} — Instant (rare, all).
## Oracle: Return all Islands to their owners' hands. Each player sacrifices a Plains or a white permanent of their choice for each white permanent they control.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Omen of Fire", "{3}{R}{R}", Mtg.CardType.INSTANT)
	c.oracle("Return all Islands to their owners' hands. Each player sacrifices a Plains or a white permanent of their choice for each white permanent they control.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
