extends Node3D

# add script to check when all players in ready zone for scene transition

var palikka = preload("res://palikka.tscn")
var player = preload("res://pelaaja.tscn")
var raja = preload("res://rajapala.tscn")
var players_dict = {} # controller_id: player_id
var spacing: float = 3

var init_area = [
	[0,1,1,0],[0,1,2,0],[2,1,3,0],[0,1,4,0],[0,1,5,0],
	[1,2,1,0],[0,2,2,0],[2,2,3,180],[0,2,4,0],[1,2,5,270],
	[0,3,1,90],[0,3,5,90],
	[2,4,1,90],[2,4,5,-90],
	[0,5,1,90],[0,5,5,90],
	[1,6,1,90],[0,6,2,0],[2,6,3,0],[0,6,4,0],[1,6,5,180],
	[0,7,1,0],[0,7,2,0],[2,7,3,180],[0,7,4,0],[0,7,5,0]
	]
var spawn_area = [
	[0,0],[0,1],[0,2],[0,3],[0,4],[0,5],[0,6],
	[1,0],[1,6],
	[2,0],[2,6],
	[3,0],[3,6],
	[4,0],[4,6],
	[5,0],[5,6],
	[6,0],[6,6],
	[7,0],[7,6],
	[8,0],[8,1],[8,2],[8,3],[8,4],[8,5],[8,6]
	]
var borders = [
	[-1,-1],[-1,0],[-1,1],[-1,2],[-1,3],[-1,4],[-1,5],[-1,6],[-1,7],
	[0,-1],[0,7],
	[1,-1],[1,7],
	[2,-1],[2,7],
	[3,-1],[3,7],
	[4,-1],[4,7],
	[5,-1],[5,7],
	[6,-1],[6,7],
	[7,-1],[7,7],
	[8,-1],[8,7],
	[9,-1],[9,0],[9,1],[9,2],[9,3],[9,4],[9,5],[9,6],[9,7]
	]
	
func create_area():
	for i in init_area.size():
		var obj = palikka.instantiate()
		obj.type = init_area[i][0]
		add_child(obj)
		obj.pos_z = init_area[i][1]
		obj.pos_x = init_area[i][2]
		obj.rotate_y(deg_to_rad(init_area[i][3]))

func create_borders():
	for i in borders.size():
		var obj = raja.instantiate()
		add_child(obj)
		obj.transform.origin = Vector3(borders[i][1] * spacing, 0, borders[i][0] * spacing)

func listen_to_input():
	pass
	
func player_movement(pressed_event, eventdevice):
	var plr = find_player(players_dict[eventdevice])
	if Input.is_action_pressed("moveleft"):
		plr.move_left()
	if Input.is_action_pressed("moveright"):
		plr.move_right()
	if Input.is_action_pressed("moveup"):
		plr.move_up()
	if Input.is_action_pressed("movedown"):
		plr.move_down()

func find_player(pl_no):
	for plr in get_tree().get_nodes_in_group("pelaajat"):
		if plr.playerno == pl_no:
			return plr

func remove_player(key):
	var plr = find_player(players_dict[key])
	players_dict.erase(key)
	plr.queue_free()
	var i: int = 1
	for player in players_dict:
		plr = find_player(players_dict[player])
		plr.playerno = i
		players_dict[player] = i
		i += 1

func create_player(key):
	var plr
	var pos
	var next_player = find_next_player(players_dict)
	players_dict[key] = next_player
	plr = player.instantiate()
	add_child(plr)
	pos = spawn_area[randi() % spawn_area.size()]
	plr.pos_x = pos[1]
	plr.pos_z = pos[0]
	plr.playerno = next_player

func check_player(pressed_event):
	var eventdevice
	var validcheck: bool = false
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
	if players_dict.has(eventdevice):
		if pressed_event.is_action("cancel", true):
			remove_player(eventdevice)
		else:
			player_movement(pressed_event, eventdevice)
	elif validcheck == true && !pressed_event.is_action("cancel", true):
		create_player(eventdevice)
		
func find_next_player(dict):
	var highest = 0
	for player in dict:
		if dict[player] > highest:
			highest = dict[player]
	return highest + 1

func is_in_transit_area(key):
	var plr = find_player(players_dict[key])
	if plr.pos_x >= 2 && plr.pos_x <= 4 && plr.pos_z >= 2 && plr.pos_z <= 4:
		return true
	else:
		return false

func check_player_positions():
	var readyplrs: int = 0
	for plr in get_tree().get_nodes_in_group("pelaajat"):
		if plr.pos_x >= 2 && plr.pos_x <= 4 && plr.pos_z >= 3 && plr.pos_z <= 5:
			readyplrs += 1
	print(readyplrs)
	
func update_blocks(d):
	var xdist: float
	var zdist: float
	var objs: Array
	objs.append_array(get_tree().get_nodes_in_group("palikat"))
	objs.append_array(get_tree().get_nodes_in_group("pelaajat"))
	objs.append_array(get_tree().get_nodes_in_group("aarteet"))
	for obj in objs:
		xdist = abs((obj.pos_x * spacing) - obj.global_position.x)
		zdist = abs((obj.pos_z * spacing) - obj.global_position.x)
		if xdist < 0.2:
			obj.global_position.x = obj.pos_x * spacing
		else:
			obj.global_position.x += 8 * d * (obj.pos_x * spacing - obj.global_position.x)
		if zdist < 0.2:
			obj.global_position.z = obj.pos_z * spacing
		else:
			obj.global_position.z += 8 * d * (obj.pos_z * spacing - obj.global_position.z)

func _input(event):
	check_player(event)

func _ready():
	# create level
	create_area()
	create_borders()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_blocks(delta)
	if players_dict.size() > 0:
		check_player_positions()
