extends CardScript
## Balduvian Shaman — {U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.
## SIMPLIFIED: color-word changes are limited to the five colored Circles
## of Protection; the granted cumulative upkeep is unchanged. See the
## explicit player-facing text and docs/simplified-cards.md.

func build() -> CardData:
	var card := CardData.new("Balduvian Shaman", "{U}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human","cleric","shaman"])
	card.oracle("{T}: Change the text of target white enchantment you control that doesn't have cumulative upkeep by replacing all instances of one color word with another. (For example, you may change \"black creatures can't attack\" to \"blue creatures can't attack.\") That enchantment gains \"Cumulative upkeep {1}.\" (At the beginning of its controller's upkeep, that player puts an age counter on it, then sacrifices it unless they pay its upkeep cost for each age counter on it.)")
	card.oracle("Digital adaptation — {T}: Change the color named by target white Circle of Protection you control that doesn't have cumulative upkeep to another color. It gains cumulative upkeep {1}. Only the five colored Circles are eligible; arbitrary enchantment text is not rewritten.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
