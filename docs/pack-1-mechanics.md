# Pack 1 mechanics audit

`Pack-1-DotP-complete.zip` adds 373 named set entries. Of those, 369 are
reprints of cards already implemented in the core, so they introduce no new
rules identities or mechanics. The audit therefore has exactly four cards.

The project rule is simple: reusable digital behavior belongs in `engine/`
and is exposed to `EffectIntent`, while every difference from the printed card
is marked `SIMPLIFIED:` in its card file and recorded in
`docs/simplified-cards.md`. A pack being optional does not relax that rule.

| Card | Printed mechanism | Decision | Engine support | AI behavior |
|---|---|---|---|---|
| Chaos Orb | Physical one-foot flip, complete turn-over check, spatial collision with any number of nontoken permanents | **Simplified intentionally:** flip a coin; on a win destroy one uniformly random opposing nontoken permanent. The source-presence condition and self-destruction after either result remain | `RandomDestroyEffect`, backed by the shared seeded coin flip and `RandomEffects.sample` | Prices the average of the real candidate pool at 50%, not its best member as certain, and subtracts the Orb's own destruction |
| Falling Star | Physical one-foot flip and spatial collision with creatures | **Simplified intentionally:** choose one or two creatures, then flip independently for each; two is the bounded digital footprint | `CoinFlipDamageEffect` uses the shared coin log/RNG and damage/tap mutation paths | Ranks profitable opposing creatures, takes at most two, and prices each at half its hit payoff |
| Shahrazad | A complete nested Magic subgame using the libraries as decks | **Simplified:** one coin flip; the loser loses half their life rounded up | `CoinFlipLifeLossEffect` calculates the printed rounding and uses the shared life mutation path | Computes the expected life-position swing, refuses a zero-sum wager at equal life, and recognizes a lethal half-life result |
| Word of Command | Look at a hand, control the opponent while they play the chosen card, restrict mana abilities, then possibly control that spell while it resolves | **Simplified:** reveal eligible nonlands, choose one, discard it | `ChosenDiscardEffect` routes the choice through `DecisionAgent` and the shared discard path | Uses only public hand size when deciding to cast, waits against an empty hand, then chooses the most valuable eligible card after the reveal |

The four shared effects are deliberately card-name-free. Later packs can use
them without another AI special case, and `EffectIntent` classifies all four
structurally. Their stochastic decisions use `MtgGame.rng`, so tests, duel
logs and bug reports remain seed-reproducible.

Chaos Orb and Falling Star should stay simplified: mouse gestures or simulated
screen geometry would be neither a faithful tabletop dexterity test nor an
accessible deterministic game rule. Shahrazad and Word of Command may be
lifted later, but only as engine-sized projects: re-entrant subgames for the
former; temporary control of another seat, nested casting, restricted mana
and spell-controller handoff for the latter. Until then the fidelity ledger is
the authoritative list, not a promise hidden in implementation comments.

## Balance check

The first draft made Chaos Orb's random destruction certain and let Falling
Star name every profitable opposing creature. Both remove the physical cards'
uncertainty or footprint and were substantially stronger than intended. The
shipping adaptation therefore gates the Orb's destruction behind a 50% coin
flip and caps the Star at two targets. Tests pin both coin outcomes, the Orb's
self-destruction on a loss, rejection of a third Star target, and the AI's
50% valuation and two-best-target choice. All randomness uses the duel seed.
