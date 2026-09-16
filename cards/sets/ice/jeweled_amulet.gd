extends CardScript
## Jeweled Amulet — {0} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Jeweled Amulet", "{0}", Mtg.CardType.ARTIFACT)
	card.oracle("{1}, {T}: Put a charge counter on this artifact. Note the type of mana spent to pay this activation cost. Activate only if there are no charge counters on this artifact.\n{T}, Remove a charge counter from this artifact: Add one mana of this artifact's last noted type.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
