extends GutTest
## THE SHOWCASE NEVER NAMES A CARD THAT IS FACE DOWN (`docs/card-states.md`
## §5.1). The small card already keeps the secret everywhere — the board's
## own widget (`DuelScreen._make_widget`), a pile's row
## (`CardPile._make_card`) and the graveyard viewer's shelf
## (`GraveyardView._card`) all wear the card back — but the ENLARGED card
## in the sidebar is filled by three handlers of its own, and all three
## used to hand it the instance without asking:
##
##   * `@MENU_SMALLCARD`'s `Show full card` / `Original type`, which a
##     quick right-click on a masked creature reaches (an Illusionary Mask
##     creature is a legal click target — it attacks, it blocks, it can be
##     given damage — so the menu opens on it);
##   * a pile's hover, which is where a face-down land or artifact lives
##     the moment the board groups it;
##   * the graveyard/exile viewer's hover, over a card exiled face down
##     (Knowledge Vault) that nobody may look at.
##
## The seat a rule DID show an exiled card to (Gustha's Scepter) still
## reads it; that is the other half of the same question.


var screen: DuelScreen


func before_each() -> void:
	screen = load("res://game/duel/duel_screen.tscn").instantiate()
	add_child_autofree(screen)
	await get_tree().process_frame


func after_each() -> void:
	# The refresh drops old card widgets at once and frees them at frame end.
	await get_tree().process_frame
	await get_tree().process_frame


func _summon(pid: int, card_name: String) -> CardInstance:
	var g: MtgGame = screen.game
	var inst := CardInstance.new(CardRegistry.get_card(card_name),
		g._next_instance_id, pid)
	g._next_instance_id += 1
	g._instances[inst.id] = inst
	g._put_on_battlefield(inst, pid)
	inst.summoning_sick = false
	return inst


func _exile_face_down(pid: int, card_name: String, visible_to: int) -> CardInstance:
	var g: MtgGame = screen.game
	var inst := CardInstance.new(CardRegistry.get_card(card_name),
		g._next_instance_id, pid)
	g._next_instance_id += 1
	g._instances[inst.id] = inst
	inst.zone = Mtg.Zone.EXILE
	inst.face_down = true
	inst.exile_visible_to = visible_to
	g.players[pid].exile.append(inst)
	return inst


func test_the_card_menu_will_not_show_a_face_down_card(
		entry = use_parameters([0, 1])) -> void:
	var lion := _summon(1, "Savannah Lions")
	screen.game.turn_face_down(lion)
	screen._card_preview.show_back()
	screen._open_card_menu(lion, Vector2.ZERO)
	screen._card_menu.hide()
	screen._on_card_menu_chosen(int(entry))
	assert_true(screen._card_preview._back.visible,
		"entry %d must not name a masked creature" % int(entry))


func test_the_card_menu_still_shows_an_ordinary_card() -> void:
	var lion := _summon(1, "Savannah Lions")
	screen._card_preview.show_back()
	screen._open_card_menu(lion, Vector2.ZERO)
	screen._card_menu.hide()
	screen._on_card_menu_chosen(1)
	assert_false(screen._card_preview._back.visible,
		"a card anybody may look at still fills the Showcase")


func test_hovering_a_face_down_row_in_a_pile_keeps_the_showcase_shut() -> void:
	# Lands and artifacts group into a pile the moment there are two of
	# them (tests/ui/test_duel_screen.gd pins that), and the pile builds
	# its own faces.
	var open_one := _summon(0, "Ornithopter")
	var masked := _summon(0, "Ornithopter")
	screen.game.turn_face_down(masked)
	var pile := CardPile.new()
	add_child_autofree(pile)
	pile.preview = screen._card_preview
	pile.populate([open_one, masked], false, screen._on_card_clicked,
		screen._highlight_for)
	screen._card_preview.show_back()
	pile._on_card_hover(masked, null)
	assert_true(screen._card_preview._back.visible,
		"the pile's card back is worth nothing if the sidebar reads the card")
	pile._on_card_hover(open_one, null)
	assert_false(screen._card_preview._back.visible,
		"and the open one beside it is still examinable")


func test_hovering_a_face_down_exile_keeps_the_showcase_shut() -> void:
	_exile_face_down(0, "Lightning Bolt", -1)
	screen._open_graveyard(0)
	screen._card_preview.show_back()
	var shelf := screen._grave_view.widgets(Mtg.Zone.EXILE, 0)
	assert_eq(shelf.size(), 1, "the viewer shows the one exiled card")
	assert_true((shelf[0] as MiniCard).face_down, "as a card back")
	(shelf[0] as MiniCard).mouse_entered.emit()
	assert_true(screen._card_preview._back.visible,
		"nobody may look at a card exiled face down")


func test_hovering_an_exile_a_rule_showed_you_still_enlarges_it() -> void:
	# Gustha's Scepter exiles face down and lets its own controller look.
	_exile_face_down(0, "Lightning Bolt", 0)
	screen._open_graveyard(0)
	screen._card_preview.show_back()
	var shelf := screen._grave_view.widgets(Mtg.Zone.EXILE, 0)
	assert_false((shelf[0] as MiniCard).face_down)
	(shelf[0] as MiniCard).mouse_entered.emit()
	assert_false(screen._card_preview._back.visible,
		"the seat a rule showed it to reads it in the Showcase too")
