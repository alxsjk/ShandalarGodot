# SGManalink LAN playtest

Development branch: `sgmanalink`. A desktop LAN full-pool duel milestone, not the
public Internet release. No Nakama, account service, central directory or
MElo is required. Offline duels, hotseat, demonstration and Deck Builder
retain their existing code paths.

## Two computers on the same network

Use the same current development build on both computers. Old release
builds do not contain this LAN milestone.

1. Open the main-menu globe on both computers. In **Identity**, enter a name
   or **Generate name**, optionally tick **Remember this name on this device**,
   then **Use this identity**. Names use up to 20 letters, numbers, spaces,
   - or _. This is a temporary display name, not a verified or reserved account.
   You can skip identity creation and play as a guest.
2. On the host, open **Host Game**, name the duel and choose its LAN IPv4 address. Usually this
   starts with `192.168.`, `10.` or `172.16.` through `172.31.`. If there
   are several adapters, choose the address on your opponent's network.
3. Leave **Visible in the LAN game browser** checked to be discoverable.
   Uncheck it for an invitation-only host. Choose **Host on LAN**;
   the host connects itself and creates the duel room automatically.
4. Choose **Copy invitation** and send it privately to the other player.
   It is a long, single-line `sglan1:` invitation: host address, port,
   public certificate and a temporary access secret. Copy the whole thing.
5. On the other computer, open **Game Browser**, then **Find LAN games**. Select the host,
   paste their invitation into the invitation field, then **Connect**.
   Alternatively paste the invitation and Connect directly, without any
   discovery or manual IP/port entry. The invitation carries both.
6. In the connected browser, choose **Join** beside the host's duel.
   Use **Choose / review deck** to search shipped and locally saved decks,
   inspect the complete list, then **Use this deck**. Both choose **Ready**.
   Changing either deck clears both Ready flags so both players can review again.
7. Play on the **same duel screen as an offline duel**. The coin-toss winner
   chooses Play first or Draw first; keep or redraw when prompted. Click a hand
   card, choose any mode/X, then click its targets on the table, portraits, spell
   chain or public pile. If mana is needed, tap sources without cancelling the
   selected spell. Double-click auto-pays; individual mana sources remain your choice.
   Use Done, phase stops and the normal shortcuts to advance. Select attackers by
   clicking them; click a blocker then an attacker to block. Confirm with Done.
   Divide damage with the existing click-per-point combat controls and choose
   cleanup discards in your hand.

The host must keep its lobby and application open for the whole duel.
Closing that host stops its service and all rooms. There is no account
setup, router configuration, automatic port forwarding or external service.

The invitation is a secret, not a public room listing. Clipboard managers
and the application used to send it may keep their own history. The game
does not store invitations, private keys or seat credentials in settings or
logs. Only a display name is saved, and only after explicit confirmation with
**Remember** checked. Cancel discards identity edits; using a name with
Remember unchecked removes the saved preference. Stopping the host invalidates its invitations; starting
again generates new credentials. Names are not globally reserved.

## What can be played

All shipped and locally saved decks whose cards are implemented can be selected.
The host accepts names from the complete registered card pool, not scripts,
resources or paths from another computer. Main decks contain **40–250 cards**;
sideboards may contain up to 250 and can be reviewed but are not used in this
single-duel format. Build and save a custom list in the existing Deck Builder
before opening SGManalink. No selection leaves the explicitly named 40-card
Forest practice deck as a fallback, not a card-pool restriction.

Room rules currently use **Unrestricted**, 20 starting life, mana burn on and
free combat-damage assignment. The referee flips the coin; its winner chooses
whether to play or draw first.
There is no between-games sideboarding, match series or ante in this milestone.

Online play subclasses the existing `DuelScreen`, rather than maintaining a
second approximation. The same battlefield layout, full-size preview, draggable
hand, portraits, phase/combat bars, Combat window, spell chain, target arrows,
damage markers, spell flights, card sounds and music are used. Your seat always
appears below your opponent's. Hand style, placement and other presentation
preferences are shared with offline duels.

Spells and live abilities use the referee's legal targets, modes, X and divided
damage. The original choice window handles private searches and cost/resolution
questions, including information revealed before the question. The **Online**
button in the strip below the large card offers connection controls, recent
revealed information and special actions such as Channel payments. The referee
validates every answer. Menus stop your local automatic passing, not the other
player; disconnects suspend game actions. Closing SGManalink requires confirmation.

Opponent hands are normally counts. A card rule may explicitly reveal cards or
permit a private look; only the authorized viewer receives that information.
**Revealed information** retains recent looks as past observations, not live
access to hidden zones. Revelation and Field of Dreams expose only the zones
their rules permit, while active. Render cards are detached
local presentation objects, not host engine instances. Card art and skins stay
local; no asset transfer occurs. The renderer receives a detached projection,
not the host's game or a hidden-state snapshot. Durable replay and the wider
offline match/room/rules options remain separate work. Registry-wide rendering and
representative mechanic tests are not an exhaustive online playtest of every card.

## Discovery and firewall help

- Search sends local IPv4 UDP broadcast queries to **17898** every two
  seconds. Each host replies directly to the querying computer; there is
  no shared directory. Listings expire after seven seconds without replies.
- Listings contain a temporary host name, address, game port, public
  certificate fingerprint and open-room count. They contain no invitations,
  access/resume secrets, private keys, hands or decks. Discovery is not an
  identity guarantee; the separately shared invitation pins the TLS host.
- Default gameplay port: **TCP 17897**, or the port selected by the host.
  Allow the game on both computers' **private/local network** when the operating
  system asks. Do not disable the firewall or open router/Internet ports.
- If discovery is empty, try the invitation directly. Broadcasts may be
  blocked on guest Wi-Fi, separated subnets, VPNs or networks with client
  isolation. Client isolation may block direct play too.
  With several adapters, discovery depends on the operating system's LAN
  route; a direct invitation still targets the host's selected address.
- A busy UDP 17898 port disables that host's advertising, not its game
  listener; the UI reports this and direct invitations still work. Only
  one advertising service per computer is supported in this milestone.
- If a selected discovery result does not match an invitation's address,
  port and certificate fingerprint, joining is refused. **Clear selection**
  to deliberately join the pasted invitation instead. If the host restarted,
  request its new invitation.
- Use a currently assigned private IPv4 address. IPv6, public IPs,
  hostnames/DNS and Internet NAT traversal are outside this milestone.
  Private-address checks are a scope restriction, not a substitute for a
  firewall: do not expose this service with a reverse proxy or forwarding.

## Platforms

The LAN implementation uses native Godot networking APIs for Windows,
Linux and macOS. Its temporary TLS trust certificate cannot be installed
into a browser through Godot, and browsers cannot send LAN UDP broadcasts
or start this TCP listener. **This LAN milestone is desktop-only.** Web
offline play remains unchanged; future web multiplayer needs a separately
reviewed transport, such as WebRTC with signaling and relay support.

Exporting a platform is not proof of runtime compatibility. Dated test and
build results are in the roadmap. Two different physical computers remain
an important playtest even after automated local-socket tests pass.

## Same-computer fallback

For an isolated two-window check, **Host Game -> Same-computer testing ->
Start local service** retains the original loopback path. Use **Host a duel**
to create its room. Copy its access code and port into the other window's
**Game Browser**, using the **Same-computer test port**, and Connect.
This path uses plain `ws://` only on `127.0.0.1`, does
not advertise and cannot connect to another computer. LAN invitations
always use encrypted `wss://`; they never fall back to plain WebSocket.

## Session and security boundaries

- Hosting/scanning happen only on explicit button clicks. Opening the globe
  does not start a listener or send discovery packets. Closing stops sockets.
- A host generates an ephemeral RSA-2048 key and self-signed certificate.
  The client trusts only the certificate carried in the privately shared
  invitation, with an explicit common-name check. No unsafe TLS mode or
  operating-system trust-store changes are used. The `.invalid` common name
  is a local certificate label, not a domain to resolve or purchase.
- A Godot 4.7.2 certificate string-export defect is worked around using an
  automatically removed temporary file containing **only the public
  certificate**. Private keys and access/resume secrets never go to disk.
- The invitation grants a new guest session. A separate random resume
  capability controls the seat. Knowing/reusing a nickname cannot reclaim
  another session. Duplicate names get distinct service-local guest numbers.
- Disconnects pause game actions until both seats reconnect; concession is
  still available. Retry restores the same seat and does not execute a
  command twice. Replacing the controlling connection displaces the old one.
- Closing the client lobby forgets its seat; it cannot be recovered by
  reopening. Concede before intentionally leaving a running match. Host
  shutdown loses all room/session state; there is no durable match journal.
- Limits: eight connections, sixteen guest sessions, eight rooms per host;
  bounded JSON nesting, arrays, bytes, command queues and acknowledgements;
  32 KiB commands, 2 MiB views and a 512-card limit per transmitted collection;
  handshake deadline and message rate limits. Discovery has a 64-host cache,
  768-byte packet ceiling and at most sixteen replies per second per host.
- Server commands and host-to-client DTOs are validated before use. No
  arbitrary object deserialization, script/resource loading or remote method
  dispatch. Seat authorization comes from the connection, not a player
  number submitted by the client. The data protocol is version 5 (both players
  need the updated build for the shared duel presentation and mana-payment controls);
  the invitation keeps the `sglan1:` envelope prefix and carries the same
  version-5 compatibility check inside it.
- Each client receives a detached allowlisted view. Opponent hands and library
  order are not transmitted unless a card rule expressly permits that look/reveal.
  Engine logs, RNG state and raw engine IDs are never transmitted. Deck lists
  are sent to the referee and their owner, not the other client; deck titles
  are public. Hidden-zone searches use sorted names, not library order.
  Handles survive public moves so the shared card animations retain continuity;
  they are retired when a card becomes hidden to a seat, or an opening hand is shuffled.

The player operating the host can inspect its full rules-engine state or
modify the executable. Transport encryption and filtered client views do
not make that host an impartial referee. This milestone is **unrated
friendly play**; it does not claim cheat-proof multiplayer. The existing
engine RNG is unchanged, not a cryptographic ranked-shuffle protocol.

## Verification and next work

`./run_tests.sh -gselect=test_sgmanalink` covers exact schemas, guest labels,
private-state substitution, host/join/ready, encrypted invitation connections,
seat resumption, UDP query/reply and expiry, hostile host DTOs, stale/duplicate
commands and a complete encrypted duel through the interface controls, driven
only from client views. Interface tests cover identity persistence/cancel,
small-window layout, deck lists, hidden-card rendering, targeting, private choices
and combat/damage input. Full-pool tests round-trip every registered definition
through the view schema and detached renderer. Focused mechanic cases exercise
auras, modal/X spells, counterspells, regeneration, divided damage, sacrifice costs,
searches, private/public reveals, masked cards and special payments. Encrypted
deck-submission tests check privacy, validation, readiness resets and reconnects.

Next: two-computer full-deck playtests; then
Internet invitations and decentralized public discovery. Account providers,
MElo and tournaments are parked future options, not prerequisites for LAN
play. See [the design](sgmanalink-design.md), the
[authentication options](sgmanalink-authentication.md) and
[block-MElo exploration](block-MElo.md).
