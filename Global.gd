extends Node

var spacing: float = 3
var players_dict = {} # controller_id: player_id
var map_width: int = 9
var map_height: int = 9
var eventdevice
var validcheck: bool

func identify_input(pressed_event):
	# check if device of event is keyboard or controller
	validcheck = false
	if pressed_event is InputEventMouseMotion or pressed_event is InputEventMouseButton:
		validcheck = false
	elif (pressed_event is InputEventJoypadButton):
		eventdevice = pressed_event.get_device()
		validcheck = true
	elif pressed_event is InputEventJoypadMotion && pressed_event.get_axis() >= 0 && pressed_event.get_axis() <= 3:
		eventdevice = pressed_event.get_device()
		validcheck = true
	elif pressed_event is InputEventJoypadMotion && pressed_event.get_axis() >= 4:
		validcheck = false
	else:
		eventdevice = "keyboard"
		validcheck = true

func setup_camera(cam):
	var grid_size = 30
	var screen_aspect = cam.get_viewport().size.x / cam.get_viewport().size.y
	if screen_aspect >= 1.0:
		cam.size = grid_size / 2.0
	else:
		cam.size = (grid_size / 2.0) / screen_aspect
	cam.transform.origin = Vector3(10,20,15)
	cam.look_at(Vector3(10,0,12.5),Vector3(0,0,-1))
