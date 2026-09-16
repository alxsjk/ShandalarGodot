# block-MElo: a community-verifiable player ledger

Status: exploratory design, 2026-09-14. Documentation only on `sgmanalink`.
No ledger, permanent identity, consensus network, currency or ranked mode is
implemented or selected by this document. The existing
[SGManalink design](sgmanalink-design.md) remains the working baseline;
the [local prototype](sgmanalink-local-playtest.md) still uses temporary
guest seats. Alternatives and recommendations below are proposals, not
security guarantees or a commitment to build them.

## The idea, in plain language

Yes: players could keep verifiable copies of a shared register containing
player identities, name ownership and accepted ranked results. Anyone could
check its signatures and independently calculate the standings. This is a
useful goal even without a blockchain or a cryptocurrency.

However, **having many copies does not by itself prevent spoofing or decide
which copy is correct**. We must solve four different problems:

1. **Authentication:** who controls this identity? Cryptographic credentials.
2. **Agreement:** who owns a name, and which history is accepted? A registry
   authority or a defined consensus protocol, with explicit trust assumptions.
3. **Match integrity:** did this legal, eligible duel actually happen? An
   accountable referee or a much more ambitious verifiable game protocol.
4. **Audit and availability:** can others inspect and preserve the record?
   Signed records, proofs, independent copies and archival operators.

The strongest practical starting point appears to be **a publicly auditable
ledger with community mirrors**, retaining trusted ranked referees. A later
community-operated validator federation could distribute control. A public
permissionless blockchain is possible, but would not remove the need to
establish trustworthy match results.

## What each mechanism does and does not establish

| Mechanism | Useful guarantee, under its assumptions | Does not establish |
|---|---|---|
| Digital signature with a registered, uncompromised key | The matching credential authorized these exact bytes | One human per account, honest play, or ownership of an unregistered nickname |
| Hash-linked history | Changes are detectable relative to a trusted earlier commitment | Which competing history is legitimate; an attacker can invent a different chain |
| Many independently maintained copies | Better availability and opportunities to find discrepancies | Honest majority, fresh data, or automatic conflict resolution |
| Finalized registry transaction | One accepted owner of a normalized name within this ledger | Ownership of the same spelling on another network, or prevention of lookalikes |
| Consensus among eligible validators | Agreement on ordered records within the protocol's fault assumptions | Truth of an off-network event merely asserted in a record |
| Reproducible rating calculation | The rating follows the accepted results and published policy | That those results were earned honestly |

For example, an attacker can create thousands of keys and serve thousands
of copies of the same false file. Counting peers or signatures without
controlling voting eligibility counts identities, not independent people.
This is the Sybil problem, not something free key generation resolves.
[Douceur, *The Sybil Attack*](https://www.microsoft.com/en-us/research/publication/the-sybil-attack/).

## Identities and unique player names

### Separate the permanent identity from its name and keys

Keep three distinct concepts:

- **PlayerID:** permanent identifier to which history and MElo belong.
- **Canonical handle:** unique, human-readable name mapped to that PlayerID.
- **Credentials:** replaceable ways to prove control of the PlayerID.

The baseline can use a securely generated opaque PlayerID registered by
the service. A more self-sovereign alternative is an ID derived from a
dedicated inception public key or canonical identity-creation record.
Subsequent authorized key changes would preserve that original ID. Neither
approach should use the *current* login key as an identity that changes every
time a player replaces a device. Cryptographic collision resistance is not
a promise that humans or their chosen names are unique.

A local identity generator could create a provisional profile and the
necessary game-only credentials, where supported. It cannot reserve a
globally unique handle while offline: registration remains pending until
the chosen registry finalizes it. Do not import administrative or GitHub
SSH keys, derive secret keys from nicknames, or build custom cryptography.

### How a name becomes protected

Proposed registration flow:

1. Normalize the requested handle using one versioned rule shared by every
   verifier. Start with a restricted lowercase ASCII alphabet; display names
   and portraits can be separate and need not be unique.
2. Prove control of the proposed identity credentials.
3. Submit a registration bound to this ledger/network, PlayerID and handle.
4. Check the accepted registry state and finalize the binding atomically.
   If two people request `silverfox`, only the first valid request in the
   agreed final order succeeds. A client-supplied timestamp does not decide.
5. Return an authenticated receipt/state proof. Invitations and profiles
   show the canonical handle plus a stable identity discriminator.

The protection comes from **authorized signatures plus an agreed registry
state**, not from encrypting a name. Two different keys can both sign the
text `silverfox`; their signatures alone do not decide who owns it.
During a partition, conflicting claims must remain pending rather than both
being presented as final. A copied display name must never hide a different
PlayerID in a challenge or invitation.

Handle changes, reserved names, squatting and abusive names need published
policies. Prefer retaining historical ownership and preventing automatic
reuse of retired handles. If reuse is eventually allowed, show the changed
identity clearly; never transfer the previous owner's rating or history.
No registry can prevent somebody using the same spelling on a separate fork.

### Login, key replacement and recovery

Passkeys remain the preferred player-facing login in the baseline.
WebAuthn credentials are scoped to a relying party: they are not a universal
SSH-like signing key that arbitrary community servers can request. A
federation would need an explicit shared identity service or reviewed
federated authentication design. Independently signed player ledger actions
would require their own carefully designed authorization path; successful
login must not silently authorize arbitrary ledger changes.
[WebAuthn Level 3](https://www.w3.org/TR/webauthn-3/).

Distinguish player credentials, identity-service signing keys, match-referee
keys and ledger-validator keys. Their permissions are not interchangeable.
The identity service authenticates an account; validators establish whether
an identity change is admissible under the chosen policy.

Possible recovery models include a second credential and offline recovery
codes through the identity service, or a pre-enrolled threshold of recovery
guardians for a more decentralized design. Guardians add collusion and
availability risks. Define authorization, notifications, delays and appeals
before selecting a model. Knowing a nickname is never recovery evidence.

Key rotation/revocation events must bind to the previous identity revision,
be authorized under its recovery policy and take effect at a defined ledger
position. Evaluate historical signatures using the keys valid at that
position, not just today's key list. Handle compromise with explicit
corrections where justified; revocation cannot erase copies or automatically
identify which earlier actions were fraudulent. Lost credentials without a
working recovery path may mean permanently losing control of the persona.

## Possible architectures

| Option | Who orders names and results? | What the community can verify or preserve | Main trade-off |
|---|---|---|---|
| A. Signed result receipts and downloadable snapshots | One service | Issued receipts and snapshots | Simple; issuer can omit records or issue conflicting views |
| B. Append-only transparency log with mirrors and witnesses | One sequencer; independent observers audit it | Inclusion, history consistency and independent rating replay | Distributed audit/storage, not decentralized admission or guaranteed censorship resistance |
| C. Permissioned community validator federation | Agreed independent operators running BFT consensus | Finalized state and history under a published validator policy | Distributed control, but operator trust, availability and governance remain |
| D. Federated club ledgers | Each club orders its own namespace and results | Each club's history; selected cross-club attestations | No single global handle or MElo without an additional shared agreement |
| E. Public permissionless blockchain | An existing chain's consensus | Contract state and transaction history | Fees, external dependencies, privacy and oracle problems; no automatic honest-game proof |

### A and B: transparency without a currency

A signed downloadable file is a useful first audit artifact. To go further,
use an established append-only log design: records, signed checkpoints,
Merkle inclusion proofs and consistency proofs between checkpoints.
Independent mirrors retain records; monitors check admissions and replay
ratings; witnesses compare and attest to consistent checkpoints.

An inclusion proof establishes membership under a particular root, not
completeness, freshness or honesty of the included result. Comparing signed
checkpoints helps expose a log showing different histories to different
people. Detection still needs independent communication and a response policy.
This borrows transparency techniques, not a ready-made game consensus
protocol, from [RFC 9162, especially sections 2 and 11](https://www.rfc-editor.org/rfc/rfc9162.html).

For SGManalink, specify submission receipts, inclusion deadlines, witness
requirements, monitor alerts and what happens after a conflicting history.
Without those, an operator can quietly withhold submissions or isolate a
new client. A single-sequencer outage still prevents new final records,
although mirrors can preserve the last accepted history. Extra copies alone
do not elect a replacement writer.

### C: a community federation without mining or a token

Use a maintained Byzantine-fault-tolerant consensus implementation rather
than an improvised voting scheme. For the classic model with equal voting
weights, `3f + 1` validators and `2f + 1` agreement support tolerance of up to
`f` Byzantine faults under the full protocol's assumptions. Four independent
operators with a three-vote finalization threshold illustrate tolerance of
one faulty operator. If two are unavailable, progress stops; do not lower
the quorum to keep ranking. Liveness also requires the network eventually
to deliver messages sufficiently promptly.
[Castro and Liskov, PBFT service properties](https://www.usenix.org/legacy/publications/library/proceedings/osdi99/full_papers/castro/castro_html/node3.html).

These counts are not a protocol: locking, rounds, persistence, recovery and
safe validator changes are essential. CometBFT is one existing candidate
to evaluate, not a selected dependency. Its consensus and application
validation are distinct responsibilities; the application must still enforce
name ownership, credentials and result eligibility.
[CometBFT documentation](https://docs.cosmos.network/cometbft/latest/docs/introduction/intro).

Operators need genuinely independent administration, credentials and failure
domains. Four nodes controlled by one person do not provide four independent
trust decisions. Publish membership changes, removal/replacement procedures,
software/rating upgrades, incident response and how clients learn the trusted
validator set. Validator admission must not be purchased with MElo or granted
automatically to anyone generating an account.

Consensus only over the *result ledger* does not mean several validators
independently witnessed each duel. If all accept one authorized referee's
signature, they still trust that referee's account of the game.

### D: independent clubs and qualified names

An alternative accepts names such as `silverfox@club-a` and
`silverfox@club-b` as different identities. Clubs issue records in their own
namespaces and publish their own ladders. This reduces the need for one
global naming authority, but a global MElo still needs an agreed admission
policy, ordering and duplicate-result handling. Averaging club ratings does
not produce a meaningful global rating automatically.

Portable signed identity history could make migration possible, but other
clubs must agree to recognize it. This is federation, not guaranteed global
uniqueness or universal recognition.

### E: a public blockchain, or just checkpoint anchoring

An existing chain could run a registry and rating contract, accepting
properly authorized identity events and eligible match attestations. We
would inherit its consensus/finality, costs, upgrades, infrastructure and
security assumptions. Running our own small permissionless chain would add
the separate problem of securing validator participation; one-key-one-vote
is not an adequate design.

The crucial limitation is input truth. A smart contract cannot infer that
an external SGManalink duel was fair simply because someone submitted its
score. It needs a trusted result source or an independently checkable proof.
This is an application of the
[blockchain oracle problem](https://ethereum.org/developers/docs/oracles/#the-oracle-problem).

A lighter optional variant anchors only periodic public checkpoint hashes
on an existing chain. That can provide an external ordering/commitment
reference once final, but does not preserve the underlying data, settle name
disputes or validate games. Specify handling of chain reorganizations and
conflicting anchors; a hash posted later does not authenticate an earlier
claimed timestamp. Do not require wallets, payments or token ownership from
players merely to obtain an auditable ladder.

## The hard part: establishing trustworthy ranked games

Consider two accounts signing "A defeated B." Signatures can show agreement
with that statement, yet both accounts may belong to one person and no duel
may have occurred. Even a legally replayable duel can be deliberately thrown.
**Signed receipts, consensus and anti-collusion are separate protections.**

Candidate result-authority models:

- **Trusted neutral referee:** an approved headless service enforces the
  engine, owns hidden state/randomness and issues a scoped result attestation.
  This is the baseline recommendation. Operators can still abuse access or
  fabricate results, so admission, audits and incident controls matter.
- **Several referee operators:** independently check a full private game
  record, or run a deliberately replicated referee protocol. This is separate
  from ledger voting. It adds cost and more parties able to see hidden cards;
  copying complete game state to ordinary players is unacceptable.
- **Two-player signatures:** useful evidence for friendly/private games and
  dispute receipts, but insufficient on their own for the official ladder.
  Requiring the loser to sign after defeat also lets a loser suppress results.
- **Cryptographically verifiable play:** explore committed decks, verifiable
  shuffles, selective reveals and proofs of legal transitions. Research such
  as [*A Fast Mental Poker Protocol*](https://eprint.iacr.org/2009/439) shows
  that cryptographic card protocols are a real research direction. It does
  not establish a drop-in, audited solution for this MTG engine.

Our assessment is that the last option is a separate substantial research
project. It must cover library searches, shuffles, hidden choices, dynamic
card effects, randomness, disconnects, withheld reveals and aborts after
learning an unfavorable outcome. A basic hash commitment or combined random
seed is not a complete solution. Proofs can establish specified legal state
transitions, not whether a player intentionally lost or used outside advice.

Do not publish hands, library order, RNG seeds, raw engine snapshots or
private replay material to ledger peers. A public full replay may expose
private deck strategy even after a match. A hash of a small-domain secret,
such as a card name or predictable decklist, can be guessed; any commitments
to private material require a reviewed hiding construction and retention
policy. A commitment is not proof of the underlying game's validity.

## A possible ledger and verification path

This is a conceptual data model, not a wire format. Separate authorization
of an event from final acceptance of that event by the log/consensus layer.

| Record | Proposed contents and authorization |
|---|---|
| Network policy | Network/genesis ID, schema, trust roots, eligibility rules, rating policy and upgrade authority |
| Identity registration | PlayerID, canonical handle, initial credential-authority binding and possession/registration evidence |
| Identity update | Previous identity revision, changed public authorization state, authorized rotation/recovery/revocation evidence |
| Match authorization | Unique MatchID, two distinct PlayerIDs, referee assignment, format/rules/catalogue/engine versions and rated eligibility fixed before play |
| Final result | MatchID, outcome/reason, scoped referee attestation and approved evidence reference; optional player acknowledgements |
| Correction | Reference to an existing record, authorized disposition and public reason category; sensitive evidence stays restricted |
| Checkpoint | Ordered position, history root, derived public state root, policy/validator epoch and required signatures/proofs |

Use explicit network and purpose separation, bounded schemas, deterministic
encoding, account/event sequencing and reviewed signature libraries. Reject
duplicate fields, malformed identifiers and ambiguous numeric values. The
same logical record must have the same signed representation across all
platforms; [RFC 8785](https://www.rfc-editor.org/rfc/rfc8785.html) describes
one canonical JSON option, not an authorization or consensus system.

A candidate acceptance path is:

1. Authenticate each player and authorize a particular rated match before
   it begins; record eligibility and referee assignment.
2. The referee runs the duel and durably records the result before submission.
3. Validators check schema, network, authority, match identity, policy and
   prior state. They do not accept an arbitrary player-supplied winner.
4. Finalize a unique ordered event. Retrying the same MatchID must not add
   another victory; conflicting outcomes are refused or enter dispute handling.
5. Apply the deterministic rating policy and publish the checkpoint/proofs.
6. Mirrors and independent verifiers replay the accepted public events,
   check the resulting state and compare checkpoints.

Never confuse verifying a referee signature with independently replaying
and validating the underlying duel. Label both kinds of verification honestly.

## Reproducible MElo and tournament results

Store the accepted result history as the primary record; a rating is a
derived view. Specify the initial rating, formula, provisional policy,
eligible formats, rounding and any seasons/inactivity rules before launch.
Publish a policy identifier and cross-platform reference test vectors.

Order matters for ordinary sequential Elo: a win changes the rating used
to calculate the next game's expected result. Two peers processing the same
games in different arrival orders can disagree. Use the agreed final ledger
order, or define explicit rating periods and a deterministic within-period
policy. Do not sort by untrusted player clocks. The ordering authority also
needs a transparent scheduling/admission policy to limit manipulation by
delaying or reordering results.

Record corrections as new authorized events, not silent history edits.
Choose whether invalidation triggers deterministic recomputation from the
affected point or a specified adjustment. Simply subtracting an old Elo
delta does not generally undo its effects on later games and opponents.
Keep prior checkpoints identifiable, and show pending/disputed/final states.

Ledger agreement cannot remove smurfing, account sharing, collusion or
win-trading. Consider provisional periods, matchmaking constraints, review
of repeated-opponent farming and an appeal path. Do not grant consensus
power based on rating: manipulated wins must not gain control of the ledger.

Public/private visibility is independent of rated/unrated status. Start
private, self-hosted, guest and computer-opponent games outside official
MElo. For future tournaments, record a TournamentID, entrant/round/match
assignments and advancement policy; advance only on authoritative accepted
results, once. A shared ledger preserves bracket decisions but does not
itself schedule rounds, enforce clocks or establish fair booster draws.

## What players would actually store

Offer participation levels rather than making every game client a validator:

- **Normal client:** verified recent checkpoint, own receipts and bounded
  cached standings/proofs. Display when the data is stale or unverified.
- **Optional archive/verifier:** download the public registry and ranked
  result events, verify them and independently rebuild MElo.
- **Mirror/witness:** explicitly operated service with retention, uptime and
  monitoring responsibilities; a mirror is not automatically a voting node.
- **Validator:** admitted operator with consensus duties and protected keys.

Public ledger records should contain only necessary pseudonymous identity
and result metadata. Never include emails, IP addresses, access tokens,
passkey recovery material, invitations/passwords, private chat or hidden game
state. Public history still reveals associations and play patterns. Explain
that before ranked participation; deletion from our service cannot guarantee
deletion from independent copies. Keep moderation evidence separate and
publish only an appropriate decision category.

If one million compact result records averaged 1 KiB each, that alone would
be about 0.95 GiB before identity events, indexes, proofs, backups or replays.
This is illustrative sizing, not a measurement. Full archives must therefore
be optional. Browser storage can be limited or cleared, so a browser client
must not be the sole archive or credential backup. Persisted ledger data is
untrusted input: bound downloads, verification work and decompression.

Clients need an authenticated bootstrap network ID and checkpoint/trust-root
policy; contacting many unknown peers is insufficient. Verify state proofs,
signature policies, validator transitions and history consistency against
that starting point. Remember the highest accepted state to resist rollback;
a new installation needs a reviewed way to obtain a fresh trusted checkpoint.
Conflicting finalized views require an explicit incident path, not silently
choosing the longest file or most popular server. Hashes without available
records are not an archive.

HTTPS/WSS remains suitable for service and live-match traffic. It is a
transport, not the ledger's durability, consensus or signature scheme.
Windows, Linux, macOS and web should share bounded verification formats;
none should require an always-running peer listener. Offline play and casual
duels must remain independent of ledger availability. When finalization is
unavailable, rankings remain pending rather than inventing local finality.

## Experiments and acceptance gates, if pursued later

No implementation is authorized by this note. A possible staged evaluation:

1. Define an unsigned synthetic event corpus, eligibility rules and a
   deterministic rating reducer. Compare outputs across all four platforms.
2. Evaluate a maintained signing/identity component and canonical format.
   Test wrong-network replay, forged/expired authorization, malformed records,
   old keys, key rotation and duplicate or contradictory match results.
3. Demonstrate identical name races, normalization conflicts and recovery
   races. Only one ownership transition may become final in the accepted
   network; an unrelated key must never inherit another PlayerID's MElo.
4. Build a disposable transparency-log experiment with independent archives.
   Inject omissions, altered records, stale checkpoints and split views;
   distinguish what is detected from what is prevented.
5. Evaluate a federation only if independent maintainers want to operate it.
   Test malicious voting, outages, partitions, crash restoration, safe
   membership changes and fresh-client bootstrap using an existing protocol.
6. Exercise dishonest referee reports, two colluding player signatures and
   fabricated-but-legal games. Document the residual trust instead of treating
   a green signature check as an anti-cheating test.
7. Audit public exports for hidden cards, seeds, private deck material,
   credentials and identifying metadata. Verify corrections and full rating
   reconstruction from an independently held archive.
8. Agree on stewardship, operating costs, anti-abuse policy, appeals,
   retention and incident recovery; obtain specialist security review before
   any public ranking claim. Measure real storage/bandwidth and user friction.

## Open decisions and provisional recommendation

We should first decide which goal matters most: protection from accidental
loss, public audit of administrators, survival of the original service, or
removing unilateral administrator control. Those are different requirements.

The main unresolved choices are who admits referees/validators, whether
handles are global or realm-qualified, how account recovery is governed,
what records players agree to publish, how disputes affect ratings, and who
funds reliable independent operation. A federation can continue after one
operator disappears only if its quorum, identity/recovery services, archives
and operational procedures can also continue. A permissionless chain does
not automatically make those other services independent.

**Provisional recommendation:** preserve the option for signed, portable
identity/result records and independent verification; start with neutral
ranked referees and a transparent log with optional community archives.
Evaluate a small, independently operated BFT federation if shared control
becomes a real community priority. Keep public-chain anchoring as an optional
comparison, not a requirement. Avoid introducing a coin, mining, NFT names
or mandatory wallets for a community rating system.

The honest promise would be: **the community can verify accepted history
and reproduce the ladder under a published trust model**. It would not be
"spoofing and cheating are impossible because everybody has the file."
