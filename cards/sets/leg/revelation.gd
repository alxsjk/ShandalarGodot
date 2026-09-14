extends CardScript
## Revelation — {G} — World Enchantment — (leg, rare)
## Oracle: Players play with their hands revealed.
##
## The continuous pipeline marks both hands public while this is active.
## Seat-filtered views and fair observations may then disclose those cards;
## the permission ends when the enchantment leaves or loses its ability.


func build() -> CardData:
	return CardData.new("Revelation", "{G}", Mtg.CardType.ENCHANTMENT) \
		.with_supertypes(Mtg.Supertype.WORLD) \
		.static_ability(StaticAbility.new(_reveal_hands, "Players play with their hands revealed.")) \
		.oracle("Players play with their hands revealed.")


static func _reveal_hands(game: MtgGame, _source: CardInstance) -> void:
	for player in game.players:
		player.hand_revealed = true
