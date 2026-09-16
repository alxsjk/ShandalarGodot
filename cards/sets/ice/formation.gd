extends CardScript
## Formation — {1}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Formation", "{1}{W}", Mtg.CardType.INSTANT)
	card.oracle("Target creature gains banding until end of turn. (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding a player controls are blocking or being blocked by a creature, that player divides that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
