extends AutoworkTest

func before_all():
	pass

func after_all():
	OBSClient.disconnect_from_obs()

func test_001_obs_connect():
	# Test unauthenticated/authenticated depending on your local OBS instance flags
	# Here we proactively provide the password testing strict websocket binding logic
	var err = OBSClient.connect_to_obs("ws://127.0.0.1:4455", "KXH4ey8f9xVVmBkt")
	assert_eq(err, OK, "Socket connect should establish cleanly natively returning OK (0)")
	
	watch_signals(OBSClient)
	
	var time_passed = 0.0
	while OBSClient.get_connection_state() != OBSClient.STATE_CONNECTED and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01

	assert_eq(OBSClient.get_connection_state(), OBSClient.STATE_CONNECTED, "OBSClient must eventually align to STATE_CONNECTED ensuring handshake propagation fully resolved.")
	assert_signal_emitted(OBSClient, "connected", "OBSClient must properly propagate its C++ connected dispatch mapping cleanly down to GDScript space natively.")
