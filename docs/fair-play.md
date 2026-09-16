# Strong play. Fair information.

ShandalarGodot's four standard computer opponents are designed to win by playing better,
not by knowing your secrets. **No hidden-hand peeking. No knowledge of
future draws. No extra mana, free spells or special combat rules.**

This is a design requirement at every standard difficulty, not an optional setting.
A Wizard gets more analysis and fewer deliberate mistakes—not more access
to your cards.

## What the standard opponent can know

- Its own hand and registered deck: the cards it brought, their mana curve,
  colours, strategic roles and potential synergies.
- Public play: the battlefield, visible graveyards and exile, the stack,
  targets, life totals, available mana, hand sizes and library sizes.
- Information a card effect actually permits it to see. A revealed card is
  not a secret while it is revealed; a tutor may examine its legal choices.

It does not use your unrevealed hand, a face-down creature's hidden printed
identity, either library's secret order, or the random generator's state to
choose a play. Open mana is a public threat; it is not proof that you hold
a particular counterspell or combat trick. Mana that lives IN a hand
(Elvish Spirit Guide's "exile this card from your hand: add {G}") is part
of that hand: the computer's count of what you can pay — a blocking tax, a
spell tax, the mana a counter must beat — takes only the Guides you have
revealed, while the rules themselves still let you exile a hidden one.

The game's existing **card-naming menus** use registered decklists for both
human and computer players. That shared naming rule is not a peek into the
current hand. Naming hints count permitted information and leave unseen
cards uncertain. The strategic deck study itself reads only its own list.

## Preparation, not clairvoyance

Before its first decision, the computer studies its own deck. Fast creature
pressure, burn, control, ramp into large creatures, land denial, tempo,
attrition and milling can coexist in the same list. Familiar effect pairs
can suggest synergies, but finding both pieces in a deck does not mean
either is in hand—or that a combo is executable now.

The stronger profiles use that preparation when comparing useful spells
and tutor choices. They still check the actual board, targets and mana.
Survival and a win available now take priority over the deck's general plan.

Combat analysis compares teams and complete blocking assignments: who dies,
who survives, what damage gets through, and whether enough defenders remain
for a dangerous counterattack. A known, affordable pump spell can improve
one exchange; one card is not counted as a trick for every creature.

## A promise backed by tests

Regression tests replace hidden cards while holding permitted information
constant. Observations, evaluation, targets, X values, combat choices and
saved-plan reuse must remain unchanged. Public changes and actual reveals
must be able to change the answer. Tests also check that speculative study
leaves the real game and its random stream untouched.

The computer submits plays through the same rules APIs as the human player.
The rules engine can refuse its casts, payments, attacks and blocks too.

These tests are safeguards, not a claim of a formal proof of every future
card interaction. The player remains a bounded, fallible opponent. Complex
abilities retain specialised policies, and broad search is deliberately
limited so the same design works on desktop and web. An information leak
in a standard opponent is a bug to fix—not a difficulty feature to defend.

## Separate challenge: Unfair — sees your hand

This opt-in control is separate from Apprentice, Magician, Sorcerer and
Wizard, and is off on a fresh installation. It uses all Wizard capabilities
plus the opponent's **current hand**. It can bait a known payable counter,
hold extra creatures against a known payable sweeper, and study bounded
single-pump combat responses. Knowing a card does not force its owner to use it.

It still cannot inspect secret library order, future draws, the random
generator's state or a face-down permanent's hidden identity. It gets no
extra mana, free cards or rule exceptions. It does not globally reveal
either hand, and it does not retain identities after cards leave the hand.

The chosen challenge is remembered by setup, clearly displayed during the
duel, and carried between games. It sits under **Challenge modifier**, not
among the four difficulties. Enabling it visibly locks Wizard; unchecking it
restores your previous fair level, even after reopening setup. The choice
applies when starting a game, never silently during play.
Deck Lab accepts the explicit `unfair` challenge token; those runs
are labeled, never update Elo, and cannot participate in fair profile sweeps.

For implementation limits and reproducible measurements, see
[the planning study](planning-study-2026-09-13.md).
