extends RefCounted
const F := preload("res://cards/sets/fem/_rules.gd")
const C := preload("res://cards/sets/ice/_creatures.gd")

static func configure(c: CardData) -> bool:
	match c.card_name:
		"Jeweled Amulet", "Ice Cauldron":
			var cauldron := c.card_name == "Ice Cauldron"
			var a := F._ability("{X}" if cauldron else "{1}", true, F.Action.new(_store.bind(cauldron), "store the mana spent on this activation", null, true)).only_if(_empty)
			a.capture_mana_spent = true
			c.activated(a)
			c.static_ability(StaticAbility.new(_stored_ability.bind(cauldron), "Tap and remove a charge counter to release the last noted mana.").changing_abilities())
		"Krovikan Sorcerer":
			for black in [false, true]:
				var a := F._ability("", true, F.Action.new(_sorcerer.bind(black), "draw two cards, then discard one of them" if black else "draw a card", null, true)).with_discard_cost(1)
				a.discard_filter = _discard_color.bind(black)
				a.discard_filter_desc = "black card" if black else "nonblack card"
				c.activated(a)
		_: return false
	return true

static func _empty(_g: MtgGame, s: CardInstance) -> String:
	return "" if int(s.counters.get("charge", 0)) == 0 else "There must be no charge counters"
static func _store(g: MtgGame, s: CardInstance, pid: int, _t: TargetRef, _x: int, cauldron: bool) -> void:
	var exiled: CardInstance = null
	if cauldron:
		var candidates: Array[CardInstance] = []
		for i in g.players[pid].hand:
			if not i.is_land(): candidates.append(i)
		if not candidates.is_empty():
			var pick := g.agents[pid].choose_card(g, pid, candidates, "Ice Cauldron: you may exile a nonland card from your hand", true)
			if pick != null and candidates.has(pick):
				g.exile_from_hand(pick)
				g.grant_exile_play(pick, pid)
				exiled = pick
	# Exile/cast permission survives the source leaving, but a new copy of
	# the artifact must never receive this activation's counter or memory.
	if not C.same_activation(g, s): return
	g._rec(s, &"memory")
	s.memory["stored_mana"] = g.cost_paid("_mana_spent", {}).duplicate()
	if exiled != null:
		s.memory["stored_card"] = [exiled.id, exiled.exile_entry]
	g.add_counters(s, "charge")
	g.recalculate()
static func _stored_ability(_g: MtgGame, s: CardInstance, cauldron: bool) -> void:
	var mana: Dictionary = s.memory.get("stored_mana", {})
	var a := ManaAbility.new(Mtg.ManaColor.C, 0).with_counter_cost("charge")
	a.planner_counter_cost = true
	a.produces = []
	for color in mana:
		if int(mana[color]) > 0: a.produces.append([int(color), int(mana[color])])
	if a.produces.is_empty(): a.produces.append([Mtg.ManaColor.C, 0])
	if cauldron:
		var card: Array = s.memory.get("stored_card", [-1, -1])
		a.with_restriction("exiled_card:%d:%d" % [int(card[0]), int(card[1])])
	s.cur_mana_abilities.append(a)
static func _discard_color(i: CardInstance, black: bool) -> bool: return ((i.cur_colors & Mtg.ManaColor.B) != 0) == black
static func _sorcerer(g: MtgGame, _s: CardInstance, pid: int, _t: TargetRef, _x: int, black: bool) -> void:
	var before := g.players[pid].drawn_this_turn.size()
	g.draw_cards(pid, 2 if black else 1)
	if not black: return
	var candidates: Array[CardInstance] = []
	for n in range(before, g.players[pid].drawn_this_turn.size()):
		var i: CardInstance = g.players[pid].drawn_this_turn[n]
		if i.zone == Mtg.Zone.HAND and not candidates.has(i): candidates.append(i)
	if candidates.is_empty(): return
	var pick := g.agents[pid].choose_card(g, pid, candidates, "Krovikan Sorcerer: discard one of the cards just drawn", false, true)
	if pick != null and candidates.has(pick): g.discard_cards(pid, [pick])
