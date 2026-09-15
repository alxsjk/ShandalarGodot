# Ice Age — second-pass gameplay campaign

This follows the [initial Pack 3 integration](pack-3-mechanics-audit.md).
The objective is useful play, not merely successfully loading 346 scripts.
ZIPs and downloaded card artwork remain local-only. No player setting is
changed by the campaign tools.

## Reproduced defects and repairs

All rows were reproduced before their fixes with `test_pack_3_campaign.gd`,
except the command-line compilation defect, reproduced by the real Deck Lab
entry point. Zone numbers in the original failure output were 2=battlefield,
3=graveyard, 4=stack and 1=hand.

| Case | Before-fix evidence | Repair |
|---|---|---|
| Venomous Breath after a blocked attacker leaves and returns | `[3] expected to equal [2]: new attacker incarnation did not fight` | Turn-long combat pairs bind both battlefield timestamps. |
| Breath cast before combat, followed by its marked attacker dying | `[2] expected to equal [3]: Breath still destroys the surviving opponent` | Pair history survives either creature leaving; it does not depend on the active combat map. |
| Battle Cry trigger pending while its blocker leaves and returns | `[9] expected to equal [8]: the new Wall never triggered Battle Cry` | Capture and check the blocker incarnation. |
| Deflection with lethal Bolt available and a large enemy creature | `a redirected Bolt should win now`; winner stayed `-1` | Price actual damage, creature survival and lethal player damage rather than target size alone. |
| Meteor Shower against a one-life player with Glacial Chasm | `Glacial Chasm prevents the supposed lethal`; enemy Wall remained on the battlefield | Check applicable player prevention; spend the spell on a killable creature instead. Finite shields are included in the minimum lethal X. |
| AI Venomous Breath timing and aim | Before combat: `cast Venomous Breath`; after profitable blocks: empty response | Wait for declared combat, aim at the creature whose opponents should die, and do not buy kills normal combat already supplies. |
| AI Battle Cry timing | Empty-board payoff: `cast Battle Cry`; lethal attack with a tapped white blocker: empty response | Compare legal blocking before/after the white untap and toughness bonus, including lifesaving chumps. |
| Repeated delayed combat spells | The external probe printed `Venomous Breath repeated=cast Venomous Breath` and `Battle Cry repeated=cast Battle Cry` after a useful first copy had resolved | Credit already scheduled destruction and blocking bonuses. A second Battle Cry remains available when two bonuses are genuinely needed. |
| Deck Lab early-script loading | `Identifier not found: CardPacks` in `deck_model.gd` | Resolve the autoload at runtime, not while a SceneTree entry script is compiled. |

The control checks also confirmed that Energy Storm already stops the AI
spending Fire Covenant into fully prevented damage, and Lava Burst already
bypasses creature prevention but not player prevention. Lava Burst now exposes
that rule as a structural `DamageEffect` field so retarget evaluation agrees.

## AI boundaries

The existing `AiProfile.forecasts_tactics` switch owns these changes. Its off
arm preserves the previous Ice Age policies; every shipped profile already
enables it, with the ordinary difficulty-specific mistakes and reaction gates
unchanged. No new strength constant or hidden-information permission was added.

Damage estimates read the engine's applicable prevention gates without consuming
shields. Unmodelled replacement/redirection choices conservatively promise no
damage to the proposed recipient. This is a lower bound, not a complete solver
for every replacement ordering. Venomous Breath uses the existing public damage
forecast. Battle Cry's characteristic-only counterfactual is journaled and
rewound without dispatching untap triggers or asking either player questions.
Descriptive delayed-effect metadata tracks committed combat destruction and
blocking toughness, preventing the planner from buying the same benefit twice.

Regression controls substitute the opposing hand and both hidden libraries,
check RNG/state preservation, change public shields/evasion to show the policy
can respond to real information, and test the old null ranking. The engine
combat cases run in modern and Fifth Edition modes; search undo and cleanup
must remove speculative/stale combat history.

## Reproduction

From the project root, build the local ZIP using the Pack 3 construction tool,
then use the isolated test profile:

```sh
./run_tests.sh -gselect=test_pack_3_campaign
. tools/runtime.sh
shandalar_find_godot
shandalar_find_timeout
shandalar_test_profile
export SHANDALAR_PACK_3="../shandalar-packs/Pack-3-Ice_Age.zip"
"$SHANDALAR_TIMEOUT" -k 5 900 "$GODOT" --headless --path . \
  --script res://tools/pack_3_duel_audit.gd -- --rounds 10 --seed 45000
```

The duel audit runs nine themed 60-card decks, rotates their opponents, and
reports actual casts/activations. Ten rounds mean 180 full duels: modern seeds
45000–45089 and Fifth Edition seeds 145000–145089. Counts are observations,
not proof that every use was optimal or that cards absent from those decks were
exercised.

`tools/pack_3_deck_lab.gd` forwards the ordinary Deck Lab switches but always
disables Elo writes, enables only Pack 3 in memory, and requires the isolated
profile. It forces one process because the stock child-process entry does not
configure optional packs; `--jobs` still selects worker threads.

```sh
"$SHANDALAR_TIMEOUT" -k 5 900 "$GODOT" --headless --path . \
  --script res://tools/pack_3_deck_lab.gd -- \
  --deck-a path/to/ice-blue.deck --deck-b path/to/ice-red.deck \
  --games 500 --jobs 4 --seed 46000 --sweep forecasts_tactics=on,off \
  --control-deck-a big_green.deck --control-deck-b white_knights.deck \
  --no-elo --out path/to/results
```

The redirection study lists each contain 24 matching snow basics and four of
each of nine nonlands. Blue: Deflection, Brainstorm, Counterspell, Zuran
Spellcaster, Illusionary Wall, Illusionary Forces, Silver Erne, Ray of Command,
Binding Grasp. Red: Meteor Shower, Incinerate, Orcish Conscripts, Sabretooth
Tiger, Tor Giant, Goblin Ski Patrol, Balduvian Barbarians, Errantry, Goblin
Snowman. These are instrument decks, not tournament deck recommendations.

The combat study uses the same 24-basics/four-of-nine layout. Green: Fyndhorn
Elves, Balduvian Bears, Aurochs, Dire Wolves, Nature's Lore, Venomous Breath,
Wiitigo, Woolly Spider, Scaled Wurm. White: Battle Cry, Order of the White
Shield, Kjeldoran Knight, Kjeldoran Skyknight, Seraph, Sacred Boon, Hipparion,
Armor of Faith, General Jarkeld. Both orientations are measured so each new
combat policy is exercised on the experimental seat.

## Measurements

The blue/red sweep (seed **46000**, 500 games per arm) completed **3,000
duels**. Blue's win rate was **51.8% null / 51.6% on**, a **−0.2-point
delta with a ±6.2-point interval**: no measurable strength gain at this sample
size. The old/off arm replayed the null, and every Big Green/White Knights
control arm was byte-identical (**277–223**, 500/500 matched games). These
results support reproducibility and the absence of a detected broad regression,
not a claim of increased win rate. The tactical fixes are independently pinned
by public-action regression tests.

The green/white combat sweep (seed **47000**, 200 games per arm) completed
**1,200 duels**. Green scored **81.5% null / 88.0% on**, a **+6.5-point
delta with a ±7.0-point interval**. This is promising, but its interval still
includes zero. Every Big Green/White Knights control arm was byte-identical
(**118–82**, 200/200 matched games). Do not report this as a demonstrated
strength improvement.

The reverse white/green study (seed **47100**, 200 games per arm) completed
another **1,200 duels**. White scored **22.0% null / 27.0% on**, a **+5.0-point
delta with a ±8.4-point interval**; again, not statistically conclusive.
Control arms matched **200/200** games (**118–82**). Across all three sweeps,
**5,400 duels** completed with no stalls or draws, all controls matched, and
the off arms reproduced their nulls. The blue/red sweep preceded the final
duplicate-Breath/Cry repair, but neither study nor control deck contains
either affected spell; both combat orientations ran after that repair.

## Final acceptance gates

- Full GUT: **6,691/6,691 tests**, **258,995 assertions**, **393 scripts**,
  348.365 seconds, wrapper exit 0. The new campaign file contributes 23 tests;
  its final focused run passed 545 assertions. GUT's existing warning and two
  deprecation notices remain; there were no failing tests or exit-time engine
  errors. An earlier 6,688-test pass preceded the duplicate-spell repair and
  is not the final gate.
- Python construction/tool checks: **244 tests**, one platform skip,
  3.591 seconds, exit 0.
- Seeded Ice Age gameplay: **180/180 full duels**, both rulesets, no stalls or
  runtime errors. Observed uses include Battle Cry **23**, Venomous Breath
  **16**, Deflection **2**, Melee **1**, General Jarkeld activations **1**,
  Kjeldoran Royal Guard activations **14**, and Necropotence activations
  **186**. Regression cases, not those aggregate counts, establish correct
  timing and target choice.
- Whole-screen regression soak: **12/12 duels**, seeds **48000–48002** in
  modern and Fifth Edition rules, each through demo and fuzzed-human modes.
  Both wrappers exited 0 with no errors, warnings or stalls. These are the
  stock/core test decks running through the real duel UI in renderer-free
  mode, not additional Ice Age-specific coverage or a visual screenshot test.
- Fresh native macOS debug-template export: smoke boot passed, then the real
  ZIP verification loaded **373 Ice Age names**, **346 dormant scripts**,
  decoded **746 artwork images**, and loaded all **3 Ice Age UI textures**.
  There were **0 pending-rule guards**. The exported restricted-mana probe
  also executed successfully. This is a local ad-hoc build, not a signed
  public release or verification of Linux/Windows/Web exports.

Raw logs and Deck Lab reports live outside the repository in
`../shandalar-build/pack-3-campaign/`. The aborted initial Deck Lab run exposed
the autoload compilation error; it is excluded from all reported duel totals.
The player's `settings.cfg` remained byte-identical before/after the campaign
(SHA-256 `658add0897fe0f36ff27fa325addbf7acdb5166de4801d5b1f240bd209cfe03b`).
No deck ratings, saved decks, pack enablement preferences or released assets
were changed. Validation artifacts remain local; only source, tests and
documentation are included in the subsequent owner-requested commit.

## Limits

This is a targeted regression campaign, not exhaustive verification of every
Ice Age interaction or proof of optimal AI play. Complex replacement choices,
proactive combination planning, and cards not represented in the duel sample
still warrant further testing. The existing simplified-card ledger remains
authoritative; this campaign adds no new card simplifications.
