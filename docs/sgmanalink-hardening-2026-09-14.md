# SGManalink robustness pass — 14 September 2026

A second pass over the local transport, session lifecycle, client input and
host-view validation, following [the stabilization work](sgmanalink-stability-2026-09-14.md).
The scope remains temporary identities and friendly, unrated desktop LAN duels.
No accounts, central service, Internet discovery, ranking or new platform-specific
dependencies were added. Offline rules and computer-player logic are unchanged.

## Bugs reproduced and fixed

1. **An acknowledgement could unlock stale input.** A host acknowledgement and
   its updated state are separate WebSocket messages. Previously, receiving the
   first unlocked a second action before the second updated its room revision.
   The client now completes an action only after the acknowledgement and a
   following validated snapshot. A refusal is likewise reported once, after
   the refreshed state is installed.
2. **An oversized command entered an unrecoverable retry loop.** A structurally
   valid large deck submission could exceed the 32 KiB command limit. The client
   now checks the encoded size before consuming a sequence or marking itself
   busy, and the lobby displays the refusal. The encoded pending message is
   reused on retry; a socket send failure closes the connection for recovery.
3. **A replacement opponent inherited approval of the previous pairing.**
   Leaving, abandoning or joining a seat now clears both Ready marks. The
   remaining player must approve the new pairing before a duel starts. A
   transient disconnect and same-seat recovery do not replace the opponent.
4. **A roomless visitor's departure invalidated unrelated duel caches.** Empty
   room identifiers now mean a listing/requester update, not a global refresh.
   An explicit full refresh remains available for fixtures. Browser churn
   no longer rebuilds every active match's per-seat views.
5. **Duplicate commands triggered redundant full snapshots.** Duplicate
   acknowledgements still come from the bounded execution history, but their
   snapshots are coalesced per recipient in the polling batch. Encoding also
   stops early for a socket that is no longer open.
6. **Some contradictory host views passed structural validation.** Card handles
   now have consistent zone membership and definitions; combat, banding and
   damage-assignment card references must exist. Duplicate card/object handles,
   unknown keyword values and impossible choice counts are refused. Legitimate
   repeated faces, including one's hand revealed by Revelation, remain valid.
   Historical animation/observation references are not incorrectly required
   to point to a currently visible card. Invalid snapshots stop the connection
   before replacing the last valid client state.
7. **Departed attackers could regain hidden card handles through old blocks.**
   The rules correctly retain a creature's blocking status after its attacker
   leaves combat, but that historical link was being serialized as a live card.
   A returned/shuffled attacker could reacquire a private-zone handle; a token
   that ceased to exist could produce a null reference. The network view now
   keeps the public blocking status with an empty target when no attackers
   remain, and sends only current attackers for multi-blocks. The renderer maps
   that empty target to -1, not a new card. The stricter validator explicitly
   permits this absent block target while rejecting other missing card links.
   No change to the rules engine's combat bookkeeping was needed.

## Stalled-command recovery

A pending action that receives no complete acknowledgement/snapshot pair for
15 seconds on an established connection now triggers reconnection. The original
message and sequence are retained, so the referee returns the recorded outcome
instead of executing the action again. The initial resumed snapshot still gates
input; an acknowledgement alone or a welcome alone cannot release it.

This is an action-response watchdog, not a player turn clock or a replacement for
the existing transport heartbeat, handshake timeout and disconnected-seat grace.
It neither forfeits a slow player's decision nor persists a game across host
shutdown. Five-minute occupied-seat and 30-second roomless disconnect grace
periods remain unchanged.

Both players need the updated build. The wire protocol remains version 6, while
the maintained compatibility revision is `sgmanalink-2026-09-14-2`. It detects
incompatible builds, not executable tampering or verified player identity.

## Verification

The six focused reproductions failed before the fixes (13 assertion failures)
and passed afterward (45 assertions). Three further real-socket regressions
cover stalled-result replay, delayed refusal delivery and rejection of a
malformed host snapshot without installing it.

The additional departed-attacker reproduction failed seven assertions before its
fix. Coverage now also checks return-to-hand and library moves, both seat views,
blocker status in the shared renderer, multiple blocks and a vanished token.
The focused twelve-test gate passed 104 assertions before the returned-attacker
case was further extended to cross both real client sockets in the final gate.

The expanded online suite passed **90/90 tests, 7,538 assertions**, eight scripts,
89.242 seconds, wrapper exit 0. Timing and assertion counts can vary with the
bounded socket-driving loops; the tests assert completed outcomes and privacy.

Deterministic work-count checks show twelve duplicate commands in one batch
producing **one** full snapshot instead of twelve, and a roomless departure
causing **zero** additional duel-view builds instead of two for its unrelated
two-seat fixture. These are workload reductions, not frame-rate measurements.

The final full-project gate, including all twelve new regressions, passed
**6,388/6,388 tests, 240,260 assertions**, 375 scripts, 308.281 seconds, wrapper
exit 0. The earlier run before the combat fix also passed (6,385 tests); the
final gate supersedes it. The test harness's existing warnings/deprecations
remain; there were no script/runtime errors and no skipped or risky tests.

The final four-round network soak completed **1,298 commands** (318, 283, 368
and 329 per match), with delayed processing, duplicate sends, repeated seat
reconnections and session reuse across rematches. It passed **3,964 assertions**
in 82.441 seconds, wrapper exit 0. The driver alternates the shipped White Knights
and Black/Red Raiders lists; it tests transport/gameplay continuity, not optimal
deck strategy.

Offline seed 4242 also finished all **four duels** through the live interface
logic, using the isolated headless profile: demo plus human-seat under Fifth
Edition and modern rules. Fifth Edition finished in 19/12 turns (82 human
clicks); modern finished in 17/13 turns (93 human clicks). Both wrappers exited
0 with no error, warning or stall lines, matching the previous baseline's
outcomes, turns, final life and click counts.

Commands and physical-LAN playtest instructions are in
[the LAN guide](sgmanalink-local-playtest.md).

Two-computer Wi-Fi/firewall checks and native Windows/Linux runtime playtests
remain important. Local socket tests do not certify those environments. As
before, a player operating the host can inspect its full engine state; filtered
client views and TLS do not make it a trusted ranked referee.

This pass remains local on `sgmanalink`. No commit, push, release export or
public asset replacement was performed; earlier local work remains intact.
