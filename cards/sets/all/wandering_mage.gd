extends CardScript
## Wandering Mage — {W}{U}{B} — Creature — Human Cleric Wizard (rare, all).
## Oracle: {W}, Pay 1 life: Prevent the next 2 damage that would be dealt to target creature this turn.
##         {U}: Prevent the next 1 damage that would be dealt to target Cleric or Wizard creature this turn.
##         {B}, Put a -1/-1 counter on a creature you control: Prevent the next 2 damage that would be dealt to target player or planeswalker this turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Wandering Mage", "{W}{U}{B}", Mtg.CardType.CREATURE)
	c.pt(0, 3)
	c.with_subtypes(["human","cleric","wizard"])
	c.oracle("{W}, Pay 1 life: Prevent the next 2 damage that would be dealt to target creature this turn.\n{U}: Prevent the next 1 damage that would be dealt to target Cleric or Wizard creature this turn.\n{B}, Put a -1/-1 counter on a creature you control: Prevent the next 2 damage that would be dealt to target player or planeswalker this turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
