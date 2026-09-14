# ShandalarGodot

<p align="center">
  <img src="branding/logo-360.png" alt="ShandalarGodot" width="240">
</p>

> This project is a love letter to MicroProse MTG: to preserve that special
> 90s Shandalar feeling — the feel of playing early Magic, up to Fourth
> Edition, Alliances, and maybe Fifth — while still going for
> quality-of-life improvements, a modern spin on the gameplay, and the
> tools to go with it.
>
> The key is in the limitations. A specific, finite spell library is
> something you can get creative with, instead of losing time to an
> ever-widening card pool and its obsolescence. It can be fun, it can be
> creative, and — would you believe it? — it can even be relaxing. :)
>
> All the best to the players, and to the community for its help with the
> development. Good luck and good health to all!
>
> — b0realis

An open-source, from-scratch remake of MicroProse's 1997 *Magic: The
Gathering*, built in GDScript with Godot. Early Magic, a modern rules
engine, and the freedom to keep the game alive.

## Play — 0.20.0

**Our first comfortably playable release for duels and deck building is out.**

[Download Shandalar 0.20.0](https://github.com/b0realis/ShandalarGodot/releases/tag/v0.20.0)
for **Windows, Linux, macOS or web**. The release page has launch
instructions, standalone and original-skin packages, and SHA-256 checksums.

Play with an **897-card early-Magic pool**, historic decks, four computer
opponents, local hotseat, Gauntlet, sealed decks and best-of matches with
sideboarding. The Deck Builder supports large cards, live filters and
keyboard browsing. Adventure and online multiplayer are still to come.

## Philosophy

**The limitation is the feature.** Preserve the finite early-Magic pool
and the 1997 feeling. Optional additions should leave that core intact.

**Port, don't invent.** The original game's decisions guide the remake;
quality-of-life changes and rules simplifications are explicit. The
[source history](Provenance.md) and [fidelity ledger](docs/simplified-cards.md)
keep those choices open to inspection.

**Strong play. Fair information.** Apprentice, Magician, Sorcerer and Wizard
are **non-cheating** opponents. They study their own deck, plan spells and
mana, and analyse combat without reading your hidden hand, secret library
order or future draws. Stronger difficulty means stronger analysis, never
free resources or special rules. See the [fair-play contract](docs/fair-play.md).

The separate, opt-in **Unfair — sees your hand** challenge gives Wizard
knowledge of your current hand. It is off by default, unrated, and not a
fifth standard difficulty; it still gets no future draws or rule exceptions.

**Open and testable.** The rules engine runs without graphics, every card
has its own documented implementation, and changes are checked through
regression tests and reproducible simulations. Godot keeps the project
independent and the source accessible.

## Art and skins

The game is playable with its built-in appearance. Choose a `-with-skin`
release for the original look and sounds, or add `original_skin.zip`
separately. Import packs through **Options → Skin**; on desktop they can
also live in `skin/` beside the game.

**Card pictures are not included in the repository or release downloads.**
Use your own `cardart.zip`, or build one for personal use with Python 3:

```sh
python3 tools/fetch_card_art.py --out assets/cardart/
python3 tools/mtg_assets.py --from-cardart assets/cardart/ --out cardart.zip
```

To rebuild the original skin from your own game installation:

```sh
python3 tools/mtg_assets.py --install /path/to/game
```

The importer reads your installation without changing it. See the
[player-files guide](docs/player-files.md) for pack locations and the
[skin catalogue](docs/skin-catalogue.txt) for creating your own skin.
Card pictures stay personal—do not include them in a public web build.

## DeckLab CLI

The desktop releases include a headless deck-analysis tool: run
computer-versus-computer duels in parallel, compare matchups or gauntlets,
and study win rates, confidence intervals, charts and CSV/JSON reports.
Seeded runs make it useful for experimenting with decks and comparing ideas.

Run `./deck_lab.sh --help` on Linux/macOS or `.\deck_lab.bat --help`
on Windows. `--procs` and `--jobs` control parallel workers;
`--no-elo` keeps experiments out of the ratings ledger.
The [DeckLab manual](DeckLab/README.md) has examples and all options.

## Future roadmap

Planned features, not part of 0.20.0:

- [ ] **Adventure** — the Shandalar world, quests and campaign.
- [ ] **Manalink** — first, browse, host and join individual online duels;
  later, host complete tournaments, including booster opening and drafting.
- [ ] **Commander mode** — dedicated rules and deck-building support.
- [ ] **Cardpacks** — optional card-set expansions, separate from the core pool.
- [ ] **Community MElo (Magic Elo)** — a big long-term wish: a simple,
  elegant global player rating and ranking system for the community. :)

Experienced multiplayer, networking and backend developers are especially
welcome to help bring Manalink, tournaments and community rankings to life.

See the [development roadmap](docs/ROADMAP.md#major-features-for-the-future)
for the longer record.

## Build and contribute

Use **Godot 4.7.2** for source development; export templates are needed to
build releases. Start with [DEVELOPMENT.md](DEVELOPMENT.md) and
[CONTRIBUTING.md](CONTRIBUTING.md) for setup and the test workflow.

```sh
godot -e --path .
./run_tests.sh
```

Explore the [architecture](docs/ARCHITECTURE.md),
[code map](docs/CODE_MAP.md), [card-authoring guide](docs/adding-cards.md)
and [cross-platform build guide](docs/release-builds.md).
Bug reports are welcome—include your platform, version, decks and duel seed
when possible.

## Thanks

Thank you to **Godot and GUT**, **MicroProse**, the **Shandalar and Manalink
community**, **[SlightlyMagic](https://www.slightlymagic.net/)** and **The Dojo**;
to **Ben Prew** and the [s30](https://github.com/benprew/s30),
[mage-go](https://github.com/benprew/mage-go) and
[mp_pic_tools](https://github.com/benprew/mp_pic_tools) contributors;
to [Forge](https://github.com/Card-Forge/forge), Scryfall, the artists, and
everyone who tested, documented or preserved this game.

Have fun, build something unexpected, and enjoy the duels.
**All the best, good luck and good health to every player!**

## Licence

Code and project-created assets: **[GPL-3.0](LICENSE)**.
Third-party components and fonts retain their own licences; see the
[asset inventory](game/art/README.md) and [provenance](Provenance.md).

## Legal

*Magic: The Gathering* is a trademark of Wizards of the Coast LLC.
This is an unaffiliated, non-commercial fan project. The original skin and
card pictures are separate from the source-code licence and remain the
property of their respective owners.
