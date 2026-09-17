extends CardScript
## Reincarnation — {1}{G}{G} — Instant — (leg, uncommon)
## Oracle: Choose target creature. When that creature dies this turn, return
##         a creature card from its owner's graveyard to the battlefield
##         under the control of that creature's owner.
##
## Implementation: a DELAYED dies-trigger, which the engine now has as a
## floating watch (MtgGame.watch_death, new) rather than as a stack object
## (docs/ROADMAP.md still owes the real CR 603.7a version). The watch
## outlives Reincarnation itself, fires once, and is dropped at cleanup if
## the creature never dies.
##
## Whose graveyard and whose creature: BOTH are the dying creature's OWNER,
## not the caster. Cast on your opponent's creature it hands THEM something
## back, so the card is a rescue for your own board or a way to upgrade a
## dying body of theirs into the best thing in their yard — read the second
## sentence twice before pointing it.
##
## WHICH card comes back is the SPELL's controller's choice (CR 609.3 — an
## effect's instructions are carried out by the object's controller unless
## it says otherwise, and this one only names whose graveyard to look in
## and whose control to land under), which is not the same seat: pointed at
## an opponent's creature you hand them their WORST body, not their best.
## Glyph of Reincarnation, same set and same clause, reads it the same way;
## this file asked the graveyard's owner until 2026-09-17. The list is
## sorted from the CHOOSER's point of view, so the heuristic's first pick
## is their own biggest body or an opponent's smallest. The creature that
## just died is already in the graveyard by then, so it may return itself,
## which is the printed behaviour and the usual line.


func build() -> CardData:
	return CardData.new("Reincarnation", "{1}{G}{G}", Mtg.CardType.INSTANT) \
		.spell(MarkEffect.new()) \
		.oracle("Choose target creature. When that creature dies this turn, return "
			+ "a creature card from its owner's graveyard to the battlefield under "
			+ "the control of that creature's owner.")


class MarkEffect extends EffectBase:
	func _init() -> void:
		target_spec = TargetSpec.creature()

	func resolve(game: MtgGame, _source: CardInstance, controller: int,
			target: TargetRef, _x_value: int = 0) -> void:
		var doomed := game.find_instance(target.instance_id)
		if doomed == null or doomed.zone != Mtg.Zone.BATTLEFIELD:
			return
		# The delayed ability is the SPELL's (CR 603.7a), so its controller
		# rides along to make the choice when it fires.
		game.watch_death(doomed, MarkEffect._reincarnate.bind(controller))
		game.log_line("%s is marked for reincarnation" % doomed.data.card_name)

	static func _reincarnate(game: MtgGame, dead: CardInstance,
			chooser: int) -> void:
		var owner := dead.owner_id
		var candidates: Array[CardInstance] = []
		for card in game.players[owner].graveyard:
			if card.data.is_creature():
				candidates.append(card)
		if candidates.is_empty():
			return
		# From the CHOOSER's point of view: their own graveyard's biggest
		# body first, an opponent's smallest first.
		if owner == chooser:
			candidates.sort_custom(func(a: CardInstance, b: CardInstance) -> bool:
				return a.data.cost.mana_value() > b.data.cost.mana_value())
		else:
			candidates.sort_custom(func(a: CardInstance, b: CardInstance) -> bool:
				return a.data.cost.mana_value() < b.data.cost.mana_value())
		var pick := game.agents[chooser].choose_card(game, chooser, candidates,
			"Return a creature card to the battlefield", false, false, true)
		if pick == null or not candidates.has(pick):
			pick = candidates[0]
		game.reanimate(pick, owner)

	func describe() -> String:
		return "when the target dies this turn, its owner raises a creature"
