# Pack 3 — Ice Age mechanics and AI audit

## Catalogue and local construction

Ice Age contains **373 distinct names across 383 published printings**.
Of those names, 27 reuse original game identities and 346 have new trusted
card scripts. All three packs together expose **1,745 named set entries and
1,349 unique cards**. Reprints are not additional playable identities.

```sh
python3 tools/pack_3_ice_age.py fetch       # refresh Scryfall metadata
python3 tools/pack_3_ice_age.py fetch-art   # resumable local artwork download
python3 tools/pack_3_ice_age.py             # construct Pack-3-Ice_Age.zip
python3 tools/pack_3_ice_age.py verify
```

The default output is the sibling `shandalar-packs/Pack-3-Ice_Age.zip`.
Only construction source and metadata are distributed, **never the generated
ZIP or downloaded card art**. The ZIP includes full and cropped artwork for
one selected printing per name: 746 distinct images. Alternate basic-land
printings are retained in the metadata; their art is not a separate selection.
Legacy artwork aliases for the 346 new identities are also included.

The loader checks format, pack/game versions, exact archive inventory,
metadata checksums and an artwork digest. It rejects scripts and malformed
archives. Executable rules are shipped with the game, not accepted from ZIPs.
Pack 3 does not require Pack 1 or Pack 2.

## Player-facing integration

- Options → Card Packs: availability, enable/disable, version, rejection reason,
  Open Folder and Rescan.
- Deck Builder → Extras: independent 1997, tDotP, Fallen Empires and Ice Age
  filters. Ice Age alone displays 373 names, including its reprints.
- A blue-grey stone medallion and gold ice-crystal emblem match the existing
  set-button family without extending the original set strip.
- Ice Age set filtering selects its printing artwork. Deck identity stays
  name-based, with required-pack metadata and existing printing-pin support.
- The last Help chapter explains ordinary combat abilities, Fallen Empires
  resources and combat, and Ice Age snow, cumulative upkeep, restricted mana,
  delayed draws, graveyard/exile permissions, control, combat and adaptations.
- Installing a ZIP does not silently change the player's enabled-pack choice.

## Rules coverage

All **346 new identities have executable first-pass handlers**; the other
27 names reuse existing scripts. The catalogue test and exported-build probe
reject any remaining `_pending` cast guard. This is not a claim that every
possible combination of cards has been exhaustively verified.

New or extended engine paths include:

- Live snow supertypes, snow landwalk, snow-dependent costs and effects;
  painlands, depletion, storage and coupled mana outputs.
- Cumulative upkeep with age counters, complete optional payments, mana/life/
  sacrifice costs, restricted upkeep mana and source-incarnation checks.
- Next-turn cantrips and delayed effects independent of their departed source.
- Life/X/divided-damage costs, restricted actual B/R spending for Soul Burn,
  generic-X reductions, actual-spend life gain, and snapshot-safe spell copies.
- Drought's additional Swamp costs for printed black symbols, reserving distinct
  resources for ordinary sacrifice/exile costs before payment.
- Finite repeatable mana abilities (Iceberg), restricted intermediate mana
  through opted-in artifact converters, and exact stored mana type/amount.
- Graveyard activations, particular-card exile-play permissions, normal play
  timing and land limits, hidden information and permission expiry.
- Timestamp-ordered control layers, source-presence/control/tap leashes,
  temporary control return, moved control Auras and incarnation-safe reanimation.
- Merieke's independent destruction trigger; Seraph and Krovikan Vampire's
  damage/death claims; last-known death listeners and simultaneous deaths.
- Sacred Boon's actual-prevention receipt, packet-specific Errant Minion
  prevention, Winter's Chill choices, source shields and classic damage windows.
- Whole-army attack/block restrictions, land-sacrifice attack fees, aggregate
  Hipparion block costs, Melee's block-choice authority and retreat triggers,
  General Jarkeld's blocker exchange, and Gaze of Pain's targeted triggers.
- Departed-source snapshots for Gaze of Pain: power at departure, not at trigger
  creation, and no damage-suppression effect on a returned incarnation.
- Paid Aura movement, enchantments attached to graveyard cards, one-time
  activations, world effects, retargeting, library order and card-name choices.

Behavioral tests cover refusal without spending resources, trigger timing,
source changes, target legality, actual prevention, visible UI entry points
and AI search undo. The suite also verifies every Ice Age name is visible and
loadable, including reprints.

## Deliberate digital adaptations

Two Pack 3 adaptations are explicit in card rules text, the manifest, Help and
the [simplified-card ledger](simplified-cards.md):

- **Balduvian Shaman:** color rewriting is restricted to the five colored Circles
  of Protection you control that are white and lack cumulative upkeep. It still
  grants the full cumulative upkeep ability.
- **Game of Chaos:** a resolution stops after 30 flips. Coin outcomes, voluntary
  continuation and doubling are otherwise retained.

Existing engine-wide adaptations in the roadmap still apply. A supported card
is not an assertion that every old engine limitation has disappeared.

## AI integration

The Ice Age tactics module uses public information and the existing decision
agent interfaces. It covers upkeep affordability, restricted and stored mana,
snow requirements, graveyard/exile actions, life/card budgets, divided damage,
temporary control, reanimation, profitable blocker exchanges, Aura movement,
Hecatomb sacrifices, Gaze of Pain and Melee. Whole-declaration repair preserves
combat legality and avoids forcing optional costs. Cost heuristics account for
Drought's Swamp sacrifices.

Targeted tests exercise the actual AI action entry points, not only helper
scores. A separate deterministic audit runs ten complete Wizard-versus-Wizard
duels using five Ice Age decks in both modern and Fifth Edition rules modes.
This is a regression sample, not a claim of optimal AI play with every card.

The subsequent [gameplay campaign](pack-3-gameplay-campaign.md) adds
reproduce-first engine fixes, shield-aware damage choices, useful combat-spell
timing and a larger nine-deck rotating duel audit with actual usage counts.

```sh
# From the project root, after building the real local ZIP:
. tools/runtime.sh
shandalar_find_godot
shandalar_find_timeout
shandalar_test_profile
export SHANDALAR_PACK_3="../shandalar-packs/Pack-3-Ice_Age.zip"
"$SHANDALAR_TIMEOUT" -k 5 600 "$GODOT" --headless --path . \
  --script res://tools/pack_3_duel_audit.gd
```

## Acceptance record

- Python construction/tool suite: **244 tests, one platform-specific skip**.
  The Pack 3 tests include deterministic builds, missing/extra/duplicate entries,
  atomic failure, exact name counts and release-stage refusal of all three ZIPs.
- All **746 selected-printing images** decoded successfully, and the final ZIP
  passes checksum/inventory verification.
- **10/10 complete Ice Age Wizard duels** passed: modern seeds 43000–43004,
  Fifth Edition seeds 43100–43104; no stalls or runtime errors.
- **12/12 full live-UI duels** passed in the headless UI driver: demo and fuzzed
  human seats at seeds 1000, 1037 and 1074 under each ruleset. This exposed and
  fixed an early-script-load dependency in card previews, which GUT's normal
  autoload order had not exposed.
- Real native 1280×800 source-scene captures verified 373-card Ice Age-only
  filtering, all three Options rows, matching medallions/artwork, and page 37/37
  of Help with the complete final ability page visible.
- The final **macOS desktop export** (debug template, local ad-hoc signature)
  passed the real-ZIP probe: **1,243 original-plus-Ice Age identities, 373 set
  names, 346 dormant scripts, 746 decoded images, three UI textures, executable
  restricted mana, and zero pending card rules**. No runtime-error or leaked-
  object line was printed. This is a local export check, not release signing.
- Final full GUT regression: **6,668/6,668 tests, 258,440 assertions, 392
  scripts**, exit 0. The runner found no runtime errors, pending tests or
  exit-time object leaks. The complete run includes 237 Pack 3-focused tests
  and the broader original-pool/Fallen Empires regressions.

The installed ZIP remains **disabled** in the player's saved settings until
they choose to enable it. Captures enabled the packs only in memory. The ZIP
and card images were not included in Git or a published release.

## Rules references

The checked-in Scryfall Oracle snapshot is the per-card source. General rules:
[Wizards rules page](https://magic.wizards.com/en/rules), including CR 702.24
(cumulative upkeep). Snow is a supertype, not a sixth mana color; see Wizards'
[snow explanation](https://magic.wizards.com/en/news/making-magic/theres-no-business-snow-business-2006-06-26).
