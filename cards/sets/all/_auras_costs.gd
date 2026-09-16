extends RefCounted
const F := preload("res://cards/sets/fem/_rules.gd")
const A := preload("res://cards/sets/ice/_auras.gd")
const B := preload("res://cards/sets/all/_basic.gd")
const W := preload("res://cards/sets/all/_worlds.gd")

static func configure(c: CardData) -> bool:
	match c.card_name:
		"Awesome Presence": c.enchants(TargetSpec.creature()).static_ability(StaticAbility.new(_presence, "Pay {3} for each creature blocking enchanted creature."))
		"Nature's Chosen", "Veteran's Voice", "Krovikan Plague":
			var spec := TargetSpec.creature().with_source_filter(F._own)
			if c.card_name == "Krovikan Plague": spec.filter = _nonwall
			c.enchants(spec)
			if c.card_name == "Nature's Chosen":
				c.activated(F._ability("", false, F.Action.new(_untap_host, "untap enchanted creature", null, true)).your_turn_only().per_turn(1))
				var ability := F._ability("", false, UntapEffect.new(TargetSpec.new(TargetSpec.Kind.PERMANENT, "target artifact, creature, or land", _untappable))).only_if(_white_host).per_turn(1)
				ability.object_costs = [_tap_host()]
				c.activated(ability)
			elif c.card_name == "Veteran's Voice":
				var pump := PumpEffect.new(2, 1)
				pump.target_spec.with_source_filter(B._not_host)
				var ability := F._ability("", false, pump)
				ability.object_costs = [_tap_host()]
				c.activated(ability)
			else:
				c.triggered(TriggeredAbility.new(Mtg.EventType.ENTERS_BATTLEFIELD, B._slow_draw, "Draw next turn's upkeep.", F._self_enter))
				var ability := F._ability("", false, Plague.new())
				ability.object_costs = [_tap_host()]
				c.activated(ability)
		"Nature's Blessing":
			c.activated(F._ability("{G}{W}", false, CounterMarkerEffect.new("+1/+1")).with_discard_cost(1))
			for keyword in [Mtg.Keyword.BANDING, Mtg.Keyword.FIRST_STRIKE, Mtg.Keyword.TRAMPLE]:
				var label := {Mtg.Keyword.BANDING: "banding", Mtg.Keyword.FIRST_STRIKE: "first strike", Mtg.Keyword.TRAMPLE: "trample"}
				c.activated(F._ability("{G}{W}", false, F.Action.new(_permanent_keyword.bind(keyword), "grant %s permanently" % label[keyword], TargetSpec.creature(), true)).with_discard_cost(1))
		"Surge of Strength":
			c.object_costs = [{"operation": "discard", "filter": W._red_green, "desc": "a red or green card", "zone": Mtg.Zone.HAND}]
			c.spell(Surge.new())
		"Viscerid Drone":
			for snow in [false, true]:
				var spec := TargetSpec.creature() if snow else TargetSpec.creature("target nonartifact creature", _nonartifact)
				var ability := F._ability("", true, DestroyEffect.new(spec, false))
				ability.object_costs = [{"operation": "sacrifice", "filter": B._creature, "desc": "a creature"}, {"operation": "sacrifice", "filter": _swamp.bind(snow), "desc": "a snow Swamp" if snow else "a Swamp"}]
				c.activated(ability)
		"Benthic Explorers":
			var ability := ManaAbility.new(Mtg.ManaColor.C)
			ability.object_costs = [{"operation": "untap", "filter": B._land, "desc": "a tapped land an opponent controls", "opponent": true}]
			ability.borrow_paid_land_type = true
			c.mana(ability)
		"Wandering Mage":
			c.activated(F._ability("{W}", false, PreventDamageEffect.new(2).target_creature()).with_life_cost(1))
			c.activated(F._ability("{U}", false, PreventDamageEffect.new(1).target_creature("target Cleric or Wizard", _cleric_wizard)))
			var prevention := PreventDamageEffect.new(2)
			prevention.target_spec = TargetSpec.player()
			var ability := F._ability("{B}", false, prevention)
			ability.object_costs = [{"operation": "counter", "filter": B._creature, "desc": "a creature you control", "kind": "-1/-1"}]
			c.activated(ability)
		"Seasoned Tactician": c.activated(F._ability("{3}", false, PreventDamageShieldEffect.new(0).from_sources("a source", _any)).with_library_exile_cost(4))
		"Mishra's Groundbreaker": c.activated(F._ability("", true, F.Action.new(_groundbreaker, "target land permanently becomes a 3/3 artifact creature that's still a land", TargetSpec.new(TargetSpec.Kind.PERMANENT, "target land", B._land), true)).with_sacrifice_cost())
		"Scarab of the Unseen": c.activated(ActivatedAbility.new("", true, [F.Action.new(_scarab, "return all Auras attached to target permanent you own", TargetSpec.new(TargetSpec.Kind.PERMANENT, "target permanent you own").with_source_filter(_owned), true), DelayedDrawEffect.new()], "{T}, Sacrifice this artifact: Return all Auras attached to target permanent you own; draw next upkeep").with_sacrifice_cost())
		_: return false
	return true

static func _any(_i: CardInstance) -> bool: return true
static func _nonartifact(i: CardInstance) -> bool: return not i.is_type(Mtg.CardType.ARTIFACT)
static func _nonwall(i: CardInstance) -> bool: return not i.has_subtype("wall")
static func _swamp(i: CardInstance, snow: bool) -> bool: return i.is_land() and i.has_subtype("swamp") and (not snow or (i.cur_supertypes & Mtg.Supertype.SNOW) != 0)
static func _cleric_wizard(i: CardInstance) -> bool: return i.has_subtype("cleric") or i.has_subtype("wizard")
static func _untappable(i: CardInstance) -> bool: return (i.cur_types & (Mtg.CardType.CREATURE | Mtg.CardType.ARTIFACT | Mtg.CardType.LAND)) != 0
static func _owned(_g: MtgGame, s: CardInstance, i: CardInstance) -> bool: return s != null and i.owner_id == s.controller_id
static func _host_only(_g: MtgGame, i: CardInstance, s: CardInstance) -> bool: return s != null and s.attached_to == i.id
static func _tap_host() -> Dictionary: return {"operation": "tap", "filter": B._creature, "source_filter": _host_only, "desc": "enchanted creature"}
static func _white_host(g: MtgGame, s: CardInstance) -> String:
	var host := A.host(g, s)
	return "" if host != null and (host.cur_colors & Mtg.ManaColor.W) != 0 else "Enchanted creature must be white"
static func _untap_host(g: MtgGame, s: CardInstance, _pid: int, _t: TargetRef, _x: int) -> void:
	var host := A.paid_host(g, s)
	if host != null: g.untap_permanent(host)
static func _presence(g: MtgGame, s: CardInstance) -> void:
	var host := A.host(g, s)
	if host != null: host.cur_blocked_by_tax += 3
class Plague extends DamageEffect:
	func _init() -> void:
		super(1)
		any_target()
	func resolve(g: MtgGame, s: CardInstance, pid: int, t: TargetRef, x := 0) -> void:
		super(g, s, pid, t, x)
		var host := A.paid_host(g, s)
		if host != null: g.add_counters(host, "-0/-1")
static func _permanent_keyword(g: MtgGame, s: CardInstance, _pid: int, t: TargetRef, _x: int, keyword: int) -> void:
	g.continuous.add_floating_static(s, StaticAbility.new(_keyword.bind(t.instance_id, keyword), "Granted keyword.").changing_abilities(), ContinuousEffects.Duration.INDEFINITE, -1, false, t.instance_id)
	g.recalculate()
static func _keyword(g: MtgGame, _s: CardInstance, id: int, keyword: int) -> void:
	var i := g.find_instance(id)
	if i != null and not i.cur_keywords.has(keyword): i.cur_keywords.append(keyword)
class Surge extends PumpEffect:
	func _init() -> void: super(0, 0, [Mtg.Keyword.TRAMPLE])
	func resolve(g: MtgGame, _s: CardInstance, _pid: int, t: TargetRef, _x := 0) -> void:
		var i := g.find_instance(t.instance_id)
		g.continuous.add_until_eot_pump(i.id, i.data.cost.mana_value(), 0, [Mtg.Keyword.TRAMPLE])
		g.recalculate()
static func _groundbreaker(g: MtgGame, _s: CardInstance, _pid: int, t: TargetRef, _x: int) -> void:
	g.continuous.add_until_eot_animation(t.instance_id, Mtg.CardType.ARTIFACT | Mtg.CardType.CREATURE, 3, 3, [], false, ContinuousEffects.Duration.INDEFINITE)
	g.recalculate()
static func _scarab(g: MtgGame, _s: CardInstance, _pid: int, t: TargetRef, _x: int) -> void:
	for aura in g.all_battlefield().duplicate():
		if aura.attached_to == t.instance_id: g.return_to_hand(aura)
