extends CardScript
## Visions — {W} — Sorcery — (4ed, uncommon)
## Oracle: Look at the top five cards of target player's library. You may
##         then have that player shuffle that library.
##
## Implementation: pure information plus an optional shuffle — the five
## cards go to the CASTER ALONE (MtgGame.reveal_information's per-viewer
## channel) and the caster's DecisionAgent is asked whether to shuffle.
## Nothing moves zones either way.
##
## THE DUEL LOG IS SHARED, so it must not say what was there: "look at" is
## not "reveal", and a library is a hidden zone (rule 8, docs/fair-play.md).
## Until 2026-09-17 the log line named all five cards to both seats — the
## same mechanic done right is Natural Selection, whose log line says only
## that the pile was restacked.


func build() -> CardData:
	return CardData.new("Visions", "{W}", Mtg.CardType.SORCERY) \
		.spell(VisionsEffect.new()) \
		.oracle("Look at the top five cards of target player's library. You may then "
			+ "have that player shuffle that library.")


class VisionsEffect extends EffectBase:
	func _init() -> void:
		target_spec = TargetSpec.player()

	func resolve(game: MtgGame, _source: CardInstance, controller: int,
			target: TargetRef, _x_value: int = 0) -> void:
		var library := game.players[target.player_id].library
		var names := PackedStringArray()
		for i in range(library.size() - 1, maxi(library.size() - 6, -1), -1):
			names.append(library[i].data.card_name)
		game.reveal_information(controller, "Visions — top cards, top first", Array(names))
		game.log_line("%s looks at the top %d card(s) of %s's library" % [
			game.players[controller].player_name, names.size(),
			game.players[target.player_id].player_name])
		if game.agents[controller].choose_yes_no(game, controller,
				"Have that player shuffle?", false):
			# The public, JOURNALED shuffle: a rewound AI probe must be able
			# to put the pile back the way it found it.
			game.shuffle_library(target.player_id)

	func describe() -> String:
		return "look at the top five cards of target player's library"
