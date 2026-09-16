extends CardScript
## Retribution — {2}{R}{R} — Sorcery (uncommon, hml).
## Oracle: Choose two target creatures controlled by the same opponent. That player chooses and sacrifices one of those creatures. Put a -1/-1 counter on the other.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Retribution", "{2}{R}{R}", Mtg.CardType.SORCERY)
	c.pt(0, 0)
	c.oracle("Choose two target creatures controlled by the same opponent. That player chooses and sacrifices one of those creatures. Put a -1/-1 counter on the other.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
