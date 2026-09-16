extends CardScript
## Drudge Spell — {B}{B} — Enchantment (uncommon, hml).
## Oracle: {B}, Exile two creature cards from your graveyard: Create a 1/1 black Skeleton creature token. It has "{B}: Regenerate this token."
##         When this enchantment leaves the battlefield, destroy all Skeleton tokens. They can't be regenerated.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Drudge Spell", "{B}{B}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.oracle("{B}, Exile two creature cards from your graveyard: Create a 1/1 black Skeleton creature token. It has \"{B}: Regenerate this token.\"\nWhen this enchantment leaves the battlefield, destroy all Skeleton tokens. They can't be regenerated.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
