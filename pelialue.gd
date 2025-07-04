extends Node3D

var palikka = preload("res://palikka.tscn")
var player = preload("res://pelaaja.tscn")
var raja = preload("res://rajapala.tscn")
var treasure = preload("res://aarre.tscn")

@export var camspeed: float = 10.0
var grid_width: int = Global.map_width
var grid_height: int = Global.map_height
var no_of_players: int
var phase
var player_turn: int = 1
var turn_plr
var match_ongoing: bool
var MAX_SCORE: int = 5
var CAM_MIN_X: int
var CAM_MIN_Z: int
var cam_vis_width: float
var cam_vis_height: float
var obj_pos
var cam_x_mod: float
var cam_z_mod: float
var cam_new_pos: Vector3
	
func random_rotation_90_degrees() -> int:
	var rotations = [0,90,180,270]
	return rotations[randi() % 4]  # Pick a random rotation

func create_grid():
	for x in range(grid_width):
		for z in range(grid_height):
			var obj = palikka.instantiate()
			add_child(obj)
			obj.pos_x = x
			obj.pos_z = z
			#obj.transform.origin = Vector3(x * Global.spacing, 0, z * Global.spacing)
			obj.rotate_y(deg_to_rad(random_rotation_90_degrees()))

func create_borders():
	for x in range(grid_width):
		var obj = raja.instantiate()
		add_child(obj)
		obj.transform.origin = Vector3(x * Global.spacing, 0, grid_height * Global.spacing + 1)
	for x in range(grid_width):
		var obj = raja.instantiate()
		add_child(obj)
		obj.transform.origin = Vector3(x * Global.spacing, 0, -1 * Global.spacing)
	for x in range(grid_height):
		var obj = raja.instantiate()
		add_child(obj)
		obj.transform.origin = Vector3(-1 * Global.spacing, 0, x * Global.spacing)
	for x in range(grid_height):
		var obj = raja.instantiate()
		add_child(obj)
		obj.transform.origin = Vector3(grid_width * Global.spacing + 1, 0, x * Global.spacing)

func create_spare():
	var spare_obj = palikka.instantiate()
	add_child(spare_obj)
	spare_obj.pos_x = 0
	spare_obj.pos_z = -2
	spare_obj.extrablock = true

func add_players(players_n):
	var plr
	for i in players_n:
		plr = player.instantiate()
		add_child(plr)
		plr.name = "player" + str(i + 1)
		plr.pos_x = randi() % grid_width
		plr.pos_z = randi() % grid_height
		plr.playerno = i + 1
		instantiate_treasure(plr.pos_x, plr.pos_z, plr.playerno)

func instantiate_treasure(not_x, not_z, plr_no):
	var trs = treasure.instantiate()
	add_child(trs)
	trs.assigned_plr = plr_no
	trs.pos_x = randi() % grid_width
	trs.pos_z = randi() % grid_height
	while trs.pos_x == not_x && trs.pos_z == not_z:
		trs.pos_x = randi() % grid_width
		trs.pos_z = randi() % grid_height
	for blk in get_tree().get_nodes_in_group("palikat"):
		if blk.pos_x == trs.pos_x && blk.pos_z == trs.pos_z:
			trs.attach_treasure(blk)

func update_blocks(d):
	var xdist: float
	var zdist: float
	var objs: Array
	objs.append_array(get_tree().get_nodes_in_group("palikat"))
	objs.append_array(get_tree().get_nodes_in_group("pelaajat"))
	objs.append_array(get_tree().get_nodes_in_group("aarteet"))
	for obj in objs:
		xdist = abs((obj.pos_x * Global.spacing) - obj.global_position.x)
		zdist = abs((obj.pos_z * Global.spacing) - obj.global_position.x)
		if xdist < 0.2:
			obj.global_position.x = obj.pos_x * Global.spacing
		else:
			obj.global_position.x += 8 * d * (obj.pos_x * Global.spacing - obj.global_position.x)
		if zdist < 0.2:
			obj.global_position.z = obj.pos_z * Global.spacing
		else:
			obj.global_position.z += 8 * d * (obj.pos_z * Global.spacing - obj.global_position.z)
	
func camera_movement(d):
	if phase == "spare_movement":
		obj_pos = find_spare().global_transform.origin
	elif phase == "player_movement":
		obj_pos = find_player(player_turn).global_transform.origin
	var clamped_x = clamp(obj_pos.x, 1, grid_width * Global.spacing - 5)
	var clamped_z = clamp(obj_pos.z, 1, grid_height * Global.spacing - 5)
	if Input.is_action_pressed("camleft"):
		cam_x_mod -= camspeed * d
	if Input.is_action_pressed("camright"):
		cam_x_mod += camspeed * d
	if Input.is_action_pressed("camup"):
		cam_z_mod -= camspeed * d
	if Input.is_action_pressed("camdown"):
		cam_z_mod += camspeed * d
	if Input.is_action_just_released("camleft") || Input.is_action_just_released("camright"):
		cam_x_mod = 0
	if Input.is_action_just_released("camup") || Input.is_action_just_released("camdown"):
		cam_z_mod = 0
	cam_new_pos = Vector3(clamped_x + cam_x_mod, $Camera3D.transform.origin.y, clamped_z + cam_z_mod)
	$Camera3D.transform.origin = $Camera3D.transform.origin.lerp(cam_new_pos, 0.1)

func find_spare():
	for blok in get_tree().get_nodes_in_group("palikat"):
		if blok.extrablock:
			return blok

func find_player(pl_no):
	for plr in get_tree().get_nodes_in_group("pelaajat"):
		if plr.playerno == pl_no:
			return plr

func spare_position(blok):
	if blok.pos_x < 0:
		return "left"
	elif blok.pos_x > grid_width:
		return "right"
	elif blok.pos_z < 0:
		return "up"
	elif blok.pos_z > grid_height:
		return "down"

func spare_movement(delta):
	var spare_block
	spare_block = find_spare()
#	if $cooldown_timer.time_left == 0:
	if Input.is_action_pressed("moveleft"):
		spare_block.move_left(grid_width, grid_height)
	elif Input.is_action_pressed("moveright"):
		spare_block.move_right(grid_width, grid_height)
	elif Input.is_action_pressed("moveup"):
		spare_block.move_up(grid_width, grid_height)
	elif Input.is_action_pressed("movedown"):
		spare_block.move_down(grid_width, grid_height)
	elif Input.is_action_pressed("rotate_left"):
		spare_block.rotate_left()
	elif Input.is_action_pressed("rotate_right"):
		spare_block.rotate_right()
	elif Input.is_action_pressed("action"):
		if $cooldown_timer.time_left == 0:
			spare_action(spare_block)
			$cooldown_timer.start()

func spare_action(spare_block):
	var spare_pos = spare_position(spare_block)
	var spare_coord: int
	if spare_pos == "left" || spare_pos == "right":
		spare_coord = spare_block.pos_z
	elif spare_pos == "up"  || spare_pos == "down":
		spare_coord = spare_block.pos_x
	spare_block.extrablock = false
	switch_block(spare_block, spare_pos, spare_coord, 2)
	for blok in get_tree().get_nodes_in_group("palikat"):
		if blok != spare_block:
			switch_block(blok, spare_pos, spare_coord, 1)
	for plr in get_tree().get_nodes_in_group("pelaajat"):
		switch_block(plr, spare_pos, spare_coord, 1)
	phase_control()

func switch_block(blok, direction, coord, multiplier):
	if direction == "left" && blok.pos_z == coord:
		blok.pos_x += 1 * multiplier
		if blok.pos_x == grid_width:
			if blok.is_in_group("palikat"):
				blok.pos_x += 1
				blok.extrablock = true
			if blok.is_in_group("pelaajat"):
				blok.pos_x = 0
	if direction == "right" && blok.pos_z == coord:
		blok.pos_x -= 1 * multiplier
		if blok.pos_x == -1:
			if blok.is_in_group("palikat"):
				blok.pos_x -= 1
				blok.extrablock = true
			if blok.is_in_group("pelaajat"):
				blok.pos_x = grid_width - 1
	if direction == "up" && blok.pos_x == coord:
		blok.pos_z += 1 * multiplier
		if blok.pos_z == grid_height:
			if blok.is_in_group("palikat"):
				blok.pos_z += 1
				blok.extrablock = true
			if blok.is_in_group("pelaajat"):
				blok.pos_z = 0
	if direction == "down" && blok.pos_x == coord:
		blok.pos_z -= 1 * multiplier
		if blok.pos_z == -1:
			if blok.is_in_group("palikat"):
				blok.pos_z -= 1
				blok.extrablock = true
			if blok.is_in_group("pelaajat"):
				blok.pos_z = grid_height - 1

func player_movement():
	if Input.is_action_pressed("moveleft"):
		turn_plr.move_left()
	if Input.is_action_pressed("moveright"):
		turn_plr.move_right()
	if Input.is_action_pressed("moveup"):
		turn_plr.move_up()
	if Input.is_action_pressed("movedown"):
		turn_plr.move_down()
	if (check_treasure(turn_plr.pos_x, turn_plr.pos_z, turn_plr.playerno)):
		turn_plr.score += 1
		phase_control()
	
func check_treasure(x, z, plr_no):
	var checkresult: bool = false
	for obj in get_tree().get_nodes_in_group("aarteet"):
		if obj.pos_x == x && obj.pos_z == z && obj.assigned_plr == plr_no:
			obj.queue_free()
			instantiate_treasure(obj.pos_x, obj.pos_z, obj.assigned_plr)
			checkresult = true
	return checkresult

func check_scores():
	for plr in get_tree().get_nodes_in_group("pelaajat"):
		if plr.score == MAX_SCORE:
			match_ongoing = false
			

func player_action():
	if Input.is_action_pressed("action") && $cooldown_timer.time_left == 0:
		phase_control()
		$cooldown_timer.start()

func phase_control():
	if phase == "player_movement":
		if player_turn == no_of_players:
			player_turn = 1
		else:
			player_turn += 1
		phase = "spare_movement"
	elif phase == "spare_movement":
		turn_plr = find_player(player_turn)
		phase = "player_movement"
	
func _ready():
	if Global.players_dict.size() >= 1:
		pass
	else:
		Global.players_dict["keyboard"] = 1
	no_of_players = Global.players_dict.size()
	create_grid()
	create_spare()
	add_players(Global.players_dict.size())
	create_borders()
	match_ongoing = true
	phase = "spare_movement"
	turn_plr = find_player(player_turn)
	Global.setup_camera($Camera3D)

func _input(event):
	Global.identify_input(event)
	
func _process(delta):
	update_blocks(delta)
	if match_ongoing == true:
		if Global.eventdevice != null:
			# if inputdevice is same as player number then process
			if Global.players_dict[Global.eventdevice] == player_turn:
				#camera_movement(delta)
				if phase == "spare_movement":
					spare_movement(delta)
				if phase == "player_movement":
					player_movement()
					player_action()
	camera_movement(delta)
	
# to-do:
# https://trello.com/b/ZQvWv9RW/pelilabyrintti
