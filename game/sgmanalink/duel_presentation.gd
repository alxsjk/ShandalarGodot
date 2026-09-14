class_name SgDuelPresentation
extends RefCounted
## A deliberate allowlist for the existing duel renderer. Never a snapshot.
## References are viewer-local capabilities, not engine ids. Even the host's
## UI consumes this filtered representation instead of its referee object.

const FLAGS := ["cur_extra_blocks", "cur_cant_attack", "cur_attacks_as_if_hasty",
	"cur_must_be_blocked", "must_attack_this_turn", "cur_indestructible", "cur_skips_untap",
	"skip_next_untap", "skip_untaps"]
const RULES := ["mana_burn", "attackers_revocable", "tapped_artifacts_stop",
	"life_checked_at_phase_end", "pool_empties_on_attack", "free_damage_assignment",
	"damage_prevention_window"]
const CUES := ["sfx_cast", "sfx_land", "sfx_draw", "sfx_tap", "sfx_attack",
	"sfx_block", "sfx_life_loss", "sfx_damage", "sfx_mana_burn", "sfx_buried", "sfx_discard",
	"sfx_summon", "sfx_cast_artifact", "sfx_cast_enchantment", "sfx_cast_sorcery",
	"sfx_cast_interrupt", "sfx_cast_instant", "sfx_land_grey"]


static func object_handle(match_state: SgPracticeMatch, pid: int, kind: String, id: int) -> String:
	var key := kind + str(id)
	var handles: Dictionary = match_state._object_handles[pid]
	if not handles.has(key): handles[key] = "o%d" % (handles.size() + 1)
	return handles[key]


static func target_reference(m: SgPracticeMatch, pid: int, target: TargetRef) -> Dictionary:
	if target == null: return {}
	if target.is_player: return {"kind": "player", "id": str(target.player_id), "amount": target.amount}
	if target.is_ability:
		return {"kind": "ability", "id": object_handle(m, pid, "ability", target.ability_id), "amount": target.amount}
	if target.is_damage:
		return {"kind": "damage", "id": object_handle(m, pid, "damage", target.packet_id), "amount": target.amount}
	var card := m.game.find_instance(target.instance_id)
	if not m._visible(pid, card): return {}
	return {"kind": "card", "id": m._handle(pid, card), "amount": target.amount}


static func build(m: SgPracticeMatch, pid: int, view: Dictionary) -> Dictionary:
	var g := m.game
	var result := {"priority": g.priority_player, "toss": m.toss_winner, "order": m.order_chosen,
		"rules": {}, "cues": m.cues.duplicate(true), "events": m.visual_events[pid].duplicate(true), "cards": [], "players": [],
		"chain": [], "packets": [], "bands": [], "blocks": [], "blocked": [],
		"attackable": [], "blockable": [], "assignment": {}, "targets": [],
		"prevention": g.awaiting_damage_prevention, "regeneration": g.awaiting_regeneration,
		"draft": {}, "respond": false, "floating": false, "untap_capped": not g.untap_caps.is_empty()}
	for key in RULES: result.rules[key] = g.rules.get(key)
	for seat in 2:
		var p := g.players[seat]
		result.players.append({"poison": p.poison, "lands": p.lands_played_this_turn,
			"hand_revealed": p.hand_revealed})
		var visible: Array = p.battlefield + p.graveyard + p.exile + p.ante
		for card in p.hand:
			if m._visible(pid, card): visible.append(card)
		for card: CardInstance in visible:
			var row := {"id": m._handle(pid, card), "flags": {}, "abilities": [], "castable": false}
			for key in FLAGS:
				row.flags[key] = (0 if key in ["cur_extra_blocks", "skip_untaps"] else false) if card.face_down and card.zone != Mtg.Zone.BATTLEFIELD else card.get(key)
			if card.zone == Mtg.Zone.HAND and card.owner_id == pid:
				row.castable = g.cast_timing_refusal(pid, card).is_empty() and g.could_afford(pid, card.data)
				if card.data.is_type(Mtg.CardType.INSTANT):
					result.floating = result.floating or g.can_afford(pid, card.data)
					result.respond = result.respond or (g.could_afford(pid, card.data) and has_aim(g, card))
			for option in ([] if card.face_down else SgDuelActions.options(card, pid)):
				var cost: ManaCost = card.data.cost if option.kind == "spell" else ManaCost.new()
				if option.kind == "ability": cost = card.cur_activated_abilities[option.index].cost
				var surcharge := g.spell_surcharge(pid, card.data) if option.kind == "spell" else 0
				var usage := g.mana_usage_keys(card.data) if option.kind == "spell" else []
				var budget := 0
				if option.x:
					while budget < 1000 and not ManaPlanner.plan(g, pid, cost, surcharge + budget + 1, usage).is_empty(): budget += 1
				row.abilities.append({"kind": option.kind, "index": option.index, "cost": str(cost), "budget": budget})
				if option.kind == "ability":
					var ability: ActivatedAbility = card.cur_activated_abilities[option.index]
					if DuelScreen._ability_usable(card, ability) and g.can_afford_cost(pid, cost):
						result.respond = true
						result.floating = true
			result.cards.append(row)
			if card.zone == Mtg.Zone.BATTLEFIELD and card.controller_id == pid:
				if CombatState.attack_illegality(g, card, 1 - pid).is_empty(): result.attackable.append(row.id)
				for attacker_id in g.combat.attackers:
					var attacker := g.find_instance(attacker_id)
					if attacker != null and CombatState.block_illegality(g, card, attacker, pid).is_empty():
						result.blockable.append([row.id, m._handle(pid, attacker)])
	for item in g.stack:
		var card := item.card
		# A source can have left for a private zone while its ability remains.
		# Give that chain item only its already-public name, not a hidden-zone card.
		var face: Dictionary = m._cards(pid, [card])[0] if m._visible(pid, card) else {}
		var refs: Array = []
		if not item.target_held:
			for target in item.targets:
				var ref := target_reference(m, pid, target)
				if not ref.is_empty(): refs.append(ref)
		result.chain.append({"id": object_handle(m, pid, "ability", item.id), "kind": item.kind,
			"face": face, "refs": refs})
	for packet in g.damage_pending:
		result.packets.append({"id": object_handle(m, pid, "damage", packet.id),
			"source": m._handle(pid, packet.source) if m._visible(pid, packet.source) else "",
			"target": target_reference(m, pid, packet.target), "amount": packet.remaining(), "combat": packet.is_combat})
	for band in g.combat.bands:
		var members: Array = []
		for id in band: members.append(m._handle(pid, g.find_instance(id)))
		result.bands.append(members)
	for id in g.combat.blocks:
		for attacker in [g.combat.blocks[id]] + g.combat.extra_blocks.get(id, []):
			result.blocks.append([m._handle(pid, g.find_instance(id)), m._handle(pid, g.find_instance(attacker))])
	for id in g.combat.blocked_attackers:
		var card := g.find_instance(id)
		if card != null: result.blocked.append(m._handle(pid, card))
	if g.awaiting_damage_assignment:
		var request := g.damage_assignment_request()
		var assigned: Array = []
		for id in request.assigned:
			var card := g.find_instance(id)
			if card != null: assigned.append([m._handle(pid, card), int(request.assigned[id])])
		result.assignment = {"source": m._handle(pid, request.source), "assigner": int(request.assigner),
			"trample": bool(request.trample), "assigned": assigned}
	if not view.announcement.is_empty():
		for slot in view.announcement.slots:
			for target in slot.targets:
				result.targets.append({"token": target.id, "ref": target_reference(m, pid, m.actions._targets[target.id])})
		var d := m.actions.draft
		result.draft = {"card": m._handle(pid, d.card), "kind": d.kind, "index": d.index, "x": d.x, "mode": d.mode,
			"reachable": m.actions.payment_reachable()}
	return result


static func has_aim(g: MtgGame, card: CardInstance) -> bool:
	if card.data.is_modal(): return true
	for effect in card.data.spell_effects:
		if effect.target_spec == null or effect.target_min <= 0 or effect.target_count_is_x: continue
		if effect.target_spec.legal_targets(g, card).is_empty(): return false
	return true
