extends AutoworkTest

var version_received = false
var version_data = {}

func before_all():
	pass

func after_all():
	OBSClient.disconnect_from_obs()

func _on_version(status, data):
	version_received = true
	version_data = data

func test_003_obs_requests():
	OBSClient.connect_to_obs("ws://127.0.0.1:4455", "KXH4ey8f9xVVmBkt")
	
	var time_passed = 0.0
	while OBSClient.get_connection_state() != OBSClient.STATE_CONNECTED and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_eq(OBSClient.get_connection_state(), OBSClient.STATE_CONNECTED)
	
	OBSClient.get_version(Callable(self, "_on_version"))
	
	time_passed = 0.0
	while not version_received and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_true(version_received, "Engine Callable bindings synchronously intercepted the GET request return JSON successfully")
	assert_true(version_data.has("obsVersion"), "Returned version Dictionary uniquely matches OBS WebSocket V5 schemas")
	assert_true(version_data.has("obsWebSocketVersion"), "Returned version Dictionary features absolute WebSocket protocol bounds")
