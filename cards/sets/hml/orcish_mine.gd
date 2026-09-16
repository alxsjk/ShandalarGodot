extends CardScript
## Orcish Mine — {1}{R}{R} — Enchantment — Aura (uncommon, hml).
## Oracle: Enchant land
##         This Aura enters with three ore counters on it.
##         At the beginning of your upkeep and whenever enchanted land becomes tapped, remove an ore counter from this Aura.
##         When the last ore counter is removed from this Aura, destroy enchanted land and this Aura deals 2 damage to that land's controller.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Orcish Mine", "{1}{R}{R}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.with_subtypes(["aura"])
	c.oracle("Enchant land\nThis Aura enters with three ore counters on it.\nAt the beginning of your upkeep and whenever enchanted land becomes tapped, remove an ore counter from this Aura.\nWhen the last ore counter is removed from this Aura, destroy enchanted land and this Aura deals 2 damage to that land's controller.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
