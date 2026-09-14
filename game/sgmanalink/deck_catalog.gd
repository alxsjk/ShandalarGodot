class_name SgDeckCatalog
extends RefCounted
## [QoL] Local deck files become bounded card-name lists, never remote paths.
## The referee validates names again. Sideboards are retained privately for
## review; a friendly single duel does not have a between-games sideboard step.

static func validate(cards: Array, sideboard: Array = []) -> String:
	if cards.size() < 40 or cards.size() > 250 or sideboard.size() > 250:
		return "Choose a deck with 40-250 cards and at most 250 sideboard cards."
	CardRegistry.ensure_loaded()
	for card_name in cards + sideboard:
		if not CardRegistry.has_card(card_name):
			return "The host does not implement one or more cards in this deck."
	return ""


static func available() -> Array:
	var result: Array = []
	for path in DeckStore.all_deck_paths():
		var deck := DeckList.load_file(path)
		if not deck.errors.is_empty() or not validate(deck.cards, deck.sideboard).is_empty():
			continue
		result.append({"name": deck.deck_name, "cards": Array(deck.cards),
			"sideboard": Array(deck.sideboard), "group": path.get_base_dir().trim_prefix("res://decks")})
	return result
