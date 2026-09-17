extends CardScript
## Shelkin Brownie — {1}{G} — Creature — Ouphe — 1/1 — (leg, common)
## Oracle: {T}: Target creature loses all "bands with other" abilities
##         until end of turn.
##
## Implementation: LoseAbilityEffect stripping the "bands with other"
## grants alone (CardInstance.cur_bands_with, what the five Legends lands
## and Master of the Hunt hand out) and NOT the banding keyword — the
## Brownie's printed text names only the former, which is the one thing
## that tells it apart from Tolaria ("loses banding AND all 'bands with
## other' abilities"). CR 702.22b runs one way: losing banding takes the
## "bands with other" abilities too, never the reverse. Until 2026-09-17
## this stripped BANDING, so a Benalish Hero the Brownie touched could no
## longer band at all.


func build() -> CardData:
	return CardData.new("Shelkin Brownie", "{1}{G}", Mtg.CardType.CREATURE) \
		.pt(1, 1) \
		.with_subtypes(["ouphe"]) \
		.activated(ActivatedAbility.new(
			"", true,
			[LoseAbilityEffect.new([], "all \"bands with other\" abilities") \
				.and_bands_with()],
			"{T}: Target creature loses all \"bands with other\" abilities until end of turn.")) \
		.oracle("{T}: Target creature loses all \"bands with other\" abilities until "
			+ "end of turn.")
