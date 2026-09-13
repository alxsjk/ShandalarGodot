extends CardScript
## Whippoorwill — {G} — Creature — Bird — 1/1 — (drk, uncommon)
## Oracle: {G}{G}, {T}: Target creature can't be regenerated this turn.
##         Damage that would be dealt to that creature this turn can't be
##         prevented or dealt instead to another permanent or player. When
##         the creature dies this turn, exile the creature.
##
## Implementation: MtgGame.mark_unpreventable_death sets the this-turn
## restrictions and schedules the delayed exile trigger (CR 603.7/615.12).
## The creature enters the graveyard and triggers death abilities before
## exile resolves. This is deliberately not Disintegrate's replacement.


func build() -> CardData:
	return CardData.new("Whippoorwill", "{G}", Mtg.CardType.CREATURE) \
		.pt(1, 1) \
		.with_subtypes(["bird"]) \
		.activated(ActivatedAbility.new("{G}{G}", true, [MarkEffect.new()],
			"{G}{G}, {T}: Target creature can't be regenerated this turn, damage to it can't be prevented or redirected, and it is exiled if it dies this turn.")) \
		.oracle("{G}{G}, {T}: Target creature can't be regenerated this turn. "
			+ "Damage that would be dealt to that creature this turn can't be "
			+ "prevented or dealt instead to another permanent or player. When the "
			+ "creature dies this turn, exile the creature.")


class MarkEffect extends EffectBase:
	func _init() -> void:
		target_spec = TargetSpec.creature()

	func resolve(game: MtgGame, source: CardInstance, controller: int,
			target: TargetRef, _x_value: int = 0) -> void:
		var inst := game.find_instance(target.instance_id)
		if inst == null or inst.zone != Mtg.Zone.BATTLEFIELD:
			return
		game.mark_unpreventable_death(inst, source, controller)

	func describe() -> String:
		return "marks a creature: no regeneration, no prevention, exiled if it dies"
