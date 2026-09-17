extends GutTest
## A HOST MUST BE JOINABLE WITH ITS OWN INVITATION. The Game Browser
## refuses a listing whose address, port or certificate fingerprint is not
## the one inside the privately shared invitation, so those two have to
## agree — and until now nothing compared them: the discovery tests build
## their advert by hand with the same literals `start_lan` uses, which is
## green however `start_lan` changes. Only a second computer, or
## `tools/lan_smoke.sh`, ever ran the comparison.

var server: SgLocalServer
var scanner: SgLanDiscovery


func before_each() -> void:
	server = SgLocalServer.new()
	add_child_autofree(server)
	scanner = SgLanDiscovery.new()
	add_child_autofree(scanner)


func after_each() -> void:
	scanner.stop()
	server.stop()
	for i in 3: await get_tree().process_frame


func _until(predicate: Callable, frames := 600) -> bool:
	for i in frames:
		if predicate.call(): return true
		await get_tree().process_frame
	assert_true(false, "LAN discovery exceeded its frame budget")
	return false


## An ephemeral discovery port: one computer can lend UDP 17898 to one
## advertising service, and a suite that takes it would fight a player's
## own host — or another checkout — for it.
func _advertising_host(nickname := "Forest Fox") -> Dictionary:
	assert_eq(server.start_lan("127.0.0.1", 0, true, nickname, 0), OK)
	assert_eq(server.discovery_error, OK)
	assert_eq(scanner.scan(), OK)
	scanner.query("127.0.0.1", server.discovery._socket.get_local_port())
	await _until(func() -> bool: return scanner.hosts.size() == 1)
	return scanner.hosts.values()[0].host if scanner.hosts.size() == 1 else {}


func test_the_advert_and_the_invitation_of_one_host_name_the_same_host() -> void:
	var advert := await _advertising_host()
	var invitation := SgLanInvite.parse(server.invitation())
	assert_false(invitation.is_empty(), "a started LAN host issues a parseable invitation")
	if advert.is_empty() or invitation.is_empty(): return
	# Exactly SgLobby._connect_local's refusal rule, read from both sides.
	assert_eq(String(advert.address), String(invitation.address),
		"a joinable advert names the invitation's address")
	assert_eq(int(advert.port), int(invitation.port),
		"a joinable advert names the port the listener actually took, not the one asked for")
	assert_eq(String(advert.fingerprint), String(invitation.fingerprint),
		"a joinable advert pins the certificate the invitation carries")
	assert_eq(String(advert.name), "Forest Fox")
	assert_eq(String(advert.build), SgCompatibility.fingerprint())
	assert_eq(advert.stamp, SgCompatibility.stamp())
	assert_false(JSON.stringify(scanner.hosts).contains(server.access_code),
		"a listing is not an invitation: the access secret is never broadcast")
	assert_false(JSON.stringify(scanner.hosts).contains(server._lan_pem),
		"the advert carries a fingerprint of the certificate, not the certificate")


func test_an_advertised_table_count_moves_without_naming_the_table() -> void:
	var advert := await _advertising_host("Kitchen host")
	if advert.is_empty(): return
	assert_eq(int(advert.rooms), 0, "a host with no table advertises none")
	var client := SgLocalClient.new()
	add_child_autofree(client)
	assert_eq(client.connect_invitation(server.invitation(), "Guest"), OK)
	await _until(func() -> bool: return client.online)
	assert_true(client.command({"op": "host", "name": "Kitchen table"}), client.command_error)
	await _until(func() -> bool: return not client.busy())
	scanner.query("127.0.0.1", server.discovery._socket.get_local_port())
	await _until(func() -> bool: return int(scanner.hosts.values()[0].host.rooms) == 1)
	assert_eq(int(scanner.hosts.values()[0].host.rooms), 1, "an open table raises the advertised count")
	assert_false(JSON.stringify(scanner.hosts).contains("Kitchen table"),
		"a listing carries how many tables are open, never their names")
	assert_false(JSON.stringify(scanner.hosts).contains(client._resume),
		"a listing never carries a seat's resume capability")
	client.forget()
