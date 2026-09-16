extends RefCounted
## Homelands spell compositions. Choices pass through the resolving agent;
## zone changes, randomness, damage and costs use journaled engine helpers.
const F := preload("res://cards/sets/fem/_rules.gd")
const TYPES := ["plains", "island", "swamp", "mountain", "forest"]

static func configure(c: CardData) -> bool:
	match c.card_name:
		"Memory Lapse": c.spell(CounterEffect.new().to_library_top())
		"Shrink": c.spell(PumpEffect.new(-5, 0))
		"Aliban's Tower":
			var pump := PumpEffect.new(3, 1)
			pump.target_spec = TargetSpec.creature("target blocking creature").with_game_filter(F._blocking)
			c.spell(pump)
		"Ambush": c.spell(F.Action.new(_ambush, "blocking creatures gain first strike until end of turn", null, true))
		"An-Havva Inn": c.spell(F.Action.new(_inn, "gain 1 life plus 1 for each green creature", null, true))
		"Dry Spell": c.spell(DamageAllEffect.new(1).and_each_player())
		"Evaporate": c.spell(DamageAllEffect.new(1, "each white and/or blue creature", _white_blue))
		"Baki's Curse": c.spell(F.Action.new(_baki, "deal 2 damage to each creature for each Aura attached to it"))
		"Forget": c.spell(F.Action.new(_forget, "target player discards two cards, then draws as many cards as they discarded", TargetSpec.player()))
		"Leeches": c.spell(F.Action.new(_leeches, "remove target player's poison counters and deal that much damage to them", TargetSpec.player(), true))
		"Merchant Scroll": c.spell(SearchLibraryEffect.new("a blue instant card (revealed)", _blue_instant))
		"Headstone":
			c.spell(F.Action.new(_headstone, "exile target card from a graveyard", TargetSpec.new(TargetSpec.Kind.CARD_IN_ANY_GRAVEYARD, "target card in a graveyard")))
			c.spell(DelayedDrawEffect.new())
		"Prophecy":
			c.spell(F.Action.new(_prophecy, "reveal target opponent's top card; gain 1 life if it is a land; that player shuffles", TargetSpec.opponent(), true))
			c.spell(DelayedDrawEffect.new())
		"Renewal":
			c.with_additional_sacrifice("a land", _land)
			c.spell(SearchLibraryEffect.new("a basic land card", _basic).to_battlefield()).spell(DelayedDrawEffect.new())
		"Jinx":
			c.spell(F.Action.new(_jinx, "target land becomes a basic land type of your choice until end of turn", TargetSpec.new(TargetSpec.Kind.PERMANENT, "target land", _land)))
			c.spell(DelayedDrawEffect.new())
		"Winter Sky": c.spell(F.Action.new(_winter, "flip a coin: deal 1 damage to each creature and player, or each player draws a card"))
		"Truce": c.spell(F.Action.new(_truce, "each player may draw up to two cards, gaining 2 life for each card fewer than two", null, true))
		"Broken Visage": c.spell(F.Action.new(_visage, "destroy target nonartifact attacking creature without regeneration and create a Spirit with its power/toughness until the next end step", TargetSpec.creature("target nonartifact attacking creature", _nonartifact).with_game_filter(_attacking)))
		"Chain Stasis": c.spell(F.Action.new(_chain, "tap or untap target creature; its controller may pay {2}{U} to copy this spell", TargetSpec.creature()))
		"Retribution": c.spell(Retribution.new())
		_: return false
	return true

static func _white_blue(i: CardInstance) -> bool: return (i.cur_colors & (Mtg.ManaColor.W | Mtg.ManaColor.U)) != 0
static func _blue_instant(i: CardInstance) -> bool: return i.is_type(Mtg.CardType.INSTANT) and (i.cur_colors & Mtg.ManaColor.U) != 0
static func _land(i: CardInstance) -> bool: return i.is_land()
static func _basic(i: CardInstance) -> bool: return i.is_land() and (i.cur_supertypes & Mtg.Supertype.BASIC) != 0
static func _nonartifact(i: CardInstance) -> bool: return not i.is_type(Mtg.CardType.ARTIFACT)
static func _attacking(g: MtgGame, i: CardInstance) -> bool: return g.combat.attackers.has(i.id)
static func _opponent(_g: MtgGame, s: CardInstance, i: CardInstance) -> bool: return s.controller_id != i.controller_id

static func _ambush(g: MtgGame, _s: CardInstance, _pid: int, _t: TargetRef, _x: int) -> void:
	for i in g.all_battlefield():
		if i.is_creature() and F._blocking(g, i): g.continuous.add_until_eot_pump(i.id, 0, 0, [Mtg.Keyword.FIRST_STRIKE])
	g.recalculate()
static func _inn(g: MtgGame, _s: CardInstance, pid: int, _t: TargetRef, _x: int) -> void:
	var count := 1
	for i in g.all_battlefield():
		if i.is_creature() and (i.cur_colors & Mtg.ManaColor.G) != 0: count += 1
	g.adjust_life(pid, count)
static func _baki(g: MtgGame, s: CardInstance, _pid: int, _t: TargetRef, _x: int) -> void:
	var hits: Array = []
	for i in g.all_battlefield():
		if not i.is_creature(): continue
		var count := 0
		for id in i.attachments:
			var aura := g.find_instance(id)
			if aura != null and aura.zone == Mtg.Zone.BATTLEFIELD and aura.data.is_aura(): count += 1
		hits.append([i, 2 * count])
	g.begin_simultaneous()
	for hit in hits: g.deal_damage(s, TargetRef.card(hit[0]), hit[1])
	g.end_simultaneous()
static func _forget(g: MtgGame, _s: CardInstance, _pid: int, t: TargetRef, _x: int) -> void:
	var who := t.player_id
	var selected := g.agents[who].choose_discard(g, who, mini(2, g.players[who].hand.size()))
	# A Library of Leng replacement still counts as a discard. Count the
	# distinct legal hand choices, not only cards that reach the graveyard.
	var legal: Array = []
	for i in selected:
		if g.players[who].hand.has(i) and not legal.has(i): legal.append(i)
	g.discard_cards(who, legal)
	g.draw_cards(who, legal.size())
static func _leeches(g: MtgGame, s: CardInstance, _pid: int, t: TargetRef, _x: int) -> void:
	var amount := g.remove_poison(t.player_id, g.players[t.player_id].poison)
	g.deal_damage(s, t, amount)
static func _headstone(g: MtgGame, _s: CardInstance, _pid: int, t: TargetRef, _x: int) -> void:
	g.exile_from_graveyard(g.find_instance(t.instance_id))
static func _prophecy(g: MtgGame, _s: CardInstance, pid: int, t: TargetRef, _x: int) -> void:
	if not g.players[t.player_id].library.is_empty():
		var top: CardInstance = g.players[t.player_id].library.back()
		g.log_line("Prophecy reveals %s" % top.data.card_name)
		if top.is_land(): g.adjust_life(pid, 1)
	g.shuffle_library(t.player_id)
static func _jinx(g: MtgGame, s: CardInstance, pid: int, t: TargetRef, _x: int) -> void:
	var pick := g.agents[pid].choose_option(g, pid, TYPES, "Jinx: choose a basic land type", 1)
	if pick < 0 or pick >= TYPES.size(): return
	g.continuous.add_floating_static(s, StaticAbility.new(_basic_type.bind(t.instance_id, TYPES[pick]), "Land becomes the chosen basic land type.").changing_land_types(), ContinuousEffects.Duration.END_OF_TURN, -1, false, t.instance_id)
	g.recalculate()
static func _basic_type(g: MtgGame, _s: CardInstance, id: int, type: String) -> void:
	var i := g.find_instance(id)
	if i != null and i.zone == Mtg.Zone.BATTLEFIELD: i.become_basic_land_type(type, Mtg.BASIC_LAND_COLORS[type])
static func _winter(g: MtgGame, s: CardInstance, pid: int, _t: TargetRef, _x: int) -> void:
	if g.flip_coin(pid): DamageAllEffect.new(1).and_each_player().resolve(g, s, pid, null)
	else:
		g.begin_simultaneous()
		for who in [g.active_player, 1 - g.active_player]: g.draw_cards(who, 1)
		g.end_simultaneous()
static func _truce(g: MtgGame, _s: CardInstance, _pid: int, _t: TargetRef, _x: int) -> void:
	var choices := {}
	for who in [g.active_player, 1 - g.active_player]:
		var hint := mini(2, g.players[who].library.size())
		choices[who] = clampi(g.agents[who].choose_option(g, who, ["Draw no cards; gain 4 life", "Draw 1 card; gain 2 life", "Draw 2 cards"], "Truce: how many cards?", hint), 0, 2)
	g.begin_simultaneous()
	for who in [g.active_player, 1 - g.active_player]:
		g.draw_cards(who, int(choices[who]))
		g.adjust_life(who, 2 * (2 - int(choices[who])))
	g.end_simultaneous()
static func _visage(g: MtgGame, s: CardInstance, pid: int, t: TargetRef, _x: int) -> void:
	var i := g.find_instance(t.instance_id)
	var token := CardData.new("Spirit", "", Mtg.CardType.CREATURE).pt(i.cur_power, i.cur_toughness).with_colors(Mtg.ManaColor.B).with_subtypes(["spirit"])
	g.destroy(i, false)
	for made in g.create_token(pid, token):
		g.schedule_delayed_trigger(TriggeredAbility.new(Mtg.EventType.END_STEP_START, _sacrifice.bind(made.id, made.layer_timestamp), "Sacrifice the Spirit token."), pid, s)
static func _sacrifice(g: MtgGame, _s: CardInstance, _e: GameEvent, id: int, stamp: int) -> void:
	var i := g.find_instance(id)
	if i != null and i.zone == Mtg.Zone.BATTLEFIELD and i.layer_timestamp == stamp: g.sacrifice_permanent(i)
static func _chain(g: MtgGame, s: CardInstance, pid: int, t: TargetRef, _x: int) -> void:
	var i := g.find_instance(t.instance_id)
	var who := i.controller_id
	var hint := 1 if who == pid else 0
	var action := g.agents[pid].choose_option(g, pid, ["Tap", "Untap"], "Chain Stasis: tap or untap?", hint)
	if action == 0: g.tap_permanent(i)
	elif action == 1: g.untap_permanent(i)
	if EffectBase.unless_paid(g, who, ManaCost.parse("{2}{U}"), "Pay {2}{U} to copy Chain Stasis?", who != pid):
		var copy := g.copy_spell_on_stack(s, who)
		if copy != null: g.offer_new_targets(copy, who, pid)

class Retribution extends EffectBase:
	func _init() -> void:
		target_spec = TargetSpec.creature("two target creatures controlled by the same opponent").with_source_filter(load("res://cards/sets/hml/_spells.gd")._opponent)
		target_min = 2
		target_max = 2
	func resolve_multi(g: MtgGame, _s: CardInstance, _pid: int, targets: Array, _x := 0) -> void:
		var choices: Array[CardInstance] = []
		for t in targets:
			var i := g.find_instance(t.instance_id)
			if i != null and i.zone == Mtg.Zone.BATTLEFIELD: choices.append(i)
		if choices.is_empty(): return
		var who := choices[0].controller_id
		var picked := g.agents[who].choose_card(g, who, choices, "Retribution: choose the creature to sacrifice", false, true)
		if picked == null or not choices.has(picked): return
		g.sacrifice_permanent(picked)
		for i in choices:
			if i != picked: g.add_counters(i, "-1/-1")
	func describe() -> String: return "opponent sacrifices one of two target creatures; put a -1/-1 counter on the other"
