class_name CreateTokenEffect
extends EffectBase
## A reusable, AI-readable token effect. Token data lives on the effect, not
## in a static cache, and is released with the owning registry card.

var token: CardData
var count: int

func _init(name: String, power: int, toughness: int, color: int,
		subtype: String, number := 1) -> void:
	token = CardData.new(name, "", Mtg.CardType.CREATURE).pt(power, toughness) \
		.with_colors(color).with_subtypes([subtype])
	count = number
	ai_helpful = true

func resolve(game: MtgGame, _source: CardInstance, controller: int,
		_target: TargetRef, _x_value := 0) -> void:
	game.create_token(controller, token, count)

func describe() -> String:
	return "create %d %d/%d %s creature token(s)" % [count, token.power, token.toughness, token.card_name]
