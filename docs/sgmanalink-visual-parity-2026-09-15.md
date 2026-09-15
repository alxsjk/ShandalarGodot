# SGManalink visual parity review — 2026-09-15

Scope: compare online play with the existing local duel screen and correct
presentation differences. Work is on `sgmanalink`; no release replacement,
new account service or rules-engine change is included.

## Shared foundation and corrections

Online play already subclasses `DuelScreen`. Battlefield rows, large card
preview, land/aura piles, life/mana registers, hand styles, phase/combat bars,
target arrows, damage markers, spell chain, card flights and opening/result
windows use the actual local widgets. The review found adapter-level differences:

- **Deck palette:** hard-coded blue/red online territories differed from the
  local deck-based colours. The referee now computes the same dominant colour
  once at match creation. It sends one public cosmetic string per player,
  validated against the five supported colours. No opposing deck list, hidden
  draw or remote resource path is sent for this purpose. Both seat orientations
  map correctly, and later hand/library changes cannot change this value.
- **Phase instructions:** every pending acknowledgement previously replaced
  the situation bar with a transport wait message. Sending, reconnecting and
  suspended states now live on the Online control and its tooltip; phase,
  combat and targeting instructions remain readable. Actions stay locked until
  their confirmed snapshot arrives. Connection details update while open and
  distinguish a missing opponent from restoration of the viewer's own seat.
- **Button style:** Online now wears the duel's stone button chrome instead
  of main-menu gold. Existing controls and the large card retain their space.
- **Opening stability:** unchanged answer buttons and hand cards are reused
  across snapshots instead of being rebuilt for every busy/readiness update.
  Actual question/hand changes still rebuild; disabled state remains current.
- **Defeat presentation:** the result handler now receives the previously
  painted life total before refresh overwrites it, restoring the shared death
  countdown. Duplicate snapshots cannot restart it. A first snapshot of an
  already-finished duel does not invent a previous life total.
- **Restored combat layout:** a first snapshot already in combat could fit its
  window against the not-yet-laid-out screen, hiding the title behind the large
  card. The online adapter now refits on deferred board resize notifications,
  without rebuilding combat cards or changing the phase instruction. The
  regression reproduces both initial layout and a subsequent window resize.

The wire protocol is **7**, with compatibility revision
`sgmanalink-2026-09-15-1`. Both players need this development build. Existing
skins/card art remain usable; this review does not export new binaries.

## Verification

Five initial regression cases reproduced the pre-fix differences. The expanded
tests cover palette validation/privacy, both seat orientations, busy/disconnected
combat instructions, stable opening buttons, live connection details, result
ordering and initially finished snapshots. The additional restored-combat test
failed four geometry assertions before the fix; all ten focused tests now pass
with 97 assertions, wrapper exit 0.

Matched fixtures were rendered by native macOS Godot 4.7.2/OpenGL with the
existing original skin and local card art at **1280×800** and **960×600**.
These are staged states using the real local/online widgets, not screenshots
of a user's current duel or a two-computer session. Both use a **300×428**
large preview in logical canvas coordinates; the smaller window scales that
same layout. Checks include the normal table, a blocked command during combat,
connection details, opening hand and a live defeat countdown.

An RGB pixel comparison of the matched normal-table captures found differences
only inside the extra Online button: bounds `(4, 600, 109, 630)` at 1280×800
and `(3, 450, 82, 472)` at 960×600. Every pixel outside those bounds matched.
This is evidence for these matched fixtures, not every possible game state.

Capture runs use a separate test profile and explicit silent-audio cleanup.
An early dummy-audio capture left playback objects at shutdown; the corrected
fixture stops its playback before capture teardown. This is not a claimed
production audio fix. Final captures require exit 0, a saved-viewport marker
and no error/leak lines.

Final full-project GUT gate: **6,398/6,398 tests, 239,942 assertions, 376
scripts**, 311.801 seconds, wrapper exit **0**. This supersedes the earlier
6,397-test run before the final combat-layout correction. The final run includes
the ten new tests and the two-round varied-deck socket soak, which finished in
325 and 242 commands with delayed processing, duplicates and reconnects.
Bounded socket loops can change assertion/work counts between runs. The
harness's existing one warning and two deprecations remain; the wrapper found
no script/runtime errors, skipped/risky tests or exit-time leaked objects.

Offline live-interface logic also completed **four duels**, seed 4242, in the
isolated headless profile: demo/human-seat finished in 19/12 turns under Fifth
Edition (82 human clicks) and 17/13 turns under modern rules (93 clicks).
Both soak wrappers exited **0**, with no error, warning or stall lines; outcomes,
turns, life totals and click counts match the previous robustness baseline.

Disposable capture scripts were removed; screenshots and logs remain outside
the source tree. No commit, push or release export was performed.

## Deliberate differences and next steps

The viewer's seat is always below, with an opponent's hidden hand represented
only by its count unless a card rule authorizes a reveal. The Online control
is an additional session control, not a replacement for a phase instruction.
Games remain friendly, unrated and player-hosted: the operator of the referee
can inspect its state. Client filtering is not ranked-host anti-cheat.

Recommended next work, in order:

1. Play several full-deck duels between two physical computers using matching
   builds, testing both host roles, mixed operating systems, reconnect during
   combat and private searches. Local socket tests do not certify Wi-Fi,
   firewalls or native Linux/Windows behavior.
2. Exercise visible connection states under delayed/lost responses and crowded
   boards at several window sizes; retain an automated screenshot baseline.
3. Add explicit public portrait/palette choices, then best-of-three rematches
   and sideboarding using the existing local match presentation. Keep public
   Internet discovery, tournament hosting and MElo as separately reviewed work.
