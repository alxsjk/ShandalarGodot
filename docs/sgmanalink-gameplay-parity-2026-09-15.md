# SGManalink LAN gameplay review — 2026-09-15

Scope: the current two-player LAN duel, compared with the local single duel.
No Internet hosting, account service, MElo or tournament work is included.

## Match introduction

Before the coin toss, each player sees an explicit **Continue** window on the
same classical ground as the local opening-hand/ante window. It shows both
temporary player names, public deck names and deck-colour portraits, plus
**Unrated friendly duel**, **No ante**, **Unrestricted**, 20 starting life and
the seven rule switches received from the referee. Rule explanations contain
player-facing facts only. It does not infer an archetype from an opposing deck
list, reveal cards or claim authenticated identities/ranked play.

The screen waits for its reader; there is no automatic five-second dismissal.
Leave duel still requires confirmation and cannot navigate into offline setup.
Duplicate snapshots and reconnects preserve the current introduction. An already
active/finished duel is restored directly, and a concession while reading cannot
start a fresh opening window over the result. The introduction is once per new
duel, not every turn.

The local duel's opening shuffle sound is restored, once only. A finished
snapshot received while the introduction is open preserves the previous painted
life total for the result countdown; dismissing that introduction cannot refresh
it away first. Both boundaries have failing-before/fixed-after regressions.

The match information remains beside the player's actual opening hand while
choosing play/draw or taking mulligans. Previously, this no-ante flow displayed
two unexplained card backs in the ante positions. A regression reproduced both
visible backs before the replacement. Offline ante cards, stakes and the shared
opening-hand placement are unchanged.

## Gameplay boundary checked

The client still subclasses the actual `DuelScreen`; the host still executes
the same `MtgGame`, registered cards and human decisions as a local duel.
There is no second network-only implementation of card resolution.

| Area | LAN path and verification |
| --- | --- |
| Decks and opening | Full registered pool and complete deck lists; referee-owned shuffle/toss, play/draw, successive smaller mulligans, opening hand and zero-card keep. |
| Casting and mana | Shared clicks/double-clicks, host-authorized modes, X, target tokens, divided damage, manual/automatic payment, reserved mana sources, cost modifiers and mana-source questions. |
| Combat | Shared attack/block selection, bands, multiple blockers, damage division, markers, arrows, actual public power/toughness and phase instructions. |
| Abilities and questions | Host live ability lists (not just printed abilities), private searches, resolution/cost questions, cancellation and special actions. |
| Information | Detached filtered views; unknown opposing hands/libraries, explicitly authorized reveals, public spell chain and seat-filtered log. |
| Presentation | Existing full-size cards, hand styles/placement, deck colours, aura/reminder layers, card movement, sounds, phase stops and result window. |
| Recovery | Real TLS clients, exactly-once commands, delayed snapshots, duplicate sends, lost acknowledgements, reconnects and restored combat layout. |

New focused checks exercise mana-burn life loss and its original sound exactly
once for both seats, Kormus Bell's animated lands, Aswan Jaguar's empty-library
reminder and Circle of Protection targeting actual damage markers. Existing
full-pool, shared-interface and network recovery tests cover the surrounding
mechanics. This is representative automated coverage, not a proof that every
possible card interaction or user gesture is omission-free.

## Intentional current differences

- Each client places its own player below and its opponent above. Private cards
  never become visible merely because priority changes.
- LAN room rules are fixed for this milestone: Unrestricted, 20 life, mana burn
  and free combat-damage assignment on; the other switches use the advertised
  referee defaults. Local saved rule preferences cannot silently change a room.
- No ante, match series, sideboarding between games, tournament progression,
  ranking or verified accounts. These are future match/session features, not
  missing implementations of otherwise playable cards.
- Menus stop the viewer's automatic passing, not their opponent's play.
  Disconnects suspend game actions. The Online control carries connection
  information without replacing combat/phase instructions.
- The hosting player operates a trusted referee containing the full game.
  Filtering protects what a client receives; it is not ranked-host anti-cheat.

## Verification record

The final focused visual/opening script passes **14 tests / 151 assertions**,
and the shared-interface script passes **21 tests / 360 assertions**, both with
wrapper exit 0. Regressions were observed before fixing the ante placeholders,
opening shuffle cue and finished-snapshot refresh order.

Native macOS Godot captures show the actual widgets with the original skin at
1280×800, the opening hand at 960×600 and fallback dialog grounds at 960×600.
These are staged new-match fixtures, not a physical two-computer session. All
three final captures saved fresh viewport images and exited 0 without errors or
leaks. The first opening capture's frame-only wait did not outlast the configured
video; the corrected capture uses the instant coin setting and a bounded wait.
This is capture setup, not a claimed game-animation fix.

An additional six-game TLS sample (seeds 4250–4252, baseline/fault pairs) finished
**2,682 commands**, 88 spell submissions, 32 duplicate sends and 15 lost-ACK
reconnects with identical public transcripts and no referee refusals. Its full
suite run was **not green**: 6,427/6,428 tests passed, with the sole failure the
extended campaign's coverage requirement for interactive combat division. Those
particular draws never reached a division, despite completing every game.
The guaranteed damage/private-search socket scenarios passed. The coverage gate
was retained unchanged; the established seeds were rerun for final acceptance.

That established twelve-game campaign (4242–4247) passed again with **6,484
commands**, 252 spell submissions, 36 blockers, two interactive damage answers,
74 duplicate sends and 37 lost-ACK reconnects. All baseline/fault transcripts
matched; no refusal, unfinished duel or client divergence occurred.

The final full-project gate passed **6,428/6,428 tests / 305,264 assertions /
379 scripts** in 576.67 seconds, wrapper exit **0**, including that twelve-game
campaign and the actual GUI/discovery/recovery tests. No skipped/risky scripts,
runtime errors or exit-time leaks were accepted. The harness's existing one
warning and two deprecations remain unchanged.

Offline live-interface logic completed four more duels, seed 4242, wrapper
exit 0 for both rules runs: classic demo/human-seat games took 19/12 turns
(82 human gestures), modern took 17/13 (93 gestures). No stalls, warnings or
errors occurred, and outcomes/turns match the previous baseline.

No wire schema, engine/card behavior or standard player policy changed. Protocol
7 and the existing rules fingerprint remain compatible. Tests/captures use the
isolated test profile, not players' saved decks or presentation preferences.

Matching local Linux x86-64 and universal macOS development builds were exported
using the existing desktop-template policy. The Mac app passed headless startup
and strict ad-hoc signature verification; its temporary smoke-profile override
was removed. The Linux game pack loaded cleanly under the Mac editor runtime
from the export folder, using absolute paths and an isolated profile. This does
**not** certify native Linux execution. Both ZIP integrity checks passed; the
archives contain the app or executable/PCK, plus LAN instructions, with checksums
beside them. Existing art/skin packs are reused, not repackaged. No old build,
public release, GitHub branch or player profile was overwritten.

## Physical LAN playtest

Use matching development builds on both computers. Start with full shipped
decks, then custom decks. Test both host roles and both toss results; read and
dismiss the introduction independently, redraw a hand, play targets/responses,
gang-block and assign damage, use private searches, reconnect during a decision,
and finish or concede. Verify the other hand stays private throughout.

Automated sockets on one Mac do not certify two-computer routing, Wi-Fi,
firewall permissions or Linux/Windows native behavior. That remains the next
manual check. See [LAN instructions](sgmanalink-local-playtest.md) and the
[repeatable network campaign](sgmanalink-network-campaign.md).
