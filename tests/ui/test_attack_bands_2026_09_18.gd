extends GutTest
## THE BAND THAT COULD NOT BE FORMED — the playtest defect of 2026-09-18.
##
## *"Examine banding. When i declare 2 attackers during combat (for
## example "benalish hero" - i should be able to form a band)."*
##
## The engine has taken attack bands since banding landed:
## [method MtgGame.declare_attackers] validates a `band_list` with
## [method CombatState.band_illegality], a blocker of one member fights
## the whole band, the AI declares bands (`AiPlayer._declare_attacks`)
## and the SGManalink wire carries them (`attack_bands`). The duel screen
## never sent one — Done declared [member DuelScreen._selected_attackers]
## and nothing else, so two Benalish Heroes always attacked as two.
##
## THE 1997 GESTURE this pins (`Duel.hlp`, topic **Combat**; the prompts
## are `@PROMPT_BANDWITHWHOM`, UIStrings.txt:1031): a creature that can
## band with an attacker already in the lineup is asked *"Band with which
## attacker?"* — click that attacker to band, click the creature itself
## (the manual's double-click) or Done to attack alone. The window frames
## the band; the declaration carries it; the log names it.

var screen: DuelScreen


func before_each() -> void:
	screen = load("res://game/duel/duel_screen.tscn").instantiate()
	add_child_autofree(screen)
	await get_tree().process_frame
	screen.stops.clear_all()


func _summon(card_name: String, pid: int) -> CardInstance:
	var g: MtgGame = screen.game
	var inst := CardInstance.new(CardRegistry.get_card(card_name),
		g._next_instance_id, pid)
	g._next_instance_id += 1
	g._instances[inst.id] = inst
	g._put_on_battlefield(inst, pid)
	inst.summoning_sick = false
	return inst


## OUR turn, the engine waiting on our attack declaration.
func _attackers_moment() -> void:
	var g: MtgGame = screen.game
	g.active_player = 0
	g._step_index = Mtg.STEP_ORDER.find(Mtg.Step.DECLARE_ATTACKERS)
	g.awaiting_attackers = true
	# The refresh enters ATTACKERS mode itself and puts the standing
	# instruction on the bar, as the real step's entry does.
	screen.mode = DuelScreen.Mode.NORMAL
	screen._refresh()
	assert_eq(screen.mode, DuelScreen.Mode.ATTACKERS)


func _prompt() -> String:
	return screen._prompt_label.text


# ================================================== THE QUESTION --

func test_a_second_bander_is_asked_band_with_which_attacker() -> void:
	var hero := _summon("Benalish Hero", 0)
	var pegasus := _summon("Mesa Pegasus", 0)
	var bears := _summon("Grizzly Bears", 0)
	_attackers_moment()
	assert_eq(screen._highlight_for(bears), MiniCard.Highlight.OPTIONAL,
		"a creature that may attack wears the 'you may' ring")
	screen._on_card_clicked(hero)
	assert_eq(screen._band_candidate, -1,
		"the first attacker has nobody to band with — no question")
	assert_eq(_prompt(), "Combat phase: Choose attackers.")
	screen._on_card_clicked(pegasus)
	assert_eq(screen._highlight_for(bears), MiniCard.Highlight.NONE,
		"while the question is up only its answers light — the Bears wait")
	assert_true(screen._selected_attackers.has(pegasus.id),
		"the Pegasus is in the lineup")
	assert_eq(screen._band_candidate, pegasus.id, "and the bar asks about it")
	assert_eq(_prompt(), DuelScreen.BAND_QUESTION,
		"@PROMPT_BANDWITHWHOM entry 1, verbatim")
	assert_eq(screen._highlight_for(hero), MiniCard.Highlight.TARGET_LEGAL,
		"the attacker it may band with wears the 'click one of these' ring")
	assert_eq(screen._highlight_for(pegasus), MiniCard.Highlight.COMMITTED)


func test_clicking_the_attacker_forms_the_band_and_done_declares_it() -> void:
	var g: MtgGame = screen.game
	var hero := _summon("Benalish Hero", 0)
	var pegasus := _summon("Mesa Pegasus", 0)
	_attackers_moment()
	screen._on_card_clicked(hero)
	screen._on_card_clicked(pegasus)
	screen._on_card_clicked(hero)
	assert_eq(screen._band_candidate, -1, "the question is answered")
	assert_eq(_prompt(), "Combat phase: Choose attackers.",
		"and the bar is back on the standing instruction")
	assert_eq(screen._selected_bands.size(), 1, "one band pencilled in")
	assert_true(screen._selected_bands[0].has(hero.id))
	assert_true(screen._selected_bands[0].has(pegasus.id))
	assert_eq(screen._combat_window.band_groups(), [[hero.id, pegasus.id]],
		"the Combat window frames the two together")
	screen._on_done()
	assert_false(g.awaiting_attackers, "the declaration went in")
	assert_eq(g.combat.bands.size(), 1, "and the engine has the band")
	assert_true(g.combat.band_of(hero.id).has(pegasus.id),
		"the Hero's band holds the Pegasus")
	assert_eq(screen._selected_bands, [], "the pencilled band is spent")
	assert_eq(screen._combat_window.band_groups(), [[hero.id, pegasus.id]],
		"the declared band stays framed after the declaration")
	assert_true(g.log_lines[-1].contains("(a band: Benalish Hero + Mesa Pegasus)"),
		"the log names the band: %s" % g.log_lines[-1])


func test_a_blocker_of_one_member_fights_the_whole_band() -> void:
	var g: MtgGame = screen.game
	var hero := _summon("Benalish Hero", 0)
	var pegasus := _summon("Mesa Pegasus", 0)
	var bears := _summon("Grizzly Bears", 1)
	_attackers_moment()
	screen._on_card_clicked(hero)
	screen._on_card_clicked(pegasus)
	screen._on_card_clicked(hero)
	screen._on_done()
	var guard := 0
	while not g.awaiting_blockers and guard < 10:
		assert_eq(g.pass_priority(g.priority_player), "")
		guard += 1
	assert_eq(g.declare_blockers(1, {bears.id: hero.id}), "")
	assert_true(g.combat.was_blocked(g.combat.band_of(pegasus.id)),
		"blocking the Hero blocks the Pegasus's band too (CR 702.22j)")


func test_clicking_the_creature_again_answers_alone() -> void:
	var g: MtgGame = screen.game
	var hero := _summon("Benalish Hero", 0)
	var pegasus := _summon("Mesa Pegasus", 0)
	_attackers_moment()
	screen._on_card_clicked(hero)
	screen._on_card_clicked(pegasus)
	screen._on_card_clicked(pegasus)
	assert_eq(screen._band_candidate, -1, "the manual's double-click: alone")
	assert_true(screen._selected_attackers.has(pegasus.id),
		"the creature is still attacking — that click was an answer, not a take-back")
	assert_eq(screen._selected_bands, [])
	assert_eq(_prompt(), "Combat phase: Choose attackers.")
	screen._on_done()
	assert_eq(g.combat.attackers.size(), 2)
	assert_eq(g.combat.bands, [], "two attackers, no band")


func test_done_answers_alone_and_declares_in_one_press() -> void:
	var g: MtgGame = screen.game
	var hero := _summon("Benalish Hero", 0)
	var pegasus := _summon("Mesa Pegasus", 0)
	_attackers_moment()
	screen._on_card_clicked(hero)
	screen._on_card_clicked(pegasus)
	assert_eq(screen._band_candidate, pegasus.id)
	screen._on_done()
	assert_false(g.awaiting_attackers, "one Done: the lineup went in as shown")
	assert_eq(g.combat.attackers.size(), 2)
	assert_eq(g.combat.bands, [])


func test_a_plain_creature_may_ride_with_a_bander_but_two_may_not() -> void:
	var g: MtgGame = screen.game
	var hero := _summon("Benalish Hero", 0)
	var lions := _summon("Savannah Lions", 0)
	var bears := _summon("Grizzly Bears", 0)
	_attackers_moment()
	screen._on_card_clicked(hero)
	screen._on_card_clicked(lions)
	assert_eq(screen._band_candidate, lions.id,
		"a creature without banding may be the band's one rider (CR 702.22c)")
	screen._on_card_clicked(hero)
	assert_eq(screen._selected_bands.size(), 1)
	screen._on_card_clicked(bears)
	assert_eq(screen._band_candidate, -1,
		"the Bears have nobody to band with: the band has its rider, and Bears + Lions has no bander")
	assert_true(screen._selected_attackers.has(bears.id))
	screen._on_done()
	assert_false(g.awaiting_attackers)
	assert_eq(g.combat.attackers.size(), 3)
	assert_eq(g.combat.bands.size(), 1)
	assert_false(g.combat.band_of(bears.id).has(hero.id), "the Bears attack alone")


func test_two_plain_creatures_are_never_asked() -> void:
	var lions := _summon("Savannah Lions", 0)
	var bears := _summon("Grizzly Bears", 0)
	_attackers_moment()
	screen._on_card_clicked(lions)
	screen._on_card_clicked(bears)
	assert_eq(screen._band_candidate, -1, "no banding anywhere — no question")
	assert_eq(_prompt(), "Combat phase: Choose attackers.")


func test_a_click_on_a_non_attacker_keeps_the_question_up() -> void:
	var hero := _summon("Benalish Hero", 0)
	var pegasus := _summon("Mesa Pegasus", 0)
	var bears := _summon("Grizzly Bears", 0)
	var theirs := _summon("Grizzly Bears", 1)
	_attackers_moment()
	screen._on_card_clicked(hero)
	screen._on_card_clicked(pegasus)
	screen._on_card_clicked(bears)
	assert_eq(screen._band_candidate, pegasus.id, "still asking")
	assert_false(screen._selected_attackers.has(bears.id),
		"the Bears were not added: the click was an answer that missed")
	assert_true(_prompt().begins_with("That isn't an attacker. "),
		"@PROMPT_BANDWITHWHOM entry 3: %s" % _prompt())
	assert_true(_prompt().contains(DuelScreen.BAND_QUESTION),
		"the question stays on the bar behind the refusal")
	assert_true(_prompt().contains("click Mesa Pegasus again to attack alone"),
		"and the way out is named")
	screen._on_card_clicked(theirs)
	assert_eq(screen._band_candidate, pegasus.id)
	assert_true(_prompt().begins_with("That isn't an attacker. "),
		"the opponent's creature is no attacker either")


func test_a_third_bander_joins_the_whole_band() -> void:
	var g: MtgGame = screen.game
	var hero := _summon("Benalish Hero", 0)
	var pegasus := _summon("Mesa Pegasus", 0)
	var wolves := _summon("Timber Wolves", 0)
	_attackers_moment()
	screen._on_card_clicked(hero)
	screen._on_card_clicked(pegasus)
	screen._on_card_clicked(hero)
	screen._on_card_clicked(wolves)
	assert_eq(screen._band_candidate, wolves.id)
	assert_eq(screen._highlight_for(hero), MiniCard.Highlight.TARGET_LEGAL)
	assert_eq(screen._highlight_for(pegasus), MiniCard.Highlight.TARGET_LEGAL,
		"either member of the band is the band")
	screen._on_card_clicked(pegasus)
	assert_eq(screen._selected_bands.size(), 1, "one band of three, not two bands")
	assert_eq(screen._selected_bands[0].size(), 3)
	assert_eq(screen._combat_window.band_groups(), [[hero.id, pegasus.id, wolves.id]])
	screen._on_done()
	assert_eq(g.combat.band_of(wolves.id).size(), 3)


func test_taking_an_attacker_back_dissolves_its_band() -> void:
	var hero := _summon("Benalish Hero", 0)
	var pegasus := _summon("Mesa Pegasus", 0)
	_attackers_moment()
	screen.game.rules.attackers_revocable = true
	screen._on_card_clicked(hero)
	screen._on_card_clicked(pegasus)
	screen._on_card_clicked(hero)
	assert_eq(screen._selected_bands.size(), 1)
	screen._on_card_clicked(hero)
	assert_false(screen._selected_attackers.has(hero.id), "the Hero is taken back")
	assert_eq(screen._selected_bands, [],
		"a band of one is no band (CombatState.remove_from_bands' shape)")
	assert_eq(screen._combat_window.band_groups(), [])


func test_cancel_forgets_the_bands_and_the_question() -> void:
	var hero := _summon("Benalish Hero", 0)
	var pegasus := _summon("Mesa Pegasus", 0)
	_attackers_moment()
	screen.game.rules.attackers_revocable = true
	screen._on_card_clicked(hero)
	screen._on_card_clicked(pegasus)
	assert_eq(screen._band_candidate, pegasus.id)
	screen._on_cancel()
	assert_eq(screen._selected_attackers, [])
	assert_eq(screen._selected_bands, [])
	assert_eq(screen._band_candidate, -1)


func test_an_illegal_band_is_refused_with_the_engines_reason() -> void:
	# Two riders: the Lions ride with the Hero, then the Bears try to join.
	# The Bears are never ASKED (no partner is legal), so force the
	# answer the way a stale click would and read the refusal.
	var hero := _summon("Benalish Hero", 0)
	var lions := _summon("Savannah Lions", 0)
	var bears := _summon("Grizzly Bears", 0)
	_attackers_moment()
	screen._on_card_clicked(hero)
	screen._on_card_clicked(lions)
	screen._on_card_clicked(hero)
	screen._on_card_clicked(bears)
	assert_eq(screen._band_candidate, -1)
	screen._band_candidate = bears.id
	screen._on_card_clicked(hero)
	assert_eq(screen._band_candidate, bears.id, "still asking")
	assert_true(_prompt().begins_with("Illegal band. at most one creature in a band can lack banding."),
		"@PROMPT_BANDWITHWHOM entry 2 with the engine's reason: %s" % _prompt())
	assert_true(_prompt().ends_with(DuelScreen.BAND_QUESTION))
	assert_eq(screen._selected_bands.size(), 1, "the Hero's band is untouched")


func test_the_opponents_declared_band_is_framed_too() -> void:
	var g: MtgGame = screen.game
	var hero := _summon("Benalish Hero", 1)
	var pegasus := _summon("Mesa Pegasus", 1)
	var bears := _summon("Grizzly Bears", 1)
	g.active_player = 1
	g._step_index = Mtg.STEP_ORDER.find(Mtg.Step.DECLARE_ATTACKERS)
	g.awaiting_attackers = true
	assert_eq(g.declare_attackers(1, [hero.id, pegasus.id, bears.id],
		[[hero.id, pegasus.id]]), "")
	screen._refresh()
	assert_eq(screen._combat_window.lane_ids()[0], [hero.id, pegasus.id, bears.id],
		"their attack fills the upper lane")
	assert_eq(screen._combat_window.band_groups(), [[hero.id, pegasus.id]],
		"the AI's band is framed; the Bears stand loose")
