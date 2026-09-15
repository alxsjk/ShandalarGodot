extends CardScript
## Total War — {3}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Total War", "{3}{R}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Whenever a player attacks with one or more creatures, destroy all untapped non-Wall creatures that player controls that didn't attack, except for creatures the player hasn't controlled continuously since the beginning of the turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
