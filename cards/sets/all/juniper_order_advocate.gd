extends CardScript
## Juniper Order Advocate — {2}{W} — Creature — Human Knight (uncommon, all).
## Oracle: As long as this creature is untapped, green creatures you control get +1/+1.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Juniper Order Advocate", "{2}{W}", Mtg.CardType.CREATURE)
	c.pt(1, 2)
	c.with_subtypes(["human","knight"])
	c.oracle("As long as this creature is untapped, green creatures you control get +1/+1.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
