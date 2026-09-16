extends CardScript
## Dread Wight — {3}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Dread Wight", "{3}{B}{B}", Mtg.CardType.CREATURE)
	card.pt(3, 4)
	card.with_subtypes(["zombie"])
	card.oracle("At end of combat, put a paralyzation counter on each creature blocking or blocked by this creature and tap those creatures. Each of those creatures doesn't untap during its controller's untap step for as long as it has a paralyzation counter on it. Each of those creatures gains \"{4}: Remove a paralyzation counter from this creature.\"")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
