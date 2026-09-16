extends CardScript
## Soldier of Fortune — {R} — Creature — Human Mercenary (uncommon, all).
## Oracle: {R}, {T}: Target player shuffles their library.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Soldier of Fortune", "{R}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["human","mercenary"])
	c.oracle("{R}, {T}: Target player shuffles their library.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
