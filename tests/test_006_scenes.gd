extends GutTest

var scene_created = false
var scene_list_received = false
var scenes_array = []

func before_all():
	pass

func after_all():
	OBSClient.disconnect_from_obs()

func _on_create_scene(status, data):
	scene_created = true

func _on_scene_list(status, data):
	scene_list_received = true
	scenes_array = data.get("scenes", [])

func test_006_obs_scenes():
	OBSClient.connect_to_obs("ws://127.0.0.1:4455", "KXH4ey8f9xVVmBkt")
	
	var time_passed = 0.0
	while OBSClient.get_connection_state() != OBSClient.STATE_CONNECTED and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_eq(OBSClient.get_connection_state(), OBSClient.STATE_CONNECTED)
	
	OBSClient.create_scene("BlaziumTestScene", Callable(self, "_on_create_scene"))
	time_passed = 0.0
	while not scene_created and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_true(scene_created, "Successfully created a discrete isolated BlaziumTestScene natively within OBS limits.")
	
	OBSClient.get_scene_list(Callable(self, "_on_scene_list"))
	time_passed = 0.0
	while not scene_list_received and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01

	assert_true(scene_list_received, "Scene list retrieved properly resolving limits natively")
	var found = false
	for s in scenes_array:
		if s.get("sceneName", "") == "BlaziumTestScene":
			found = true
			break
	assert_true(found, "BlaziumTestScene reliably embedded over WebSocket iterations.")
	
	# Transition gracefully rendering internally
	OBSClient.set_current_program_scene("BlaziumTestScene")
	
	time_passed = 0.0
	while time_passed < 1.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	# Tear down aggressively reverting rendering mappings cleanly
	OBSClient.remove_scene("BlaziumTestScene")
