extends AutoworkTest

func _before_all():
	pass

func _after_all():
	OBSClient.disconnect_from_obs()

func test_002_obs_auth_missing_password():
	if OS.get_environment("OBS_LIVE_TESTS") != "1":
		pending("Requires local OBS WebSocket on ws://127.0.0.1:4455")
		return
	var err = OBSClient.connect_to_obs("ws://127.0.0.1:4455", "")
	assert_eq(err, OK, "Socket connect wrapper fires correctly (since protocol validation happens inside stream polling)")
	
	watch_signals(OBSClient)
	
	var time_passed = 0.0
	while OBSClient.get_connection_state() != OBSClient.STATE_DISCONNECTED and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01

	assert_eq(OBSClient.get_connection_state(), OBSClient.STATE_DISCONNECTED, "Socket strictly terminates upon detecting authentication omission over configured bounds")
	assert_signal_emitted(OBSClient, "connection_error", "Signals explicit error natively informing engine users of the authentication failure")
