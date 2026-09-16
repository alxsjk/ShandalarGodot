extends CardScript
## Thelonite Monk — {2}{G}{G} — Creature — Insect Monk Cleric — 1/2 — (fem, rare)
## Oracle: {T}, Sacrifice a green creature: Target land becomes a Forest. (This effect lasts indefinitely.)
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Thelonite Monk", "{2}{G}{G}", Mtg.CardType.CREATURE)
	card.pt(1, 2)
	card.with_subtypes(["insect", "monk", "cleric"])
	card.oracle("{T}, Sacrifice a green creature: Target land becomes a Forest. (This effect lasts indefinitely.)")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
