# Pack 2 — Fallen Empires

Pack 2 is independent of Pack 1. Its exact filename is
`Pack-2-Fallen-Empires.zip`, and its status badge is `2-FEM`.

The official [Scryfall Fallen Empires catalog](https://scryfall.com/sets/fem)
contains **187 printings and 102 distinct card names**. None of those names
belongs to our default 897-card pool. The checked-in `cards.json` preserves
all 187 records; the playable catalog uses one identity per name. Multiple
illustrations of the same named card do not create new playable identities.

| Enabled packs | Named set entries | Unique playable cards |
|---|---:|---:|
| None | 897 | 897 |
| Pack 1 only | 1,270 | 901 |
| Pack 2 only | 999 | 999 |
| Both | 1,372 | 1,003 |

## Build locally

From the repository root, using Python 3's standard library:

```sh
python3 tools/pack_2_fallen_empires.py fetch-art
python3 tools/pack_2_fallen_empires.py build
python3 tools/pack_2_fallen_empires.py verify
```

The default output is `../shandalar-packs/Pack-2-Fallen-Empires.zip`.
`fetch-art` resumes an incomplete download. `--art-dir PATH` chooses another
cache, and the optional path after `build`/`verify` chooses the ZIP location.
Use `fetch` to refresh the official Scryfall metadata; a changed 187/102 census
requires deliberate review before the builder will proceed. `-h` and
`--version` are supported.

Copy the ZIP into **Options → Card Packs → Open Folder**, then **Rescan**
and **Enable** Pack 2. A development checkout also discovers it in the
default sibling output directory. The ZIP contains metadata and 204 images
(crop + full card for each name), with an additional 204 name-based aliases.
It does not contain GDScript or executables. Artwork is one representative
printing per name; this is not a 187-illustration collector browser.

The original eight set medallions do not move or gain another set. In the
Deck Builder, **Extras** immediately left of **Stats** opens three matching
rows: **1997**, **tDotP Pack 1**, and **Fallen E. Pack 2**. Each has separate
**On / Off** captions beneath square blue-grey stone tiles, with the original
strip's bevels, gold rings and dark emblems: **97**, **fanned cards**, and the
**Fallen Empires crown**. The chosen option is bright; the other is dark.
**Close** is the only footer button. Fallen Empires cards retain their gold
crown set symbol.

All three sources are independent. Turn **1997 Off**, **Pack 1 Off**, and
**Pack 2 On** to browse just the 102 Fallen Empires cards. Turn both packs
Off and 1997 On to restore the **897 unique names** in the shipped pool.
Pack 1-only views include its added reprints as well as its four new names;
the artwork follows an added printing, not the hidden original printing.
That is **373 added set entries / 372 unique names**, or **474 names** with
Pack 2 also On and 1997 Off. Repeated printings still share one playable name.
All sources Off intentionally shows an empty inventory; On restores a source
without changing the set strip.

Other set/color/type/search filters remain intact. These are browser filters,
not changes to globally enabled packs, saved decks or duel legality. Closing
and reopening the popup preserves the selections. Rows for unavailable packs
remain visible with On disabled and a tooltip directing players to
**Options → Card Packs**. Filtering never enables a disabled pack implicitly.
The visible count updates immediately.

With 1997 On and both ZIPs enabled globally, the four browser combinations
are 1,003 (both packs shown), 999 (only Pack 2 shown), 901 (only Pack 1 shown),
and 897 (neither pack shown).
Fourth Edition has 378 published printings but 368 distinct names; repeated
basic-land illustrations do not become separately playable deck identities.

Stats stays compact; the wider emerald **Done** button remains at the
right end of the command bar. Popup medallions and action buttons are
centered within the stone panel.

Saved decks remain name-based. Their `required_packs` metadata records
`pack-2`; loading one while disabled offers to enable the installed pack.
Disabling warns when the current deck contains a Fallen Empires card.

## Rules and AI audit

All 102 card scripts ship dormant in the game and are registered only after
the exact trusted data/art archive has been validated and enabled. Pack 2
does not add cards to the old prebuilt decks or change the default pool.

| Mechanic | Implementation |
|---|---|
| Spore, javelin, credit, net, tide and unusual P/T counters | Existing continuous counter arithmetic plus a shared named-counter effect. Costs remove counters before the ability is on the stack. Tide resets are responseable state triggers, with no duplicate pending occurrence. |
| Token tribes | Shared Saproling, Thrull, Camarid, Citizen and Goblin construction; fixed counts or sacrificed mana value as printed. |
| Compound costs | Fixed multiple sacrifices, multiple non-`{T}` taps (including summoning-sick helpers), same-graveyard multi-exile, and source/cost last-known information. |
| Storage and sacrifice lands | Enter tapped, optional untap, upkeep charging, variable counter expenditure, and two-mana sacrifice alternatives. The mana planner understands charged storage output. |
| Derelor | Additional black pips, not generic mana, scoped to its controller's black spells. Cast/payment planning uses the modified cost. |
| Menace / blocking restrictions | Minimum blocker count and live attacker predicates; AI declarations repair incomplete menace gangs or leave the attacker unblocked. |
| Delif / Farrel combat substitutions | Delayed or unblocked triggers and explicit suppression of combat-damage assignment, distinct from damage prevention. |
| Leashes, land changes and untap restrictions | Existing control, type-change, floating-effect and untap systems. Bound effects end when the affected object leaves the battlefield. |
| Merseine / Tourach's Gate | Live host-derived mana or tap costs; Merseine's ability is restricted to the enchanted creature's controller. |
| Vodalian War Machine | Crew taps recorded when costs are paid, not when effects resolve; the death trigger retains that information. Defender remains present while its attack restriction is waived. |
| Choices and random effects | Existing player-choice flow; game-seeded randomness for Hymn and coin effects. Orcish Spy's information goes to the activating seat, not the public game log. |

The AI reads shared token, discard, damage, removal, regeneration and counter
effects structurally. Its price-aware ability checks include multiple bodies,
crew taps and same-graveyard exile requirements. Decisions inspect public
boards and permitted information, never hidden library order or future RNG.
The September 15 pass adds public-board policies for control theft, targeted
shroud responses, tax counters, spore-cycle completion, Merseine escape on an
enemy-controlled Aura, War Machine crew/attack preparation, held artifact
boosts, unblocked-attack substitutions, storage and token engines, and
sacrifice/discard-priced regeneration. High Tide's resolved bonus is visible
to the mana planner; the caster holds it unless it unlocks a worthwhile spell.
Dwarven Catapult sizes X for divided creature damage, not damage to its player
target. See [the detailed audit](pack-2-mechanics-audit.md) for scope and limits.

The follow-up engine/AI pass adds cost-first automatic mana conversion for
Initiates, Farrelite Priest and Implements of Sacrifice, plus all five Rainbow
Vale colours. Hymn targets the opponent and waits against an empty hand;
Goblin Kites buys useful pre-block evasion only after pricing the coin's
sacrifice risk. Delayed end-step effects use the stack, and source-incarnation,
untap/control continuity and trigger-controller snapshots prevent old effects
from attaching to returned cards or the wrong player.

No new intentional card simplification is introduced by this pack. Existing
engine-wide rule limitations still apply; see `docs/ROADMAP.md`. Any future
intentional shortcut must be marked in the card and entered in
`docs/simplified-cards.md`, not silently substituted.

## Distribution

**Publish construction source and metadata only. Do not publish this ZIP or
its downloaded art.** Release packaging rejects numbered pack ZIPs inside
the macOS app payload and uses explicit platform payload lists elsewhere.
The hidden `--metadata-only` switch exists solely for isolated automated tests;
normal player builds reject an archive without its complete artwork.

## Export smoke check

After building a desktop app, run its executable with `-- --verify-pack-2`
and `SHANDALAR_PACK_2` pointing to the real, art-complete ZIP. This enables
Pack 2 only in memory, checks 999 identities and all 102 dormant scripts,
decodes all 204 representative images and checks the three shipped crown
textures, then exits without changing the
player's pack preferences. A metadata-only test fixture is not sufficient
for this check.
