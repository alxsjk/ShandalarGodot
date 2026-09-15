# SGManalink — lobby polish and robustness, 2026-09-15

Scope: another review of the desktop LAN lifecycle and the Identity, Host Game,
Game Browser, waiting-room and deck-selection interfaces. The preceding visual
parity work remains intact on `sgmanalink`. No public service, account provider,
ranking, Internet discovery or gameplay rules change is included.

## Reproduced problems and corrections

The first six-case gate passed one case and failed five. The connection-refusal
case printed `Cannot call method 'get_available_packet_count' on a null value.`
The client's refusal subscriber had disconnected, but the rest of the old
snapshot handler set the client online again and continued reading its forgotten
socket. The reader now checks that the same connection is still active after
callbacks before continuing. The separate fatal-response-plus-queued-state probe
already passed before changes; it is retained as a regression guard, not claimed
as another reproduced bug.

A later callback audit reproduced two related cases: cancelling from the
connecting notification dereferenced a null socket in `connect_to_url`, and
reconnecting from a loss notification created two replacement sockets. The
attempt is now initialized before notifying listeners, and polling stops if
the loss callback has cancelled or replaced its connection. Both regressions
failed before the fix in the expanded fourteen-case gate.

Other initial failures covered:

- Repeated waiting-room snapshots destroyed/recreated all rows and controls.
  A bounded display snapshot now keeps unchanged rows stable; busy updates only
  change command availability, preserving focus and scroll placement.
- The deck chooser stayed open after its room disappeared. It is now bound to
  its originating room and closes on departure, replacement or duel start.
- Escape inside the chooser began closing the entire visit. It now closes only
  the topmost deck chooser, leaving the room intact.
- Searching away from a chosen deck left that invisible result submit-ready.
  Search changes now clear selection and give an explicit empty-results message.

An additional test reproduced identity controls remaining editable while the
initial connection was in progress. Connecting is now an explicit client state
used to lock identity/connection controls and expose a way to disconnect the
attempt. Identity Cancel also restores the remember-name choice, not just text.

Deck submission now waits for the host's acknowledged snapshot before closing
the chooser. A refused or interrupted submission retains the selected deck and
explains its state; an acknowledgement alone cannot falsely confirm a deck.
The chooser refits when its viewport changes. These paths are checked through
real local sockets, including held-back snapshots and refused deck submissions.

## Presentation

`SgLobbyStyle` shares the existing original fonts, stone buttons and green
vector globe. A dark stone outer frame, calm parchment sections, restrained
gold accents, consistent text fields and compact primary/secondary actions
replace the large undifferentiated sandstone form. No new artwork downloads,
image packs, native OS dialogs or platform-specific UI code are required.

The overview gives general guidance rather than repeating the top navigation:
same-build/LAN prerequisites, separate host/join instructions, Ready flow and
temporary-name/referee boundaries. Identity, hosting and joining remain in the
top tabs. The waiting room gives each player a separate panel with name, deck
and explicit ready or connection status. The browser separates discovery from the private invitation
field, with useful empty states. The deck chooser keeps the searchable catalogue
and complete selected list side by side. Less-used same-computer settings are
collapsed. Long content scrolls inside a bounded window; navigation and notices
remain outside that scroll area. Focused controls retain dark, readable text.

Menus open no sockets automatically. The invitation remains masked and is only
copied at the player's request. Temporary names are not authenticated identities;
the trusted host still owns the full referee state. Opposing hidden cards are
not added to any menu. The duel screen and its visual parity corrections remain
shared with offline play.

## Verification and remaining scope

Native source-scene captures use the isolated test profile and existing skin.
All six menus were rendered at 1280×800; Host Game, waiting room and deck chooser
were also rendered at 960×600 with the game's normal viewport scaling. Separate
layout tests exercise actual logical viewports of 960×600, 800×540 and 640×480.
Overview and deck chooser fallback captures force only the relevant skin-cache
entries to use the normal built-in styles/fonts in a disposable process; no
assets or player settings are moved or changed. These capture runs all exited 0
with fresh PNG confirmations and no error, warning or leaked-object lines.

The first full run passed 6,409 of 6,410 tests; the remaining title-screen
assertion still expected the replaced "not available yet" wording. It now
checks the explicit Internet-discovery/MElo future-feature statement. The
initial online-only aggregate also caught a narrow Port label wrapping by
letter; fixed address/port captions do not wrap. These failures were corrected
before the final full gate, rather than omitted from its selection.

The room and deck examples are staged menu states, not a physical two-computer
session. Automated socket checks do not replace mixed Linux/macOS/Windows LAN,
Wi-Fi/firewall and long-session playtests. Exported binaries and the public
release are not replaced by this pass. Final gate results are recorded below.

- Focused lobby/callback gate: **14 tests, 91 assertions, 2.855 seconds**,
  wrapper exit **0**. The separate title-screen activation test passed its
  **15 assertions**, wrapper exit **0**.
- Final full GUT gate: **6,412 tests, 241,829 assertions, 377 scripts,
  341.352 seconds**, wrapper exit **0**. The existing one warning and two
  deprecation counts remain; the wrapper found no error or leaked-object lines.
- The full gate used `SGMANALINK_SOAK_ROUNDS=4`: all four varied-deck rounds
  completed, in **306, 341, 323 and 274 commands** (**1,244 total**), including
  delayed processing, duplicate commands and repeated seat reconnects.
- Four renderer-free offline UI duels completed with seed **4242**, both wrappers
  exiting **0** without error, warning or stall lines. Fifth Edition: demo
  **19 turns**, human-seat **12 turns / 82 clicks**. Modern: demo **17 turns**,
  human-seat **13 turns / 93 clicks**. These exercise the live screen controls,
  not native rendering; the native captures above cover menu appearance.
- `git diff --check` passed. Added tracked-content candidates were checked for
  personal paths, private contact details and tool attribution. Disposable
  capture scripts were removed; verification images and logs remain outside
  the game repository. All work remains local on `sgmanalink`.

### Overview guidance follow-up

Removed the three shortcut cards that duplicated Identity, Host Game and Game
Browser. Overview now explains desktop LAN support, matching builds, optional
names, hosting versus joining, deck readiness and host trust. Top navigation
is unchanged; the connected visit's Disconnect action remains available.

The follow-up passed **48 focused tests / 516 assertions** across the interface,
lobby-polish and title-screen scripts, each wrapper exiting **0**. The new
regression prohibits buttons inside the Overview content, checks the guidance
and exercises label containment at 1280×800, 960×600 and 640×480 logical sizes.
Fresh native source-scene captures were inspected with the original skin at
1280×800 and 960×600, and with built-in fallback styling at 1280×800. The
fallback retains scrolling for its taller font metrics. All capture wrappers
exited **0** with fresh PNG confirmations and no error/warning/leak lines.

This follow-up changes only Overview content/layout and its tests/docs; the
full-suite and duel-soak results above precede it. No transport, rules, saved
settings, build exports or public release changes were made.
