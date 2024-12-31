extends Node3D

var pos_x: int
var pos_z: int
var type: int = -1	
var extrablock: bool = false

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
	print(type)

func move_left(grid_width, grid_height):
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
	
func move_right(grid_width, grid_height):
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

func move_up(grid_width, grid_height):
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

func move_down(grid_width, grid_height):
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

func rotate_left():
	self.rotate_y(deg_to_rad(90))

func rotate_right():
	self.rotate_y(deg_to_rad(-90))
	
func _ready():
	build_walls()

func _process(delta):
	pass
