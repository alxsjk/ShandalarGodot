extends CardScript
## Scarab of the Unseen — {2} — Artifact (uncommon, all).
## Oracle: {T}, Sacrifice this artifact: Return all Auras attached to target permanent you own to their owners' hands. Draw a card at the beginning of the next turn's upkeep.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Scarab of the Unseen", "{2}", Mtg.CardType.ARTIFACT)
	c.oracle("{T}, Sacrifice this artifact: Return all Auras attached to target permanent you own to their owners' hands. Draw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
