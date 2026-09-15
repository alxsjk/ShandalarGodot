extends CardScript
## Mystic Might — {U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Mystic Might", "{U}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant land you control\nCumulative upkeep {1}{U} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nEnchanted land has \"{T}: Target creature gets +2/+2 until end of turn.\"")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
