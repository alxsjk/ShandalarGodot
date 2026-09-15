extends CardScript
## Winter's Chill — {X}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Winter's Chill", "{X}{U}", Mtg.CardType.INSTANT)
	card.oracle("Cast this spell only during combat before blockers are declared.\nX can't be greater than the number of snow lands you control.\nChoose X target attacking creatures. For each of those creatures, its controller may pay {1} or {2}. If that player doesn't, destroy that creature at end of combat. If that player pays only {1}, prevent all combat damage that would be dealt to and dealt by that creature this combat.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
