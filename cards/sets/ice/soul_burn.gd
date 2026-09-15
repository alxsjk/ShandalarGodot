extends CardScript
## Soul Burn — {X}{2}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Soul Burn", "{X}{2}{B}", Mtg.CardType.SORCERY)
	card.oracle("Spend only black and/or red mana on X.\nSoul Burn deals X damage to any target. You gain life equal to the damage dealt, but not more than the amount of {B} spent on X, the player's life total before the damage was dealt, the planeswalker's loyalty before the damage was dealt, or the creature's toughness.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
