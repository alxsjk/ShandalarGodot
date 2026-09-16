extends CardScript
## Nature's Blessing — {2}{G}{W} — Enchantment (uncommon, all).
## Oracle: {G}{W}, Discard a card: Put a +1/+1 counter on target creature or that creature gains banding, first strike, or trample. (This effect lasts indefinitely. Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding a player controls are blocking or being blocked by a creature, that player divides that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Nature's Blessing", "{2}{G}{W}", Mtg.CardType.ENCHANTMENT)
	c.oracle("{G}{W}, Discard a card: Put a +1/+1 counter on target creature or that creature gains banding, first strike, or trample. (This effect lasts indefinitely. Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding a player controls are blocking or being blocked by a creature, that player divides that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)")
	return load("res://cards/sets/all/_rules.gd").apply(c)
