extends CardScript
## Sworn Defender — {2}{W}{W} — Creature — Human Knight (rare, all).
## Oracle: {1}: This creature's power becomes the toughness of target creature blocking or being blocked by this creature minus 1 until end of turn, and its toughness becomes 1 plus the power of that creature until end of turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Sworn Defender", "{2}{W}{W}", Mtg.CardType.CREATURE)
	c.pt(1, 3)
	c.with_subtypes(["human","knight"])
	c.oracle("{1}: This creature's power becomes the toughness of target creature blocking or being blocked by this creature minus 1 until end of turn, and its toughness becomes 1 plus the power of that creature until end of turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
