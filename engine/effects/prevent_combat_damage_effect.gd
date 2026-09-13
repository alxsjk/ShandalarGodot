class_name PreventCombatDamageEffect
extends EffectBase
## "Prevent all combat damage that would be dealt this turn." — the Fog
## effect (Fog, Holy Day, Darkness, and Angus Mackenzie's activation).
##
## Raises MtgGame.combat_damage_prevented; planning and landing check each
## combat packet, except unpreventable recipients (CR 615.12). Cleanup
## clears it. Non-combat damage (Bolt, Pestilence) is untouched.


## When set, only the TARGET creature's combat damage is prevented
## (Lady Evangela, Horn of Deafening) instead of the whole combat.
## [member prevent_taken] adds the "dealt TO it" half. Cards that want the
## both-ways shield without a target of their own (Maze of Ith, Ebony Horse)
## call ContinuousEffects.add_until_eot_combat_prevention directly, so
## [method and_to_target] currently has no card in the pool.
var targeted_mode: bool = false
var prevent_dealt: bool = true
var prevent_taken: bool = false


func _init() -> void:
	# One of the three families `Duel.hlp` lets you use in the damage
	# prevention window: "those that prevent, heal, or redirect damage".
	#
	# Pending packets recheck the flag when they land, so a Fog in this
	# window prevents their combat damage as well as later waves.
	is_damage_prevention = true


## Fluent: "prevent all combat damage that would be dealt by target
## creature this turn".
func by_target_creature(spec: TargetSpec = null) -> PreventCombatDamageEffect:
	targeted_mode = true
	target_spec = spec if spec != null else TargetSpec.creature()
	return self


## Fluent: also prevent combat damage dealt TO the target (Maze of Ith).
func and_to_target() -> PreventCombatDamageEffect:
	prevent_taken = true
	return self


## Whole-combat mode sets the MtgGame.combat_damage_prevented flag, which the
## damage pipeline reads per recipient and the cleanup step clears.
## Targeted mode instead registers a floating entry with game.continuous and
## recalculates, which raises the instance's cur_prevent_combat_damage_*
## flags — the same flags Gaseous Form's static ability sets, so
## MtgGame.deal_damage needs only one check for both.
func resolve(game: MtgGame, source: CardInstance, _controller: int,
		target: TargetRef, _x_value: int = 0) -> void:
	if not targeted_mode:
		game.combat_damage_prevented = true
		game.log_line("%s: all combat damage is prevented this turn" % source.data.card_name)
		return
	var inst := game.find_instance(target.instance_id)
	if inst == null or inst.zone != Mtg.Zone.BATTLEFIELD:
		return
	game.continuous.add_until_eot_combat_prevention(inst.id, prevent_dealt, prevent_taken)
	game.recalculate()
	game.log_line("%s: %s's combat damage is prevented this turn" % [
		source.data.card_name, inst.data.card_name])


## One-line log/UI text.
func describe() -> String:
	if targeted_mode:
		return "prevents all combat damage dealt by %s this turn" % target_spec.description
	return "prevents all combat damage this turn"
