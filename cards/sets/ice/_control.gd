extends RefCounted
const F := preload("res://cards/sets/fem/_rules.gd")
const C := preload("res://cards/sets/ice/_creatures.gd")

static func configure(c: CardData) -> bool:
	match c.card_name:
		"Ray of Command":
			c.spell(F.Action.new(_borrow, "untap and gain control until end of turn, with haste; tap it when control ends", TargetSpec.creature().with_source_filter(_enemy)))
		"Magus of the Unseen":
			c.activated(F._ability("{1}{U}", true, F.Action.new(_borrow, "untap and gain control until end of turn, with haste; tap it when control ends", TargetSpec.new(TargetSpec.Kind.PERMANENT, "target artifact an opponent controls", _artifact).with_source_filter(_enemy))))
		"Merieke Ri Berit":
			c.static_ability(StaticAbility.new(_no_untap, "Doesn't untap during your untap step."))
			c.activated(F._ability("", true, F.Action.new(_merieke, "gain control while you control Merieke; destroy without regeneration when Merieke untaps or leaves", TargetSpec.creature())))
		"Infernal Denizen":
			c.triggered(TriggeredAbility.new(Mtg.EventType.UPKEEP_START, _denizen_upkeep, "Sacrifice two Swamps, or tap this creature and an opponent may take one of your creatures.", F._your_upkeep))
			c.activated(F._ability("", true, F.Action.new(_denizen, "gain control while Infernal Denizen remains on the battlefield", TargetSpec.creature())))
		"Orcish Squatters":
			c.triggered(TriggeredAbility.new(Mtg.EventType.BLOCKERS_DECLARED, _squatters, "May steal target defending land while you control this creature instead of assigning combat damage.", F._farrel_unblocked.bind(false)).capturing(_squat_context).targeting(TargetSpec.new(TargetSpec.Kind.PERMANENT, "target land defending player controls", _land).with_source_filter(_defender_land), F._enemy_first))
		"Krovikan Vampire":
			c.triggered(TriggeredAbility.new(Mtg.EventType.END_STEP_START, _vampire, "Return cards of creatures damaged by this creature that died this turn.", _vampire_due))
		"Seraph":
			c.triggered(TriggeredAbility.new(Mtg.EventType.DIES, _seraph, "Return that card at the beginning of the next end step.", _seraph_due).capturing(_seraph_context))
		_: return false
	return true

static func _enemy(_g: MtgGame, s: CardInstance, i: CardInstance) -> bool: return s.controller_id != i.controller_id
static func _artifact(i: CardInstance) -> bool: return i.is_type(Mtg.CardType.ARTIFACT)
static func _land(i: CardInstance) -> bool: return i.is_land()
static func _no_untap(_g: MtgGame, s: CardInstance) -> void: s.cur_skips_untap = true
static func _same(i: CardInstance, id: int, stamp: int) -> bool:
	return i != null and i.id == id and i.layer_timestamp == stamp
static func _control_lost(_g: MtgGame, _s: CardInstance, e: GameEvent, id: int, stamp: int, pid: int) -> bool:
	return _same(e.data.get("instance"), id, stamp) and int(e.data.get("from_controller", -1)) == pid
static func _released(_g: MtgGame, _s: CardInstance, e: GameEvent, id: int, stamp: int) -> bool:
	return _same(e.data.get("instance"), id, stamp)
static func _tap_returned(g: MtgGame, _s: CardInstance, _e: GameEvent, id: int, stamp: int) -> void:
	var i := g.find_instance(id)
	if _same(i, id, stamp): g.tap_permanent(i)
static func _destroy_released(g: MtgGame, _s: CardInstance, _e: GameEvent, id: int, stamp: int) -> void:
	var i := g.find_instance(id)
	if _same(i, id, stamp) and i.zone == Mtg.Zone.BATTLEFIELD: g.destroy(i, false)
static func _borrow(g: MtgGame, s: CardInstance, pid: int, t: TargetRef, _x: int) -> void:
	var i := g.find_instance(t.instance_id)
	if i == null or i.zone != Mtg.Zone.BATTLEFIELD: return
	g.untap_permanent(i)
	g.gain_control_until_eot(i, pid)
	g.continuous.add_until_eot_pump(i.id, 0, 0, [Mtg.Keyword.HASTE])
	g.recalculate()
	var trigger := TriggeredAbility.new(Mtg.EventType.CONTROL_CHANGED, _tap_returned.bind(i.id, i.layer_timestamp), "Tap the borrowed permanent.", _control_lost.bind(i.id, i.layer_timestamp, pid)).also_when(Mtg.EventType.LEAVES_BATTLEFIELD)
	g.schedule_delayed_trigger(trigger, pid, s)
static func _merieke(g: MtgGame, s: CardInstance, pid: int, t: TargetRef, _x: int) -> void:
	var i := g.find_instance(t.instance_id)
	if i == null or i.zone != Mtg.Zone.BATTLEFIELD: return
	if F._original_source(g, s, pid): g.gain_control_leashed(i, s)
	# The destruction is a separate, once-only delayed trigger. Losing
	# Merieke's control is NOT untapping/leaving, and doesn't destroy it.
	var stamp := int(g.cost_paid("_source_timestamp", s.layer_timestamp))
	var trigger := TriggeredAbility.new(Mtg.EventType.BECAME_UNTAPPED, _destroy_released.bind(i.id, i.layer_timestamp), "Destroy Merieke's creature; it can't be regenerated.", _released.bind(s.id, stamp)).also_when(Mtg.EventType.LEAVES_BATTLEFIELD)
	g.schedule_delayed_trigger(trigger, pid, s)
static func _denizen(g: MtgGame, s: CardInstance, pid: int, t: TargetRef, _x: int) -> void:
	if not C.same_activation(g, s): return
	g.CONTROL_LAYERS.add(g, g.find_instance(t.instance_id), pid, "leash", s, false, false, false)
	g.recalculate()
static func _denizen_upkeep(g: MtgGame, s: CardInstance, _e: GameEvent) -> void:
	var pid := int(g.trigger_context(s).controller)
	var lands: Array[CardInstance] = []
	for i in g.players[pid].battlefield:
		if i.has_subtype("swamp"): lands.append(i)
	if lands.size() >= 2:
		var chosen: Array[CardInstance] = []
		for n in 2:
			var pick := g.agents[pid].choose_card(g, pid, lands, "Infernal Denizen: choose Swamp %d of 2 to sacrifice" % (n + 1), false, true)
			if pick == null or not lands.has(pick): return
			chosen.append(pick)
			lands.erase(pick)
		g.begin_simultaneous()
		for i in chosen: g.sacrifice_permanent(i)
		g.end_simultaneous()
		return
	# Do as much of an instruction as possible: one Swamp is still lost.
	for i in lands: g.sacrifice_permanent(i)
	if not F._same_trigger_source(g, s): return
	g.tap_permanent(s)
	var creatures: Array[CardInstance] = []
	for i in g.players[pid].battlefield:
		if i.is_creature(): creatures.append(i)
	if creatures.is_empty(): return
	var pick := g.agents[1 - pid].choose_card(g, 1 - pid, creatures, "Infernal Denizen: you may take one of that player's creatures", true)
	if pick != null and creatures.has(pick):
		g.CONTROL_LAYERS.add(g, pick, 1 - pid, "leash", s, false, false, false)
		g.recalculate()
static func _squat_context(g: MtgGame, s: CardInstance, e: GameEvent) -> Dictionary:
	var ctx := F._source_context(g, s, e)
	ctx["control"] = s.control_sequence
	ctx["defender"] = 1 - s.controller_id
	return ctx
static func _defender_land(g: MtgGame, s: CardInstance, i: CardInstance) -> bool:
	return i.controller_id == int(g.trigger_context(s).get("defender", 1 - s.controller_id))
static func _squatters(g: MtgGame, s: CardInstance, _e: GameEvent) -> void:
	if g.current_targets().is_empty(): return
	var ctx := g.trigger_context(s)
	var pid := int(ctx.controller)
	if not F._same_trigger_source(g, s) or s.control_sequence != int(ctx.control): return
	if not g.agents[pid].choose_yes_no(g, pid, "Orcish Squatters: take the land instead of assigning combat damage?", true): return
	var i := g.find_instance(g.current_targets()[0].instance_id)
	if i == null: return
	g.gain_control_leashed(i, s)
	if i.controller_id == pid:
		g.continuous.add_floating_static(s, StaticAbility.new(_no_damage.bind(s.id), "Assigns no combat damage this turn."), ContinuousEffects.Duration.END_OF_TURN, -1, false, s.id)
		g.recalculate()
static func _no_damage(g: MtgGame, _s: CardInstance, id: int) -> void:
	var i := g.find_instance(id)
	if i != null and i.zone == Mtg.Zone.BATTLEFIELD: i.cur_assigns_no_combat_damage = true

static func _vampire_due(g: MtgGame, s: CardInstance, _e: GameEvent) -> bool:
	var key := "%d:%d" % [s.id, s.layer_timestamp]
	for row in g.deaths_this_turn:
		if row.origins.has(key): return true
	return false
static func _vampire(g: MtgGame, s: CardInstance, _e: GameEvent) -> void:
	var ctx := g.trigger_context(s)
	var stamp := int(ctx.timestamp)
	var pid := int(ctx.controller)
	var key := "%d:%d" % [s.id, stamp]
	# Re-evaluate on resolution: another damaged creature can die in
	# response to the end-step trigger and also be returned (Oracle).
	var rows: Array = []
	for row in g.deaths_this_turn:
		if row.origins.has(key) and not bool(row.token): rows.append(row)
	for row in rows: _return_claim(g, s, pid, stamp, int(row.id), int(row.entry))
static func _seraph_due(_g: MtgGame, s: CardInstance, e: GameEvent) -> bool:
	var i: CardInstance = e.data.instance
	return (i.last_types & Mtg.CardType.CREATURE) != 0 and e.data.get("damage_origins", {}).has("%d:%d" % [s.id, s.layer_timestamp])
static func _seraph_context(g: MtgGame, s: CardInstance, e: GameEvent) -> Dictionary:
	var ctx := F._source_context(g, s, e)
	ctx.merge({"id": e.data.instance.id, "entry": e.data.graveyard_entry, "token": e.data.instance.is_token})
	return ctx
static func _seraph(g: MtgGame, s: CardInstance, _e: GameEvent) -> void:
	var ctx := g.trigger_context(s)
	if bool(ctx.token): return
	g.schedule_delayed_trigger(TriggeredAbility.new(Mtg.EventType.END_STEP_START, _seraph_return.bind(int(ctx.controller), int(ctx.timestamp), int(ctx.id), int(ctx.entry)), "Return Seraph's claimed card."), int(ctx.controller), s)
static func _seraph_return(g: MtgGame, s: CardInstance, _e: GameEvent, pid: int, stamp: int, id: int, entry: int) -> void:
	_return_claim(g, s, pid, stamp, id, entry)
static func _return_claim(g: MtgGame, s: CardInstance, pid: int, stamp: int, id: int, entry: int) -> void:
	var i := g.find_instance(id)
	if i == null or i.is_token or i.zone != Mtg.Zone.GRAVEYARD or i.graveyard_entry != entry: return
	g.reanimate(i, pid)
	if i.zone != Mtg.Zone.BATTLEFIELD: return
	var trigger := TriggeredAbility.new(Mtg.EventType.CONTROL_CHANGED, _sacrifice_claim.bind(i.id, i.layer_timestamp), "Sacrifice the returned permanent when you lose control of its claimant.", _control_lost.bind(s.id, stamp, pid)).also_when(Mtg.EventType.LEAVES_BATTLEFIELD)
	g.schedule_delayed_trigger(trigger, pid, s)
static func _sacrifice_claim(g: MtgGame, _s: CardInstance, _e: GameEvent, id: int, stamp: int) -> void:
	var i := g.find_instance(id)
	if _same(i, id, stamp) and i.zone == Mtg.Zone.BATTLEFIELD and i.controller_id == int(g.current_delayed().controller):
		g.sacrifice_permanent(i)
