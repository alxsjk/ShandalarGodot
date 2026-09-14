PACK 1 — DOTP COMPLETE

Pack-1-DotP-complete.zip completes the eight card groups represented by
ShandalarGodot's set badges. It carries the full published checklist for
each group, including cards reprinted in more than one set.

Pack 1 itself adds 373 named set entries: 369 cross-set reprints plus four
new rules identities. The enabled pool therefore reports 1,270 set entries
across the eight checklists, representing 901 unique rules identities. Reprints
still share one deck entry and the same name-based copy count. The pack catalog
also records all 1,305 published collector slots; the remaining 35 slots are
alternate-art printings of the same name inside the same set.

Four distinct cards are absent from the default 897-card pool because
their printed procedures require dexterity, a subgame, or control of
another player. Pack 1 supplies bounded digital adaptations:

  Chaos Orb       first flips a coin, then may destroy one random permanent.
  Falling Star    flips once for each of one or two chosen creatures.
  Shahrazad       resolves its half-life result with a coin flip.
  Word of Command becomes a targeted nonland discard choice.

Every adapted card says "Digital adaptation" in its displayed rules text.
The exact deviations, reusable engine mechanics, and AI policies are recorded
in docs/pack-1-mechanics.md and docs/simplified-cards.md in the source tree.
The manifest records pack version, minimum game version, SHA-256 hashes for
the metadata, and one deterministic SHA-256 over all artwork. The game refuses
a corrupt or incompatible file and explains why under Options > Card Packs.
The finished ZIP carries an art crop and a full-card scan for every one of
its 373 set entries. Set-specific files live in the pack's own catalog;
the four new identities are also exposed through skin/cardart/ so the game
can display them immediately. The fetch-art command keeps downloads in the
sibling shandalar-packs cache, never in git.

The finished ZIP is a local gameplay artifact and is not distributed in a
ShandalarGodot release. The source repository distributes this construction
tool and its inputs instead.

Build or verify this pack with the dedicated tool:

  python3 tools/pack_1_dotp_complete.py fetch-art
  python3 tools/pack_1_dotp_complete.py
  python3 tools/pack_1_dotp_complete.py verify

Card names and rules text are Wizards of the Coast material. Set and card
metadata are obtained through Scryfall's public API and remain subject to
their respective owners' terms. No card artwork is committed to the source
repository; the local build command places the fetched images in this ZIP.
