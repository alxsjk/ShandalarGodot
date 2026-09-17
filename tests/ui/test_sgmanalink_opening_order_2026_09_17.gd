extends GutTest
## The toss winner's play/draw choice is spent by KEEPING or REDRAWING, and by
## nothing else. Any op is a legal wire command at any moment, and one the
## referee refused during the opening used to consume the choice anyway — with
## no state change, so the room's revision did not move either, and the opening
## went on offering neither the order nor a mulligan.

var referee: SgPracticeMatch


func before_each() -> void:
	referee = SgPracticeMatch.new(42)


func after_each() -> void:
	referee = null


func test_a_refused_opening_action_does_not_decide_play_or_draw() -> void:
	var winner := referee.toss_winner
	assert_true(referee.game.mulligan_open)
	assert_false(referee.order_chosen)
	assert_eq(int(referee.decision_state().actor), winner)
	assert_ne(referee.act(winner, {"op": "pass"}), "", "there is no priority to pass yet")
	assert_false(referee.order_chosen, "a refused action must not spend the choice")
	assert_false(referee.view(winner).presentation.order, "and the opening still asks for it")
	assert_eq(referee.act(winner, {"op": "order", "play": false}), "")
	assert_true(referee.order_chosen)
	assert_eq(referee.first_player, 1 - winner)


func test_the_opening_still_completes_after_a_refused_action() -> void:
	var winner := referee.toss_winner
	assert_ne(referee.act(winner, {"op": "cancel"}), "")
	assert_eq(referee.act(winner, {"op": "order", "play": true}), "")
	var first := referee.first_player
	assert_eq(first, winner)
	assert_eq(referee.act(first, {"op": "keep"}), "")
	assert_eq(referee.act(1 - first, {"op": "keep"}), "")
	assert_false(referee.game.mulligan_open)
	assert_eq(referee.game.active_player, first)
