extends CardScript
## Wiitigo — {3}{G}{G}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Wiitigo", "{3}{G}{G}{G}", Mtg.CardType.CREATURE)
	card.pt(0, 0)
	card.with_subtypes(["yeti"])
	card.oracle("This creature enters with six +1/+1 counters on it.\nAt the beginning of your upkeep, put a +1/+1 counter on this creature if it has blocked or been blocked since your last upkeep. Otherwise, remove a +1/+1 counter from it.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
