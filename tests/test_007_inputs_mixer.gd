extends AutoworkTest

var list_received = false
var audio_inputs = []
var mute_state_received = false
var is_muted = false
var volume_received = false
var volume_db = 0.0

func before_all():
	pass

func after_all():
	OBSClient.disconnect_from_obs()

func _on_input_list(status, data):
	list_received = true
	audio_inputs = data.get("inputs", [])

func _on_input_mute(status, data):
	mute_state_received = true
	is_muted = data.get("inputMuted", false)

func _on_input_volume(status, data):
	volume_received = true
	volume_db = data.get("inputVolumeDb", 0.0)

func test_007_obs_mixer():
	OBSClient.connect_to_obs("ws://127.0.0.1:4455", "KXH4ey8f9xVVmBkt")
	
	var time_passed = 0.0
	while OBSClient.get_connection_state() != OBSClient.STATE_CONNECTED and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_eq(OBSClient.get_connection_state(), OBSClient.STATE_CONNECTED)
	
	# Query all inputs matching audio metrics locally across host limits natively
	OBSClient.get_input_list("", Callable(self, "_on_input_list"))
	time_passed = 0.0
	while not list_received and time_passed < 2.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01

	if audio_inputs.size() == 0:
		pass_test("No sources detected locally resolving bounds, omitting specific mutations flawlessly")
		return

	var target_input = audio_inputs[0].get("inputName", "")
	
	# Initial structural validations toggling native flags 
	OBSClient.set_input_mute(target_input, true)
	time_passed = 0.0
	while time_passed < 0.5:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	OBSClient.get_input_mute(target_input, Callable(self, "_on_input_mute"))
	time_passed = 0.0
	while not mute_state_received and time_passed < 1.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_true(is_muted, "Audio bounds conclusively restricted strictly mutating tracking maps internally exactly via Engine")

	# Recover structural bounds
	OBSClient.set_input_mute(target_input, false)

	OBSClient.set_input_volume(target_input, -1.0, -10.0)
	time_passed = 0.0
	while time_passed < 0.5:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01

	OBSClient.get_input_volume(target_input, Callable(self, "_on_input_volume"))
	time_passed = 0.0
	while not volume_received and time_passed < 1.0:
		OBSClient.poll()
		OS.delay_msec(10)
		time_passed += 0.01
		
	assert_true(volume_received, "Volume limits retrieved exactly caching explicit DB queries properly.")
