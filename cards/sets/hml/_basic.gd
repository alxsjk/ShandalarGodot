extends RefCounted
## Homelands' reusable mana, stats, tribal and activated-effect compositions.
## Continuous contributions use live characteristics (CR 613), not printings.

const F := preload("res://cards/sets/fem/_rules.gd")
const LANDS := {"An-Havva Township": [Mtg.ManaColor.G, Mtg.ManaColor.R, Mtg.ManaColor.W],
	"Aysen Abbey": [Mtg.ManaColor.W, Mtg.ManaColor.G, Mtg.ManaColor.U],
	"Castle Sengir": [Mtg.ManaColor.B, Mtg.ManaColor.U, Mtg.ManaColor.R],
	"Koskun Keep": [Mtg.ManaColor.R, Mtg.ManaColor.B, Mtg.ManaColor.G],
	"Wizards' School": [Mtg.ManaColor.U, Mtg.ManaColor.W, Mtg.ManaColor.B]}

static func configure(c: CardData) -> bool:
	var n := c.card_name
	if LANDS.has(n):
		c.mana(ManaAbility.new(Mtg.ManaColor.C))
		for index in 3:
			c.mana(ManaAbility.new(LANDS[n][index]).with_mana_cost("{1}" if index == 0 else "{2}").with_plannable_conversion())
		return true
	match n:
		"Abbey Matron": c.activated(F._ability("{W}", true, PumpEffect.new(0, 3).self_buff()))
		"Anaba Ancestor":
			var pump := PumpEffect.new(1, 1)
			pump.target_spec = TargetSpec.creature("another target Minotaur creature", F._subtype.bind("minotaur")).with_source_filter(_another)
			c.activated(F._ability("", true, pump))
		"Anaba Shaman": c.activated(F._ability("{R}", true, DamageEffect.new(1).any_target()))
		"Aysen Bureaucrats":
			var tap := TapEffect.new()
			tap.target_spec = TargetSpec.creature("target creature with power 2 or less", _small)
			c.activated(F._ability("", true, tap))
		"Beast Walkers": c.activated(F._ability("{G}", false, PumpEffect.new(0, 0, [Mtg.Keyword.BANDING]).self_buff()))
		"Chandler": c.activated(F._ability("{R}{R}{R}", true, DestroyEffect.new(TargetSpec.creature("target artifact creature", _artifact))))
		"Joven": c.activated(F._ability("{R}{R}{R}", true, DestroyEffect.new(TargetSpec.new(TargetSpec.Kind.PERMANENT, "target noncreature artifact", _noncreature_artifact))))
		"Clockwork Gnomes": c.activated(F._ability("{3}", true, RegenerateEffect.new().target_creature("target artifact creature", _artifact)))
		"Eron the Relentless": c.activated(F._ability("{R}{R}{R}", false, RegenerateEffect.new()))
		"Grandmother Sengir": c.activated(F._ability("{1}{B}", true, PumpEffect.new(-1, -1)))
		"Leaping Lizard": c.activated(F._ability("{1}{G}", false, PumpEffect.new(0, -1, [Mtg.Keyword.FLYING]).self_buff()))
		"Mesa Falcon": c.activated(F._ability("{1}{W}", false, PumpEffect.new(0, 1).self_buff()))
		"Roterothopter": c.activated(F._ability("{2}", false, PumpEffect.new(1, 0).self_buff()).per_turn(2))
		"An-Havva Constable", "Aysen Crusader": c.static_ability(StaticAbility.new(_defined_stats, "Power/toughness track the current creatures.").setting_base_pt())
		"Anaba Spirit Crafter", "Soraya the Falconer", "Faerie Noble", "Serra Aviary":
			c.static_ability(StaticAbility.new(_tribal_stats, "Live tribal/flying bonus."))
			if n == "Soraya the Falconer":
				var pump := PumpEffect.new(0, 0, [Mtg.Keyword.BANDING])
				pump.target_spec = TargetSpec.creature("target Bird creature", F._subtype.bind("bird"))
				c.activated(F._ability("{1}{W}", false, pump))
			elif n == "Faerie Noble":
				c.activated(F._ability("", true, F.Action.new(_faerie_pump, "other Faeries you control get +1/+0 until end of turn", null, true)))
		"Baron Sengir", "Sengir Bats":
			c.triggered(TriggeredAbility.new(Mtg.EventType.DIES, _feed,
				"Put a counter on this creature after a creature it damaged dies.", _wounded).public_aftermath())
			if n == "Baron Sengir":
				var regenerate := RegenerateEffect.new().target_creature("another target Vampire", F._subtype.bind("vampire"))
				regenerate.target_spec.with_source_filter(_another)
				c.activated(F._ability("", true, regenerate))
		_: return false
	return true

static func _another(_g: MtgGame, s: CardInstance, i: CardInstance) -> bool: return s.id != i.id
static func _small(i: CardInstance) -> bool: return i.cur_power <= 2
static func _artifact(i: CardInstance) -> bool: return i.is_type(Mtg.CardType.ARTIFACT)
static func _noncreature_artifact(i: CardInstance) -> bool: return _artifact(i) and not i.is_creature()
static func _green(i: CardInstance) -> bool: return (i.cur_colors & Mtg.ManaColor.G) != 0

static func _defined_stats(g: MtgGame, s: CardInstance) -> void:
	if s.data.card_name == "An-Havva Constable":
		var count := 1
		for i in g.all_battlefield():
			if i.is_creature() and _green(i): count += 1
		s.cur_toughness = count
	else:
		var count := 2
		for i in g.players[s.controller_id].battlefield:
			if i.is_creature() and (i.has_subtype("soldier") or i.has_subtype("warrior")): count += 1
		s.cur_power = count
		s.cur_toughness = count

static func _tribal_stats(g: MtgGame, s: CardInstance) -> void:
	for i in g.all_battlefield():
		if not i.is_creature(): continue
		match s.data.card_name:
			"Anaba Spirit Crafter":
				if i.has_subtype("minotaur"): i.cur_power += 1
			"Soraya the Falconer":
				if i.has_subtype("bird"):
					i.cur_power += 1
					i.cur_toughness += 1
			"Faerie Noble":
				if i.id != s.id and i.controller_id == s.controller_id and i.has_subtype("faerie"): i.cur_toughness += 1
			"Serra Aviary":
				if i.has_keyword(Mtg.Keyword.FLYING):
					i.cur_power += 1
					i.cur_toughness += 1

static func _faerie_pump(g: MtgGame, s: CardInstance, pid: int, _t: TargetRef, _x: int) -> void:
	for i in g.players[pid].battlefield:
		if i.id != s.id and i.is_creature() and i.has_subtype("faerie"):
			g.continuous.add_until_eot_pump(i.id, 1, 0)
	g.recalculate()

static func _wounded(_g: MtgGame, s: CardInstance, e: GameEvent) -> bool:
	return e.data.get("damage_origins", {}).has("%d:%d" % [s.id, s.layer_timestamp])
static func _feed(g: MtgGame, s: CardInstance, _e: GameEvent) -> void:
	if F._same_trigger_source(g, s): g.add_counters(s, "+2/+2" if s.data.card_name == "Baron Sengir" else "+1/+1")
