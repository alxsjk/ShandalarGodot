class_name CumulativeUpkeep
extends RefCounted
## CR 702.24: one age counter, then one indivisible payment multiplied by
## ALL age counters. Each instance is its own trigger; no partial payment.
## Restricted upkeep mana is visible to both planning and final payment.

const USAGE := ["cumulative_upkeep"]

static func attach(card: CardData, cost := "", life := 0, sacrifice_type := "") -> CardData:
	return card.triggered(ability(cost, life, sacrifice_type))

static func ability(cost := "", life := 0, sacrifice_type := "") -> TriggeredAbility:
	return TriggeredAbility.new(Mtg.EventType.UPKEEP_START,
		_resolve.bind(cost, life, sacrifice_type),
		"Cumulative upkeep " + (cost if cost != "" else "— ") +
		("Pay %d life" % life if life > 0 else "") +
		("Sacrifice a " + sacrifice_type if sacrifice_type != "" else ""),
		_your_upkeep).capturing(_capture)

static func _your_upkeep(_g: MtgGame, source: CardInstance, event: GameEvent) -> bool:
	return int(event.data.get("player", -1)) == source.controller_id

static func _capture(_g: MtgGame, source: CardInstance, _event: GameEvent) -> Dictionary:
	return {"timestamp": source.layer_timestamp, "controller": source.controller_id}

static func _resolve(g: MtgGame, source: CardInstance, _event: GameEvent,
		cost_text: String, life: int, sacrifice_type: String) -> void:
	var context := g.trigger_context(source)
	if source.zone != Mtg.Zone.BATTLEFIELD or source.layer_timestamp != int(context.get("timestamp", -1)):
		return
	var pid := int(context.get("controller", source.controller_id))
	g.add_counters(source, "age")
	var ages := int(source.counters.get("age", 0))
	var cost := ManaCost.parse(cost_text.repeat(ages))
	var victims: Array[CardInstance] = []
	if sacrifice_type != "":
		for inst in g.players[pid].battlefield:
			if (sacrifice_type == "land" and inst.is_land()) or inst.has_subtype(sacrifice_type):
				victims.append(inst)
	var affordable := g.players[pid].life >= life * ages and g.can_afford_cost(pid, cost, USAGE)
	if sacrifice_type != "" and victims.size() < ages:
		affordable = false
	var hint := g.agents[pid].cumulative_upkeep_hint(g, pid, source, cost, life * ages,
		ages if sacrifice_type != "" else 0)
	var prompt := "%s: pay cumulative upkeep (%d age counters)%s%s%s?" % [
		source.data.card_name, ages, " " + cost.text if cost.text != "" else "",
		" and %d life" % (life * ages) if life > 0 else "",
		" and sacrifice %d %s(s)" % [ages, sacrifice_type] if sacrifice_type != "" else ""]
	if not affordable or not g.agents[pid].choose_yes_no(g, pid, prompt, hint):
		if source.controller_id == pid:
			g.sacrifice_permanent(source)
		return
	var selected: Array[CardInstance] = []
	if sacrifice_type != "":
		for i in ages:
			var pick := g.agents[pid].choose_card(g, pid, victims,
				"%s: sacrifice %s %d of %d for cumulative upkeep" % [source.data.card_name, sacrifice_type, i + 1, ages])
			if pick == null or not victims.has(pick):
				return
			victims.erase(pick)
			selected.append(pick)
	if not g.try_pay(pid, cost, USAGE):
		if source.controller_id == pid:
			g.sacrifice_permanent(source)
		return
	g.begin_simultaneous()
	if life > 0:
		g.adjust_life(pid, -life * ages)
	for inst in selected:
		g.sacrifice_permanent(inst)
	g.end_simultaneous()
