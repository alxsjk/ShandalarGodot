# Strong play. Fair information.

ShandalarGodot's computer opponent is designed to win by playing better,
not by knowing your secrets. **No hidden-hand peeking. No knowledge of
future draws. No extra mana, free spells or special combat rules.**

This is a design requirement at every difficulty, not an optional setting.
A Wizard gets more analysis and fewer deliberate mistakes—not more access
to your cards.

## What the opponent can know

- Its own hand and registered deck: the cards it brought, their mana curve,
  colours, strategic roles and potential synergies.
- Public play: the battlefield, visible graveyards and exile, the stack,
  targets, life totals, available mana, hand sizes and library sizes.
- Information a card effect actually permits it to see. A revealed card is
  not a secret while it is revealed; a tutor may examine its legal choices.

It does not use your unrevealed hand, a face-down creature's hidden printed
identity, either library's secret order, or the random generator's state to
choose a play. Open mana is a public threat; it is not proof that you hold
a particular counterspell or combat trick.

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
is a bug to fix—not a difficulty feature to defend.

For implementation limits and reproducible measurements, see
[the planning study](planning-study-2026-09-13.md).
