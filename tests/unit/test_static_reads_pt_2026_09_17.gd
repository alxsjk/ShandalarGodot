extends GameTest
## A STATIC THAT READS A LIVE POWER RUNS AFTER EVERY P/T LAYER
## (CR 613.8, the layer-7 twin of the retyper waves) — 2026-09-17.
##
## Three cards in the pool ask a question ABOUT a power while the
## continuous pipeline is still answering it: Meekstone's *"creatures with
## power 3 or greater don't untap"*, Orgg's and Goblin Mutant's *"can't
## attack if the defending player controls an untapped creature with power
## 3 or greater"*. Each was applied in the ordinary statics pass, so it saw
## whatever had been added to a power BY THEN — and two things had not been:
##
##  * an anthem or an Aura printed on a permanent that entered LATER
##    (ContinuousEffects walks the statics in battlefield timestamp order),
##    so a Scathe Zombies under a Bad Moon was a 3/3 a Meekstone that
##    entered first never saw; and
##  * every FLOATING pump, which the pipeline applies a pass later, so a
##    creature a Giant Growth had just made huge was invisible to all three.
##
## The answer therefore depended on which permanent entered first, which is
## exactly what the two layer-4 retyper waves exist to stop (Conversion
## under Blood Moon, 2026-09-10, StaticAbility.reading_land_types). This is
## the same fix one layer up: StaticAbility.reading_pt() takes the static
## out of the anthem pass and into one of its own, after layer 7e's
## switches — the last thing the pipeline does to a power.


# ------------------------------------------------------- the reproduction --

## THE REPRODUCTION. Meekstone first, the anthem second: the Zombies is a
## 3/3 and must not untap.
func test_meekstone_sees_an_anthem_that_entered_after_it() -> void:
	put_battlefield(0, "Meekstone")
	put_battlefield(0, "Bad Moon")
	var zombie := put_battlefield(0, "Scathe Zombies")
	g.recalculate()
	assert_eq(zombie.cur_power, 3, "the Bad Moon made it a 3/3")
	assert_true(zombie.cur_skips_untap, "and the Meekstone sees the 3/3")


## The other way round, which always worked — the control that says the
## pass order is what moved and not the rule.
func test_meekstone_sees_an_anthem_that_entered_before_it() -> void:
	put_battlefield(0, "Bad Moon")
	put_battlefield(0, "Meekstone")
	var zombie := put_battlefield(0, "Scathe Zombies")
	g.recalculate()
	assert_true(zombie.cur_skips_untap)


## And a FLOATING pump, the half no entry order could have rescued.
func test_meekstone_sees_a_floating_pump() -> void:
	put_battlefield(0, "Meekstone")
	var bear := put_battlefield(0, "Grizzly Bears")
	g.continuous.add_until_eot_pump(bear.id, 1, 1)   # Giant Growth-shaped
	g.recalculate()
	assert_eq(bear.cur_power, 3)
	assert_true(bear.cur_skips_untap)


## A 2/2 with nothing on it still untaps — the pass did not become a
## blanket lock.
func test_a_small_creature_still_untaps() -> void:
	put_battlefield(0, "Meekstone")
	put_battlefield(0, "Bad Moon")
	var bear := put_battlefield(0, "Grizzly Bears")   # green: no Bad Moon
	g.recalculate()
	assert_false(bear.cur_skips_untap)


# ------------------------------------------------------ through the turn --

## The flag is read by the untap step, so the whole turn says the same
## thing: a Bad Moon'd Zombies stays tapped through its controller's untap.
func test_the_untap_step_keeps_the_boosted_creature_tapped() -> void:
	put_battlefield(0, "Meekstone")
	put_battlefield(0, "Bad Moon")
	var zombie := put_battlefield(0, "Scathe Zombies")
	g.tap_permanent(zombie)
	advance_to_next_turn()      # P1's turn
	advance_to_next_turn()      # P0's turn — the untap step that matters
	assert_true(zombie.tapped, "a 3/3 under a Meekstone does not untap")


# ------------------------------------------------------------- the flag --

## The flag reaches the CardData the engine reads, not just the file.
func test_meekstone_declares_that_it_reads_a_power() -> void:
	var flagged := false
	for ability in CardRegistry.get_card("Meekstone").static_abilities:
		if ability.reads_pt:
			flagged = true
	assert_true(flagged, "Meekstone declares its layer-7 read")
