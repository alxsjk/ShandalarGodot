extends GameTest
## THE MASKED CREATURE THE SIDEBOARDER COULD NAME (2026-09-17, rule 8).
##
## [AiMatchMemory] is the ONLY thing [AiSideboard] may read, and its whole
## reason for existing is that the opponent's decklist is off-limits: it
## holds what the seat SAW. Its own header says so, and it takes its
## sightings off [signal MtgGame.event_occurred] *"so nothing here reaches
## into a hidden zone: an event about a card in a hand or a library is
## never dispatched in the first place"*.
##
## A zone is not the only place a card can be hidden. Illusionary Mask puts
## a creature onto the battlefield FACE DOWN — a 2/2 with no name until
## something turns it up, and its printed identity is exactly what
## `CONTRIBUTING.md` rule 8 and `docs/fair-play.md` name as off-limits
## ("a face-down creature's hidden printed identity"). `_put_on_battlefield`
## still dispatches ENTERS_BATTLEFIELD for it, so the memory wrote the
## masked card's real name into the tally the sideboarder reads, and a
## Craw Wurm nobody had seen could be boarded against.
##
## [AiObservation] already draws this line for planning (`_card(card, ...
## or not card.face_down ...)`); this is the same line, in the memory.
##
## The correction is deliberately the CONSERVATIVE one: a masked creature
## is not a sighting at all. Turning face up is not an event this engine
## dispatches, so a card that is unmasked later is simply missed — an
## undercount, which is the safe side of a fairness rule, and the same side
## the observation boundary errs on.


func test_a_masked_creature_is_not_a_sighting() -> void:
	var memory := AiMatchMemory.new(1)
	memory.watch(g)
	var mask := put_battlefield(0, "Illusionary Mask")
	var wurm := give_hand(0, "Craw Wurm")
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.C, 6)
	assert_ok(g.activate_ability(0, mask, 0, [], 6))
	resolve_stack()
	assert_true(wurm.face_down, "the creature is masked")
	assert_eq(wurm.zone, Mtg.Zone.BATTLEFIELD, "and on the battlefield")
	memory.end_duel()
	assert_eq(memory.copies_seen("Craw Wurm"), 0,
		"a face-down identity is not something this seat saw")
	assert_eq(memory.copies_seen("Illusionary Mask"), 1,
		"the artifact that hid it is public, and is counted")


## THE POSITIVE CONTROL: a permanent that arrives face up — the very case
## ENTERS_BATTLEFIELD is watched for (an Animate Dead target, a creature
## that was never cast) — is still a sighting.
func test_a_face_up_arrival_is_still_a_sighting() -> void:
	var memory := AiMatchMemory.new(1)
	memory.watch(g)
	put_battlefield(0, "Craw Wurm")
	put_battlefield(0, "Craw Wurm")
	memory.end_duel()
	assert_eq(memory.copies_seen("Craw Wurm"), 2,
		"both bodies were seen by everyone at the table")
