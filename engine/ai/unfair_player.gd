class_name UnfairPlayer
extends AiPlayer
## Explicit opt-in challenge: Wizard plus the opponent's CURRENT hand.
## This is the only player implementation allowed to inspect that hand.
## No library identities/order, opponent decklist, future draws, RNG state,
## face-down identity, free resources or alternative rules are available.
## Knowledge is transient; never reveal cards globally or retain departed ones.

const LABEL := "Unfair — sees your hand"
const DESCRIPTION := "Wizard strategy with access to your current hand. No knowledge of future draws or library order; no extra mana, cards or rule exceptions. Unrated challenge."
const RESPONSE_LIMIT := 8


func _init(seat: int) -> void:
	super(seat, AiProfile.wizard())


func _planning_key(game: MtgGame, ignored: Array = [], resources := false) -> String:
	var hand: Array = []
	for card in game.players[1 - pid].hand:
		hand.append([card.id, card.data.card_name])
	return super._planning_key(game, ignored, resources) + JSON.stringify(hand)


func _answers(game: MtgGame) -> Array[CardInstance]:
	var out: Array[CardInstance] = []
	var opponent := 1 - pid
	var reader := AiPlayer.new(opponent, profile)
	for card in game.players[opponent].hand:
		if not card.data.is_modal() and reader._cast_gate(game, card) == "" \
				and game.could_afford(opponent, card.data):
			out.append(card)
	return out


func _information_cast_value(game: MtgGame, inst: CardInstance,
		choice: Dictionary, intent: EffectIntent) -> float:
	var value := float(choice["value"])
	for answer in _answers(game):
		for effect in answer.data.spell_effects:
			# A known unconditional counter changes sequencing, not legality.
			# Bait it only when BOTH development spells share a payable budget.
			if effect is CounterEffect and not effect.target_spec.filter.is_valid() \
					and not effect.target_spec.game_filter.is_valid() \
					and not effect.target_spec.source_filter.is_valid() \
					and answer.data.is_type(Mtg.CardType.INSTANT):
				for bait in game.players[pid].hand:
					if bait == inst or not bait.data.is_creature() \
							or not bait.data.spell_effects.is_empty() \
							or _card_value(bait.data) >= _card_value(inst.data): continue
					if game.cast_refusal(pid, bait) != "": continue
					var cost := _combined_cost(inst.data.cost_for(int(choice["x"])), bait.data.cost)
					var extra := _generic_x(inst.data, int(choice["x"])) \
						+ game.spell_surcharge(pid, inst.data) + game.spell_surcharge(pid, bait.data)
					if not _plan_taps(game, cost, extra).is_empty():
						return value * 0.15
			# Do not assume a damage target is dead if a known, payable pump
			# saves it. Still permit urgent burn; this is a discount, not a veto.
			if effect is PumpEffect and not effect.self_mode \
					and answer.data.is_type(Mtg.CardType.INSTANT) and intent.damage_at(int(choice["x"])) > 0:
				for target in choice["targets"]:
					if target.is_player: continue
					var victim := game.find_instance(target.instance_id)
					if victim == null or victim.controller_id == pid: continue
					if game.target_legal_at(effect.target_spec, target, answer, 0) \
							and victim.cur_toughness + effect.toughness - victim.damage \
								> intent.damage_at(int(choice["x"])):
						value *= 0.25
			# Hold a third ordinary body against a known payable creature
			# sweeper unless public danger calls for developing a blocker.
			if effect is DestroyAllEffect and not effect.filter.is_valid() \
					and inst.data.is_creature() and not _in_danger(game):
				var bodies := game.players[pid].battlefield.filter(func(c: CardInstance) -> bool:
					return c.is_creature()).size()
				if bodies >= 2: return 0.0
	return value


## Mini-study of up to eight legal, affordable single-pump responses.
## Each branch checks the opponent's mana before a reversible probe; the real
## opponent still chooses whether to cast anything. No guessed future cards.
func _attack_choice(game: MtgGame, candidates: Array[CardInstance], defender: int) -> Array:
	var attackers := super._attack_choice(game, candidates, defender)
	var mine: Array[CardInstance] = []
	var theirs: Array[CardInstance] = []
	var excluded := {}
	for card in game.players[pid].battlefield:
		if card.is_creature() and not card.tapped: mine.append(card)
	for card in game.players[defender].battlefield:
		if card.is_creature():
			theirs.append(card)
			excluded[card.id] = true
	# Do not spend mana twice on mixed activated-pump lines, or imagine a
	# mana creature both tapping for the trick and blocking. These complex
	# boards keep the Wizard's specialised shared-mana analysis.
	if not _study_supported(game, mine, theirs, defender): return attackers
	var branches := 0
	for answer in _answers(game):
		if not answer.data.is_type(Mtg.CardType.INSTANT) \
				or answer.data.spell_effects.size() != 1 \
				or not game.could_afford(defender, answer.data, excluded): continue
		var effect: EffectBase = answer.data.spell_effects[0]
		if not effect is PumpEffect or effect.self_mode or effect.use_x_power \
				or (effect.power <= 0 and effect.toughness <= 0): continue
		for blocker in game.players[defender].battlefield:
			if not blocker.is_creature() or blocker.tapped: continue
			var target := TargetRef.card(blocker)
			if not game.target_legal_at(effect.target_spec, target, answer, 0): continue
			if branches >= RESPONSE_LIMIT: return attackers
			branches += 1
			var nested := game.undo_log != null
			var mark := game.make_mark()
			# The cost is checked against shared, colored, restricted sources.
			# Do not execute mana-source triggers here: only this public pump
			# effect is in the forecast's safe vocabulary.
			effect.resolve(game, answer, defender, target)
			var response := super._attack_choice(game, candidates, defender)
			game.unmake_to(mark)
			if not nested: game.end_search()
			attackers = attackers.filter(func(id: int) -> bool: return response.has(id))
	return attackers
