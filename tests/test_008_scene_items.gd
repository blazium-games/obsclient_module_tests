extends AutoworkTest

var input_created = false
var list_received = false
var item_list = []
var enabled_received = false
var is_enabled = true

func before_all():
	pass

func after_all():
	OBSClient.disconnect_from_obs()

func _on_create_input(status, data):
	input_created = true

func _on_item_list(status, data):
	list_received = true
	item_list = data.get("sceneItems", [])

func _on_enabled(status, data):
	enabled_received = true
	is_enabled = data.get("sceneItemEnabled", true)

func _on_noop(status, data):
	pass

func test_008_obs_items():
	OBSClient.connect_to_obs("ws://127.0.0.1:4455", "KXH4ey8f9xVVmBkt")
	
	var time_passed = 0.0
	while OBSClient.get_connection_state() != OBSClient.STATE_CONNECTED and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_eq(OBSClient.get_connection_state(), OBSClient.STATE_CONNECTED)
	
	OBSClient.create_scene("TestOverlayScene", Callable(self, "_on_noop"))
	time_passed = 0.0
	while time_passed < 0.5:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	OBSClient.create_input("TestOverlayScene", "TestColorInput", "color_source_v3", {"color": 4278190335}, true, Callable(self, "_on_create_input"))
	time_passed = 0.0
	while not input_created and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	OBSClient.get_scene_item_list("TestOverlayScene", Callable(self, "_on_item_list"))
	time_passed = 0.0
	while not list_received and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_true(item_list.size() > 0, "Color input accurately captured mapping overlay states internally.")
	var item_id = item_list[0].get("sceneItemId", -1)
	
	OBSClient.set_scene_item_enabled("TestOverlayScene", item_id, false)
	time_passed = 0.0
	while time_passed < 0.5:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	OBSClient.get_scene_item_enabled("TestOverlayScene", item_id, Callable(self, "_on_enabled"))
	time_passed = 0.0
	while not enabled_received and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_false(is_enabled, "Visibility overlay securely triggered caching explicit boolean states conclusively executing cross TCP bridges")

	OBSClient.remove_scene("TestOverlayScene")
	OBSClient.remove_input("TestColorInput")
