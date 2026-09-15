extends CardScript
## Elvish Scout — {G} — Creature — Elf Scout — 1/1 — (fem, common)
## Oracle: {G}, {T}: Untap target attacking creature you control. Prevent all combat damage that would be dealt to and dealt by it this turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Elvish Scout", "{G}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["elf", "scout"])
	card.oracle("{G}, {T}: Untap target attacking creature you control. Prevent all combat damage that would be dealt to and dealt by it this turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
