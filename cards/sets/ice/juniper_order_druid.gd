extends CardScript
## Juniper Order Druid — {2}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Juniper Order Druid", "{2}{G}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human","cleric","druid"])
	card.oracle("{T}: Untap target land.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
