# Fair planning and combat study — 2026-09-13

This is a coordinated extension of the existing player, informed by the
local Forge, Shandalar 30th Anniversary and mage-go source studies. It is
not a port of another engine's hidden-state evaluator or a claim to beat
every other MTG program. The player-facing contract is [fair play](fair-play.md).

## Information and lifecycle

`MtgGame.set_agent` calls `DecisionAgent.prepare`. `AiPlayer` derives an
`AiDeckStudy` from **its own** registered list before making its first
decision. The study retains names, counts and numeric summaries, not live
cards or shuffled library references. Reattaching a seat to a new game
rebuilds its study and clears pending action plans.

`AiObservation` supplies value-only planning/cache observations. It excludes
unrevealed opponent hands, opponent decklists, hidden library order and RNG
state. Known hand cards and explicitly revealed top cards are included.
Face-down opponent permanents contribute public characteristics, not their
printed identities. This boundary does not pretend GDScript prevents all
legacy code from accessing `MtgGame`: review and invariance tests remain
mandatory for the engine-facing proposal builders and card-choice hints.

The naming-hint audit also removed Petra Sphinx's library-composition scan
and excluded face-down identities from Nebuchadnezzar's public-copy count.
The existing shared decklist-based naming menu remains unchanged.

## Own-deck strategy

The study counts the mana curve, average nonland cost, creatures, lands,
nominal colour sources, coloured mana demand and effect roles. It assigns
multiple plan scores: fast creatures, burn, control, ramp, land control,
tempo, attrition and mill. The strongest label describes a list; it does
not replace the other scores or change difficulty.

Effect-pair synergies include life-for-mana plus X damage, acceleration plus
finishers, land denial plus artifact mana, discard plus reanimation, tokens
plus sacrifice outlets, and untapping plus repeatable tap effects. These
are **potential synergies**, not proofs of a legal combo or a general combo
solver. Source counts are nominal card counts, not simultaneous mana output.

`studies_deck` gives modest preferences to already useful casts and tutor
choices, with an additional preference for a visible own complementary
piece. Zero-value plays stay zero; lethal priorities are not diluted. The
existing tactical counter, removal, reserve and combo execution policies
still decide whether a play actually works.

## Short action lines

`AiActionPlanner` compares up to ten already useful, legal proposals, to a
depth of three, with a hard node budget. A real shared-source mana plan
checks combined costs, coloured requirements, X, surcharges and reserves.
Restricted mana is conservatively allowed only where every card in the
line accepts its restriction. A guaranteed winning action outranks a sum
of ordinary development scores.

Only independent creature development can be an intermediate move. An
unknown, targeted, draw or other unmodelled effect ends the line. This is
bounded resource sequencing, **not general full-turn simulation**. No draw
is tested against the actual hidden library.

Only entirely independent development lines are cached. Expected own casts
and their mana expenditure are normalised in the key; every resumed cast
is nevertheless rebuilt through the current legality, usefulness, reserve
and payment checks. Prior casts must actually have reached the battlefield.
A public-state change, missing predecessor or opposing stack intervention
invalidates the plan. Hidden-card substitutions cannot invalidate it.

## A coordinated combat model

`AiCombatStudy` enumerates attack subsets and complete defender assignments
using the existing `CombatSearch` flat public model and damage resolver.
One blocker has one shared allocation bit. Gang blocks, first strike,
trample, rampage, casualties and face damage are evaluated together.
The cohort scorer, damage forecast and declaration use this same model;
damage/clock queries minimise damage first, while tactical exchanges price
the whole trade. A defender being able to stop damage is distinct from it
preferring to preserve a creature.

A dangerous counterattack is studied over survivors and untapped defenders
using the existing `crack_back_margin` danger gate. One affordable, ordinary
own-hand pump can be evaluated on up to six legal own bodies; alternatives
are mutually exclusive and carry a card opportunity cost. Its temporary
stats expire before the counterattack model. Speculative continuous effects
are journaled and undone; real mana and the hand are untouched.

Damage outcomes and ordered gang choices are memoised **inside one study**,
including its reply searches. Keys describe a flat-model variant, attack
direction, attacker and blocker mask. They contain no hidden game state;
no combat cache survives into the next real game decision. The memo changes
work performed, not the number or ordering of search leaves.

Bounds and retained approximations:

- At most twelve creatures per side enter this study. Attack subsets are
  exhaustive through five optional attackers, then a deterministic chain.
- Gangs use the existing singles plus bounded two/three-body generator.
  Candidate attacks share the total leaf budget; responses and counterattack
  leaves consume that same budget. No minimum slice silently exceeds it.
- Counterattack replies use at most 24 leaves per forward outcome. This is
  selective minimax, not an exhaustive solution to all possible combats.
  It is a survivor/current-characteristic forecast, not a full end-turn
  replay of every continuous effect, upkeep and future priority window.
- Repeatable pumps, booked self-pump mana, tap-to-kill threats and gaze
  triggers retain the existing specialised combat policy. Wide boards fall
  back too. The flat model does not simulate every triggered/replacement
  effect, every regeneration payment or every legal combat trick.
- A deterministic legal fallback is always available. More nodes can refine
  the answer, but cannot confer more hidden information.

## Profiles and measurement

The switches are `studies_deck`, `studies_combat` and `action_search_nodes`.
Their null is `off,off,0`; fairness itself has no off switch. Search and
deck style are distinct from mistake injection. See [difficulty presets](ai-difficulty.md).

Sorcerer and Wizard enable both studies, with action budgets 64 and 96.
Apprentice and Magician retain the null. The combat leaf budgets remain
1,500 and 3,000 respectively. No platform-specific dependency was added.

### Fixed-policy acceptance

The final complete `./run_tests.sh` gate exits **0**: **6,209 tests** in
361 scripts, with 231,118 assertions. The player-specific selection passes
1,134 tests. This change adds 32 tests across deck study, fair planning,
combat study and card-naming fairness. Historical A/B fixtures explicitly
disable the new study when measuring an older isolated knob; new fixtures
cover the coordinated policy and its real combat outcomes.

Five starter decks, all ten unordered matchups, with candidate/baseline
assignments reversed so each deck is piloted by each policy. Play/draw
alternates within each matchup. Candidate = Wizard with the three new
switches enabled; baseline = the same Wizard with `off,off,0`. Other
existing fixes/settings are shared, so this does not compare against an
unrelated older release. Separate both-baseline null runs use the same seeds.

| Seed | Games per matchup per assignment | Candidate wins | Candidate vs baseline games | Win rate |
|---|---:|---:|---:|---:|
| 91326 | 500 | 5,100 | 10,000 | 51.0% |
| 91327 | 200 | 2,095 | 4,000 | 52.4% |
| Combined | | 7,195 | 14,000 | **51.4%** |

No stalls in those games or the 7,000 both-baseline null games. These are
two seed sets, not 14,000 unrelated experiments: reversed assignments reuse
deals. The result is a modest measured gain over this fixed baseline, not
proof of universal superiority. The first seed informed iteration; the
second checks the resulting policy without further strategic tuning.

| Deck | Candidate wins / 2,800 | Both-baseline wins / 2,800 | Change in win-rate points |
|---|---:|---:|---:|
| Big Green | 1,533 | 1,438 | +3.39 |
| Black-Red Raiders | 1,229 | 1,239 | -0.36 |
| Blue Skies | 1,766 | 1,749 | +0.61 |
| Mountain Artillery | 1,406 | 1,368 | +1.36 |
| White Knights | 1,261 | 1,206 | +1.96 |

The small Raiders decline is retained in the record; no claim is made that
every deck improves. Broader historical/control/combo gauntlets remain
useful future measurements, especially before increasing search width.

### Controls and replay

A `studies_combat=on,off` sweep of Big Green versus White Knights uses
200 games per arm, seed 91328. The positive pair moves from 61% to 64%;
its interval is too wide to establish a separate combat-only win-rate gain.
The negative pair is forty Forests versus forty Islands: no spell, combat
or synergy can fire there. Every candidate control replays its 200 null
games exactly, including complete game-log fingerprints.

Repeating that 1,200-record experiment with one worker instead of four
produces byte-identical `games.csv`, not merely the same winner totals.
After combat memoisation, the 5,000-game seed-91326 candidate-A matrix
also reproduces every recorded matchup statistic from before memoisation.
No experiment updates Elo or player saves.

### Latency and platforms

`tools/bench_planning.gd` measures complete attack-choice calls on macOS,
Godot 4.7.2, after one warm-up and across five repetitions. These are local
CPU timings, not browser measurements or frame-time guarantees.

| Creatures per side | Median, no hand trick | Median, own Giant Growth | Highest measured call |
|---|---:|---:|---:|
| 1 | 0.061 ms | 0.159 ms | 0.165 ms |
| 3 | 1.384 ms | 4.020 ms | 4.199 ms |
| 6 | 24.095 ms | 25.477 ms | 25.821 ms |
| 12 | 84.872 ms | 89.151 ms | 90.096 ms |
| 13, legacy fallback | 64.286 ms | 62.615 ms | 64.333 ms |

Before per-study memoisation, the 12-body case took about 4.3 seconds per
decision; identical exchanges and branch orderings were being recomputed
inside every reply. Memoisation preserves leaf counts (maximum 2,785 in
that fixture, below 3,000) and does not consult a clock or random state.

All new engine code remains pure RefCounted GDScript: no native extension,
thread requirement, OS/input access or platform-specific decision policy.
Windows, Linux, macOS and web retain the same source path. This verification
ran natively on macOS; Windows/Linux runtime and browser/export smoke tests
were **not** performed for this change. The desktop measurements do not
substitute for a future web latency check.

### Reproduction

Run `./run_tests.sh` for the complete gate. The focused entry points are
`-gselect=test_ai_` and `-gselect=test_card_naming_fairness.gd`.

From the project root, the primary candidate arm is:

```sh
. tools/runtime.sh
shandalar_find_timeout
"$SHANDALAR_TIMEOUT" -k 5 600 DeckLab/deck_lab.sh \
  --matrix decks/ --games 500 --seed 91326 --jobs 4 \
  --profile-a wizard:studies_deck=on,studies_combat=on,action_search_nodes=96 \
  --profile-b wizard:studies_deck=off,studies_combat=off,action_search_nodes=0 \
  --no-elo --no-svg --out ../shandalar-build/planning-candidate-a
```

Swap the two profile strings for candidate B; use the baseline string on
both seats for the null. Repeat with `--games 200 --seed 91327`, giving
each run a distinct output directory. For the fingerprinted control,
use the Lab's documented `--sweep` mode and two `.deck` files containing
`40 Forest` and `40 Island`, with distinct deck names. Preserve the
profiles above except omit `studies_combat` from both strings (the sweep
sets it), then pass `--sweep studies_combat=on,off --null off`,
`--games 200 --seed 91328`, the two control paths, and the Big Green /
White Knights positive pair. Compare `games.csv` at `--jobs 1` and `4`.

For the latency probe, discover the pinned Godot with
`shandalar_find_godot`, select the isolated profile with
`shandalar_test_profile`, then run the same timeout directly around
`"$GODOT" --headless --path . -s res://tools/bench_planning.gd`.
