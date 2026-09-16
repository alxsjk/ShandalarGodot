# Eight-player LAN tournament campaign — 2026-09-15

Eight automated clients and a separate organiser used the real TLS service,
normal deck registration, random draws, readiness, duel commands and results.
First to one win, three rounds, eight different shipped decks. This is the
DTO-only network coverage pilot, **not the local Wizard AI** and not a deck
strength or ranking experiment. No production AI or rules code was changed.

Draw seed **4250**, game seeds **4250–4256**. The test referee alone sets those
seeds; a bot receives only its permitted seat view. Duplicate sends and
lost-acknowledgement reconnects are injected while other tables remain live.
These are same-Mac sockets, not a physical, mixed-platform LAN playtest.

## What the run found

The initial run stopped in semifinal table 2, game seed 4255, with:

> Giant Spider can only be cast in your main phase with an empty stack

Manabarbs added triggers while automatic payment tapped lands. The test bot
used its pre-payment casting decision without checking the new stack. The
referee correctly refused the sorcery-speed cast in that state. The ordinary
local AI already has a wait-and-retry path for this case; the network coverage
pilot did not. This was a **test-instrument bug**, not a tournament-score or
transport defect.

A small failing-before regression reproduced the bot choosing `submit` where
it needed `cancel`. The correction consults the referee's current castability,
releases the temporary draft, lets triggers resolve and retries using floating
mana. It does not hide refusals or blacklist the spell for the remainder of the
phase. The regression verifies the creature reaches play in the same turn,
exactly four lands are tapped, four life is lost and no second payment occurs.
A control verifies instants remain playable over those triggers.

The corrected run's first **1,798 command/public-state entries** matched the
original run exactly; the next decision changed from the refused submission
to the intended deferral. The completed semifinal used five such deferrals.
All seven pilot tests passed, **122 assertions**, wrapper exit **0**.

A separate new recovery assertion initially compared JSON float arrays with
the restored ledger's normalized integer arrays. The scores and paths agreed,
but the test's strict array comparison did not. Comparing both through the same
wire representation corrects the test without discarding or relaxing result
fields. This was also an instrument correction, not lost tournament data.

The final identical-seed replay passed **14,364 assertions**, wrapper exit
**0**, in 116.348 seconds. Its complete 2,833-entry journal is identical to
the prior completed replay: seven games, 2,824 actions, one start and one final
summary. The comparison correction did not change any game action or result.

The broader SGManalink regression run then passed **166 tests / 35,687
assertions**, wrapper exit **0**, in 201.337 seconds, including the existing
paired baseline/fault games, privacy, GUI and tournament tests. No new
production tournament/network defect was reproduced. Changes in this pass are
limited to test instrumentation, its regressions and documentation; no exports,
commits, pushes or release changes were made.

## Match results

The two named enemy decks below are the shipped Duels of the Planeswalkers
variants. Every series was 1–0; no drawn games, byes or forfeits occurred.

| Round | Match | Winner | Final turn | Commands |
| --- | --- | --- | ---: | ---: |
| Quarterfinal | Nether Fiend — Goblin Warlord | Goblin Warlord | 14 | 302 |
| Quarterfinal | Black-Red Raiders — Big Green | Big Green | 14 | 320 |
| Quarterfinal | White Knights — Mountain Artillery | Mountain Artillery | 16 | 395 |
| Quarterfinal | Blue Skies — Merfolk Shaman | Blue Skies | 16 | 404 |
| Semifinal | Mountain Artillery — Blue Skies | Blue Skies | 22 | 551 |
| Semifinal | Big Green — Goblin Warlord | Big Green | 12 | 366 |
| Final | Blue Skies — Big Green | **Blue Skies** | 19 | 486 |

Blue Skies finished 3–0 and survived the final at 2 life. Big Green finished
2–1. Mountain Artillery and Goblin Warlord share third; the other four entrants
share fifth. All nine clients agreed on the complete standings.

The completed replay exercised **2,824 commands**, including 93 spell
submissions, 89 land plays, 111 attack declarations and 15 declared blockers.
There were **31 duplicate sends and 16 lost-acknowledgement reconnects**, with
no extra sessions or duplicate results. The 17 legal draft cancellations were
12 pre-payment cancellations and five mana-trigger deferrals. This particular
seed did not reach interactive damage division or private-choice questions;
the existing guaranteed network scenarios cover those paths separately.

## Repeat it

Use a fresh local artifact directory outside the checkout:

```sh
tournament_run=$(mktemp -d ../shandalar-build/tournament-eight.XXXXXX)
SG_TOURNAMENT_CAMPAIGN_PLAYERS=8 \
SG_TOURNAMENT_CAMPAIGN_VARIETY=1 \
SG_TOURNAMENT_CAMPAIGN_FAULTS=1 \
SG_TOURNAMENT_CAMPAIGN_SEED=4250 \
SG_TOURNAMENT_CAMPAIGN_LOG="$tournament_run/games.jsonl" \
SUITE_TIMEOUT=900 ./run_tests.sh \
  -gselect=test_sgmanalink_tournament_network.gd \
  -gunit_test_name=test_full_games_through_parallel_tables_and_final_use_only_seat_views \
  > "$tournament_run/run.log" 2>&1 </dev/null
```

The journal records test seeds, seat-local commands, refusal messages,
public-state hashes and event results. It contains no invitations, session
credentials, recovery codes, complete hidden hands or library order. This is
a developer artifact for fixed test fixtures, not a recording format for
private human games. Tests use the isolated profile and do not update Elo or
the player's decks/settings. A printed completion line is not the verdict:
the wrapper must exit 0 after every assertion and teardown check.
