extends GutTest

var initial_transition = ""
var transitions_received = false
var trans_list = []
var active_transition = ""
var active_duration = 0
var current_received = false

func before_all():
	pass

func after_all():
	OBSClient.disconnect_from_obs()

func _on_trans_list(status, data):
	transitions_received = true
	trans_list = data.get("transitions", [])

func _on_current(status, data):
	current_received = true
	active_transition = data.get("transitionName", "")
	active_duration = data.get("transitionDuration", 0)

func test_009_obs_transitions():
	OBSClient.connect_to_obs("ws://127.0.0.1:4455", "KXH4ey8f9xVVmBkt")
	
	var time_passed = 0.0
	while OBSClient.get_connection_state() != OBSClient.STATE_CONNECTED and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_eq(OBSClient.get_connection_state(), OBSClient.STATE_CONNECTED)
	
	OBSClient.get_scene_transition_list(Callable(self, "_on_trans_list"))
	time_passed = 0.0
	while not transitions_received and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_true(trans_list.size() > 0, "Global transition definitions extracted safely rendering internal structures cleanly.")
	
	OBSClient.set_current_scene_transition("Fade")
	OBSClient.set_current_scene_transition_duration(750)
	
	time_passed = 0.0
	while time_passed < 0.5:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	OBSClient.get_current_scene_transition(Callable(self, "_on_current"))
	time_passed = 0.0
	while not current_received and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_eq(active_transition, "Fade", "Execution correctly locked target transition natively assigning rendering mappings cleanly.")
	assert_eq(active_duration, 750, "Execution explicitly modified precise rendering duration limits strictly aligning metrics successfully.")
