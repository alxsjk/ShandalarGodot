extends CardScript
## Norritt — {3}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Norritt", "{3}{B}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["imp"])
	card.oracle("{T}: Untap target blue creature.\n{T}: Choose target non-Wall creature the active player has controlled continuously since the beginning of the turn. That creature attacks this turn if able. Destroy it at the beginning of the next end step if it didn't attack this turn. Activate only before attackers are declared.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
