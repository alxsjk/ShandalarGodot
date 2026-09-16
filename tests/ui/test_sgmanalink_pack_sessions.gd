extends GutTest
## A live or resumable network session pins one effective card catalogue.

func before_each() -> void:
	for id in CardPacks.available_ids(): CardPacks.set_enabled(id, false)

func after_each() -> void:
	for id in CardPacks.available_ids(): CardPacks.set_enabled(id, false)

func test_host_pins_packs_and_rescan_until_stop() -> void:
	var server := SgLocalServer.new()
	add_child_autofree(server)
	assert_eq(server.start_local(0), OK)
	var revision := CardRegistry.revision
	assert_false(CardPacks.set_enabled("pack-5", true))
	assert_false(CardRegistry.has_card("Force of Will"))
	CardPacks.rescan()
	assert_eq(CardRegistry.revision, revision, "rescan cannot replace a live referee catalogue")
	server.stop()
	assert_true(CardPacks.set_enabled("pack-5", true))

func test_client_uses_connect_time_catalogue_and_holds_until_forget() -> void:
	var client := SgLocalClient.new()
	add_child_autofree(client)
	var old_stamp := client.build_fingerprint
	assert_true(CardPacks.set_enabled("pack-5", true))
	# A refused socket still represents a resumable/connecting intention.
	client.connect_local(1, "a".repeat(64))
	assert_ne(client.build_fingerprint, old_stamp)
	assert_eq(client.build_fingerprint, SgCompatibility.fingerprint())
	assert_false(CardPacks.set_enabled("pack-5", false))
	client.forget()
	assert_true(CardPacks.set_enabled("pack-5", false))

func test_host_stop_does_not_unlock_an_independent_client() -> void:
	var server := SgLocalServer.new()
	var client := SgLocalClient.new()
	add_child_autofree(server)
	add_child_autofree(client)
	assert_eq(server.start_local(0), OK)
	assert_eq(client.connect_local(server.port, server.access_code), OK)
	server.stop()
	assert_false(CardPacks.set_enabled("pack-3", true))
	client.forget()
	assert_true(CardPacks.set_enabled("pack-3", true))
