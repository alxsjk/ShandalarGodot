extends RefCounted
const F := preload("res://cards/sets/fem/_rules.gd")

static func configure(c: CardData) -> bool:
	match c.card_name:
		"Sacred Boon": c.spell(Boon.new())
		"Balduvian Shaman":
			c.activated(F._ability("", true, F.Action.new(_shaman, "change a Circle of Protection's color and grant cumulative upkeep {1}", TargetSpec.new(TargetSpec.Kind.PERMANENT, "target white Circle of Protection you control without cumulative upkeep", _circle).with_source_filter(_eligible_circle), true)))
		"Soul Burn": c.with_colored_x(Mtg.ManaColor.B | Mtg.ManaColor.R).spell(SoulBurn.new())
		"Spoils of War":
			c.announcement_condition = _spoils_x
			var effect := F.Action.new(_spoils, "distribute X +1/+1 counters among target creatures", TargetSpec.creature(), true)
			effect.divided_among(-1)
			c.spell(effect)
		"Winter's Chill":
			c.castable_only_when(_before_blocks)
			c.announcement_condition = _chill_x
			c.spell(F.Action.new(_chill, "pay {2}, pay {1} to prevent combat damage, or face destruction at end of combat", TargetSpec.creature("target attacking creature").with_game_filter(_attacking)).x_targets())
		_: return false
	return true

class Boon extends PreventDamageEffect:
	func _init() -> void:
		super(3)
		target_creature()
		helpful()
	func resolve(g: MtgGame, s: CardInstance, pid: int, target: TargetRef, _x := 0) -> void:
		var i := g.find_instance(target.instance_id)
		if i == null or i.zone != Mtg.Zone.BATTLEFIELD: return
		var id := g.book_tracked_prevention(i, 3, "Sacred Boon")
		g.schedule_delayed_trigger(TriggeredAbility.new(Mtg.EventType.END_STEP_START,
			load("res://cards/sets/ice/_remaining.gd")._boon_counters.bind(i.id, i.layer_timestamp, id),
			"Put a +0/+1 counter on the creature for each damage Sacred Boon prevented."), pid, s)

static func _boon_counters(g: MtgGame, _s: CardInstance, _event: GameEvent, id: int, stamp: int, receipt: int) -> void:
	var i := g.find_instance(id)
	if i == null or i.zone != Mtg.Zone.BATTLEFIELD or i.layer_timestamp != stamp: return
	var row := g.prevention_receipt(i, receipt)
	if row.is_empty(): return
	var n := int(row.prevented)
	g._rec(i, &"tracked_prevention")
	row.collected = true
	if n > 0: g.add_counters(i, "+0/+1", n)

class SoulBurn extends DamageEffect:
	func _init() -> void:
		super(0)
		x_damage()
		any_target()
	func resolve(g: MtgGame, s: CardInstance, pid: int, target: TargetRef, x := 0) -> void:
		var max_life := g.players[target.player_id].life if target.is_player else g.find_instance(target.instance_id).cur_toughness
		var black := int(g.cost_paid("restricted_x_paid", {}).get(Mtg.ManaColor.B, 0))
		var cap := maxi(0, mini(max_life, black))
		g.deal_damage(s, target, x, false, func(dealt: int) -> void: g.adjust_life(pid, mini(dealt, cap)))

static func spoils_count(g: MtgGame, pid: int) -> int:
	var count := 0
	for i in g.players[1 - pid].graveyard:
		if i.is_type(Mtg.CardType.ARTIFACT) or i.is_creature(): count += 1
	return count
static func _spoils_x(g: MtgGame, pid: int, _s: CardInstance, x: int, _targets: Array) -> String:
	return "" if x == spoils_count(g, pid) else "X must equal the number of artifact and/or creature cards in your opponent's graveyard"
static func _spoils(g: MtgGame, _s: CardInstance, _pid: int, t: TargetRef, _x: int) -> void:
	if t == null: return
	var i := g.find_instance(t.instance_id)
	if i != null: g.add_counters(i, "+1/+1", t.amount)
static func _before_blocks(g: MtgGame, _pid: int) -> String:
	return "" if g.current_step() in [Mtg.Step.COMBAT_BEGIN, Mtg.Step.DECLARE_ATTACKERS] else "Cast only during combat before blockers are declared"
static func snow_lands(g: MtgGame, pid: int) -> int:
	var count := 0
	for i in g.players[pid].battlefield:
		if i.is_land() and (i.cur_supertypes & Mtg.Supertype.SNOW) != 0: count += 1
	return count
static func _chill_x(g: MtgGame, pid: int, _s: CardInstance, x: int, _targets: Array) -> String:
	return "" if x <= snow_lands(g, pid) else "X cannot exceed the number of snow lands you control"
static func _attacking(g: MtgGame, i: CardInstance) -> bool: return g.combat.attackers.has(i.id)
static func _chill(g: MtgGame, s: CardInstance, pid: int, t: TargetRef, _x: int) -> void:
	if t == null: return
	var i := g.find_instance(t.instance_id)
	if i == null: return
	var who := i.controller_id
	var options: Array[String] = ["Don't pay — destroy at end of combat"]
	var costs: Array[int] = [0]
	for n in [1, 2]:
		if g.can_afford_cost(who, ManaCost.parse("{%d}" % n)):
			options.append("Pay {%d}%s" % [n, " — prevent combat damage to and from it" if n == 1 else ""])
			costs.append(n)
	var selected := g.agents[who].choose_option(g, who, options, "Winter's Chill: choose for " + i.data.card_name, options.size() - 1)
	var paid := int(costs[selected]) if selected >= 0 and selected < costs.size() else 0
	if paid > 0 and not g.try_pay(who, ManaCost.parse("{%d}" % paid)): paid = 0
	if paid == 1:
		g.continuous.add_until_eot_combat_prevention(i.id, true, true, true)
		g.recalculate()
	elif paid == 0:
		g.schedule_delayed_trigger(TriggeredAbility.new(Mtg.EventType.END_OF_COMBAT, _chill_destroy.bind(i.id, i.layer_timestamp), "Destroy the creature affected by Winter's Chill."), pid, s)
static func _chill_destroy(g: MtgGame, _s: CardInstance, _event: GameEvent, id: int, stamp: int) -> void:
	var i := g.find_instance(id)
	if i != null and i.zone == Mtg.Zone.BATTLEFIELD and i.layer_timestamp == stamp: g.destroy(i)

static func _circle(i: CardInstance) -> bool:
	return i.data.card_name in ["Circle of Protection: White", "Circle of Protection: Blue", "Circle of Protection: Black", "Circle of Protection: Red", "Circle of Protection: Green"] and (i.cur_colors & Mtg.ManaColor.W) != 0 and i.is_type(Mtg.CardType.ENCHANTMENT)
static func circle_color(i: CardInstance) -> int:
	if i.memory.has("shaman_circle_color"): return int(i.memory.shaman_circle_color)
	return {"White": Mtg.ManaColor.W, "Blue": Mtg.ManaColor.U, "Black": Mtg.ManaColor.B, "Red": Mtg.ManaColor.R, "Green": Mtg.ManaColor.G}.get(i.data.card_name.get_slice(": ", 1), 0)
static func _eligible_circle(_g: MtgGame, s: CardInstance, i: CardInstance) -> bool:
	if s.controller_id != i.controller_id: return false
	for trigger in i.cur_triggered_abilities:
		if trigger.text.begins_with("Cumulative upkeep"): return false
	return true
static func _shaman(g: MtgGame, s: CardInstance, pid: int, target: TargetRef, _x: int) -> void:
	var i := g.find_instance(target.instance_id)
	if i == null: return
	var previous := circle_color(i)
	var colors: Array[int] = []
	var labels: Array[String] = []
	var hint := 0
	var most := -1
	for color in Mtg.WUBRG:
		if color == previous: continue
		var strength := 0
		for enemy in g.players[1 - pid].battlefield:
			if (g.damage_source_colors(enemy) & color) != 0: strength += maxi(1, enemy.cur_power)
		if strength > most:
			most = strength
			hint = colors.size()
		colors.append(color)
		labels.append(Mtg.COLOR_NAMES[color])
	var answer := g.agents[pid].choose_option(g, pid, labels, "Balduvian Shaman: choose this Circle's new color", hint)
	if answer < 0 or answer >= colors.size(): return
	g._rec(i, &"memory")
	i.memory["shaman_circle_color"] = colors[answer]
	g.continuous.add_floating_static(s, StaticAbility.new(_shaman_grant.bind(i.id), "Changed Circle color; cumulative upkeep {1}.").changing_abilities(), ContinuousEffects.Duration.INDEFINITE, -1, false, i.id)
	g.recalculate()
static func _shaman_grant(g: MtgGame, _s: CardInstance, id: int) -> void:
	var i := g.find_instance(id)
	if i == null or i.zone != Mtg.Zone.BATTLEFIELD: return
	var color := circle_color(i)
	i.cur_activated_abilities = [F._ability("{1}", false, PreventDamageShieldEffect.new(color))]
	i.cur_triggered_abilities.append(CumulativeUpkeep.ability("{1}"))
