extends Node3D

var pos_x: int
var pos_z: int
var type: int = -1	
var extrablock: bool = false
var rotating: bool = false
var start_angle
var end_angle
var t: float
var rot_duration: float = 0.5

func build_walls():
	if type == -1:
		type = randi() % 3
	if type == 0:
		#suora
		$wall1.position = Vector3(0,0,-1)
		$wall2.position = Vector3(0,0,1)
		$wall3.position = Vector3(0,0,-1)
		$wall1.scale = Vector3(3,1,1)
		$wall2.scale = Vector3(3,1,1)
		$wall3.scale = Vector3(3,1,1)
	if type == 1:
		# mutka
		$wall1.position = Vector3(0,0,-1)
		$wall2.position = Vector3(-1,0,0.5)
		$wall3.position = Vector3(1,0,1)
		$wall1.scale = Vector3(3,1,1)
		$wall2.scale = Vector3(1,1,2)
		$wall3.scale = Vector3(1,1,1)
	if type == 2:
		# risteys
		$wall1.position = Vector3(0,0,-1)
		$wall2.position = Vector3(-1,0,1)
		$wall3.position = Vector3(1,0,1)
		$wall1.scale = Vector3(3,1,1)
		$wall2.scale = Vector3(1,1,1)
		$wall3.scale = Vector3(1,1,1)

func move_left(grid_width, grid_height):
	if $movTimer.time_left == 0:
		print("left?")
		if pos_x == -2:
			pass
		# onko oikealla reunalla
		elif pos_x == grid_width + 1:
			pos_x = -2
		# onko rivin vasemmassa laidassa
		elif pos_x == 0:
			pos_x = -2
			if pos_z == -2:
				pos_z = 0
			else:
				pos_z = grid_height -1
		# muussa tapauksessa
		else:
			pos_x -= 1
		$movTimer.start()
	
func move_right(grid_width, grid_height):
	if $movTimer.time_left == 0:
		if pos_x == grid_width + 1:
			pass
		elif pos_x == -2:
			pos_x = grid_width + 1
		elif pos_x == grid_width - 1:
			pos_x = grid_width + 1
			if pos_z == -2:
				pos_z = 0
			else:
				pos_z = grid_height - 1
		else:
			pos_x += 1
		$movTimer.start()

func move_up(grid_width, grid_height):
	if $movTimer.time_left == 0:
		if pos_z == -2:
			pass
		elif pos_z == grid_height + 1:
			pos_z = -2
		elif pos_z == 0:
			pos_z = -2
			if pos_x == -2:
				pos_x = 0
			else:
				pos_x = grid_width - 1
		else:
			pos_z -= 1	
		$movTimer.start()

func move_down(grid_width, grid_height):
	if $movTimer.time_left == 0:
		if pos_z == grid_height + 1:
			pass
		elif pos_z == -2:
			pos_z = grid_height + 1
		elif pos_z == grid_height - 1:
			pos_z = grid_height + 1
			if pos_x == -2:
				pos_x = 0
			else:
				pos_x = grid_width -1
		else:
			pos_z += 1
		$movTimer.start()

func process_rotate(degrees):
	start_angle = rotation_degrees
	end_angle = start_angle
	end_angle.y += fmod(degrees, 360.0)
	
	var tween = create_tween()
	tween.tween_property(self,"rotation_degrees",end_angle,rot_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	

func rotate_left():
	if $rotTimer.time_left == 0:
		process_rotate(90)
		$rotTimer.start()
		
func rotate_right():
	if $rotTimer.time_left == 0:
		process_rotate(-90)
		$rotTimer.start()
		
func _ready():
	build_walls()
	$rotTimer.wait_time = rot_duration

func _process(delta):
	pass
