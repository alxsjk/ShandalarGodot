extends CardScript
## Arcum's Whistle — {3} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Arcum's Whistle", "{3}", Mtg.CardType.ARTIFACT)
	card.oracle("{3}, {T}: Choose target non-Wall creature the active player has controlled continuously since the beginning of the turn. That player may pay {X}, where X is that creature's mana value. If they don't pay, the creature attacks this turn if able, and at the beginning of the next end step, destroy it if it didn't attack this turn. Activate only before attackers are declared.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
