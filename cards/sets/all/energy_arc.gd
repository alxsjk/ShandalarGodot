extends CardScript
## Energy Arc — {W}{U} — Instant (uncommon, all).
## Oracle: Untap any number of target creatures. Prevent all combat damage that would be dealt to and dealt by those creatures this turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Energy Arc", "{W}{U}", Mtg.CardType.INSTANT)
	c.oracle("Untap any number of target creatures. Prevent all combat damage that would be dealt to and dealt by those creatures this turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
