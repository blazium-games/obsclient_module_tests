extends GutTest

var batch_received = false
var batch_results = []

func before_all():
	pass

func after_all():
	OBSClient.disconnect_from_obs()

func _on_batch(results):
	batch_received = true
	batch_results = results

func test_005_obs_batch():
	OBSClient.connect_to_obs("ws://127.0.0.1:4455", "KXH4ey8f9xVVmBkt")
	
	var time_passed = 0.0
	while OBSClient.get_connection_state() != OBSClient.STATE_CONNECTED and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_eq(OBSClient.get_connection_state(), OBSClient.STATE_CONNECTED)
	
	var req1 = {"requestType": "GetVersion", "requestId": "vers1"}
	var req2 = {"requestType": "GetStats", "requestId": "stat1"}
	
	OBSClient.send_request_batch([req1, req2], false, OBSClient.OBS_REQUEST_BATCH_EXECUTION_TYPE_SERIAL_REALTIME, Callable(self, "_on_batch"))
	
	time_passed = 0.0
	while not batch_received and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_true(batch_received, "Batch callbacks securely resolved resolving massive scale deployment potentials exclusively")
	assert_eq(batch_results.size(), 2, "Accurately intercepted multiform array definitions exclusively linked")
