extends GutTest

var event_triggered = false
var event_payload = {}

func before_all():
	pass

func after_all():
	OBSClient.disconnect_from_obs()

func _on_event(event_type, event_data):
	if event_type == "CustomEvent":
		event_triggered = true
		event_payload = event_data

func test_004_obs_events():
	OBSClient.connect_to_obs("ws://127.0.0.1:4455", "KXH4ey8f9xVVmBkt")
	
	var time_passed = 0.0
	while OBSClient.get_connection_state() != OBSClient.STATE_CONNECTED and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_eq(OBSClient.get_connection_state(), OBSClient.STATE_CONNECTED)
	
	var cb = Callable(self, "_on_event")
	OBSClient.subscribe_to_events(OBSClient.OBS_EVENT_SUBSCRIPTION_ALL, cb)
	
	OBSClient.broadcast_custom_event({"blazium_test_auth": "secure_broadcast"})
	
	time_passed = 0.0
	while not event_triggered and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_true(event_triggered, "Custom event natively triggered resolving WebSocket multiplexing pipelines safely")
	assert_eq(event_payload.get("blazium_test_auth", ""), "secure_broadcast", "Custom payload accurately maintained integrity executing throughout the Engine -> OBS -> Engine TCP loop")
	
	OBSClient.unsubscribe_from_events(OBSClient.OBS_EVENT_SUBSCRIPTION_ALL, cb)
