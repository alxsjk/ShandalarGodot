extends CardScript
## Meteor Shower — {X}{X}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Meteor Shower", "{X}{X}{R}", Mtg.CardType.SORCERY)
	card.oracle("Meteor Shower deals X plus 1 damage divided as you choose among any number of targets.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
