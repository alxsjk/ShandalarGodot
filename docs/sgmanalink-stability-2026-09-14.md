# SGManalink stabilization — 14 September 2026

This implements the review of `c638ced` on the `sgmanalink` branch. The scope
remains friendly desktop LAN play, using temporary names and a trusted player
host. No accounts, ranking service, Internet discovery or tournament hosting
were introduced. The existing fair-information computer players are unchanged.

## Correctness and recovery

- Auto-payment now waits for colour/cost questions, resumes its remaining work
  after the answer, and clears its continuation when cancelled. The screen
  cannot repeatedly submit a spell while a question is outstanding. A refusal
  unrelated to payment stops automatic retries and allows deliberate retargeting.
- Legal blocks use bounded adjacency rows, rather than treating all possible
  blocker/attacker pairs as a card list. A 24-by-24 combat validates, crosses
  the socket and accepts actual blocker declarations. Separate row/column,
  total-byte and nesting limits remain enforced.
- Automatic X is computed by the referee using the actual engine payment
  helper, reserved sources, target charges, coloured X and restricted mana.
  Manual X remains available, including spells with multiple X symbols.
- Explicit departure releases a session. Unannounced room disconnects reserve
  the seat for five minutes; expiry concedes an unfinished game for the absent
  seat and releases it. Disconnected roomless sessions expire after 30 seconds
  or can be reclaimed under capacity pressure. The host can remove a disconnected
  waiting-room guest, but cannot use that button against a connected guest or
  during a running duel.
- Fatal invitation, expiry, capacity and build failures have distinct messages.
  A rejection is delivered before the connection is dropped, and is not retried
  indefinitely. Temporary connectivity loss still supports same-seat recovery
  and duplicate-command acknowledgements. Input waits for the first refreshed
  room snapshot after welcome, so a resumed connection cannot submit new actions
  against its cached pre-disconnect revision.
- The shared log shows audience-filtered public actions and permitted private
  looks, with serial-based reconnect catch-up and deduplication. The host retains
  256 entries per seat; missing earlier history is explicitly indicated. Raw
  engine logs, seeds and hidden deck/hand snapshots are never used as its input.

Protocol 6 adds a compatibility fingerprint for the protocol, release version,
maintained rules revision and printed catalogue. It is portable across desktop
platforms, but is not authentication, executable attestation or protection against
a modified player-host. Engine/card behavior changes between release versions
must update `SgCompatibility.RULES_REVISION`.

## Performance

Same larger-board fixture as the review: five Fireballs in hand, 50 Mountains
on the battlefield, and approximately 48 KB for the tested seat's state.
Native macOS headless Godot 4.7.2; new measurements average ten iterations.
The earlier review used a single view measurement and five codec iterations,
so these are local microbenchmarks, not an end-to-end frame-rate guarantee.

| Operation | Before | After |
|---|---:|---:|
| Build one seat's view | 55.68 ms | 2.51 ms |
| Encode state | 79.77 ms | 0.79 ms |
| Decode and validate | 5.38 ms | 5.45 ms |
| Apply display projection | 2.13 ms | 0.38 ms |

The encoder scans for non-ASCII characters natively and joins escaped chunks
once. ASCII wire framing, Unicode round trips and the parser's safety limits
are unchanged. View generation shares source enumeration, caches equivalent
spell budgets within the view, and searches X using actual payment costs.

Command authorization reads a lightweight decision state instead of building
a complete presentation. Each room/seat view is cached by revision; publications
are coalesced and unrelated rooms are not rebuilt for a command. Even a refused
multi-step action invalidates its room if it changed engine state or its private
announcement before refusing. This includes an unpaid multi-target Fireball:
the refreshed payment estimate includes the additional target's cost.

Display cards are updated in place and hidden-zone placeholders are reused as
anonymous slots, all with id -1 and no wire handle. They never become hidden
card identities. Obsolete local/stack-handle maps are retired without reusing
the monotonically assigned identifiers.

## Regression coverage

The normal online suite now includes the five original reproductions, malformed
matrix bounds, Unicode codec cases, private-history substitution/catch-up,
actual coloured/restricted X payments, manual double-X selection, refusal
recovery, session churn/expiry, build mismatch and unrelated-room cache reuse.

Actual lobby/socket tests interrupt a mana-colour answer before its acknowledgement
is received, reconnect the same seat and verify a single cast. Private searches,
triggered payments and divided combat damage also retain the pending decision
across reconnect and apply the answer once when its acknowledgement is lost.
The tests also cancel the mana question, play the large combat across the socket,
and deliberately delay the first resumed snapshot while checking that input stays
disabled.

Verification gates used the isolated test profile and checked wrapper exit status:

- Full project: **6,375/6,375 tests, 239,779 assertions**, 374 scripts,
  305.614 seconds, exit 0.
- Final online suite: **81/81 tests, 7,650 assertions**, seven scripts,
  90.814 seconds, exit 0. This includes the extra refused-Fireball cache
  regression added after the full run. That regression first failed both
  revision/estimate assertions, then passed all 20 assertions after the fix.

A four-duel varied-deck soak alternated the shipped White Knights and Black/Red
Raiders decks and reused both sessions between games. All four finished: 259,
388, 369 and 311 commands, with delayed client processing, duplicate commands
and repeated reconnects. The gate passed 4,051 assertions in approximately
85 seconds. This is transport/gameplay coverage, not a claim of optimal play
by the deliberately simple test driver. Run instructions are in
[the LAN guide](sgmanalink-local-playtest.md).

Offline interface soaks also finished seed 4242 in both demo and human-seat
modes under Fifth Edition and modern rules. Fifth Edition finished in 19 and
12 turns (82 human clicks); modern finished in 17 and 13 turns (93 human clicks).
Both isolated headless wrappers exited 0 with no error, warning or stall lines.

Two-physical-machine and cross-platform playtests remain important. The transport
is still native-desktop LAN; offline web support is unaffected, and future web
multiplayer requires a separately reviewed transport. Ranked play also requires
an explicit referee/trust design: a player operating the current host can inspect
its complete rules state despite encrypted transport and filtered client views.
