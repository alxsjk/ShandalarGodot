extends CardScript
## Forgotten Lore — {G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Forgotten Lore", "{G}", Mtg.CardType.SORCERY)
	card.oracle("Target opponent chooses a card in your graveyard. You may pay {G}. If you do, repeat this process except that opponent can't choose a card already chosen for Forgotten Lore. Then put the last chosen card into your hand.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
