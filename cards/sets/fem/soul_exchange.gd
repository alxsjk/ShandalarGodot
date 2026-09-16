extends CardScript
## Soul Exchange — {B}{B} — Sorcery — (fem, uncommon)
## Oracle: As an additional cost to cast this spell, exile a creature you control.
##         Return target creature card from your graveyard to the battlefield. Put a +2/+2 counter on that creature if the exiled creature was a Thrull.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Soul Exchange", "{B}{B}", Mtg.CardType.SORCERY)
	card.oracle("As an additional cost to cast this spell, exile a creature you control.\nReturn target creature card from your graveyard to the battlefield. Put a +2/+2 counter on that creature if the exiled creature was a Thrull.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
