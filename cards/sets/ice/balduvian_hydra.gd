extends CardScript
## Balduvian Hydra — {X}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Balduvian Hydra", "{X}{R}{R}", Mtg.CardType.CREATURE)
	card.pt(0, 1)
	card.with_subtypes(["hydra"])
	card.oracle("This creature enters with X +1/+0 counters on it.\nRemove a +1/+0 counter from this creature: Prevent the next 1 damage that would be dealt to it this turn.\n{R}{R}{R}: Put a +1/+0 counter on this creature. Activate only during your upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
