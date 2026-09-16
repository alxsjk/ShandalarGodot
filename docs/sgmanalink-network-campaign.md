# SGManalink automated network campaign

The offline AI-versus-AI demo does not exercise SGManalink. This campaign
instead puts two automated, fair-information clients through the real encrypted
WebSocket service: host, join, submit decks, ready, play, reconnect and rematch.
The test pilot reads only its own received view and static printed definitions.
It is a coverage driver, not the Wizard AI and not a measure of playing strength.

## Design and failure criteria

- Referee-only deterministic seeds; neither client receives seed, shuffle order
  or hidden opposing cards. No public command can set the seed.
- Repeat each fixture unchanged and with delayed client processing, duplicate
  commands and disconnected/resumed seats. Compare the public-table transcript,
  not just the winner. Duplicates must have no second effect.
- Use full shipped decks and targeted coverage decks. Exercise spell targets,
  responses, blocks, damage assignment, questions and cleanup, not just passing
  until someone runs out of cards.
- After every settled command, both clients must agree on the public table.
  Normalize viewer-local card handles; never compare one client's private hand
  or history against the other's. Validate both filtered views and projections.
- Every refusal is recorded and fails the campaign. A legal cancel when no
  targets are available is recorded separately; it is not a hidden skip list.
- Bound commands, wall time and reconnect waits. A stalled or unfinished duel is
  a failure. After rematches, rooms must be reclaimed and sessions reused.
- Reproduce a suspected issue in a small regression before changing production
  code. Separate transport/UI/engine failures from a coverage-pilot limitation.

## Scope

Two clients on the same computer exercise real sockets and TLS. Binding to that
computer's LAN interface also checks invitation/address handling, but does not
prove two-computer routing, Wi-Fi, firewall rules or mixed operating systems.
Those require a second machine. Existing real-UDP discovery and GUI gesture
tests complement this campaign; automated command play alone cannot verify every
mouse gesture or visual effect. No Internet server, authentication or ranking
service is started by these tests.

The normal `AiPlayer` is a synchronous local-engine agent. Attaching it to the
host referee would not test a remote client's action path; attaching it directly
to the render-only projection would not give it a rules simulator. This driver
therefore has its own small, deterministic coverage policy. It is not a new
difficulty, does not change the offline demo, and does not claim expert combat
evaluation. [Host-managed computer seats](sgmanalink-computer-players.md) now
use the actual local players and have a separate eight-Wizard campaign. Their
decisions execute at the referee, not through a remote client command stream;
a remote Wizard would still need an asynchronous decision/action adapter.

## Run it

From a development checkout with the pinned Godot runtime available:

```sh
# One baseline/fault pair plus guaranteed damage and private-search scenarios.
./run_tests.sh -gselect=test_sgmanalink_campaign.gd

# Six seeds, twelve full duels, alternating seats and three deck matchups.
campaign_dir=$(mktemp -d)
SGMANALINK_CAMPAIGN_CASES=6 \
SGMANALINK_CAMPAIGN_SEED=4242 \
SGMANALINK_CAMPAIGN_LOG="$campaign_dir/games.jsonl" \
SUITE_TIMEOUT=900 ./run_tests.sh -gselect=test_sgmanalink_campaign.gd \
  > "$campaign_dir/run.log" 2>&1

# Check the pilot/oracle and the surrounding UI, discovery and recovery tests.
./run_tests.sh -gselect=test_sgmanalink_
```

`CASES` is bounded to 1–20 and defaults to one. Each case is replayed twice;
`SEED` defaults to 4242 and increments per case. Each duel has a 2,400-command
and 180-second bound, each network wait a ten-second bound, and the suite wrapper
supplies the overall timeout. Its **exit code**, not a printed green line, is
the verdict. It also rejects engine errors, skipped tests and exit-time leaks.

The optional JSONL is a local developer artifact: fixture seeds, commands with
seat-local handles, fault labels and normalized public-table hashes/states.
It contains no invitations, TLS keys, session credentials, private hands or
library order. Keep it outside the checkout; a twelve-game detailed trace is
roughly 60 MB. Tests use the isolated test profile, never the player's profile.
Full-game bots use ordinary validated deck/ready commands; only the test server's
match factory supplies deterministic seeds. Guaranteed scenarios use referee-side
fixture setup, then send the tested damage/search answer through real TLS.

## Campaign record — 2026-09-15

The twelve-game run (seeds **4242–4247**) passed **65,174 assertions** in
274 seconds, wrapper exit **0**. Every accepted-action public-state hash matched
between baseline and fault replay, and both clients agreed after every command.

| Measure | Observed |
| --- | ---: |
| Duel commands | 6,484 |
| Spell submissions | 252 |
| Land plays | 184 |
| Attack declarations | 260 |
| Declared blockers | 36 |
| Interactive damage answers | 2 |
| Cleanup discard answers | 2 |
| Duplicate sends | 74 |
| Lost-acknowledgement reconnects | 37 |
| Referee refusals / unfinished games / divergent replays | 0 |

The 42 cancels were explicit draft cancellations, not suppressed errors; all
42 left the normalized public state unchanged. The run included counters,
removal, auras, first strike and trample: the submission trace includes eight
Counterspells, ten Control Magics, ten Unsummons and four Fireballs. These are
coverage observations, not claims about the pilot's strategic quality.
Rooms were reclaimed after every game;
reconnects/rematches retained exactly two sessions. Wins occurred on turns
15–28, not by a stalled driver reaching its command limit.

The first small pair correctly failed its *coverage* expectation: ordinary
one-on-one blocks did not require interactive damage division. The driver gained
gang-block coverage; seed 4247 exercised actual division. Separate guaranteed
TLS scenarios cover a lost acknowledgement during damage division and a private
library-search answer, so those paths do not depend on fortunate shuffled draws.
The pilot/oracle instrument itself passed **5 tests / 73 assertions**, including
detecting a target switched between two identical creatures.

No new production transport or rules bug was reproduced in these twelve games;
do not present test-driver corrections as gameplay-engine fixes. The only
production change for the campaign is a referee-owned match-construction seam.
The shipped AI policies, hidden-information rules and wire schema are unchanged.
This is same-Mac TLS testing, **not yet a two-physical-computer LAN result**.

Final verification, including both guaranteed TLS scenarios and the existing
GUI/discovery/recovery tests: **6,421 tests / 250,340 assertions / 379 scripts**,
353.332 seconds, full wrapper exit **0**. The original varied-deck network soak
also completed two more games (418 and 280 commands). No release assets or
exported binaries were changed by this campaign.
