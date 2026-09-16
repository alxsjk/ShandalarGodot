extends CardScript
## Gustha's Scepter — {0} — Artifact (rare, all).
## Oracle: {T}: Exile a card from your hand face down. You may look at it for as long as it remains exiled.
##         {T}: Return a card you own exiled with this artifact to your hand.
##         When you lose control of this artifact, put all cards exiled with this artifact into their owner's graveyard.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Gustha's Scepter", "{0}", Mtg.CardType.ARTIFACT)
	c.oracle("{T}: Exile a card from your hand face down. You may look at it for as long as it remains exiled.\n{T}: Return a card you own exiled with this artifact to your hand.\nWhen you lose control of this artifact, put all cards exiled with this artifact into their owner's graveyard.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
