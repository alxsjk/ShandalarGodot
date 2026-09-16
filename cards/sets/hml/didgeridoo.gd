extends CardScript
## Didgeridoo — {1} — Artifact (rare, hml).
## Oracle: {3}: You may put a Minotaur permanent card from your hand onto the battlefield.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Didgeridoo", "{1}", Mtg.CardType.ARTIFACT)
	c.pt(0, 0)
	c.oracle("{3}: You may put a Minotaur permanent card from your hand onto the battlefield.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
