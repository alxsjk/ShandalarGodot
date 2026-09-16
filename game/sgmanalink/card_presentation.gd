class_name SgCardPresentation
extends RefCounted
## [QoL] Detached, render-only cards for the shared MiniCard/CardPreview widgets.
## Never a host CardInstance or rules game. A local printed definition is used
## only for a named card already disclosed in the seat-filtered, validated DTO.


static func make(card: Dictionary, seat: int, zone: int, existing: CardInstance = null) -> CardInstance:
	var data: CardData = CardRegistry.get_card(card.name) if CardRegistry.has_card(card.name) else null
	if data == null or card.masked:
		# Tokens and masked creatures need no executable definition from a host.
		data = CardData.new(card.name, "", int(card.types)).oracle(card.rules)
	# Numeric ids are UI-local, not the referee's instance ids. Keep the opaque
	# handle separately; never manufacture a command by guessing an engine id.
	var instance := existing if existing != null else CardInstance.new(data, -1, seat)
	instance.data = data
	instance.printed_data = data
	instance.zone = zone
	instance.cur_power = int(card.power)
	instance.cur_toughness = int(card.toughness)
	instance.tapped = card.tapped
	instance.damage = int(card.damage)
	instance.summoning_sick = card.sick
	instance.owner_id = int(card.owner)
	instance.controller_id = int(card.controller)
	instance.cur_types = int(card.types)
	instance.cur_colors = int(card.colors)
	instance.cur_keywords.assign(card.keywords)
	instance.cur_subtypes.assign(card.subtypes)
	instance.cur_landwalk.assign(card.landwalk)
	instance.cur_protection = int(card.protection)
	instance.cur_rampage = int(card.rampage)
	instance.counters = card.counters.duplicate()
	instance.prevention = int(card.prevention)
	instance.regeneration_shields = int(card.regeneration)
	instance.face_down = card.masked
	instance.set_meta("sg_handle", card.id)
	return instance
