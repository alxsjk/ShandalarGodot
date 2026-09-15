extends RefCounted
## The final Help chapter: player-facing rules, not implementation notes.
## Verified against engine/combat.gd, the effect classes, fem/_rules.gd and
## Wizards' Comprehensive Rules (magic.wizards.com/en/rules), especially
## combat, keyword abilities, costs, counters and delayed triggers.
## Keep examples textual so this reference also works with packs disabled.

static func pages() -> Array:
	return [
		_page("Abilities — Combat", [
			["Flying and reach", "A flying attacker can be blocked only by creatures with flying or reach. Reach does not let a creature fly. Giving flying after blockers are chosen does not remove an existing block."],
			["First strike", "First strikers deal combat damage before creatures without first strike. A creature killed by that early damage does not strike back. First strike does not double the damage."],
			["Trample", "An attacker can assign excess combat damage to the defending player after assigning lethal damage to its blockers. Without trample, an attacker that became blocked normally stays blocked even if its blockers leave."],
			["Vigilance, haste and defender", "Vigilance means attacking does not tap the creature. Haste removes the usual summoning-sickness restriction on attacking and tap-symbol abilities. Defender prevents attacking unless another effect specifically allows it."],
			["Landwalk and menace", "Landwalk makes an attacker unblockable while the defender controls the named land type. Menace means it cannot be blocked by just one creature: the defender needs at least two legal blockers. Goblin War Drums gives this blocking restriction to your creatures."],
		]),
		_page("Abilities — Banding and protection", [
			["Banding when attacking", "You may group creatures with banding and up to one creature without banding into an attacking band. If a creature blocks a member, the whole band becomes blocked. Band members do not share flying, trample or other abilities."],
			["Banding changes damage assignment", "When an attacking band includes banding, its controller chooses how its blockers assign damage among that band. A defending creature with banding similarly lets its controller assign the blocked attacker's damage. Banding does not merge the creatures or their toughness."],
			["Protection", "Protection from a quality prevents damage from matching sources, stops matching Auras from enchanting the creature, stops matching creatures from blocking it, and stops matching spells or abilities from targeting it. Protection from black does not stop every black effect: a non-targeting destroy-all effect can still destroy it."],
			["Shroud", "A permanent with shroud cannot be targeted by either player's spells or abilities, including your own. It can still be affected by effects that do not target. Deep Spawn and Homarid Warrior can gain temporary shroud, but their abilities also tap them and delay their next untap."],
		]),
		_page("Abilities — Costs, triggers and survival", [
			["Activated abilities: cost : effect", "Pay everything before the colon when you activate: mana, tapping, sacrifices, discards or counter removal. Those costs are not returned if the ability is countered or loses its target. A tap-symbol cost needs an untapped source; a summoning-sick creature cannot pay it without haste."],
			["Triggered and static abilities", "When, whenever and at usually introduce triggered abilities. They wait on the Spell Chain and can be answered. Static abilities apply continuously while their conditions hold, without an activation. Mana abilities normally produce mana immediately rather than waiting on the chain."],
			["Regeneration", "Regeneration replaces destruction: tap the creature, remove its marked damage and remove it from combat. It does not return a dead creature. With modern damage timing, create the shield before lethal damage; with classic damage timing, use the regeneration window. Regeneration cannot stop sacrifice, exile, zero toughness or an effect that forbids regeneration."],
			["Counters and temporary boosts", "Counters stay on a permanent until removed or until it leaves the battlefield. A +1/+1 counter changes both stats; +1/+0 and +0/+1 counters change only one. An until-end-of-turn boost expires at cleanup instead. Damage is not a counter and does not reduce the displayed toughness."],
			["Tokens and creature types", "A token is a permanent and follows its creature's normal rules, including summoning sickness. A token that leaves the battlefield cannot later return. Creature types such as Thrull, Goblin, Merfolk and Fungus matter only when a card refers to them; sharing a type does not give creatures shared abilities."],
		]),
		_page("Abilities — Fallen Empires resources", [
			["Spore counters", "Thallids and related creatures gain spore counters during your upkeep. Remove three to pay for the printed ability: making a Saproling, dealing damage, preventing combat damage or regenerating. Spore counters alone do not increase power or toughness. Fungal Bloom adds a spore counter to a Fungus."],
			["Storage lands", "These lands enter tapped. You may leave one tapped during your untap step, and it gains a storage counter during your upkeep if it is tapped. Once untapped, use its mana ability and remove the chosen number of storage counters to produce that much mana."],
			["Mana conversion and High Tide", "Initiates of the Ebon Hand and Farrelite Priest turn one mana into the printed color without tapping. Using one at least four times in a turn creates a sacrifice trigger for the next end step. Implements of Sacrifice costs one mana, tapping and sacrificing itself to make two mana of one color. High Tide adds blue mana when an Island is tapped for mana that turn."],
			["Tide, net, time and credit counters", "Homarid and Tidal Influence change their effects as tide counters rise, then reset. Merseine's net counters keep its host from untapping; the host's controller may pay to remove them. Tourach's Gate consumes time counters at upkeep. Icatian Moneychanger stores credit counters that its sacrifice ability turns into life."],
		]),
		_page("Abilities — Fallen Empires combat tricks", [
			["Sacrifices and crew taps", "Goblin Warrens sacrifices two Goblins to make three. Night Soil exiles two creature cards from one graveyard to make a Saproling. War Machine and Hand of Justice require other creatures to tap as costs. A cost that says to tap an eligible creature is different from that creature paying its own tap symbol, so newly arrived helpers can be used."],
			["Unblocked-attack abilities", "Farrel's Zealot, Farrel's Mantle, Mindstab Thrull and Necrite trigger after blockers are declared if their attacker is unblocked. Delif's artifacts first set up a delayed trigger. Read whether the card replaces combat-damage assignment, prevents damage, or sacrifices the attacker: these are different effects."],
			["Effects that last while a condition holds", "Seasinger's control lasts while it remains tapped and under your control; Thrull Champion also needs you to keep control of the Champion. Spirit Shield and Zelyon Sword maintain their bonuses while tapped. Untapping or losing the required control ends the effect; tapping or taking the source back does not restart it."],
			["Coin flips and delayed effects", "Goblin Kites grants flying now, then flips a coin at the next end step; losing means sacrificing that creature if you still control it. Orcish Captain flips for a bonus or penalty. These are genuine random outcomes. Rainbow Vale gives its mana now and changes control through a later end-step trigger."],
			["New objects, not returned effects", "A card that leaves the battlefield and returns is a new permanent. Old counters, temporary effects and abilities waiting to affect its previous incarnation do not automatically follow it back. An ability already on the Spell Chain can still resolve even if its source leaves."],
		]),
		_page("Abilities — Ice Age resources", [
			["Snow lands", "Snow is a supertype, not a sixth mana color. Snow-Covered Island is still a basic Island and makes blue mana. A card counts snow lands only when its instructions say so. Snow landwalk checks the defending player's snow land of the named type."],
			["Cumulative upkeep", "At the beginning of your upkeep, put an age counter on that permanent. Then pay its upkeep cost once for each age counter, or sacrifice it. The whole payment is optional but must be paid in full. Multiple cumulative-upkeep abilities trigger separately and use the same age counters. Sacrifice cannot be regenerated."],
			["Restricted mana", "Adarkar Unicorn and Snowfall can produce mana usable only for cumulative upkeep. Soldevi Machinist's mana is only for activated abilities of artifacts, not for casting artifact spells. The game keeps restricted mana separate and checks what you are paying for."],
			["Delayed card draws", "Many Ice Age spells draw at the beginning of the next turn's upkeep, not immediately. The draw is already scheduled even if its source leaves play. If every target of the original spell becomes illegal, that spell does not resolve and does not schedule its draw."],
			["Wind counters and one-time abilities", "Freyalise's Winds adds a counter when a permanent becomes tapped. During its controller's untap step, removing all wind counters replaces untapping it. Other untap effects still work normally. Goblin Ski Patrol says activate only once: countering that activation does not restore the use. Leaving and returning creates a new object."],
		]),
		_page("Abilities — Ice Age zones and control", [
			["Abilities in the graveyard", "Most abilities work only on the battlefield. Ashen Ghoul and Whiteout explicitly let you activate from your graveyard; their timing and costs still apply. A graveyard ability on the Spell Chain does not give every other card in that graveyard permission to act."],
			["Playing cards from exile", "Exile does not normally let you play a card. Elkin Bottle and Ice Cauldron give permission for the particular exiled card. Normal costs and timing still apply, including the land-per-turn limit. Face-down exiled cards stay hidden unless an effect lets a player look at them."],
			["Storing mana", "Jeweled Amulet remembers the mana type actually paid to charge it. Ice Cauldron remembers the amounts and types paid and releases mana usable only for its last exiled card. Removing the artifact does not cancel the permission to cast a card already exiled with it."],
			["Borrowing and holding permanents", "Ray of Command and Magus of the Unseen borrow until end of turn and later tap the returned permanent through a trigger. Merieke's control ends when you lose control of Merieke, but her destruction trigger waits until she untaps or leaves. A newer control effect can override an older one; ending it reveals any older effect that is still valid."],
			["Claims on dead creatures", "Krovikan Vampire checks at each end step for creatures it damaged that died that turn. Seraph first triggers when a damaged creature dies, then schedules the return. The card must remain in that graveyard. Leaving and returning makes a new object: old damage and old claims do not follow a fresh incarnation."],
		]),
		_page("Abilities — Ice Age combat and adaptations", [
			["Attacking and blocking costs", "Orcish Conscripts needs at least two other attacking creatures to attack, or two other blocking creatures to block. Errantry's host can attack only alone. Flooded Woodlands and Reclamation charge land sacrifices to attack with the named color; you may decline to attack instead. Hipparion charges mana to block a creature with power 3 or greater."],
			["Melee and General Jarkeld", "Melee lets the attacker choose the defender's blocks for that combat; the defender still decides whether to pay any blocking costs. Unblocked attackers are untapped and removed from combat through triggered abilities. General Jarkeld exchanges the blockers of two blocked attackers only if the new blocks are legal."],
			["Gaze of Pain", "Each unblocked attacker gets a targeted trigger. You may have that creature deal damage equal to its power to the target creature; if you do, it assigns no combat damage that turn. This is not combat damage, and a creature that was blocked does not qualify just because its blocker later leaves."],
			["Drought and Soul Burn", "Drought adds Swamp sacrifices for each printed black mana symbol in a spell's cost or an ability's activation cost. Soul Burn's X is not extra black symbols: it accepts only actual black or red mana. Cost reductions can reduce what you pay for X without reducing X's damage; life gain counts only black mana actually spent on X and is capped by the damage and the victim's life or toughness."],
			["Documented digital adaptations", "Balduvian Shaman changes a color only on one of the five colored Circles of Protection you control; it cannot rewrite arbitrary enchantment text. It still grants cumulative upkeep. Game of Chaos stops after 30 flips in one resolution. These differences are also printed on the digital cards."],
		]),
	]

static func _page(title: String, entries: Array) -> Dictionary:
	var blocks: Array = []
	for entry in entries:
		blocks.append({"kind": "heading", "text": entry[0]})
		blocks.append({"kind": "text", "text": entry[1]})
	return {"title": title, "blocks": blocks}
