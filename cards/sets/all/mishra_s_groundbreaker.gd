extends CardScript
## Mishra's Groundbreaker — {4} — Artifact (uncommon, all).
## Oracle: {T}, Sacrifice this artifact: Target land becomes a 3/3 artifact creature that's still a land. (This effect lasts indefinitely.)
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Mishra's Groundbreaker", "{4}", Mtg.CardType.ARTIFACT)
	c.oracle("{T}, Sacrifice this artifact: Target land becomes a 3/3 artifact creature that's still a land. (This effect lasts indefinitely.)")
	return load("res://cards/sets/all/_rules.gd").apply(c)
