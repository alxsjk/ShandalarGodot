# Draft replay v1

The `# draft-recipe: ` line of a native draft deck contains compact JSON. The
same object is `recipe` in the accompanying pool receipt. Neither is signed.
For judging, retain the original receipt or recipe fingerprint before building;
never accept a player's newly supplied fingerprint as independent evidence.

## Record

The object has exactly these fields:

- `schema`: integer 1.
- `algorithm`: `sha256-counter-fisher-yates-v1`.
- `seed`: 64 lowercase hexadecimal characters, representing 32 fresh random
  bytes from the operating system. Never convert it to a JSON number.
- `options`: integer `boosters`, `starters`, `free_lands`, `extras`, `minutes`.
- `sheets`: sorted, unique card-name arrays keyed by `rare`, `uncommon`, `common`,
  `land`. Each card occurs on exactly one sheet. These frozen sheets, not a
  judge's current pool settings or rarity database, are the reconstruction input.
- `pool_sha256`: lowercase SHA-256 of the reconstructed pack payload below.
- `fingerprint`: lowercase SHA-256 of the recipe payload below.

The ordinary display comments `# draft-seed:`, `# draft-packs:` and
`# draft-fingerprint:` are conveniences. The machine-readable recipe is the
authoritative input to the verifier. No username, machine path or clock value
is needed for reconstruction.

## Random choices and dealing

Start an integer counter at zero. For each candidate random word, hash the
UTF-8 bytes of `Shandalar draft v1`, a newline, the literal seed text, a newline,
and the counter in unsigned decimal without leading zeros. There is no trailing
newline. Increment the counter. Interpret the first four digest bytes as an
unsigned **little-endian** 32-bit integer `word`.

For a uniform choice below positive `n`, set `limit = 2^32 - (2^32 mod n)`.
Reject words at or above `limit`, consuming another counter value. Otherwise
return `word mod n`. Even a bound of one consumes a word.

A nonbasic draw copies its sheet. For each index `i` from zero to `wanted - 1`,
choose `j = i + below(sheet_size - i)`, swap positions `i` and `j`, then take
position `i`. Sort the resulting names before appending them to the pack.
This is partial Fisher–Yates without replacement. Reset the sheet for each
pack, but never reset the random counter between packs or rarity slots.

Deal starters first, then boosters, numbered from one. Within every pack, draw
rare, uncommon, common and land in that order:

| Pack | Rare | Uncommon | Common | Basic land |
|---|---:|---:|---:|---:|
| Starter | 3 | 9 | 26 | 22 |
| Booster | 1 | 3 | 10 | 1 |

Basic lands draw with replacement from the sorted land sheet; sort the drawn
land names before appending. Pack titles are `Starter Pack N` and `Booster Pack N`.
Nonbasic sheets must be large enough; undersized recipes are rejected.
All name sorting is case-sensitive Unicode code-point order, without locale
collation or Unicode normalization.

If extra lands are requested, append `Free Lands`: N copies each in this fixed
order: Plains, Island, Swamp, Mountain, Forest. This consumes no random words.
If random extras are requested, concatenate the four sorted sheets in slot
order, draw without replacement using the same procedure/counter and append
`Random Cards`. Omit either extra pack when its count is zero.

## Canonical fingerprints

Use compact UTF-8 JSON: no indentation or separator spaces, no ASCII-escaping
of Unicode characters, standard JSON string escaping, and decimal integer
numbers. Arrays avoid dictionary-key ordering ambiguities.

The pool payload is an array of `[pack_title, card_names_array]` in dealt order.
`pool_sha256` hashes that JSON. Counts are derived by summing all those names.

The recipe payload is:

```text
[1, algorithm, seed,
 [boosters, starters, free_lands, extras, minutes],
 [rare_names, uncommon_names, common_names, land_names],
 pool_sha256]
```

`fingerprint` hashes that JSON. The fingerprint includes the stated time limit,
but does not prove that the player respected it. Completion state, timestamps,
deck contents and filenames are excluded, so checkpoints and recovery copies
retain the same pre-build commitment.

`tests/ui/test_draft_recipe.gd` includes a fixed independently calculated
reference vector using seed `000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f`.
For its explicit sheets and options, the expected pool SHA-256 is
`3231e8474ee8be69f58b972d1febb6c7261f11d6f2a08b3a7ac7bec2de4ef879`,
and the recipe fingerprint is
`ba56d2dcd6a70463fbfec7e3f7fdbd3848685a912f854eaf697bef54451b95da`.

V1 must remain frozen. Changes to slot order, pack sizes, random-byte handling,
sorting or the hash payload require a new algorithm identifier and an explicit
decoder; they must not silently reinterpret existing decks.
